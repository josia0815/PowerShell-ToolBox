# PowerShell-ToolBox

## Modul 122 – Abläufe mit einer Scriptsprache automatisieren  
**LB2 Praktische Umsetzungsarbeit**

---

## Projektübersicht

**PowerShell-ToolBox** ist ein modulares PowerShell-Skript zur automatisierten Einrichtung, Wartung und Anpassung eines Windows-Clients.  
Das Projekt richtet sich an den praktischen Einsatz im Home- und Support-Umfeld und fokussiert sich auf saubere Automatisierung, Wiederverwendbarkeit und Dokumentation.

Das Skript erinnert konzeptionell an bekannte Windows-Tweaking-Tools (z. B. Setup- oder Maintenance-Tools), ist jedoch vollständig eigenständig entwickelt und auf die Anforderungen des Moduls M122 abgestimmt.

---

## Zielsetzung

- Automatisierung wiederkehrender Windows-Client-Aufgaben
- Reduktion manueller Installations- und Wartungsschritte
- Klare Trennung von Logik, Konfiguration und Ausführung
- Nachvollziehbare Umsetzung gemäss Modulvorgaben M122

---

## Funktionsumfang

### Hauptfunktionen
- **Applikationsinstallation** über `winget` (konfigurierbar via JSON)
- **Cleanup / Wartung**
  - Temporäre Dateien
  - Papierkorb
  - optionale Download-Bereinigung
- **Windows-Tweaks**
  - Anzeige von Dateiendungen
  - Energieoptionen
  - weitere optionale Systemeinstellungen
- **Custom Script Runner**
  - Ausführung benutzerdefinierter PowerShell-Skripte

---

## Projektstruktur
PowerShell-ToolBox/
├── PowerShell-ToolBox.ps1
├── modules/
├── config/
├── diagrams/
├── docs/
├── logs/
├── test/
└── CustomScripts/

**PowerShell-ToolBox.ps1**  
  Einstiegspunkt, Menüführung, Modulaufrufe

- **modules/**  
  Funktional getrennte PowerShell-Module (Installation, Cleanup, Tweaks, Logging)

- **config/**  
  JSON-Konfigurationsdateien (Apps, Tweaks)

- **diagrams/**  
  Struktogramme und Flussdiagramme zur Ablaufdarstellung

- **docs/**  
  Projektdokumentation gemäss LB2-Meilensteinen

- **logs/**  
  Laufzeitlogs (nicht versioniert)

- **test/**  
  Testdaten und Testprotokolle

---

## Ausführung

```powershell
.\PowerShell-ToolBox.ps1

## Parameter

Das Skript **PowerShell-ToolBox.ps1** unterstützt optionale Parameter zur Steuerung der Ausführung und zur sicheren Nutzung während Tests.

### Unterstützte Parameter

- **-WhatIf**  
  Führt das Skript im Testmodus aus.  
  Es werden keine Änderungen am System vorgenommen, sondern nur angezeigt, welche Aktionen ausgeführt *würden*.  
  *Einsatz:* Testen der Logik ohne Risiko.

- **-Confirm**  
  Erzwingt eine Benutzerbestätigung vor kritischen Aktionen (z. B. Software-Installation, System-Tweaks, Cleanup).  
  *Einsatz:* Erhöhte Sicherheit bei produktiver Nutzung.

- **-Verbose**  
  Gibt detaillierte Zusatzinformationen zur Programmausführung aus.  
  *Einsatz:* Debugging, Fehlersuche, Fachgespräch.

- **-ConfigPath** *(optional)*  
  Pfad zu einer alternativen Konfigurationsdatei (Standard: `config/`).  
  *Einsatz:* Erweiterbarkeit und Wiederverwendbarkeit.

- **-LogPath** *(optional)*  
  Zielpfad für Logdateien (Standard: `logs/`).  
  *Einsatz:* Anpassung an unterschiedliche Umgebungen.

---

## Voraussetzungen

Für die Ausführung der **PowerShell-ToolBox** müssen folgende Voraussetzungen erfüllt sein:

### System
- Windows 10 oder Windows 11
- PowerShell Version **5.1 oder höher**

### Software / Tools
- **winget (Windows Package Manager)**  
  Wird für die automatisierte Installation und Aktualisierung von Applikationen verwendet.

### Berechtigungen
- Administratorrechte erforderlich für:
  - Software-Installationen
  - System- und Registry-Tweaks
  - Bestimmte Wartungs- und Cleanup-Funktionen

### Empfohlene Entwicklungswerkzeuge
- Visual Studio Code mit PowerShell-Erweiterung
- Git / GitHub für Versionskontrolle

---

## Dokumentation

Die Projektdokumentation ist vollständig im Repository integriert und gemäss den Meilensteinen der LB2 strukturiert.

### Dokumentationsstruktur (`docs/`)

- **01_Anforderungsdefinition.md**  
  Beschreibung der Automatisierungsaufgabe, Zielsetzung und Mehrwert.

- **02_Loesungsdesign.md**  
  Technisches Design, Modularchitektur und Ablaufmodelle.

- **03_Implementation.md**  
  Beschreibung der Umsetzung, Code-Struktur und eingesetzter Techniken.

- **04_Testprotokoll.md**  
  Dokumentation der durchgeführten Tests, Testfälle und Resultate.

- **05_Reflexion.md**  
  Persönlicher Lerngewinn, Selbsteinschätzung und Optimierungspotenzial.

---

## Diagramme

Grafische Darstellungen der Ablaufstruktur befinden sich im Ordner `diagrams/`:

- **Struktogramm** des Hauptablaufs (Menü und Modulsteuerung)
- **Flussdiagramme** der einzelnen Module (z. B. App-Installation)

Die Diagramme visualisieren die Ablaufstruktur gemäss den Anforderungen des Moduls **M122**.

---

## Sicherheit und Qualität

- Keine sensiblen oder systemspezifischen Daten im Repository
- Logdateien werden lokal erzeugt und sind über `.gitignore` ausgeschlossen
- Konfigurationsdaten sind ausgelagert (JSON)
- Modularer Aufbau zur besseren Wartbarkeit
- Kontrollierte Fehlerbehandlung und zentrales Logging

---

## Autor

- **Name:** *Josia Gisiger*  
- **Klasse:** *ICT23e*  
- **Modul:** M122 – Abläufe mit einer Scriptsprache automatisieren  
- **Arbeit:** LB2 Praktische Umsetzungsarbeit  
- **Projektname:** PowerShell-ToolBox  
- **Schule:** *TBZ*  
- **Datum:** *22.01.2026*

---

## Versionskontrolle

Dieses Projekt wird mit **Git/GitHub** versioniert.  
Der Commit-Verlauf dokumentiert den Entwicklungsprozess und ermöglicht eine transparente Nachvollziehbarkeit der einzelnen Arbeitsschritte.

