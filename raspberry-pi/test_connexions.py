# test_connexions.py
import smbus2
import requests
import socket
import time

print("=" * 60)
print("  🔍 TEST CONNEXIONS SYSTÈME PARKING")
print("=" * 60)

# ============================================================
# TEST I2C - Arduino Uno et Nano
# ============================================================
print("\n📡 Test I2C...")
try:
    bus = smbus2.SMBus(1)
    
    # Test Uno
    try:
        bus.read_byte(0x08)
        print("  ✅ Arduino Uno  (0x08) → CONNECTÉ")
    except:
        print("  ❌ Arduino Uno  (0x08) → NON DÉTECTÉ")
    
    # Test Nano
    try:
        bus.read_byte(0x09)
        print("  ✅ Arduino Nano (0x09) → CONNECTÉ")
    except:
        print("  ❌ Arduino Nano (0x09) → NON DÉTECTÉ")
        
    bus.close()
except Exception as e:
    print(f"  ❌ Bus I2C erreur : {e}")

# ============================================================
# TEST ESP32 SORTIE (avec capteurs IR)
# ============================================================
print("\n📶 Test ESP32 SORTIE (avec IR5)...")
ESP32_SORTIE_IP = "192.168.76.144"  # ESP32 sortie (barrière sortie)
try:
    response = requests.get(f"http://{ESP32_SORTIE_IP}/capteurs", timeout=3)
    if response.status_code == 200:
        data = response.json()
        print(f"  ✅ ESP32 SORTIE ({ESP32_SORTIE_IP}) → CONNECTÉ")
        print(f"     IR_SORTIE : {data.get('IR_SORTIE')}")
        print(f"     IR5 : {data.get('IR5')}")
    else:
        print(f"  ⚠️ ESP32 SORTIE ({ESP32_SORTIE_IP}) → HTTP {response.status_code}")
except requests.exceptions.ConnectionError:
    print(f"  ❌ ESP32 SORTIE ({ESP32_SORTIE_IP}) → INACCESSIBLE (connexion refusée)")
except requests.exceptions.Timeout:
    print(f"  ❌ ESP32 SORTIE ({ESP32_SORTIE_IP}) → TIMEOUT")
except Exception as e:
    print(f"  ❌ ESP32 SORTIE ({ESP32_SORTIE_IP}) → ERREUR : {e}")

# ============================================================
# TEST ESP32 ENTRÉE (avec LCD + Servo)
# ============================================================
print("\n📶 Test ESP32 ENTRÉE (LCD + Barrière)...")
ESP32_ENTREE_IP = "192.168.76.88"  # ESP32 entrée (barrière entrée)
try:
    # L'ESP32 entrée n'a PAS d'endpoint /capteurs !
    # Il faut utiliser /status pour vérifier son état
    response = requests.get(f"http://{ESP32_ENTREE_IP}/status", timeout=3)
    if response.status_code == 200:
        data = response.json()
        print(f"  ✅ ESP32 ENTRÉE ({ESP32_ENTREE_IP}) → CONNECTÉ")
        print(f"     Barrière : {data.get('barriere')}")
        print(f"     Endpoints disponibles : /commande (POST), /status (GET)")
    else:
        print(f"  ⚠️ ESP32 ENTRÉE ({ESP32_ENTREE_IP}) → HTTP {response.status_code}")
except requests.exceptions.ConnectionError:
    print(f"  ❌ ESP32 ENTRÉE ({ESP32_ENTREE_IP}) → INACCESSIBLE (connexion refusée)")
    print(f"     Vérifiez : alimentation + connexion WiFi")
except requests.exceptions.Timeout:
    print(f"  ❌ ESP32 ENTRÉE ({ESP32_ENTREE_IP}) → TIMEOUT")
except Exception as e:
    print(f"  ❌ ESP32 ENTRÉE ({ESP32_ENTREE_IP}) → ERREUR : {e}")

