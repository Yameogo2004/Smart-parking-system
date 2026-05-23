"""
PARKING INTELLIGENT - Raspberry Pi (MAÎTRE)
"""

import time
import smbus2
import socket
import requests

BUS = smbus2.SMBus(1)
UNO_ADDR = 0x08
NANO_ADDR = 0x09

PC_ANPR_IP        = "192.168.76.22"
PC_ANPR_PORT      = 5000
FLASK_API         = "http://localhost:5000"
ESP32_ENTREE_IP   = "192.168.76.88"
ESP32_SORTIE_IP   = "192.168.76.144"

compteur_voiture   = 0
dernier_ir1        = 1
dernier_ir2        = 1
dernier_ir_pin     = 1
barriere_ouverte   = False
etage_cible        = 0
derniere_plaque    = ""
voitures_par_etage = {0: None, 1: None, 2: None}

# Variables pour l'ascenseur de sortie
ascenseur_sortie_etage_actuel = 0  # 0 = étage 0, 1 = étage 1
ascenseur_sortie_en_mouvement = False

CAPTEURS_SURVEILLES = {
    "IR1":   (1, 0, "Capteur IR entrée barrière"),
    "IR2":   (2, 0, "Capteur IR ascenseur entrée"),
    "POIDS": (6, 0, "Capteur de poids"),
}

etat_capteurs    = {nom: True for nom in CAPTEURS_SURVEILLES}
SEUIL_ERREUR     = 3
compteur_erreurs = {nom: 0 for nom in CAPTEURS_SURVEILLES}

def envoyer_commande(adresse, commande, retries=3):
    """Envoie une commande I2C avec réessais"""
    for attempt in range(retries):
        try:
            data = [ord(c) for c in commande]
            BUS.write_i2c_block_data(adresse, 0, data)
            print(f"[I2C] ✅ Envoyé à {hex(adresse)} : {commande}")
            return True
        except Exception as e:
            print(f"[I2C] ⚠️ Tentative {attempt+1}/{retries} échouée : {e}")
            time.sleep(0.3)
    print(f"[I2C] ❌ Échec après {retries} tentatives")
    return False

def lire_uno():
    try:
        data = BUS.read_i2c_block_data(UNO_ADDR, 0, 32)
        texte = ''.join(chr(x) for x in data if x != 0).strip()
        return texte, True
    except Exception as e:
        print(f"[ERREUR I2C] Lecture Uno : {e}")
        return "", False

def parser_donnees(texte):
    donnees = {}
    try:
        parties = texte.strip().split(";")
        if len(parties) >= 1 and len(parties[0]) >= 4:
            donnees["IR1"]  = parties[0][0]
            donnees["IR2"]  = parties[0][1]
            donnees["IR3"]  = parties[0][2]
            donnees["IR4"]  = parties[0][3]
        if len(parties) >= 2: donnees["POIDS"] = parties[1]
        if len(parties) >= 3: donnees["DIST"]  = parties[2]
        if len(parties) >= 4: donnees["L1"]    = parties[3]
        if len(parties) >= 5: donnees["L2"]    = parties[4]
    except Exception as e:
        print(f"[ERREUR] Parser : {e}")
    return donnees

def calculer_etage(numero_voiture):
    return (numero_voiture - 1) % 3

def ouvrir_barriere_entree(plaque):
    try:
        requests.post(
            f"http://{ESP32_ENTREE_IP}/commande",
            data=f"BAR:OPEN:{plaque}",
            headers={"Content-Type": "text/plain"},
            timeout=5
        )
        print(f"[ESP32 ENTREE] ✅ BAR:OPEN:{plaque}")
    except Exception as e:
        print(f"[ERREUR ESP32 ENTREE] {e}")

def fermer_barriere_entree():
    try:
        requests.post(
            f"http://{ESP32_ENTREE_IP}/commande",
            data="BAR:CLOSE",
            headers={"Content-Type": "text/plain"},
            timeout=5
        )
        print("[ESP32 ENTREE] ✅ BAR:CLOSE")
    except Exception as e:
        print(f"[ERREUR ESP32 ENTREE] {e}")

