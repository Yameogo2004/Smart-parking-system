# Smart-parking-system
🏆 Projet primé au concours Nexus (ENSA Tétouan). Parking automatisé 2 étages : ascenseurs, reconnaissance plaques marocaines (CNN), capteurs, RFID, application mobile. Stack : Raspberry Pi, Arduino, ESP32.


# 🅿️ Smart Parking System - 2 Étages Automatisé

> 🏆 **1er Prix au Concours Nexus** – ENSA Tétouan

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


### Application mobile
- **Côté client** : réservation de places, guidage
- **Côté admin** : taux d'occupation, liste des véhicules garés, capteurs défaillants, alertes sécurité


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


## 🧠 Architecture logicielle

cd smart-parking/raspberry-pi
pip install -r requirements.txt
python app.py
