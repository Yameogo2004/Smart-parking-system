#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>
#include <WiFi.h>
#include <WebServer.h>

const char* SSID     = "TON WIFI";
const char* PASSWORD = "TON MOT DE PASSE";

#define SERVO_PIN    18
#define ANGLE_FERME   0
#define ANGLE_OUVERT 90

LiquidCrystal_I2C lcd(0x27, 16, 2);
Servo barriere;
WebServer server(80);

bool barriereOuverte       = false;
unsigned long dernierLCD   = 0;
unsigned long timerAction  = 0;
int etapeLCD               = 0;
int etapeAction            = 0; // étape courante de la séquence

struct MessageLCD { const char* ligne1; const char* ligne2; };
MessageLCD messages[] = {
  {"   BIENVENUE",   "  AU PARKING   "},
  {"  OUVERT 24/7",  " BONNE VISITE  "},
  {" SUIVEZ LES",    " INSTRUCTIONS  "},
};
const int NB_MESSAGES = 3;

void afficherMessage(const char* l1, const char* l2) {
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print(l1);
  lcd.setCursor(0, 1); lcd.print(l2);
}

// ── Séquence ouverture non bloquante ────────────────────────
// étape 0 : idle
// étape 1 : servo ouvert → attendre 500ms
// étape 2 : afficher "ACCES AUTORISE" → attendre 1000ms
// étape 3 : afficher "AVANCEZ SVP" → fin
String plaqueCourante = "";

void ouvrirBarriere(String plaque) {
  Serial.println(">>> OUVERTURE BARRIERE");
  plaqueCourante = plaque;
  barriere.write(ANGLE_OUVERT);
  barriereOuverte = true;
  etapeAction = 1;
  timerAction = millis();
}

void fermerBarriere() {
  Serial.println(">>> FERMETURE BARRIERE");
  barriere.write(ANGLE_FERME);
  barriereOuverte = false;
  etapeAction = 4;
  timerAction = millis();
}

// ── Gestion des séquences non bloquantes ────────────────────
void gererSequence() {
  unsigned long now = millis();

  switch (etapeAction) {
    case 1: // servo vient d'ouvrir → attendre 500ms puis afficher
      if (now - timerAction >= 500) {
        lcd.clear();
        lcd.setCursor(0, 0); lcd.print("ACCES AUTORISE  ");
        lcd.setCursor(0, 1); lcd.print(plaqueCourante.substring(0, 16));
        timerAction = now;
        etapeAction = 2;
      }
      break;

    case 2: // attendre 1000ms puis afficher "AVANCEZ"
      if (now - timerAction >= 1000) {
        lcd.clear();
        lcd.setCursor(0, 0); lcd.print("BARRIERE OUVERTE");
        lcd.setCursor(0, 1); lcd.print("AVANCEZ SVP...  ");
        etapeAction = 0; // fin de séquence ouverture
      }
      break;

    case 4: // barrière vient de fermer → afficher "MERCI"
      if (now - timerAction >= 0) {
        lcd.clear();
        lcd.setCursor(0, 0); lcd.print("MERCI !         ");
        lcd.setCursor(0, 1); lcd.print("BONNE JOURNEE   ");
        timerAction = now;
        etapeAction = 5;
      }
      break;

    case 5: // attendre 2000ms puis retour messages normaux
      if (now - timerAction >= 2000) {
        etapeLCD = 0;
        dernierLCD = now;
        afficherMessage(messages[0].ligne1, messages[0].ligne2);
        etapeAction = 0;
      }
      break;

    default:
      break;
  }
}

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);
  lcd.init();
  lcd.backlight();
  afficherMessage("  DEMARRAGE...  ", "  PATIENCE...   ");

  ESP32PWM::allocateTimer(0);
  barriere.setPeriodHertz(50);
  barriere.attach(SERVO_PIN, 544, 2400);
  barriere.write(ANGLE_FERME);

  WiFi.begin(SSID, PASSWORD);
  int t = 0;
  while (WiFi.status() != WL_CONNECTED && t < 20) {
    delay(500); Serial.print("."); t++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nIP : " + WiFi.localIP().toString());
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("WiFi OK !       ");
    lcd.setCursor(0, 1); lcd.print(WiFi.localIP().toString());
    delay(2000);
  }

  server.on("/commande", HTTP_POST, []() {
    String body = server.arg("plain");
    Serial.println("Commande : " + body);
    if (body.startsWith("BAR:OPEN")) {
      String plaque = "";
      int idx = body.indexOf(":", 9);
      if (idx != -1) plaque = body.substring(idx + 1);
      plaque.trim();
      ouvrirBarriere(plaque);
      server.send(200, "application/json", "{\"success\":true}");
    } else if (body == "BAR:CLOSE") {
      fermerBarriere();
      server.send(200, "application/json", "{\"success\":true}");
    } else {
      server.send(400, "application/json", "{\"error\":\"inconnu\"}");
    }
  });

  server.on("/status", HTTP_GET, []() {
    String json = "{\"barriere\":\"";
    json += barriereOuverte ? "ouverte" : "fermee";
    json += "\"}";
    server.send(200, "application/json", json);
  });

  server.begin();
  afficherMessage(messages[0].ligne1, messages[0].ligne2);
  dernierLCD = millis();
  Serial.println("=== ESP32 ENTREE PRET ===");
}

void loop() {
  server.handleClient();   // ← toujours disponible, jamais bloqué
  gererSequence();         // ← gère LCD et servo sans delay

  // Rotation messages si barrière fermée et pas de séquence active
  if (!barriereOuverte && etapeAction == 0) {
    if (millis() - dernierLCD >= 3000) {
      etapeLCD = (etapeLCD + 1) % NB_MESSAGES;
      afficherMessage(messages[etapeLCD].ligne1, messages[etapeLCD].ligne2);
      dernierLCD = millis();
    }
  }
}
