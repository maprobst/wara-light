# WARA Light - Azure Resiliency Tools

Dieses Projekt bietet zwei GitHub Actions zur Arbeit mit Azure Resiliency-Tools:

1. **Recommendations Exporter** - Extrahiert Empfehlungen aus dem Azure Proactive Resiliency Library v2
2. **WARA Assessment** - Führt das Well-Architected Reliability Assessment aus

## Projektstruktur

```
wara-light/
├── .github/workflows/
│   ├── process-recommendations.yml   # Recommendations Export Workflow
│   └── run-wara-assessment.yml       # WARA Assessment Workflow
├── scripts/
│   ├── process_recommendations.py    # Python-Verarbeitungsskript
│   └── run_wara.ps1                  # PowerShell WARA-Skript
├── results/                          # Ausgabeverzeichnis
├── requirements.txt                  # Python-Abhängigkeiten
└── README.md
```

---

## 1. Recommendations Exporter

Extrahiert automatisch alle Empfehlungen aus dem [Azure Proactive Resiliency Library v2](https://github.com/Azure/Azure-Proactive-Resiliency-Library-v2) Repository und exportiert sie in eine CSV-Datei.

### Funktionsweise

1. Die GitHub Action checkt das Azure-Repository aus
2. Ein Python-Skript durchsucht alle `recommendations.yaml` Dateien
3. Alle Empfehlungen werden in eine CSV-Datei mit Zeitstempel geschrieben
4. Die CSV-Datei wird automatisch in den `results/` Ordner committed

### GitHub Action

Die Action wird ausgeführt:
- **Manuell**: Actions → "Process Azure Resiliency Recommendations" → "Run workflow"
- **Automatisch**: Täglich um 6:00 UTC

### Lokale Ausführung

```bash
# Repository klonen
git clone https://github.com/Azure/Azure-Proactive-Resiliency-Library-v2.git azure-resiliency-library

# Abhängigkeiten installieren
pip install -r requirements.txt

# Skript ausführen
python scripts/process_recommendations.py azure-resiliency-library
```

### CSV-Ausgabe

Die generierte CSV-Datei enthält alle Felder aus den `recommendations.yaml` Dateien, darunter:
- `description` - Beschreibung der Empfehlung
- `aprlGuid` - Eindeutige ID
- `recommendationTypeId` - Typ der Empfehlung
- `recommendationImpact` - Auswirkung (High/Medium/Low)
- `recommendationResourceType` - Betroffener Azure-Ressourcentyp
- `query` - KQL-Abfrage zur Identifikation betroffener Ressourcen
- `_source_file` - Quelldatei der Empfehlung

Dateiname-Format: `recommendations_YYYY-MM-DD_HH-MM-SS.csv`

---

## 2. WARA Assessment

Führt das [Well-Architected Reliability Assessment (WARA)](https://github.com/Azure/Well-Architected-Reliability-Assessment) aus.

### Funktionsweise

1. Die GitHub Action checkt das WARA-Repository aus
2. Ein PowerShell-Skript wird ausgeführt, das den Pfad zum WARA-Repository erhält
3. Das Skript importiert das WARA-Modul und kann die WARA-Tools ausführen
4. Ergebnisse werden in den `results/` Ordner committed

### GitHub Action

Die Action wird ausgeführt:
- **Manuell**: Actions → "Run WARA Assessment" → "Run workflow"
  - Optionale Parameter: Subscription ID, Resource Group
- **Automatisch**: Wöchentlich Montags um 7:00 UTC

### Lokale Ausführung

```powershell
# Repository klonen
git clone https://github.com/Azure/Well-Architected-Reliability-Assessment.git wara-repo

# Skript ausführen
./scripts/run_wara.ps1 -WaraRepoPath ./wara-repo
```

### WARA-Funktionen

Das WARA-Modul bietet drei Hauptfunktionen:
- **Start-WARACollector** - Sammelt Daten aus Azure-Ressourcen
- **Start-WARAAnalyzer** - Analysiert die gesammelten Daten
- **Start-WARAReport** - Generiert PowerPoint- und Excel-Reports
