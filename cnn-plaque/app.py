from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta
import random
import uuid

app = Flask(__name__)
CORS(app)

# Stockage des tokens actifs
active_tokens = {}

# ========== ROUTES DE BASE ==========

@app.route('/')
def accueil():
    return jsonify({"message": "Mon API Parking fonctionne !"})

# ========== STATUT PARKING ==========

@app.route('/api/parking/statut')
def statut():
    return jsonify({
        "places_libres": 10,
        "places_occupees": 5,
        "total_places": 15,
        "taux_occupation": 33.33,
        "entrees_jour": 42,
        "ca_jour": 1250
    })

@app.route('/api/parking/statut-par-niveau', methods=['GET'])
def get_statut_par_niveau():
    return jsonify([
        {"niveau": 0, "libelle": "Rez-de-chaussée", "libres": 8, "total": 12},
        {"niveau": 1, "libelle": "Étage 1", "libres": 5, "total": 12},
        {"niveau": 2, "libelle": "Étage 2", "libres": 3, "total": 12},
    ])

# ========== AUTHENTIFICATION ==========

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if email == 'admin@parking.com' and password == 'admin123':
        token = str(uuid.uuid4())
        active_tokens[token] = {
            "id": 2,
            "nom": "Admin",
            "prenom": "Système",
            "email": "admin@parking.com",
            "role": "admin"
        }
        return jsonify({
            "success": True,
            "token": token,
            "user_id": 2,
            "user": {
                "id": 2,
                "nom": "Admin",
                "prenom": "Système",
                "email": "admin@parking.com",
                "role": "admin"
            }
        })

    if email == 'test@test.com' and password == 'password':
        token = str(uuid.uuid4())
        active_tokens[token] = {
            "id": 1,
            "nom": "Dupont",
            "prenom": "Jean",
            "email": "test@test.com",
            "role": "client"
        }
        return jsonify({
            "success": True,
            "token": token,
            "user_id": 1,
            "user": {
                "id": 1,
                "nom": "Dupont",
                "prenom": "Jean",
                "email": "test@test.com",
                "role": "client"
            }
        })

    return jsonify({"success": False, "error": "Email ou mot de passe incorrect"}), 401

@app.route('/api/auth/register', methods=['POST'])
def register():
    return jsonify({
        "success": True,
        "user_id": random.randint(100, 999),
        "message": "Inscription réussie"
    })

@app.route('/api/auth/me', methods=['GET'])
def get_current_user():
    auth_header = request.headers.get('Authorization', '')
    token = auth_header.replace('Bearer ', '') if auth_header.startswith('Bearer ') else None
    
    if token and token in active_tokens:
        return jsonify({"user": active_tokens[token]})
    
    return jsonify({"error": "Non authentifié"}), 401

# ========== VEHICULES ==========

@app.route('/api/vehicules', methods=['GET'])
def get_vehicules():
    return jsonify({
        "vehicules": [
            {"id": 1, "plaque": "AB-123-CD"},
            {"id": 2, "plaque": "EF-456-GH"}
        ]
    })

# ========== RESERVATION ==========

@app.route('/api/reservation', methods=['POST'])
def create_reservation():
    data = request.json
    distance = data.get('distance', 0)
    temps_trajet = data.get('temps_trajet', 0)
    reservation_id = random.randint(1000, 9999)

    return jsonify({
        "success": True,
        "reservation_id": reservation_id,
        "message": "Réservation créée",
        "code_confirmation": f"RES{reservation_id}",
        "heure_arrivee_estimee": (
            datetime.now() + timedelta(minutes=temps_trajet)
        ).strftime("%H:%M")
    })

# ========== PAIEMENT ==========

@app.route('/api/payment/process', methods=['POST'])
def process_payment():
    transaction_id = str(uuid.uuid4())[:8].upper()
    return jsonify({
        "success": True,
        "transaction_id": transaction_id,
        "message": "Paiement réussi"
    })

# ========== STATIONNEMENT ACTIF ==========

@app.route('/api/stationnement/actif', methods=['GET'])
def get_stationnement_actif():
    return jsonify({
        "has_active": False,
        "stationnement": None
    })

# ========== ADMIN DASHBOARD ==========

@app.route('/api/admin/dashboard', methods=['GET'])
def admin_dashboard():
    return jsonify({
        "total_places": 15,
        "occupied_places": 5,
        "free_places": 10
    })

# ========== ADMIN ALERTES ==========

@app.route('/api/admin/alertes', methods=['GET'])
def admin_alertes():
    return jsonify({
        "alertes": [
            {
                "id": 1,
                "type": "critical",
                "message": "Capteur HS niveau 1",
                "date": datetime.now().isoformat()
            }
        ]
    })

# ========== ADMIN CAPTEURS ==========

@app.route('/api/admin/capteurs', methods=['GET'])
def admin_capteurs():
    return jsonify({
        "capteurs": [
            {"id": 1, "etat": "online"},
            {"id": 2, "etat": "offline"},
            {"id": 3, "etat": "online"}
        ]
    })

# ========== ADMIN VEHICULES ==========

@app.route('/api/admin/vehicules', methods=['GET'])
def admin_vehicules():
    return jsonify({
        "vehicules": [
            {"id": 1, "plaque": "AB-123-CD"},
            {"id": 2, "plaque": "EF-456-GH"}
        ]
    })

# ========== ADMIN PARKING ==========

@app.route('/api/admin/parking', methods=['GET'])
def admin_parking():
    return jsonify({
        "niveaux": [
            {"niveau": 0, "places": 12},
            {"niveau": 1, "places": 12}
        ]
    })

@app.route('/api/admin/parking/places', methods=['GET'])
def admin_places():
    return jsonify({
        "places": [
            {"id": 1, "etat": "libre"},
            {"id": 2, "etat": "occupée"}
        ]
    })

# ========== ADMIN STATIONNEMENTS ==========

@app.route('/api/admin/stationnements', methods=['GET'])
def admin_stationnements():
    return jsonify({
        "stationnements": [
            {"id": 1, "plaque": "AB-123-CD"},
            {"id": 2, "plaque": "EF-456-GH"}
        ]
    })

# ========== ADMIN PAIEMENTS ==========

@app.route('/api/admin/paiements', methods=['GET'])
def admin_paiements():
    return jsonify({
        "paiements": [
            {"id": 1, "montant": 10},
            {"id": 2, "montant": 20}
        ]
    })

# ========== ADMIN ASCENSEUR ==========

@app.route('/api/admin/ascenseur', methods=['GET'])
def admin_ascenseur():
    return jsonify({
        "statut": "fonctionnel",
        "niveauActuel": 1
    })

# ========== LANCEMENT ==========

if __name__ == '__main__':
    print("=" * 50)
    print("🚗 Parking Intelligent API")
    print("=" * 50)
    print("📍 http://localhost:5000")
    print("\n🔥 API démarrée...")
    app.run(debug=True, port=5000)
