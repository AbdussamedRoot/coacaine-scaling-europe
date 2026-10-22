# DECISIONS.md – Logbuch

Hier steht jede Entscheidung, die nicht schon wörtlich in `PROJEKTPLAN.md`
festgelegt ist, und jede Abweichung vom Plan – mit Datum und Begründung.
Änderungen an den Spezifikationen in §4 nur nach Rückfrage; solche
Abweichungen werden auch im Paper berichtet.

Format: **Nummer · Datum · Phase · Abweichung vom Plan?** – Entscheidung – Begründung

---

## D001 · 2026-10-22 · Phase 0 · keine Abweichung

**Rohdaten-Schutz.** Die drei EUDA-Dateien liegen byte-identisch zum Download
in `data/raw/`. Ihre MD5-Prüfsummen stehen in `data/raw_md5.txt`.
`R/00_setup.R` prüft sie bei jedem Skriptstart und bricht ab, wenn eine Datei
fehlt oder verändert wurde. `.gitattributes` verhindert, dass Git die
Zeilenenden der Dateien umwandelt (das würde die Prüfsummen brechen).

*Begründung:* setzt Regel 1 (CLAUDE.md) technisch durch – eine versehentliche
Änderung der Rohdaten fällt sofort auf.

## D002 · 2026-10-22 · Phase 0 · keine Abweichung

**Jedes Skript läuft in einem eigenen R-Prozess.** `run_all.R` startet die
Skripte nacheinander mit `Rscript` statt mit `source()`. Jedes Skript lädt
selbst `R/00_setup.R` (Pakete, Optionen, Seed, Pfade). Die Bildschirmausgabe
jedes Skripts wird in `output/logs/<skript>.log` gespeichert.

*Begründung:* Mit `source()` blieben Objekte eines früheren Skripts im
Speicher, und ein späteres Skript könnte nur „zufällig“ funktionieren. Ein
frischer Prozess beweist, dass jedes Skript eigenständig läuft (CLAUDE.md,
Technik).

## D003 · 2026-10-22 · Phase 0 · keine Abweichung

**Was kommt in Git?** Code, Dokumente, Rohdaten und alle Outputs (`output/`):
ja. `data/processed/`: nein – es wird jederzeit aus `data/raw/` und dem Code
neu erzeugt. Für die Veröffentlichung (§10) werden die bereinigten Daten
später zusätzlich bereitgestellt.

*Begründung:* Abgeleitete Daten in Git können unbemerkt vom Code abweichen.

## D004 · 2026-10-22 · Phase 0 · keine Abweichung

**R-Version und Paketquelle.** R 4.6.1 (offizieller CRAN-Build für Ubuntu
24.04). Alle Pakete kommen von CRAN. `renv.lock` hält die R-Version und die
exakte Version jedes Pakets fest (`renv` 1.3.1); `renv::restore()` installiert
auf jedem Rechner genau diese Versionen.

*Begründung:* Gleiche Paketversionen bedeuten gleiche Ergebnisse, auch in
einem Jahr. CRAN ist die offizielle Quelle. Der schnellere Posit Package
Manager (fertig kompilierte Pakete) ist in der Cloud-Umgebung zurzeit nicht
nutzbar; ein späterer Wechsel der Download-Quelle würde keine Versionen
ändern.
