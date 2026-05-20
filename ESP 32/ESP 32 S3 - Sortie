#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>

// ========== WiFi ==========
const char* ssid      = "TON WIFI";
const char* password  = "TON MOT DE PASSE";
const char* FLASK_API = "http://192.168.76.138:5000";

// ========== BROCHES ==========
#define RFID_SS    21
#define RFID_RST   14
#define SERVO_PIN   5
#define I2C_SDA     8
#define I2C_SCL     9
#define IR_PIN      6
#define IR5_PIN    10
#define IR_PRES     7

// ========== BADGES AUTORISÉS ==========
String badgesAutorises[] = {
  "0C46F106",
  "D3A7BD27",
  "E306DC2A",
  "02A50F1B",
  "938F6306"
};
int nbBadges = 5;

// ========== CONSTANTES ==========
const int ANGLE_OUVERT    = 90;
const int ANGLE_FERME     = 0;
const int DELAI_FERMETURE = 30000;

// ========== OBJETS ==========
MFRC522 rfid(RFID_SS, RFID_RST);
LiquidCrystal_I2C lcd(0x27, 16, 2);
Servo barriere;
WebServer server(80);

// ========== VARIABLES ==========
unsigned long tempsOuverture  = 0;
bool barriereOuverte          = false;
bool lcdAllume                = false;
int  dernierEtatPresence      = HIGH;

// ============================================================
// BADGE LOCAL
// ============================================================
bool verifierBadgeLocal(String uid) {
  for (int i = 0; i < nbBadges; i++) {
    if (uid == badgesAutorises[i]) return true;
  }
  return false;
}

// ============================================================
// LCD
// ============================================================
void allumerLCD() {
  if (!lcdAllume) {
    lcd.backlight();
    lcdAllume = true;
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Barriere fermee ");
    lcd.setCursor(0, 1); lcd.print("Badge pour sortir");
    Serial.println("[LCD] Allume");
  }
}

void eteindreLCD() {
  if (lcdAllume) {
    lcd.noBacklight();
    lcdAllume = false;
    Serial.println("[LCD] Eteint");
  }
}

// ============================================================
// FLASK
// ============================================================
void notifierRaspberry(String uid) {
  if (WiFi.status() != WL_CONNECTED) return;
  HTTPClient http;
  http.begin(String(FLASK_API) + "/api/sortie/demande");
  http.addHeader("Content-Type", "application/json");
  String body = "{\"uid\":\"" + uid + "\"}";
  http.POST(body);
  http.end();
}

// ============================================================
// BARRIERE
// ============================================================
void ouvrirBarriere() {
  if (!barriereOuverte) {
    Serial.println(">>> OUVERTURE barriere sortie");
    barriere.write(ANGLE_OUVERT);
    barriereOuverte = true;
    tempsOuverture  = millis();
    allumerLCD();
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Bonne route !   ");
    lcd.setCursor(0, 1); lcd.print("Au revoir !     ");
  }
}

void fermerBarriere() {
  if (barriereOuverte) {
    Serial.println(">>> FERMETURE barriere sortie");
    barriere.write(ANGLE_FERME);
    barriereOuverte = false;
    allumerLCD();
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Barriere fermee ");
    lcd.setCursor(0, 1); lcd.print("Badge pour sortir");
  }
}

// ============================================================
// ROUTES HTTP
// ============================================================
void setupRoutes() {
  server.on("/capteurs", HTTP_GET, []() {
    int ir       = digitalRead(IR_PIN);
    int ir5      = digitalRead(IR5_PIN);
    int presence = digitalRead(IR_PRES);
    String json  = "{\"IR_SORTIE\":" + String(ir) +
                   ",\"IR5\":"       + String(ir5) +
                   ",\"IR_PRES\":"   + String(presence) + "}";
    server.send(200, "application/json", json);
  });

  server.on("/commande", HTTP_POST, []() {
    String body = server.arg("plain");
    if (body.indexOf("BAR:OPEN")  >= 0) ouvrirBarriere();
    if (body.indexOf("BAR:CLOSE") >= 0) fermerBarriere();
    server.send(200, "application/json", "{\"success\":true}");
  });
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);
  delay(500);

  pinMode(IR_PIN,  INPUT);
  pinMode(IR5_PIN, INPUT);
  pinMode(IR_PRES, INPUT);

  Wire.begin(I2C_SDA, I2C_SCL);
  lcd.init();
  lcd.backlight();
  lcdAllume = true;
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print("Connexion WiFi  ");

  barriere.attach(SERVO_PIN);
  barriere.write(ANGLE_FERME);

  SPI.begin(19, 11, 20, RFID_SS);
  rfid.PCD_Init();

  WiFi.begin(ssid, password);
  int tentatives = 0;
  while (WiFi.status() != WL_CONNECTED && tentatives < 20) {
    delay(500);
    Serial.print(".");
    tentatives++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi OK ! IP : " + WiFi.localIP().toString());
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("IP:             ");
    lcd.setCursor(0, 1); lcd.print(WiFi.localIP().toString());
    delay(3000);
  } else {
    Serial.println("\nWiFi ECHEC");
  }

  setupRoutes();
  server.begin();

  lcd.clear();
  lcd.setCursor(0, 0); lcd.print("Barriere fermee ");
  lcd.setCursor(0, 1); lcd.print("Badge pour sortir");

  Serial.println("=== ESP32 SORTIE PRET ===");
}

// ============================================================
// LOOP — ascenseur supprimé, géré par Raspi via Nano I2C
// ============================================================
void loop() {
  server.handleClient();

  // IR présence pin 7 → allume/éteint LCD
  int presence = digitalRead(IR_PRES);
  if (presence != dernierEtatPresence) {
    if (presence == LOW) {
      allumerLCD();
    } else {
      if (!barriereOuverte) eteindreLCD();
    }
    dernierEtatPresence = presence;
  }

  // Fermeture barrière après passage IR5
  if (barriereOuverte) {
    int ir5 = digitalRead(IR5_PIN);
    if (ir5 == LOW) {
      Serial.println(">>> IR5 : Voiture passee → Fermeture");
      delay(1500);
      fermerBarriere();
    }
    if (millis() - tempsOuverture > DELAI_FERMETURE) {
      Serial.println(">>> Fermeture auto timeout 30s");
      fermerBarriere();
    }
  }

  // Lecture badge RFID
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    delay(50);
    return;
  }

  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) uid += "0";
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  Serial.println("Badge : " + uid);

  allumerLCD();
  bool autorise = verifierBadgeLocal(uid);

  if (autorise) {
    Serial.println("Badge autorise");
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Acces autorise  ");
    lcd.setCursor(0, 1); lcd.print("A bientot !     ");
    notifierRaspberry(uid);
    ouvrirBarriere();
  } else {
    Serial.println("Badge refuse");
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Acces refuse    ");
    lcd.setCursor(0, 1); lcd.print("Badge invalide  ");
    delay(2000);
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print("Barriere fermee ");
    lcd.setCursor(0, 1); lcd.print("Badge pour sortir");
  }

  rfid.PICC_HaltA();
  delay(500);
}
