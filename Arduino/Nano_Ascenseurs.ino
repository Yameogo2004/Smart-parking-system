#include <Wire.h>
#include <Stepper.h>

#define NANO_ADDR 0x09

const int stepsPerRevolution = 2048;

Stepper moteur1(stepsPerRevolution, 5, 3, 4, 2);
Stepper moteur2(stepsPerRevolution, 6, 8, 7, 9);

const int PAS_PAR_ETAGE = 9100;
const int VITESSE_MOTEUR = 17;

int etageActuel1 = 0;
int etageActuel2 = 0;

String commandeRecue = "";

void setup() {
  Serial.begin(9600);
  moteur1.setSpeed(VITESSE_MOTEUR);
  moteur2.setSpeed(VITESSE_MOTEUR);
  Wire.begin(NANO_ADDR);
  Wire.onReceive(recevoirCommande);
  Serial.println("=== NANO ASCENSEUR I2C ===");
}

void loop() {
  traiterCommande();
  delay(100);
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
  if (commandeRecue.startsWith("A1:")) {
    int etage = commandeRecue.substring(3).toInt();
    deplacerAscenseur(moteur1, etageActuel1, etage);
  }
  if (commandeRecue.startsWith("A2:")) {
    int etage = commandeRecue.substring(3).toInt();
    deplacerAscenseur(moteur2, etageActuel2, etage);
  }
  commandeRecue = "";
}

void deplacerAscenseur(Stepper &moteur, int &etageActuel, int etageDemande) {
  if (etageDemande < 0 || etageDemande > 2) {
    Serial.println("Etage invalide");
    return;
  }
  if (etageDemande == etageActuel) {
    Serial.println("Ascenseur deja au bon etage");
    return;
  }
  int nombreDePas = (etageDemande - etageActuel) * PAS_PAR_ETAGE;
  Serial.print("Deplacement vers etage ");
  Serial.println(etageDemande);
  moteur.step(nombreDePas);
  etageActuel = etageDemande;
  Serial.print("Arret a l'etage ");
  Serial.println(etageActuel);
}