# ============================================================
# TEST ADDITIONNEL : Commande sur ESP32 ENTRÉE
# ============================================================
print("\n🔧 Test commande ESP32 ENTRÉE (GET /status)...")
try:
    response = requests.get(f"http://{ESP32_ENTREE_IP}/status", timeout=3)
    if response.status_code == 200:
        print(f"  ✅ Statut récupéré : {response.json()}")
    else:
        print(f"  ⚠️ Réponse inattendue : {response.status_code}")
except Exception as e:
    print(f"  ❌ Impossible de tester : {e}")

# ============================================================
# TEST PC ANPR (Caméra)
# ============================================================
print("\n📸 Test PC ANPR...")
PC_ANPR_IP   = "192.168.76.22"
PC_ANPR_PORT = 5000
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(5)
    s.connect((PC_ANPR_IP, PC_ANPR_PORT))
    s.send("PING".encode())
    reponse = s.recv(1024).decode()
    s.close()
    print(f"  ✅ PC ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT}) → CONNECTÉ")
    print(f"     Réponse : {reponse}")
except socket.timeout:
    print(f"  ❌ PC ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT}) → TIMEOUT")
except ConnectionRefusedError:
    print(f"  ❌ PC ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT}) → CONNEXION REFUSÉE (serveur non démarré)")
except Exception as e:
    print(f"  ❌ PC ANPR ({PC_ANPR_IP}:{PC_ANPR_PORT}) → ERREUR : {e}")

# ============================================================
# TEST FLASK API
# ============================================================
print("\n🌐 Test Flask API...")
try:
    response = requests.get("http://localhost:5000/", timeout=3)
    if response.status_code == 200:
        data = response.json()
        print(f"  ✅ Flask API → EN LIGNE")
        print(f"     Version : {data.get('version', 'inconnue')}")
    else:
        print(f"  ⚠️ Flask API → HTTP {response.status_code}")
except requests.exceptions.ConnectionError:
    print(f"  ❌ Flask API → NON ACCESSIBLE (serveur non démarré)")
except Exception as e:
    print(f"  ❌ Flask API → ERREUR : {e}")

# ============================================================
# TEST BASE DE DONNÉES
# ============================================================
print("\n🗄️  Test Base de données...")
try:
    import pymysql
    db = pymysql.connect(
        host='localhost',
        user='parking_user',
        password='parking123',
        database='smart_parking',
        connect_timeout=5
    )
    with db.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) as c FROM parking_spots")
        result = cursor.fetchone()
        print(f"  ✅ MariaDB → CONNECTÉE")
        print(f"     Places : {result[0]}")
    db.close()
except ImportError:
    print(f"  ❌ MariaDB → pymysql non installé (pip install pymysql)")
except pymysql.Error as e:
    print(f"  ❌ MariaDB → ERREUR : {e}")
except Exception as e:
    print(f"  ❌ MariaDB → ERREUR : {e}")

# ============================================================
# RÉSUMÉ ET RECOMMANDATIONS
# ============================================================
print("\n" + "=" * 60)
print("  📊 RÉSUMÉ DU DIAGNOSTIC")
print("=" * 60)

# Vérifier les IPs
print("\n📌 IPS CONFIGURÉES :")
print(f"   ESP32 Entrée  : {ESP32_ENTREE_IP}  (doit avoir /status et /commande)")
print(f"   ESP32 Sortie  : {ESP32_SORTIE_IP}  (doit avoir /capteurs)")
print(f"   PC ANPR       : {PC_ANPR_IP}:{PC_ANPR_PORT}")
print(f"   Flask API     : http://localhost:5000")

print("\n💡 RECOMMANDATIONS :")
print("   1. Vérifiez que chaque ESP32 est bien alimenté")
print("   2. Vérifiez que les ESP32 sont sur le même réseau WiFi")
print("   3. L'ESP32 ENTRÉE doit avoir les endpoints : /commande (POST) et /status (GET)")
print("   4. L'ESP32 SORTIE doit avoir l'endpoint : /capteurs (GET)")
print("   5. Pour tester l'ESP32 ENTRÉE manuellement : curl http://192.168.76.88/status")

print("\n" + "=" * 60)
print("  Test terminé !")
print("=" * 60)
