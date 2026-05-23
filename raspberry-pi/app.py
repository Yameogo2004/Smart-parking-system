"""
Smart Parking API v3.1
- Véhicules enrichis avec place actuelle + statut depuis DB
- Plaques marocaines correctes (UTF-8)
- Sortie libère automatiquement la place
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'parking_user',
    'password': 'parking123',
    'database': 'smart_parking',
    'cursorclass': pymysql.cursors.DictCursor,
    'charset': 'utf8mb4',       # ← Fix plaques arabes
}

def get_db():
    return pymysql.connect(**DB_CONFIG)

def get_current_user_from_token():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None
    token = auth_header.replace("Bearer ", "").strip()
    if not token.startswith("fake_token_"):
        return None
    parts = token.split("_")
    if len(parts) < 4:
        return None
    try:
        user_id = int(parts[-1])
    except ValueError:
        return None
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM users WHERE id=%s", (user_id,))
            return cursor.fetchone()
    finally:
        db.close()

def build_user_payload(user):
    return {
        "id": user["id"],
        "nom": user["nom"],
        "prenom": user.get("prenom", ""),
        "email": user["email"],
        "telephone": user.get("telephone", ""),
        "role": user["role"],
    }

# =========================================================
# ROOT
# =========================================================
@app.route("/")
def accueil():
    return jsonify({"message": "Smart Parking API", "version": "3.1.0"})

# =========================================================
# AUTH
# =========================================================
@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM users WHERE email=%s AND password=%s", (email, password))
            user = cursor.fetchone()
        if not user:
            return jsonify({"success": False, "error": "Email ou mot de passe incorrect"}), 401
        return jsonify({
            "success": True,
            "token": f"fake_token_{user['role']}_{user['id']}",
            "user_id": user["id"],
            "user": build_user_payload(user),
        })
    finally:
        db.close()

@app.route("/api/auth/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}
    email = data.get("email", "").strip().lower()
    nom = data.get("nom", "Utilisateur").strip()
    prenom = data.get("prenom", "").strip()
    telephone = data.get("telephone", "").strip()
    password = data.get("password", "").strip()
    if not email or not password:
        return jsonify({"success": False, "error": "Email et mot de passe requis"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email=%s", (email,))
            if cursor.fetchone():
                return jsonify({"success": False, "error": "Cet email existe déjà"}), 409
            cursor.execute(
                "INSERT INTO users (nom,prenom,email,password,telephone,role) VALUES (%s,%s,%s,%s,%s,'client')",
                (nom, prenom, email, password, telephone)
            )
            new_id = cursor.lastrowid
        db.commit()
        return jsonify({"success": True, "user_id": new_id, "message": "Inscription réussie"}), 201
    finally:
        db.close()

@app.route("/api/auth/me", methods=["GET"])
def me():
    user = get_current_user_from_token()
    if not user:
        return jsonify({"success": False, "error": "Non authentifié"}), 401
    return jsonify({"success": True, "user": build_user_payload(user)})

@app.route("/api/auth/logout", methods=["POST"])
def logout():
    return jsonify({"success": True, "message": "Déconnexion réussie"})

# =========================================================
# GENERAL PARKING
# =========================================================
@app.route("/api/parking/statut", methods=["GET"])
def statut():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM parking_spots")
            total = cursor.fetchone()["total"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Libre'")
            libres = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Occupée'")
            occupes = cursor.fetchone()["c"]
        taux = (occupes / total * 100) if total > 0 else 0.0
        return jsonify({
            "places_libres": libres,
            "places_occupees": occupes,
            "total_places": total,
            "taux_occupation": round(taux, 2),
            "entrees_jour": 42,
            "ca_jour": 1250,
        })
    finally:
        db.close()

@app.route("/api/parking/statut-par-niveau", methods=["GET"])
def get_statut_par_niveau():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT niveau, statut, COUNT(*) as count FROM parking_spots GROUP BY niveau, statut")
            rows = cursor.fetchall()
        niveaux = {}
        for r in rows:
            n = r["niveau"]
            if n not in niveaux:
                niveaux[n] = {"niveau": n, "libelle": "Rez-de-chaussée" if n == 0 else f"Étage {n}", "libres": 0, "occupes": 0, "total": 0, "type": "standard"}
            niveaux[n]["total"] += r["count"]
            if r["statut"] == "Libre":
                niveaux[n]["libres"] += r["count"]
            elif r["statut"] == "Occupée":
                niveaux[n]["occupes"] += r["count"]
        return jsonify([niveaux[k] for k in sorted(niveaux.keys())])
    finally:
        db.close()

# =========================================================
# ADMIN DASHBOARD
# =========================================================
@app.route("/api/admin/dashboard", methods=["GET"])
def admin_dashboard():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots")
            total = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Libre'")
            libres = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Occupée'")
            occupes = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Réservée'")
            reservees = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM alertes WHERE resolue=0")
            alertes = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM alertes WHERE resolue=0 AND niveau='Critique'")
            alertes_crit = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM capteurs")
            total_capteurs = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM capteurs WHERE statut != 'online'")
            offline_capteurs = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM paiements")
            total_paiements = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM vehicules")
            total_vehicules = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM stationnements WHERE sortie IS NULL")
            actifs = cursor.fetchone()["c"]
            cursor.execute("SELECT statut, niveauActuel FROM elevator LIMIT 1")
            elev = cursor.fetchone()
        return jsonify({
            "total_places": total,
            "occupied_places": occupes,
            "free_places": libres,
            "reserved_places": reservees,
            "total_alertes": alertes,
            "critical_alertes": alertes_crit,
            "total_capteurs": total_capteurs,
            "offline_capteurs": offline_capteurs,
            "total_paiements": total_paiements,
            "total_vehicules": total_vehicules,
            "active_stationnements": actifs,
            "elevator_status": elev["statut"] if elev else "N/A",
            "elevator_level": elev["niveauActuel"] if elev else 0,
            "occupancy_rate": round(occupes/total*100, 2) if total > 0 else 0.0,
        })
    finally:
        db.close()

# =========================================================
# ADMIN ALERTES
# =========================================================
@app.route("/api/admin/alertes", methods=["GET"])
def admin_alertes():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM alertes WHERE resolue=0 ORDER BY timestamp DESC")
            alertes = cursor.fetchall()
        for a in alertes:
            if a.get("timestamp"):
                a["timestamp"] = a["timestamp"].isoformat()
        return jsonify({"alertes": alertes})
    finally:
        db.close()

@app.route("/api/admin/alertes/vehicules", methods=["GET"])
def admin_vehicle_alertes():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM alertes WHERE resolue=0 AND (type LIKE '%vehicule%' OR type LIKE '%vehicle%' OR type LIKE '%voiture%') ORDER BY timestamp DESC")
            alertes = cursor.fetchall()
        for a in alertes:
            if a.get("timestamp"):
                a["timestamp"] = a["timestamp"].isoformat()
        return jsonify({"alertes": alertes})
    finally:
        db.close()

@app.route("/api/admin/alertes/capteurs", methods=["GET"])
def admin_sensor_alertes():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM alertes WHERE resolue=0 AND (type LIKE '%capteur%' OR type LIKE '%sensor%') ORDER BY timestamp DESC")
            alertes = cursor.fetchall()
        for a in alertes:
            if a.get("timestamp"):
                a["timestamp"] = a["timestamp"].isoformat()
        return jsonify({"alertes": alertes})
    finally:
        db.close()

@app.route("/api/admin/alertes/<int:alerte_id>/resoudre", methods=["PUT"])
def admin_resolve_alerte(alerte_id):
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("UPDATE alertes SET resolue=1 WHERE id=%s", (alerte_id,))
        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()

# =========================================================
# ADMIN USERS
# =========================================================
@app.route("/api/admin/users", methods=["POST"])
def admin_create_user():
    current_user = get_current_user_from_token()
    if not current_user or current_user["role"] != "admin":
        return jsonify({"success": False, "error": "Accès refusé"}), 403
    data = request.get_json(silent=True) or {}
    nom = data.get("nom", "").strip()
    prenom = data.get("prenom", "").strip()
    email = data.get("email", "").strip().lower()
    password = data.get("password", "admin123").strip()
    role = data.get("role", "admin").strip().lower()
    telephone = data.get("telephone", "").strip()
    if not nom or not prenom or not email:
        return jsonify({"success": False, "error": "Nom, prénom et email requis"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email=%s", (email,))
            if cursor.fetchone():
                return jsonify({"success": False, "error": "Email déjà utilisé"}), 409
            cursor.execute(
                "INSERT INTO users (nom,prenom,email,password,telephone,role) VALUES (%s,%s,%s,%s,%s,%s)",
                (nom, prenom, email, password, telephone, role)
            )
            new_id = cursor.lastrowid
        db.commit()
        return jsonify({"success": True, "user": {"id": new_id, "nom": nom, "email": email, "role": role}}), 201
    finally:
        db.close()

# =========================================================
# ADMIN CAPTEURS
# =========================================================
@app.route("/api/admin/capteurs", methods=["GET"])
def admin_capteurs():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM capteurs")
            capteurs = cursor.fetchall()
        return jsonify({"capteurs": capteurs})
    finally:
        db.close()

# =========================================================
# ADMIN VÉHICULES — ENRICHI AVEC PLACE + STATUT DB
# =========================================================
@app.route("/api/admin/vehicules", methods=["GET"])
def admin_vehicules():
    db = get_db()
    try:
        with db.cursor() as cursor:
            # Jointure avec stationnements actifs pour avoir la place actuelle
            cursor.execute("""
                SELECT 
                    v.id,
                    v.matricule,
                    v.type,
                    COALESCE(v.poids, 0) as poids,
                    COALESCE(v.suspect, 0) as suspect,
                    COALESCE(v.modele, '') as modele,
                    p.numero as place_actuelle,
                    CASE WHEN s.id IS NOT NULL THEN 1 ELSE 0 END as est_gare
                FROM vehicules v
                LEFT JOIN stationnements s 
                    ON v.id = s.vehicle_id AND s.sortie IS NULL
                LEFT JOIN parking_spots p 
                    ON s.parking_spot_id = p.id
                ORDER BY v.id DESC
            """)
            vehicules = cursor.fetchall()
        return jsonify({"vehicules": vehicules})
    finally:
        db.close()

# =========================================================
# ADMIN PARKING
# =========================================================
@app.route("/api/admin/parking", methods=["GET"])
def admin_parking():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM parking_spots")
            total = cursor.fetchone()["total"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Libre'")
            libres = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Occupée'")
            occupes = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM parking_spots WHERE statut='Réservée'")
            reservees = cursor.fetchone()["c"]
        return jsonify({"total": total, "libres": libres, "occupes": occupes, "reservees": reservees})
    finally:
        db.close()

@app.route("/api/admin/parking/niveaux", methods=["GET"])
def admin_parking_levels():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT niveau, statut, COUNT(*) as count FROM parking_spots GROUP BY niveau, statut")
            rows = cursor.fetchall()
        niveaux = {}
        for r in rows:
            n = r["niveau"]
            if n not in niveaux:
                niveaux[n] = {"niveau": n, "libelle": "Rez-de-chaussée" if n == 0 else f"Étage {n}", "libres": 0, "occupes": 0, "total": 0}
            niveaux[n]["total"] += r["count"]
            if r["statut"] == "Libre":
                niveaux[n]["libres"] += r["count"]
            elif r["statut"] == "Occupée":
                niveaux[n]["occupes"] += r["count"]
        return jsonify({"niveaux": [niveaux[k] for k in sorted(niveaux.keys())]})
    finally:
        db.close()

@app.route("/api/admin/parking/places", methods=["GET"])
def admin_parking_places():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM parking_spots ORDER BY niveau, numero")
            places = cursor.fetchall()
        return jsonify({"places": places})
    finally:
        db.close()

# =========================================================
# ADMIN STATIONNEMENTS
# =========================================================
@app.route("/api/admin/stationnements", methods=["GET"])
def admin_stationnements():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM stationnements ORDER BY entree DESC")
            rows = cursor.fetchall()
        for r in rows:
            if r.get("entree"):
                r["entree"] = r["entree"].isoformat()
            if r.get("sortie"):
                r["sortie"] = r["sortie"].isoformat()
        return jsonify({"stationnements": rows})
    finally:
        db.close()

# =========================================================
# ADMIN PAIEMENTS
# =========================================================
@app.route("/api/admin/paiements", methods=["GET"])
def admin_paiements():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM paiements WHERE type='parking'")
            paiements = cursor.fetchall()
        return jsonify({"paiements": paiements})
    finally:
        db.close()

@app.route("/api/admin/paiements/parking", methods=["GET"])
def admin_parking_payments():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM paiements WHERE type='parking'")
            paiements = cursor.fetchall()
        return jsonify({"paiements": paiements})
    finally:
        db.close()

@app.route("/api/admin/paiements/ev", methods=["GET"])
def admin_ev_payments():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM ev_charging_payments")
            paiements = cursor.fetchall()
        for p in paiements:
            if p.get("started_at"):
                p["started_at"] = p["started_at"].isoformat()
            if p.get("finished_at"):
                p["finished_at"] = p["finished_at"].isoformat()
        return jsonify({"paiements": paiements})
    finally:
        db.close()

# =========================================================
# ADMIN ASCENSEUR
# =========================================================
@app.route("/api/admin/ascenseur", methods=["GET"])
def admin_ascenseur():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM elevator LIMIT 1")
            elev = cursor.fetchone()
        return jsonify({"ascenseur": elev})
    finally:
        db.close()

# =========================================================
# ADMIN NOTIFICATIONS
# =========================================================
@app.route("/api/admin/notifications", methods=["GET"])
def admin_notifications():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM notifications ORDER BY created_at DESC")
            notifs = cursor.fetchall()
        for n in notifs:
            if n.get("created_at"):
                n["created_at"] = n["created_at"].isoformat()
        return jsonify({"notifications": notifs})
    finally:
        db.close()

@app.route("/api/admin/notifications/<int:notification_id>/read", methods=["PUT"])
def mark_notification_read(notification_id):
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("UPDATE notifications SET is_read=1 WHERE id=%s", (notification_id,))
        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()

@app.route("/api/admin/notifications/read-all", methods=["PUT"])
def mark_all_notifications_read():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("UPDATE notifications SET is_read=1")
        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()

# =========================================================
# ADMIN BLACKLIST
# =========================================================
@app.route("/api/admin/blacklist", methods=["GET"])
def admin_blacklist():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM blacklist_events ORDER BY detected_at DESC")
            events = cursor.fetchall()
        for e in events:
            if e.get("detected_at"):
                e["detected_at"] = e["detected_at"].isoformat()
        return jsonify({"events": events})
    finally:
        db.close()

# =========================================================
# ADMIN STATS
# =========================================================
@app.route("/api/admin/stats/overview", methods=["GET"])
def admin_stats_overview():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT SUM(montant) as total FROM paiements WHERE statut='paid'")
            rev = cursor.fetchone()["total"] or 0
            cursor.execute("SELECT COUNT(*) as c FROM ev_charging_payments")
            ev_count = cursor.fetchone()["c"]
            cursor.execute("SELECT COUNT(*) as c FROM vehicules")
            avg_traffic = cursor.fetchone()["c"]
        return jsonify({
            "weekly_revenue": float(rev),
            "average_daily_traffic": avg_traffic,
            "average_parking_duration_hours": 2.5,
            "weekly_ev_charges": ev_count,
            "weekly_traffic": [
                {"label": "Lun", "value": 18}, {"label": "Mar", "value": 22},
                {"label": "Mer", "value": 20}, {"label": "Jeu", "value": 25},
                {"label": "Ven", "value": 29}, {"label": "Sam", "value": 16},
                {"label": "Dim", "value": 11},
            ],
            "revenue_series": [
                {"label": "Lun", "value": 120.0}, {"label": "Mar", "value": 145.5},
                {"label": "Mer", "value": 132.0}, {"label": "Jeu", "value": 180.0},
                {"label": "Ven", "value": 210.0}, {"label": "Sam", "value": 95.0},
                {"label": "Dim", "value": 76.0},
            ],
            "weight_series": [
                {"label": "SUV", "average_weight": 1800.0},
                {"label": "Citadine", "average_weight": 1100.0},
                {"label": "Berline", "average_weight": 1450.0},
                {"label": "Utilitaire", "average_weight": 2200.0},
            ],
        })
    finally:
        db.close()

# =========================================================
# CLIENT / VÉHICULE / RÉSERVATION
# =========================================================
@app.route("/api/vehicules", methods=["GET"])
def get_vehicules():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM vehicules")
            vehicules = cursor.fetchall()
        return jsonify({"vehicules": vehicules})
    finally:
        db.close()

@app.route("/api/reservation", methods=["POST"])
def create_reservation():
    data = request.get_json(silent=True) or {}
    distance = data.get("distance", 0)
    temps_trajet = data.get("temps_trajet", 0)
    charge = data.get("charge_supplementaire", 0)
    plaque = data.get("plaque", "INCONNUE")
    modele = data.get("modele", "Véhicule")
    date_debut = data.get("date_debut", datetime.now().isoformat())
    date_fin = data.get("date_fin", (datetime.now() + timedelta(hours=2)).isoformat())
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM parking_spots WHERE statut='Libre' LIMIT 1")
            free_spot = cursor.fetchone()
        if not free_spot:
            return jsonify({"success": False, "error": "Aucune place libre"}), 409
        import random, string
        code = "RES" + ''.join(random.choices(string.digits, k=6))
        with db.cursor() as cursor:
            cursor.execute("UPDATE parking_spots SET statut='Réservée' WHERE id=%s", (free_spot["id"],))
            cursor.execute(
                "INSERT INTO reservations (user_id,code_confirmation,date_debut,date_fin,plaque,modele,charge,montant,statut,emplacement) VALUES (1,%s,%s,%s,%s,%s,%s,20.0,'confirmée',%s)",
                (code, date_debut, date_fin, plaque, modele, charge, free_spot["numero"])
            )
            new_id = cursor.lastrowid
        db.commit()
        return jsonify({
            "success": True,
            "reservation_id": new_id,
            "code_confirmation": code,
            "distance": distance,
            "temps_trajet": temps_trajet,
            "charge": charge,
            "place": {"id": free_spot["id"], "numero": free_spot["numero"], "statut": "Réservée"},
            "heure_arrivee_estimee": (datetime.now() + timedelta(minutes=int(temps_trajet))).strftime("%H:%M"),
        })
    finally:
        db.close()

@app.route("/api/reservations/historique", methods=["GET"])
def reservation_history():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM reservations ORDER BY date_reservation DESC")
            reservations = cursor.fetchall()
        for r in reservations:
            for field in ["date_reservation", "date_debut", "date_fin"]:
                if r.get(field):
                    r[field] = r[field].isoformat()
        return jsonify({"success": True, "reservations": reservations})
    finally:
        db.close()

@app.route("/api/reservation/<int:reservation_id>/annuler", methods=["POST"])
def cancel_reservation(reservation_id):
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("UPDATE reservations SET statut='annulée' WHERE id=%s", (reservation_id,))
        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()

@app.route("/api/payment/process", methods=["POST"])
def process_payment():
    data = request.get_json(silent=True) or {}
    montant = data.get("montant", 0)
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("INSERT INTO paiements (montant,statut,type) VALUES (%s,'paid','parking')", (montant,))
            new_id = cursor.lastrowid
        db.commit()
        return jsonify({"success": True, "transaction_id": f"PAY-{new_id}", "montant": montant})
    finally:
        db.close()

@app.route("/api/stationnement/actif", methods=["GET"])
def get_stationnement_actif():
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT s.*, v.matricule, p.numero 
                FROM stationnements s 
                LEFT JOIN vehicules v ON s.vehicle_id=v.id 
                LEFT JOIN parking_spots p ON s.parking_spot_id=p.id 
                WHERE s.sortie IS NULL 
                LIMIT 1
            """)
            stat = cursor.fetchone()
        if not stat:
            return jsonify({"has_active": False, "stationnement": None})
        if stat.get("entree"):
            stat["entree"] = stat["entree"].isoformat()
        numero = stat.get("numero", "P0-00")
        niveau = int(numero[1]) if numero and len(numero) > 1 else 0
        return jsonify({
            "has_active": True,
            "stationnement": {
                "id": stat["id"],
                "vehicle_id": stat["vehicle_id"],
                "parking_spot_id": stat["parking_spot_id"],
                "entree": stat["entree"],
                "sortie": None,
                "plaque": stat.get("matricule"),
                "place_numero": numero,
                "niveau": niveau,
                "box": numero,
                "emplacement": f"Place {numero}",
                "date_entree": stat["entree"],
                "qr_code": f"PARKING:{stat.get('matricule')}:{stat['id']}",
                "rfid_ticket": f"RFID:{stat['id']}",
            }
        })
    finally:
        db.close()