def lire_capteurs_esp32():
    try:
        response = requests.get(f"http://{ESP32_SORTIE_IP}/capteurs", timeout=3)
        data = response.json()
        return {
            "IR_PIN": int(data.get("IR_SORTIE", 1)),
            "IR5":    int(data.get("IR5", 1))
        }
    except:
        return {"IR_PIN": 1, "IR5": 1}

def creer_alerte_capteur(nom_capteur, capteur_id, etage, description, niveau="Warning"):
    try:
        message = f"Le capteur {description} (Étage {etage}) ne répond plus."
        response = requests.post(
            f"{FLASK_API}/api/alerte/capteur",
            json={
                "capteur_id":  capteur_id,
                "capteur_nom": nom_capteur,
                "etage":       etage,
                "message":     message,
                "niveau":      niveau,
            },
            timeout=5
        )
        if response.json().get("success"):
            print(f"   🔔 ALERTE : {nom_capteur} → Étage {etage}")
    except Exception as e:
        print(f"   [ERREUR ALERTE] {e}")

def resoudre_alerte_capteur(nom_capteur, capteur_id):
    try:
        requests.post(
            f"{FLASK_API}/api/alerte/capteur/resoudre",
            json={"capteur_id": capteur_id, "capteur_nom": nom_capteur},
            timeout=5
        )
        print(f"   ✅ Alerte résolue : {nom_capteur}")
    except Exception as e:
        print(f"   [ERREUR RÉSOLUTION] {e}")

def mettre_a_jour_statut_capteur_db(capteur_id, statut):
    try:
        requests.post(
            f"{FLASK_API}/api/capteur/statut",
            json={"capteur_id": capteur_id, "statut": statut},
            timeout=5
        )
    except Exception as e:
        print(f"   [ERREUR STATUT] {e}")

def verifier_capteur(nom, valeur_lue, lecture_ok):
    global etat_capteurs, compteur_erreurs
    est_ok = lecture_ok and valeur_lue is not None
    config = CAPTEURS_SURVEILLES.get(nom)
    if not config:
        return
    capteur_id, etage, description = config
    if est_ok:
        compteur_erreurs[nom] = 0
        if not etat_capteurs[nom]:
            etat_capteurs[nom] = True
            mettre_a_jour_statut_capteur_db(capteur_id, "online")
            resoudre_alerte_capteur(nom, capteur_id)
            print(f"   ✅ {nom} de nouveau online")
    else:
        compteur_erreurs[nom] += 1
        if compteur_erreurs[nom] >= SEUIL_ERREUR and etat_capteurs[nom]:
            etat_capteurs[nom] = False
            mettre_a_jour_statut_capteur_db(capteur_id, "offline")
            creer_alerte_capteur(nom, capteur_id, etage, description)
            print(f"\n🔴 CAPTEUR OFFLINE : {nom} — Étage {etage}")

def demander_plaque_au_pc():
    global derniere_plaque
    print(f"\n📸 Appel PC ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT})...")
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(10)
        s.connect((PC_ANPR_IP, PC_ANPR_PORT))
        s.send("LIRE_PLAQUE".encode())
        reponse = s.recv(1024).decode()
        s.close()
        print(f"   Réponse PC : {reponse}")
        if reponse.startswith("PLAQUE:"):
            plaque = reponse.split(":")[1].strip()
            derniere_plaque = plaque
            print(f"   ✅ Plaque détectée : {plaque}")
            return plaque, "OK", True
        elif reponse.startswith("ERREUR"):
            print(f"   ❌ PC ANPR : {reponse}")
    except socket.timeout:
        print("   ❌ Timeout")
    except ConnectionRefusedError:
        print("   ❌ Connexion refusée")
    except Exception as e:
        print(f"   ❌ Erreur : {e}")
    return None, None, False

def verifier_plaque_flask(plaque, poids=0):
    try:
        response = requests.post(
            f"{FLASK_API}/api/plaque",
            json={"plaque": plaque, "poids": poids},
            timeout=5
        )
        data = response.json()
        action = data.get("action", "REFUS")
        print(f"   [FLASK] Plaque {plaque} → {action}")
        return action == "OUVRIR"
    except Exception as e:
        print(f"   [ERREUR FLASK] {e}")
        return True

