# 🅿️ Smart Parking System - 2 Étages Automatisé

> 🏆 **1er Prix au Concours Nexus** – ENSA Tétouan


![Version](https://img.shields.io/badge/version-3.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Python](https://img.shields.io/badge/Python-3.9+-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Arduino](https://img.shields.io/badge/Arduino-IDE-teal)

## 📖 À propos

Ce projet est un **système de stationnement intelligent** conçu pour répondre aux besoins des grandes villes comme Rabat, Casablanca ou Tanger. Nous avons réalisé une **maquette fonctionnelle d'un parking à 2 étages** avec entrée et sortie séparées, entièrement automatisée.

Le système intègre :
- 🚗 Détection automatique des véhicules
- 🏗️ Ascenseurs pilotés pour monter les voitures aux étages
- ⚖️ Répartition intelligente par **poids** (véhicules lourds au RDC pour préserver l'infrastructure)
- 👁️ Reconnaissance des **plaques marocaines** (y compris lettres arabes) via un modèle CNN
- 📱 Application mobile pour les clients (réservations) et les admins (taux d'occupation, capteurs défaillants, alertes sécurité)
- 🔆 Éclairage adaptatif jour/nuit
- 🪪 Sortie par badge RFID




## 🎯 Fonctionnalités détaillées

### À l'entrée
1. Capteur IR détecte un véhicule → appelle l'ascenseur
2. Webcam capture la plaque (CNN entraîné sur plaques marocaines)
3. Capteur de poids pèse le véhicule
4. Base de données enregistre les informations
5. Servomoteur ouvre la barrière
6. LCD I2C affiche "Bienvenue" et instructions
7. Le système attribue un étage selon le poids :
   - Poids léger → 2ème étage
   - Poids moyen → 1er étage
   - Poids lourd → Rez-de-chaussée

### Ascenseur d'entrée
- Step motor 1 monte le véhicule à l'étage attribué
- Capteurs IR + ultrasons vérifient l'arrivée dans l'emplacement attribué
- LEDs s'adaptent à la luminosité (photorésistance)

### À la sortie
1. Capteurs détectent que le véhicule quitte son emplacement
2. Ascenseur de sortie (step motor 2) est appelé à l'étage correspondant
3. Véhicule arrive au rez-de-chaussée
4. LCD affiche "Au revoir" et instructions
5. Client présente son badge RFID
6. Servomoteur ouvre la barrière de sortie
7. Capteur IR ferme la barrière après passage


## 📱 Application Flutter

### Côté Admin
- 📊 Dashboard temps réel — taux d'occupation par niveau
- 🗺️ Grille parking interactive — statut de chaque place
- 🚗 Liste des véhicules garés avec plaque et étage
- 🔔 Alertes automatiques capteurs hors ligne
- 💰 Historique des paiements
- 📈 Statistiques hebdomadaires

### Côté Client
- 🔍 Localisation de son véhicule
- 📋 Historique des stationnements
- 💳 Paiement en ligne
- 🔔 Notifications en temps réel



## 🛠️ Matériel utilisé
| Composant | Quantité |
|-----------|----------|
| Raspberry Pi 4 | 1 |
| Arduino Uno | 1 |
| Arduino Nano | 1 |
| ESP32 / ESP32-S3 | 2 |
| Capteurs suiveurs de ligne | 2 |
| Capteurs IR | 7 |
| Capteurs ultrasons | 1 |
| Step motors | 2 |
| Servomoteurs | 2 |
| Lecteurs RFID + badges | 4 |
| LCD I2C | 2 |
| Capteur de poids | 1 |
| Webcam (PC) | 1 |
| LEDs + photorésistances | 4|
| Résistances et câbles | - |


## 🏗️ Architecture système
Raspberry Pi 4 (Maître)
├── Arduino Uno  (I2C 0x08) ── IR1 · IR2 · IR3 · IR4 · HX711 · LDR
├── Arduino Nano (I2C 0x09) ── Stepper A1 (entrée) · Stepper A2 (sortie)
├── ESP32 Entrée (WiFi)     ── LCD I2C · Servo barrière · 192.168.76.88
├── ESP32 Sortie (WiFi)     ── RFID RC522 · LCD · Servo · IR · 192.168.76.144
├── PC ANPR      (TCP)      ── Caméra · Modèle CNN · 192.168.76.22:5000
└── Flask API    (HTTP)     ── MariaDB · REST API · localhost:5000


---

## 🧠 Stack technologique

| Couche | Technologie |
|--------|-------------|
| Firmware | Arduino IDE · C++ |
| IoT Master | Python 3 · smbus2 |
| Backend | Flask · PyMySQL |
| Base de données | MariaDB |
| Application | Flutter · Dart |
| ANPR | Python · OpenCV · CNN |
| Communication | I2C · WiFi · TCP Socket · HTTP REST |

### Communications
- **Raspberry Pi** ↔ Arduino Nano : fils (step motors ascenseurs)
- **Raspberry Pi** ↔ ESP32 / ESP32-S3 : WiFi
- **Raspberry Pi** ↔ Arduino Uno : fils (entrée capteurs)

---

## 📂 Où exécuter chaque fichier ?

| Dossier / Fichier | Contenu | Où l'exécuter |
|-------------------|---------|----------------|
| `app.py` / `main.py` | Serveur Flask (API, base de données, logique métier) | **Raspberry Pi 4** |
| `Arduino/` | Codes `.ino` pour Uno, Nano | **Arduino Uno / Nano** |
| `ESP 32/` | Codes `.ino` pour ESP32, ESP32-S3 | **ESP32 / ESP32-S3** |
| `app_mobile/` | Application Flutter (Dart) | **Smartphone (Android/iOS)** ou émulateur |
| `cnn-plaque/` | Modèle CNN + script de détection | **PC avec webcam** (ou Raspberry Pi si webcam USB) |

### 🔍 Détail pour `cnn-plaque/` (PC avec webcam)

Ce dossier contient le modèle de reconnaissance des plaques marocaines.  
Sur le PC connecté à la webcam, lancer :

```bash
cd cnn-plaque
pip install -r requirements.txt
python detect_plate.py
```


## 🚀 Installation

### Prérequis Raspberry Pi
```bash
pip install flask flask-cors pymysql smbus2 requests

# Installer les dépendances Python
pip install flask flask-cors pymysql smbus2 requests

# Lancer l'API
python3 app.py
```

### Sur PC (reconnaissance plaque)
```bash
cd cnn-plaque
pip install -r requirements.txt
python detect_plate.py
```

### Sur smartphone ou pc (application Flutter)
```bash
cd app_mobile
flutter pub get
flutter run
```



## 🎥 Démonstration

[![Voir la démo](https://img.shields.io/badge/🎬_Regarder_la_démonération-4285F4?style=for-the-badge&logo=google-drive&logoColor=white)](https://drive.google.com/drive/folders/1-NwvNPaacl2qP96XJzibX-tao3X1Dn6m)
---


## 👥 Équipe

| Nom | 
|-----|--------------|
| *Ariel Barthélémy Wendtoin Yameogo* | 
| *Abdoulfatah Omar* | 
| *Nachda Nourouddine* | 

*Encadré par :* Prof. El Adib · ENSA Tétouan