@app.route("/api/vehicule/<string:plaque>/localisation", methods=["GET"])
def localiser_vehicule(plaque):
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT v.*, s.id as stat_id, s.parking_spot_id, p.numero 
                FROM vehicules v 
                LEFT JOIN stationnements s ON v.id=s.vehicle_id AND s.sortie IS NULL 
                LEFT JOIN parking_spots p ON s.parking_spot_id=p.id 
                WHERE v.matricule=%s
            """, (plaque,))
            result = cursor.fetchone()
        if not result:
            return jsonify({"trouve": False, "message": f"Véhicule {plaque} introuvable"}), 404
        if not result.get("stat_id"):
            return jsonify({"trouve": False, "message": f"Aucun stationnement actif pour {plaque}"}), 404
        numero = result.get("numero")
        niveau = int(numero[1]) if numero and len(numero) > 1 else 0
        return jsonify({
            "trouve": True,
            "vehicle_id": result["id"],
            "matricule": result["matricule"],
            "niveau": niveau,
            "place_id": result["parking_spot_id"],
            "place": numero,
            "message": f"Votre véhicule {plaque} est à la place {numero}",
        })
    finally:
        db.close()

# =========================================================
# ALPR — VÉRIFICATION PLAQUE
# =========================================================
@app.route("/api/plaque", methods=["POST"])
def recevoir_plaque():
    data = request.get_json() or {}
    plaque = data.get("plaque", "").strip().upper()
    poids = data.get("poids", 0)
    if not plaque:
        return jsonify({"success": False, "error": "Plaque manquante"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM liste_noire WHERE plaque=%s", (plaque,))
            blacklisted = cursor.fetchone()
            if blacklisted:
                cursor.execute(
                    "INSERT INTO alertes (type,message,niveau,source,vehicule_matricule) VALUES ('Intrusion vehicule',%s,'Critique','ALPR',%s)",
                    (f"Véhicule en liste noire : {plaque} - {blacklisted['raison']}", plaque)
                )
                db.commit()
                return jsonify({"success": True, "action": "REFUS", "plaque": plaque, "raison": blacklisted["raison"]})
            cursor.execute("SELECT * FROM vehicules WHERE matricule=%s AND suspect=1", (plaque,))
            suspect = cursor.fetchone()
            if suspect:
                cursor.execute(
                    "INSERT INTO alertes (type,message,niveau,source,vehicule_matricule) VALUES ('Intrusion vehicule',%s,'Critique','ALPR',%s)",
                    (f"Véhicule suspect : {plaque}", plaque)
                )
                db.commit()
                return jsonify({"success": True, "action": "REFUS", "plaque": plaque, "raison": "Véhicule suspect"})
        return jsonify({"success": True, "action": "OUVRIR", "plaque": plaque})
    finally:
        db.close()

# =========================================================
# RFID SORTIE
# =========================================================
@app.route("/api/rfid/verifier", methods=["POST"])
def verifier_rfid():
    data = request.get_json() or {}
    uid = data.get("uid", "").strip().upper()
    if not uid:
        return jsonify({"autorise": False, "error": "UID manquant"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            # Vérifier liste noire uniquement
            cursor.execute("SELECT * FROM liste_noire WHERE plaque=%s", (uid,))
            if cursor.fetchone():
                return jsonify({"autorise": False, "raison": "Liste noire"})
            # Enregistrer le badge s'il n'existe pas encore
            cursor.execute("INSERT IGNORE INTO vehicules (matricule) VALUES (%s)", (uid,))
        db.commit()
        # Pour la démo : tous les badges non blacklistés sont autorisés
        return jsonify({"autorise": True, "vehicule": uid})
    finally:
        db.close()

# =========================================================
# ÉTAT TEMPS RÉEL
# =========================================================
etat_parking = {
    "barriere": "fermee",
    "derniere_plaque": None,
    "dernier_poids": 0,
    "etage_cible": 0,
    "ascenseur_niveau": 0,
    "sortie_demandee": False,
    "uid_sortie": None
}

@app.route("/api/etat", methods=["GET"])
def get_etat():
    return jsonify(etat_parking)

@app.route("/api/etat", methods=["POST"])
def update_etat():
    data = request.get_json() or {}
    etat_parking.update(data)
    return jsonify({"success": True, "etat": etat_parking})

# =========================================================
# ENTRÉE — enregistre + marque place occupée
# =========================================================
@app.route("/api/entree", methods=["POST"])
def enregistrer_entree():
    data = request.get_json() or {}
    matricule = data.get("matricule", "").upper()
    poids = data.get("poids", 0)
    etage = data.get("etage", 0)
    if not matricule:
        return jsonify({"success": False, "error": "Matricule manquant"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            # Insérer véhicule si nouveau
            cursor.execute("INSERT IGNORE INTO vehicules (matricule, poids) VALUES (%s,%s)", (matricule, poids))
            cursor.execute("SELECT id FROM vehicules WHERE matricule=%s", (matricule,))
            veh = cursor.fetchone()
            # Trouver place libre à cet étage
            # Places des capteurs de présence par étage
            capteur_places = {0: 'P0-02', 1: 'P1-03', 2: 'P2-02'}
            numero_cible = capteur_places.get(etage)
            if numero_cible:
                cursor.execute("SELECT * FROM parking_spots WHERE numero=%s AND statut='Libre' LIMIT 1", (numero_cible,))
                spot = cursor.fetchone()
            else:
                spot = None
            # Fallback : n'importe quelle place libre à cet étage
            if not spot:
                cursor.execute("SELECT * FROM parking_spots WHERE statut='Libre' AND niveau=%s LIMIT 1", (etage,))
                spot = cursor.fetchone()
            if not spot:
                return jsonify({"success": False, "error": "Aucune place libre"}), 409
            # Marquer occupée
            cursor.execute("UPDATE parking_spots SET statut='Occupée' WHERE id=%s", (spot["id"],))
            rfid = f"RFID-{matricule}-{int(datetime.now().timestamp())}"
            cursor.execute(
                "INSERT INTO stationnements (matricule,vehicle_id,parking_spot_id,poids,etage,rfid_ticket) VALUES (%s,%s,%s,%s,%s,%s)",
                (matricule, veh["id"], spot["id"], poids, etage, rfid)
            )
        db.commit()
        return jsonify({"success": True, "place": spot["numero"], "etage": etage, "rfid": rfid})
    finally:
        db.close()

# =========================================================
# SORTIE — libère automatiquement la place
# =========================================================
@app.route("/api/sortie", methods=["POST"])
def enregistrer_sortie():
    data = request.get_json() or {}
    matricule = data.get("matricule", "").upper()
    if not matricule:
        return jsonify({"success": False, "error": "Matricule manquant"}), 400
    db = get_db()
    try:
        with db.cursor() as cursor:
            # Trouver stationnement actif
            cursor.execute("""
                SELECT * FROM stationnements 
                WHERE matricule=%s AND sortie IS NULL 
                ORDER BY entree DESC LIMIT 1
            """, (matricule,))
            stat = cursor.fetchone()
            if not stat:
                return jsonify({"success": False, "error": "Aucun stationnement actif"}), 404
            # Enregistrer l'heure de sortie
            cursor.execute("UPDATE stationnements SET sortie=NOW() WHERE id=%s", (stat["id"],))
            # ← LIBÉRER LA PLACE AUTOMATIQUEMENT
            cursor.execute("UPDATE parking_spots SET statut='Libre' WHERE id=%s", (stat["parking_spot_id"],))
        db.commit()
        return jsonify({
            "success": True,
            "message": f"Sortie enregistrée pour {matricule}",
            "place_liberee": stat["parking_spot_id"]
        })
    finally:
        db.close()

@app.route("/api/sortie/demande", methods=["POST"])
def demande_sortie():
    data = request.get_json() or {}
    uid = data.get("uid", "").strip().upper()
    etat_parking["sortie_demandee"] = True
    etat_parking["uid_sortie"] = uid
    return jsonify({"success": True})



# =========================================================
# CAPTEURS — ALERTES AUTO DEPUIS RASPI
# =========================================================

@app.route("/api/alerte/capteur", methods=["POST"])
def creer_alerte_capteur():
    """Appelé par le Raspi quand un capteur tombe offline."""
    data = request.get_json() or {}
    capteur_id  = data.get("capteur_id")
    capteur_nom = data.get("capteur_nom", "Inconnu")
    etage       = data.get("etage", 0)
    message     = data.get("message", f"Capteur {capteur_nom} hors ligne")
    niveau      = data.get("niveau", "Warning")

    db = get_db()
    try:
        with db.cursor() as cursor:
            # Vérifier qu'une alerte non résolue n'existe pas déjà
            cursor.execute("""
                SELECT id FROM alertes 
                WHERE type='Capteur' 
                AND capteur_nom=%s 
                AND resolue=0 
                LIMIT 1
            """, (capteur_nom,))
            existing = cursor.fetchone()
            if existing:
                return jsonify({"success": True, "message": "Alerte déjà existante", "id": existing["id"]})

            # Créer l'alerte
            cursor.execute("""
                INSERT INTO alertes 
                (type, message, niveau, source, capteur_nom, parking_level) 
                VALUES ('Capteur', %s, %s, 'Raspberry Pi', %s, %s)
            """, (message, niveau, capteur_nom, f"Étage {etage}"))

            alerte_id = cursor.lastrowid

            # Mettre à jour le statut du capteur dans la table capteurs
            if capteur_id:
                cursor.execute(
                    "UPDATE capteurs SET statut='offline' WHERE id=%s",
                    (capteur_id,)
                )

        db.commit()
        return jsonify({"success": True, "alerte_id": alerte_id})
    finally:
        db.close()


@app.route("/api/alerte/capteur/resoudre", methods=["POST"])
def resoudre_alerte_capteur():
    """Appelé par le Raspi quand le capteur revient online."""
    data = request.get_json() or {}
    capteur_id  = data.get("capteur_id")
    capteur_nom = data.get("capteur_nom", "")

    db = get_db()
    try:
        with db.cursor() as cursor:
            # Résoudre toutes les alertes non résolues pour ce capteur
            cursor.execute("""
                UPDATE alertes SET resolue=1 
                WHERE type='Capteur' AND capteur_nom=%s AND resolue=0
            """, (capteur_nom,))

            # Remettre le capteur online
            if capteur_id:
                cursor.execute(
                    "UPDATE capteurs SET statut='online' WHERE id=%s",
                    (capteur_id,)
                )

        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()


@app.route("/api/capteur/statut", methods=["POST"])
def update_capteur_statut():
    """Met à jour le statut d'un capteur (online/offline)."""
    data = request.get_json() or {}
    capteur_id = data.get("capteur_id")
    statut     = data.get("statut", "online")

    if not capteur_id:
        return jsonify({"success": False, "error": "capteur_id manquant"}), 400

    db = get_db()
    try:
        with db.cursor() as cursor:
            cursor.execute(
                "UPDATE capteurs SET statut=%s WHERE id=%s",
                (statut, capteur_id)
            )
        db.commit()
        return jsonify({"success": True})
    finally:
        db.close()

if __name__ == "__main__":
    print("Smart Parking API v3.1 — utf8mb4 + sortie auto + véhicules enrichis")
    app.run(host="0.0.0.0", port=5000, debug=True)
