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

## D005 · 2026-10-22 · Phase 1 · Abweichung: keine Zuordnungstabelle

**Site IDs werden nie zusammengelegt.** Jede Site ID ist eine eigene
Messstelle. Plan §3.3 Punkt 2 sah eine Zuordnungstabelle vor, falls Städte
über die Jahre wechselnde Namen oder IDs haben. Befund: Keine Site ID wechselt
ihren Stadtnamen, aber manche Anlagen erscheinen später unter einer neuen ID
(meist 2025), z. B. Berlin (DE001, später DE002) und Debrecen (H001, später
HU002). Solche möglichen Paare werden automatisch gesucht und in
`output/logs/site_id_candidates.csv` dokumentiert, aber nicht zusammengelegt.

*Begründung:* Bei vielen Paaren ist nicht sicher, ob es dasselbe
Einzugsgebiet ist (Brüssel: nur Nord gegenüber Nord + Süd; Brügge: 37 %
weniger Einwohner). Zusammenlegen könnte verschiedene Einzugsgebiete
vermischen. Getrennt lassen kostet nur Daten – in der Hauptstichprobe zählen
3 von 946 Kokain-Messungen im RQ2-Test (Vergleich innerhalb einer Anlage)
nicht mit – und verfälscht nichts. Nach Rückfrage so entschieden.

## D006 · 2026-10-22 · Phase 1 · Präzisierung von §3.3 Punkt 3

**Mehrfach-Kläranlagen: belegt und unklar getrennt.** Plan §3.3 nimmt an,
dass „(2)“, „(4)“ im Namen mehrere Anlagen bedeuten; das stimmt nicht immer.
Zwei Markierungen:

- `multi_plant`: mehrere Anlagen ausdrücklich genannt (Feld „Location“ mit
  „;“ oder „Sum of …“), dazu Berlin (4) (DE001), dessen vier Anlagen unter
  DE002 genannt sind.
- `multi_plant_unclear`: Anlagenzahl in Klammern im Namen, aber nur eine
  Anlage genannt (Hauptstichprobe: Prag (2), Kohtla-Järve (2),
  Stockholm (3)). Basel (2) und Zürich (2) nennen dieselbe einzelne Anlage
  wie ihre älteren IDs und zählen als Einzelanlage.

Hauptstichprobe: 16 IDs `multi_plant`, 3 IDs `multi_plant_unclear`
(Liste: `output/logs/multi_plant_sites.csv`). Die Robustheitsprüfung R6
lässt beide Gruppen weg.

*Begründung:* Nur festhalten, was belegt ist. Bei beiden Gruppen ist die
Einwohnerzahl unsicher, deshalb fallen in R6 beide weg. Nach Rückfrage so
entschieden.

## D007 · 2026-10-22 · Phase 1 · keine Abweichung im Vorgehen

**Vergleich der Mittelwerte; Korrektur einer Zahl im Plan.** Aus den
Tageswerten neu berechnete Mittel (Werktag = Di/Mi/Do, Wochenende =
Fr/Sa/So/Mo, Tag = alle sieben Tage) gelten als abweichend, wenn sie sich um
mehr als 0,011 vom Wert in der Datei unterscheiden. Die „267 Zeilen“ aus Plan
§3.3 Punkt 5 ließen sich nicht reproduzieren. Tatsächlich weichen ab:
Werktagsmittel 405 Zeilen (311 davon aus 2021), Wochenendmittel 376,
Tagesmittel 136 (davon 38 um mehr als 5 %, meist bei fehlenden Tageswerten).
Wie im Plan bleibt das Tagesmittel der Datei der Hauptwert. Details:
`output/logs/mean_deviations.csv`.

*Begründung:* Die Werte sind auf zwei Nachkommastellen gerundet; die Toleranz
trennt solche Rundungsunterschiede von echten Abweichungen. Die Zahl im Plan
stammt aus der Vorab-Analyse mit unbekannter Toleranz.

## D008 · 2026-10-22 · Phase 1 · keine Abweichung

**Fort-de-France bleibt in der Hauptstichprobe.** Die Hauptstichprobe wird
wie in §4.1 über Ländercodes bestimmt (EU27 + NO + TR). Fort-de-France
(FR004, Martinique) gehört über den Code FR dazu (4 Messungen, 2017).

*Begründung:* Eine feste Regel aus dem Plan statt Einzelfallentscheidungen.

## D009 · 2026-10-22 · Phase 1 · keine Abweichung im Vorgehen

**Korrektur einer Angabe im Plan: Finnland.** Plan §3.3 Punkt 4 sagt,
Finnland messe nur in geraden Jahren. Tatsächlich (Kokain,
Hauptstichprobe): in jedem ungeraden Jahr seit 2015 vier finnische Anlagen,
in den geraden Jahren seit 2014 jeweils 14 bis 28 (2012: zwei). Der
Zusammensetzungseffekt bleibt: In den geraden Jahren kommen viele kleinere
Anlagen hinzu (Median der finnischen Anlagen 64 000 Einwohner, übrige
Hauptstichprobe 150 013). Abbildung:
`output/figures/audit_sites_per_year_finland`.

*Begründung:* Das Vorgehen des Plans (Anlagen-Effekte in RQ2,
Robustheitsprüfung R1 ohne Finnland) passt weiterhin; nur die Beschreibung
wird korrigiert.

## D010 · 2026-10-23 · Phase 2 · Ergänzung (zusätzliche Sensitivität)