def enregistrer_entree_db(plaque, poids, etage):
    try:
        response = requests.post(
            f"{FLASK_API}/api/entree",
            json={"matricule": plaque, "poids": poids, "etage": etage},
            timeout=5
        )
        data = response.json()
        if data.get("success"):
            print(f"   [DB] Entrée → Place {data.get('place')} Étage {etage}")
        else:
            print(f"   [DB] Erreur : {data.get('error')}")
    except Exception as e:
        print(f"   [ERREUR DB] {e}")

def enregistrer_sortie_db(plaque):
    try:
        response = requests.post(
            f"{FLASK_API}/api/sortie",
            json={"matricule": plaque},
            timeout=5
        )
        data = response.json()
        if data.get("success"):
            print(f"   [DB] Sortie enregistrée pour {plaque}")
        else:
            print(f"   [DB] Erreur sortie : {data.get('error')}")
    except Exception as e:
        print(f"   [ERREUR DB SORTIE] {e}")

def monter_ascenseur_sortie():
    """Monte l'ascenseur de sortie à l'étage 1"""
    global ascenseur_sortie_etage_actuel, ascenseur_sortie_en_mouvement
    
    if ascenseur_sortie_en_mouvement:
        print("[ASCENSEUR SORTIE] Déjà en mouvement, ignore")
        return False
    
    if ascenseur_sortie_etage_actuel == 1:
        print("[ASCENSEUR SORTIE] Déjà à l'étage 1")
        return True
    
    print("\n" + "=" * 60)
    print("  🚗 VÉHICULE DÉTECTÉ À LA SORTIE (IR_PIN)")
    print("  📞 Montée ascenseur sortie vers ÉTAGE 1")
    print("=" * 60)
    
    ascenseur_sortie_en_mouvement = True
    
    if envoyer_commande(NANO_ADDR, "A2:1"):
        print("🛗 Ascenseur sortie monte vers ÉTAGE 1...")
        print("⏳ Attente 15 secondes pour la montée...")
        time.sleep(15)
        ascenseur_sortie_etage_actuel = 1
        print("✅ Ascenseur arrivé à l'étage 1")
    else:
        print("❌ Échec de l'envoi de la commande")
    
    ascenseur_sortie_en_mouvement = False
    print("=" * 60 + "\n")
    return True

def descendre_ascenseur_sortie():
    """Descend l'ascenseur de sortie à l'étage 0"""
    global ascenseur_sortie_etage_actuel, ascenseur_sortie_en_mouvement
    
    if ascenseur_sortie_en_mouvement:
        print("[ASCENSEUR SORTIE] Déjà en mouvement, ignore")
        return False
    
    if ascenseur_sortie_etage_actuel == 0:
        print("[ASCENSEUR SORTIE] Déjà à l'étage 0")
        return True
    
    print("\n" + "=" * 60)
    print("  🚗 VOITURE DANS L'ASCENSEUR SORTIE")
    print("  📞 Descente ascenseur sortie vers ÉTAGE 0")
    print("=" * 60)
    
    ascenseur_sortie_en_mouvement = True
    
    if envoyer_commande(NANO_ADDR, "A2:0"):
        print("🛗 Ascenseur sortie descend vers ÉTAGE 0...")
        print("⏳ Attente 15 secondes pour la descente...")
        time.sleep(15)
        ascenseur_sortie_etage_actuel = 0
        print("✅ Ascenseur arrivé à l'étage 0")
    else:
        print("❌ Échec de l'envoi de la commande")
    
    ascenseur_sortie_en_mouvement = False
    print("=" * 60 + "\n")
    return True

# ============================================================
print("=" * 60)
print("  🅿️  SYSTEME PARKING INTELLIGENT - RASPBERRY PI")
print("=" * 60)
print(f"  Arduino Uno  (I2C {hex(UNO_ADDR)}) : IR1/IR2/POIDS")
print(f"  Arduino Nano (I2C {hex(NANO_ADDR)}) : Ascenseurs")
print(f"  ESP32 Entrée ({ESP32_ENTREE_IP})  : LCD + Servo")
print(f"  ESP32 Sortie ({ESP32_SORTIE_IP})  : IR_PIN (sortie)")
print(f"  ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT})")
print(f"  Flask : {FLASK_API}")
print("-" * 60)

