# WARA Light - Azure Resiliency Recommendations Exporter

Dieses Projekt extrahiert automatisch alle Empfehlungen aus dem [Azure Proactive Resiliency Library v2](https://github.com/Azure/Azure-Proactive-Resiliency-Library-v2) Repository und exportiert sie in eine CSV-Datei.

## Funktionsweise

1. Die GitHub Action checkt das Azure-Repository aus
2. Ein Python-Skript durchsucht alle `recommendations.yaml` Dateien
3. Alle Empfehlungen werden in eine CSV-Datei mit Zeitstempel geschrieben
4. Die CSV-Datei wird automatisch in den `results/` Ordner committed

## Projektstruktur

```
wara-light/
├── .github/workflows/
│   └── process-recommendations.yml   # GitHub Action Workflow
├── scripts/
│   └── process_recommendations.py    # Python-Verarbeitungsskript
├── results/                          # Ausgabeverzeichnis für CSV-Dateien
├── requirements.txt                  # Python-Abhängigkeiten
└── README.md
```

## GitHub Action

Die Action wird ausgeführt:
- **Manuell**: Actions → "Process Azure Resiliency Recommendations" → "Run workflow"
- **Automatisch**: Täglich um 6:00 UTC

## Lokale Ausführung

```bash
# Repository klonen
git clone https://github.com/Azure/Azure-Proactive-Resiliency-Library-v2.git azure-resiliency-library

# Abhängigkeiten installieren
pip install -r requirements.txt

# Skript ausführen
python scripts/process_recommendations.py azure-resiliency-library
```

## CSV-Ausgabe

Die generierte CSV-Datei enthält alle Felder aus den `recommendations.yaml` Dateien, darunter:
- `description` - Beschreibung der Empfehlung
- `aprlGuid` - Eindeutige ID
- `recommendationTypeId` - Typ der Empfehlung
- `recommendationImpact` - Auswirkung (High/Medium/Low)
- `recommendationResourceType` - Betroffener Azure-Ressourcentyp
- `query` - KQL-Abfrage zur Identifikation betroffener Ressourcen
- `_source_file` - Quelldatei der Empfehlung

Dateiname-Format: `recommendations_YYYY-MM-DD_HH-MM-SS.csv`