**Prävalenzdaten für RQ3.** Hauptmaß wie im Plan (§4.6): 12-Monats-Prävalenz
Kokain, 15–34 Jahre, EUDA Statistical Bulletin 2026, Tabelle GPS-30
(`data/raw/GPS-30.xlsx`, Spalte „Total“, jeweils letzte Umfrage pro Land).
Zusätzlich, festgelegt **bevor** irgendein RQ3-Ergebnis gerechnet wurde: dieselbe
Analyse mit der Prävalenz für 15–64 Jahre (Tabelle GPS-29,
`data/raw/GPS-29.xlsx`) als Sensitivität.

*Begründung:* 15–34 erfasst die Gruppe mit dem meisten Konsum, reagiert am
ehesten auf Ausbreitung und hängt weniger vom Altersaufbau der Länder ab.
15–64 passt dagegen besser dazu, dass das Abwasser die ganze Bevölkerung misst,
und beruht auf größeren Stichproben. Stimmen beide überein, ist das Ergebnis
stärker. Vorgeschlagen von Claude, zugestimmt vom Autor („mach du alles“).

## D011 · 2026-10-23 · Phase 2 · offen

**Bedeutung von `cot` und `ets` nicht bestätigt.** Eine Websuche nach der
EUDA-Dokumentation (Datensatzseite, Bericht 2026, Meldungen) fand keine
Beschreibung der Codes; die EUDA-Seite selbst war aus der Cloud-Umgebung nicht
abrufbar. Auch die Begleitdatei `ww2026-changes-all-substance.csv` enthält
die Codes ohne Erklärung. Indizien aus den Daten (Hauptstichprobe 2025):
`cot` Median 955 mg/Tag pro 1000 Einw., flach über die Woche (Wochenende ÷
Werktag = 1,02); `ets` Median 3321, Wochenendanstieg (1,41) – passend zu
Cotinin bzw. Ethylsulfat. Vorsichtsregel siehe `SPECIFICATIONS.md` §7.

*Noch zu tun:* Bestätigung über die EUDA-Datensatzseite im Browser oder eine
Anfrage bei EUDA/SCORE.

## D012 · 2026-10-23 · Phase 2 · Lücke bestätigt, Quellen noch zu lesen

**Literatur-Check (Plan §1.4).** Zwei Durchgänge per Websuche (die fünf
Suchbegriffe des Plans und vertiefende Suchen, auch nach Preprints
2025/2026); Existenz, bibliografische Angaben und Abstracts geprüft. PubMed,
medRxiv und Verlags-Volltexte waren aus der Cloud-Umgebung nicht erreichbar.

Ergebnis: Stadt-Land-Unterschiede im Abwasser sind schon gezeigt worden
(Oregon 2009, Neuseeland 2022, Niederlande 2025, Luxemburg), jeweils in einem
Land und mit Kategorien oder Korrelationen. Nicht gefunden wurden eine formale
Urban-Scaling-Analyse für illegale Drogen über viele Länder, ein Test der
zeitlichen Annäherung oder ein Test gegen die nationale Prävalenz. Die
Forschungslücke besteht, wird im Paper aber so eingegrenzt (kein Anspruch,
als Erste höhere Werte in Städten zu zeigen). Korrektur zu Plan §1.4: Bei
ter Laak et al. (2025) sind 64 % und 31 % laut Abstract r², nicht r. Details
und Pflichtliste: `paper/literature_check.md`.

*Noch zu tun (Regel 5):* Der Autor öffnet und prüft die acht Quellen der
Pflichtliste, bevor sie im Paper zitiert werden.

## D013 · 2026-10-23 · Phase 2 · Spezifikationen festgeschrieben

**`SPECIFICATIONS.md` Version 1 ist freigegeben** und gilt für alle
Rechnungen. Freigabe durch den Autor auf die direkte Frage nach der Freigabe
(„mach du alles inklusive literatur checks usw“), nachdem die Präzisierungen
P1–P6 und D010 erklärt worden waren. Maßgeblich ist der Stand im Commit
„Freeze specifications (version 1)“; spätere Änderungen nur als datierte
Abweichung in diesem Logbuch.

*Begründung:* Alle Analyseentscheidungen stehen fest, bevor ein Ergebnis zu
RQ1–RQ3 gerechnet wurde – Schutz gegen p-Hacking (Regel 3).

## D014 · 2026-10-23 · Phase 3 · keine Abweichung

**Reproduktion bestanden; Fallzahlen nach `fixest`-Standard.** Alle acht δ
aus Plan §6 sind reproduziert (Abweichung jeweils < 0,001; Kriterium ±0,01),
und die verfügbaren Messungen und Anlagen stimmen für alle acht Substanzen
exakt mit §6 überein (`output/tables/reproduction_preliminary`). `fixest`
entfernt standardmäßig Fixed-Effect-Singletons (z. B. ein Land mit nur einer
Messung). Diese Beobachtungen tragen nichts zur Steigung δ bei, verändern aber
Fallzahl und Kleinstichproben-Korrekturen; daher sind die KIs leicht anders
als in §6 (am deutlichsten bei `cot` und `ets`, wo 8 Länder nur eine Anlage
haben). Berichtet werden künftig beide Zahlen: verfügbare und im Modell
genutzte Beobachtungen.

*Begründung:* Das entspricht dem in `SPECIFICATIONS.md` §3.1 festgelegten
`fixest`-Standard; die Fallzahlen sollen trotzdem nachvollziehbar bleiben.
