"""
🅿️ LECTEUR ANPR - Ton PC (fluide)
Reçoit l'ordre du Raspberry, lit la plaque, renvoie le texte
"""

import cv2
import numpy as np
from pathlib import Path
import socket
import easyocr
import torch
import torch.nn as nn
from torchvision import transforms

PORT = 5000

# ============================================================
# MODÈLE CNN
# ============================================================

class LettresCNN_V3(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 32, 3, padding=1), nn.ReLU(), nn.BatchNorm2d(32), nn.MaxPool2d(2),
            nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(), nn.BatchNorm2d(64), nn.MaxPool2d(2),
            nn.Conv2d(64, 128, 3, padding=1), nn.ReLU(), nn.BatchNorm2d(128), nn.MaxPool2d(2),
            nn.Conv2d(128, 256, 3, padding=1), nn.ReLU(), nn.BatchNorm2d(256), nn.MaxPool2d(2),
        )
        self.classifier = nn.Sequential(
            nn.Flatten(), nn.Linear(256 * 4 * 4, 512), nn.ReLU(), nn.Dropout(0.5),
            nn.Linear(512, num_classes)
        )
    def forward(self, x): return self.classifier(self.features(x))


class PlateDetector:
    def __init__(self, weights_path, cfg_path, classes_path):
        self.net = cv2.dnn.readNet(str(weights_path), str(cfg_path))
        with open(str(classes_path), "r") as f: self.classes = [line.strip() for line in f.readlines()]
        layer_names = self.net.getLayerNames()
        self.output_layers = [layer_names[i - 1] for i in self.net.getUnconnectedOutLayers()]
    
    def detecter_avec_boite(self, image, threshold=0.5):
        """Détecte et retourne (plaque_decoupee, boite, confiance)"""
        height, width = image.shape[:2]
        blob = cv2.dnn.blobFromImage(image, 0.00392, (320, 320), (0, 0, 0), True, False)
        self.net.setInput(blob)
        outputs = self.net.forward(self.output_layers)
        boxes, confidences = [], []
        for output in outputs:
            for detection in output:
                scores = detection[5:]
                if np.argmax(scores) == 0 and scores[0] > threshold:
                    center_x = int(detection[0] * width); center_y = int(detection[1] * height)
                    w = int(detection[2] * width); h = int(detection[3] * height)
                    boxes.append([int(center_x - w/2), int(center_y - h/2), w, h])
                    confidences.append(float(scores[0]))
        if not boxes: return None, None, 0
        indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)
        if len(indexes) == 0: return None, None, 0
        i = indexes.flatten()[0]; x, y, w, h = boxes[i]
        mx, my = int(w*0.2), int(h*0.4)
        plaque = image[max(0,y-my):min(height,y+h+my), max(0,x-mx):min(width,x+w+mx)]
        return plaque, (x, y, w, h), confidences[i]


class LecteurANPR:
    CNN_TO_ARABE = {'alif': 'أ', 'ba': 'ب', 'dal': 'د', 'ha': 'ه', 'waw': 'و', 'shin': 'ش'}
    
    def __init__(self, cnn_path):
        self.device = torch.device("cpu")
        self.easy_reader = easyocr.Reader(['en'], gpu=False)
        checkpoint = torch.load(cnn_path, map_location=self.device)
        self.classes_cnn = checkpoint['classes']
        self.cnn = LettresCNN_V3(checkpoint['num_classes']).to(self.device)
        self.cnn.load_state_dict(checkpoint['model']); self.cnn.eval()
        self.transform = transforms.Compose([
            transforms.ToPILImage(), transforms.Resize((64, 64)),
            transforms.ToTensor(), transforms.Normalize([0.5], [0.5])
        ])
    
    def lire(self, plaque):
        if plaque is None or plaque.size == 0: return None
        plaque_rgb = cv2.cvtColor(plaque, cv2.COLOR_BGR2RGB)
        results = self.easy_reader.readtext(plaque_rgb, allowlist='0123456789', paragraph=False, min_size=8)
        chiffres = []
        for bbox, texte, conf in results:
            ch = ''.join([c for c in texte if c.isdigit()])
            if ch: chiffres.append((ch, (bbox[0][0]+bbox[2][0])/2))
        if len(chiffres) < 2: return None
        chiffres_tries = sorted(chiffres, key=lambda c: c[1])
        if len(chiffres_tries[0][0]) >= len(chiffres_tries[-1][0]):
            gauche, droite = chiffres_tries[0], chiffres_tries[-1]
        else: gauche, droite = chiffres_tries[-1], chiffres_tries[0]
        x1 = max(0, int(gauche[1]) + 15); x2 = min(plaque.shape[1], int(droite[1]) - 15)
        if x2 <= x1: x1, x2 = int(plaque.shape[1]*0.35), int(plaque.shape[1]*0.65)
        zone = plaque[:, x1:x2]
        try:
            gris = cv2.cvtColor(zone, cv2.COLOR_BGR2GRAY)
            tenseur = self.transform(gris).unsqueeze(0).to(self.device)
            with torch.no_grad():
                probas = torch.softmax(self.cnn(tenseur), dim=1)
                conf, pred = torch.max(probas, 1)
                lettre = self.CNN_TO_ARABE.get(self.classes_cnn[pred.item()], '?')
        except: lettre = '?'
        if lettre != '?': return f"{gauche[0]}{lettre}{droite[0]}"
        return f"{gauche[0]}{droite[0]}"


