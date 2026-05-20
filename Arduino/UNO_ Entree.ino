#include <Wire.h>
#include <Servo.h>
#include "HX711.h"

#define UNO_ADDR 0x08

Servo barriere;

#define DT 4
#define SCK 5
HX711 balance;

int IR1 = 2;
int IR2 = 6;
int IR3 = 8;
int IR4 = 9;

#define TRIG 11
#define ECHO 10

int LINE1 = A1;
int LINE2 = A3;
int LDR = A0;
int LED = 7;

float poids = 0;
float distance = 0;
int lumiere = 0;
int ligne1 = 0;
int ligne2 = 0;

String commandeRecue = "";

void setup() {
  Serial.begin(9600);
  pinMode(IR1, INPUT);
  pinMode(IR2, INPUT);
  pinMode(IR3, INPUT);
  pinMode(IR4, INPUT);
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);
  pinMode(LED, OUTPUT);
  barriere.attach(3);
  barriere.write(0);
  balance.begin(DT, SCK);
  balance.set_scale(2280.f);
  balance.tare();
  Wire.begin(UNO_ADDR);
  Wire.onReceive(recevoirCommande);
  Wire.onRequest(envoyerDonnees);
  Serial.println("=== UNO CAPTEURS + BARRIERE I2C ===");
}

void loop() {
  lumiere = analogRead(LDR);
  if (lumiere < 500) digitalWrite(LED, HIGH);
  else digitalWrite(LED, LOW);
  poids = balance.get_units(5);
  distance = lireDistance();
  ligne1 = analogRead(LINE1);
  ligne2 = analogRead(LINE2);
  traiterCommande();
  delay(200);
}

float lireDistance() {
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);
  long duree = pulseIn(ECHO, HIGH, 30000);
  if (duree == 0) return 999;
  return duree * 0.034 / 2;
}

void recevoirCommande(int nbOctets) {
  commandeRecue = "";
  while (Wire.available()) {
    char c = Wire.read();
    if (c != 0) commandeRecue += c;
  }
  commandeRecue.trim();
}

void traiterCommande() {
  if (commandeRecue.length() == 0) return;
  Serial.print("Commande Raspberry : ");
  Serial.println(commandeRecue);
  if (commandeRecue == "BAR:OPEN") {
    barriere.write(90);
    Serial.println("Barriere OUVERTE");
  }
  if (commandeRecue == "BAR:CLOSE") {
    barriere.write(0);
    Serial.println("Barriere FERMEE");
  }
  commandeRecue = "";
}

void envoyerDonnees() {
  int ir1 = digitalRead(IR1);
  int ir2 = digitalRead(IR2);
  int ir3 = digitalRead(IR3);
  int ir4 = digitalRead(IR4);
  int dist = (int)distance;
  int l1 = ligne1 < 500 ? 0 : 1;
  int l2 = ligne2 < 500 ? 0 : 1;
  // Format court → reste sous 32 bytes
  char msg[32];
  snprintf(msg, 32, "%d%d%d%d;%d;%d;%d;%d",
           ir1, ir2, ir3, ir4,
           (int)poids, dist, l1, l2);
  Wire.write((uint8_t*)msg, 32);
}
