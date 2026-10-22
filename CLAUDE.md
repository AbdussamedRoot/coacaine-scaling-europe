# CLAUDE.md – Projekt „Kokain-Skalierung“

## Worum es geht
Forschungsprojekt mit öffentlichen Abwasserdaten (EUDA/SCORE, 2011–2025): Skaliert der Drogenkonsum pro Kopf mit der Stadtgröße, und schrumpft der Großstadt-Vorsprung bei Kokain über die Zeit? Ziel ist ein Paper in einem Fachjournal. **Der vollständige Plan steht in `PROJEKTPLAN.md` – lies ihn, bevor du etwas tust, und halte dich daran.**

## Wer ich bin und wie du mit mir arbeitest
- Ich kann gut Mathe und lese Physik-Lehrbücher, bin aber neu in Statistik mit R.
- **Erkläre jeden Schritt auf Deutsch**, so dass ich ihn vor Reviewern verteidigen kann: was der Code macht, warum diese Methode, was die Zahlen bedeuten.
- Mach kleine Schritte. Nach jedem Schritt: Ergebnis zeigen, Prüfungen zeigen, kurz erklären, dann auf mein Okay warten.
- Wenn etwas im Plan unklar oder falsch ist: **frag mich**, statt still etwas anderes zu machen.

## Feste Regeln
1. **`data/raw/` wird nie verändert.** Bereinigte Daten nur nach `data/processed/`.
2. **Die Spezifikationen in `PROJEKTPLAN.md` §4 sind fix.** Änderungen nur nach Rückfrage, und jede Abweichung mit Datum und Begründung in `DECISIONS.md`.
3. Keine Analysen weglassen oder umbauen, weil ein Ergebnis nicht gefällt. Kein p-Hacking.
4. Zuerst die Vorab-Ergebnisse aus `PROJEKTPLAN.md` §6 reproduzieren (δ auf ±0,01), bevor neue Analysen kommen.
5. **Keine erfundenen Zitate oder Zahlen.** Literatur nur nennen, wenn ich sie geprüft habe; Zahlen im Text immer aus den Outputs.
6. Bei Zufall immer `set.seed(2026)`.
7. Code-Kommentare und Variablennamen auf Englisch, Erklärungen an mich auf Deutsch.
8. **Das Repo ist öffentlich.** Keine persönlichen Angaben über mich (z. B. Alter, Schule, Wohnort) in Dateien, Outputs oder Commit-Nachrichten.

## Technik
- Sprache: **R**. Pakete: readr, dplyr, tidyr, stringr, ggplot2, here, fixest, lme4, lmerTest, broom.mixed, modelsummary, patchwork, renv.
- Pfade immer mit `here::here()`.
- Daten mit `encoding = "latin1"` einlesen.
- Paketversionen mit `renv`; nach neuen Paketen `renv::snapshot()`.
- Jedes Skript in `R/` läuft eigenständig; `run_all.R` führt alle der Reihe nach aus.
- Prüfungen mit `stopifnot()` einbauen (Eindeutigkeit, keine fehlenden Einwohnerzahlen, erwartete Zeilenzahlen).
- Outputs: Abbildungen nach `output/figures/` (PDF + PNG 300 dpi), Tabellen nach `output/tables/` (CSV + HTML), Logs nach `output/logs/`.
- Nach jedem abgeschlossenen Schritt: Git-Commit mit verständlicher Nachricht.

## Bekannte Datenfallen (Details in PROJEKTPLAN.md §3.3)
- Ländercode „H“ → „HU“.
- Städtenamen wechseln; Identität über **Site ID**.
- Mehrfach-Kläranlagen „(2)“, „(4)“ markieren.
- Finnland: nur gerade Jahre, viele Kleinstädte → nie ungewichtete Jahresmittel über wechselnde Städte vergleichen.
- Werte unter der Bestimmungsgrenze sind **0**.
- `cot` / `ets` (nur 2025) vermutlich Cotinin / Ethylsulfat – Bedeutung vor Verwendung bestätigen.

## Reihenfolge
Setup → Bereinigung → Audit → (Literatur-Check + Spezifikationen fixieren) → RQ1 → RQ2 → RQ3 → Robustheit → Abbildungen → Schreiben. Siehe Zeitplan in `PROJEKTPLAN.md` §9.