# ============================================================
# SERVEUR OPTIMISÉ
# ============================================================

def main():
    print("=" * 50)
    print("  📸 LECTEUR ANPR - En attente du Raspberry Pi")
    print("=" * 50)
    
    DOSSIER_BASE = Path(__file__).parent
    DOSSIER_WEIGHTS = DOSSIER_BASE / "weights"
    CNN_PATH = DOSSIER_BASE / "modele_lettres_reel.pth"
    
    print("⏳ Chargement...")
    detecteur = PlateDetector(
        DOSSIER_WEIGHTS / "yolov3-detection_final.weights",
        DOSSIER_WEIGHTS / "yolov3-detection.cfg",
        DOSSIER_BASE / "classes-detection.names"
    )
    lecteur = LecteurANPR(CNN_PATH)
    
    print("📷 Webcam...")
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 480)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 360)
    
    serveur = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serveur.bind(('0.0.0.0', PORT))
    serveur.listen(1)
    print(f"✅ En écoute sur le port {PORT}...")
    print("   Q = Quitter\n")
    
    derniere_boite = None
    compteur_frame = 0
    
    while True:
        ret, frame = cap.read()
        if not ret: break
        
        affiche = frame.copy()
        compteur_frame += 1
        
        # Détection toutes les 3 frames seulement (fluidité)
        if compteur_frame % 3 == 0:
            plaque_img, boite, conf = detecteur.detecter_avec_boite(frame)
            if boite is not None:
                derniere_boite = boite
        
        # Dessiner la dernière boîte connue
        if derniere_boite is not None:
            x, y, w, h = derniere_boite
            cv2.rectangle(affiche, (x, y), (x+w, y+h), (0, 255, 0), 2)
        
        cv2.putText(affiche, "En attente... (Q=Quitter)", (10, 25),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.imshow("Camera ANPR", affiche)
        
        # Vérifier si le Raspberry appelle (non-bloquant)
        serveur.settimeout(0.05)
        try:
            client, adresse = serveur.accept()
            message = client.recv(1024).decode()
            print(f"\n📩 Ordre : {message}")
            
            if message == "LIRE_PLAQUE":
                print("📸 Lecture...")
                for _ in range(3): cap.read()
                ret, frame = cap.read()
                
                if ret:
                    plaque_img, boite, conf = detecteur.detecter_avec_boite(frame)
                    if plaque_img is not None:
                        texte = lecteur.lire(plaque_img)
                        if texte:
                            reponse = f"PLAQUE:{texte}"
                            print(f"   ✅ {reponse}")
                        else:
                            reponse = "ERREUR:LECTURE"
                            print("   ❌ Lecture échouée")
                    else:
                        reponse = "ERREUR:PAS_PLAQUE"
                        print("   ❌ Pas de plaque")
                else:
                    reponse = "ERREUR:CAMERA"
                
                client.send(reponse.encode())
            client.close()
        except socket.timeout:
            pass
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    print("✅ Fin.")


if __name__ == "__main__":
    main()