# Initialisation des ascenseurs
print("🛗 Initialisation des ascenseurs...")
envoyer_commande(NANO_ADDR, "A1:0")
time.sleep(0.5)
envoyer_commande(NANO_ADDR, "A2:0")
time.sleep(1)

print("\n✅ Système prêt !\n")
print("=" * 60)

# ============================================================
# BOUCLE PRINCIPALE
# ============================================================
while True:
    texte, i2c_ok = lire_uno()
    if texte:
        print("UNO ->", texte)

    donnees = parser_donnees(texte)
    esp32_data = lire_capteurs_esp32()
    ir_pin = esp32_data["IR_PIN"]

    try:
        ir1   = int(donnees.get("IR1",   "1"))
        ir2   = int(donnees.get("IR2",   "1"))
        poids = float(donnees.get("POIDS","0"))
    except:
        ir1 = ir2 = 1
        poids = 0

    verifier_capteur("IR1",   donnees.get("IR1"),   i2c_ok)
    verifier_capteur("IR2",   donnees.get("IR2"),   i2c_ok)
    verifier_capteur("POIDS", donnees.get("POIDS"), i2c_ok)

    # ── ENTRÉE : IR1 détecte voiture ─────────────────────────
    if ir1 == 0 and dernier_ir1 == 1:
        compteur_voiture += 1
        print("\n" + "=" * 60)
        print(f"  🚗 VÉHICULE DÉTECTÉ À L'ENTRÉE")
        print(f"  Numéro : {compteur_voiture} | Poids : {poids} kg")
        print("=" * 60)

        plaque, statut, lu = demander_plaque_au_pc()

        if not lu or not plaque:
            print("\n⚠️  Plaque non lue - Accès refusé")
            dernier_ir1 = ir1
            continue

        autorise = verifier_plaque_flask(plaque, poids)

        if not autorise:
            print("\n⛔ ACCÈS REFUSÉ")
            dernier_ir1 = ir1
            continue

        etage_cible = calculer_etage(compteur_voiture)
        voitures_par_etage[etage_cible] = plaque

        print(f"\n🟢 ACCÈS AUTORISÉ — {plaque} → Étage {etage_cible}")
        envoyer_commande(NANO_ADDR, "A1:0")
        time.sleep(1)
        ouvrir_barriere_entree(plaque)
        barriere_ouverte = True
        print("   ➡️  Avancez vers l'ascenseur\n")

    # ── IR2 : voiture dans ascenseur → fermer + monter ────────
    if ir2 == 0 and dernier_ir2 == 1 and barriere_ouverte:
        print("\n" + "-" * 60)
        print(f"  🛗 VÉHICULE DANS L'ASCENSEUR 1")
        print(f"  Plaque : {derniere_plaque} — Étage : {etage_cible}")
        print("-" * 60)
        fermer_barriere_entree()
        barriere_ouverte = False
        time.sleep(1)
        enregistrer_entree_db(derniere_plaque, poids, etage_cible)
        envoyer_commande(NANO_ADDR, f"A1:{etage_cible}")
        print(f"✅ Véhicule ({derniere_plaque}) → Étage {etage_cible}")
        print("=" * 60 + "\n")

    # ── GESTION ASCENSEUR SORTIE (A2) basée sur IR_PIN ────────
    # Détection de front montant (IR_PIN passe de 1 à 0)
    if ir_pin == 0 and dernier_ir_pin == 1:
        monter_ascenseur_sortie()
        
        # Enregistrer la sortie
        if derniere_plaque:
            print(f"📝 Enregistrement de sortie pour : {derniere_plaque}")
            enregistrer_sortie_db(derniere_plaque)
            for etage in voitures_par_etage:
                if voitures_par_etage[etage] == derniere_plaque:
                    voitures_par_etage[etage] = None
                    print(f"   ✅ Place libérée à l'étage {etage}")
                    break
    
    # Détection de front descendant (IR_PIN passe de 0 à 1)
    elif ir_pin == 1 and dernier_ir_pin == 0:
        # Petite pause avant de redescendre
        print("⏳ Pause 3 secondes avant descente...")
        time.sleep(3)
        descendre_ascenseur_sortie()

    dernier_ir1    = ir1
    dernier_ir2    = ir2
    dernier_ir_pin = ir_pin
    time.sleep(0.5)
