# Projektplan: Wandert Kokain die Städtehierarchie hinunter?

**Arbeitstitel (Paper, Englisch):**
*Urban scaling and hierarchical diffusion of illicit drug use: evidence from wastewater in ~200 European catchments, 2011–2025*

**Stand:** 22.10.2026 · Daten: EUDA/SCORE-Release 2026 (Messjahre 2011–2025)

---

## 0. Kurzfassung

Viele soziale Größen (Wirtschaftsleistung, Innovation, Kriminalität) wachsen in Städten **überproportional** mit der Einwohnerzahl: Pro Kopf gibt es in großen Städten mehr davon („urban scaling“). Wir prüfen mit den öffentlichen Abwasserdaten des europäischen SCORE-Netzwerks, ob das auch für illegale Drogen gilt, **für welche** Drogen, und ob der Großstadt-Vorsprung bei Kokain **mit der Zeit schrumpft**, weil sich die Droge von großen in kleine Städte ausbreitet („hierarchische Diffusion“). Explorative Vorab-Analysen zeigen: Kokain, MDMA, Ketamin und Methamphetamin skalieren klar überproportional, Amphetamin, Nikotin und Alkohol etwa proportional; der Kokain-Vorsprung großer Städte scheint zu schrumpfen und ist in Ländern mit hohem Kokainkonsum fast verschwunden. Das Projekt soll diese Befunde sauber, reproduzierbar und gegen Alternativerklärungen abgesichert testen.

---

## 1. Hintergrund

### 1.1 Urban Scaling
Für eine Größe *Y* einer Stadt mit *N* Einwohnern gilt oft *Y = Y₀ · N^β*:
- **β ≈ 1** (proportional): individuelle Grundbedürfnisse (z. B. Wasser, Wohnungen)
- **β > 1** (überproportional): soziale/ökonomische Größen, typischerweise β ≈ 1,1–1,3 (BIP, Patente, Kriminalität)
- **β < 1** (unterproportional): Infrastruktur (Straßen, Tankstellen)

Referenz: Bettencourt et al. (2007), *PNAS* 104:7301.

### 1.2 Hierarchische Diffusion
Neue Praktiken (Produkte, Moden, Drogen) erscheinen oft zuerst in großen Städten und breiten sich dann die Städtehierarchie hinunter aus. Vorhersage: Am Anfang ist der Großstadt-Vorsprung groß (β deutlich > 1), mit zunehmender Sättigung wird er kleiner (β → 1).

### 1.3 Abwasserepidemiologie (WBE) und SCORE
Das SCORE-Netzwerk misst seit 2011 jährlich eine Woche lang (meist März–Mai) Drogenrückstände im Zulauf von Kläranlagen, nach einheitlichem Protokoll mit Ringversuchen. Die EUDA veröffentlicht die Daten als CSV mit Tageswerten.

### 1.4 Forschungslücke (Stand der Recherche Oktober 2026 – vor Start nochmals prüfen!)
- **González-Mariño et al. (2020), *Addiction*** – große Auswertung der SCORE-Daten 2011–2017: Stadtgröße nur **qualitativ** erwähnt („Kokain und MDMA in großen Städten meist höher“), **keine** Skalierungsmodelle, **kein** formaler Ost-West- oder Konvergenztest, **keine** Wochentagsanalyse.
- **ter Laak et al. (2025), *Addiction*** – 30 niederländische Kläranlagen 2015–2022: Kokain (r = 0,64) und MDMA (r = 0,31) korrelieren mit der Urbanität des Einzugsgebiets, Amphetamin nicht. → passt zu unseren Vorab-Ergebnissen, aber nur ein Land, kein Skalierungsexponent, keine Diffusion.
- **Neuseeland (ESR)** – Drogenkonsum nach Siedlungsgröße (Kategorien).
- **EUDA-Berichte** – rein beschreibend: „keine deutlichen Unterschiede zwischen großen und kleinen Städten“; Medien folgern daraus, Kokain habe sich „über die Großstädte hinaus verbreitet“ – ohne statistische Analyse.

→ Eine **europaweite, formale Skalierungsanalyse mit Diffusions- und Sättigungstest** wurde nicht gefunden.

**Vor Phase 3 Pflicht:** Google Scholar, PubMed und medRxiv mit u. a. diesen Suchen prüfen:
`"urban scaling" wastewater drug` · `city size cocaine wastewater Europe` · `"hierarchical diffusion" cocaine` · `SCORE wastewater population size` · `superlinear drug use cities`

---

## 2. Forschungsfragen und Hypothesen

**Zentrale Größe:** δ = β − 1 = Steigung von log(Pro-Kopf-Last) gegen log(Einwohner).
Interpretation: δ = 0,39 heißt, eine 10-mal größere Stadt hat 10^0,39 ≈ **2,5-mal** so viel Rückstand **pro Kopf**.

| | Frage | Hypothese | Status |
|---|---|---|---|
| **RQ1** | Skaliert die Pro-Kopf-Last mit der Einwohnerzahl? | **H1:** δ > 0 für Kokain, MDMA, Ketamin | primär |
| **RQ1b** | Gibt es Substanzen ohne Großstadt-Effekt? | **H1b:** δ ≈ 0 (Äquivalenz) für Amphetamin, Cotinin (Nikotin), Ethylsulfat (Alkohol) | primär (Negativkontrollen) |
| **RQ2** | Schrumpft der Großstadt-Vorsprung bei Kokain über die Zeit? | **H2:** In kleinen Städten wächst die Kokainlast schneller als in großen (negativer Interaktionsterm) | primär |
| **RQ3** | Ist der Vorsprung dort kleiner, wo Kokain national verbreiteter ist? | **H3:** Je höher die nationale Kokain-Prävalenz, desto kleiner das länderspezifische δ | sekundär (wenige Länder) |
| explorativ | Methamphetamin, Cannabis, Ketamin-Trend, Diffusion anderer Drogen | keine festen Hypothesen | explorativ |

**Wichtig:** Die Hypothesen stammen aus einer explorativen Vorab-Analyse derselben Daten (siehe §6). Das muss im Paper offen gesagt werden. Die **endgültigen Spezifikationen in §4 werden vor den finalen Rechnungen festgelegt und danach nicht mehr geändert**; Abweichungen kommen ins Logbuch `DECISIONS.md` und ins Paper.

---

## 3. Daten

### 3.1 Quellen

| Datei | Inhalt | Herkunft |
|---|---|---|
| `ww2026-all-data.csv` | Alle Messungen 2011–2025: Jahr, Substanz, Site ID, Land, Stadt, Tageswerte Mi–Di, Werktags-/Wochenend-/Tagesmittel | EUDA Datenkatalog (vom Nutzer heruntergeladen) |
| `ww2026-site-info-table.csv` | Kläranlagen: SiteID, Land, Stadt, Name, Koordinaten, **Einwohner**, Institution | EUDA |
| `ww2026-changes-all-substance.csv` | Veränderung 2024→2025 je Stadt und Substanz (EUDA-Klassifikation) | EUDA |
| **noch zu holen:** EUDA Statistical Bulletin 2026, „Prevalence of drug use“ (GPS) | Nationale Prävalenz Kokain letzte 12 Monate, 15–34 Jahre | https://www.euda.europa.eu/data/stats2026/gps_en |

**Nutzungsbedingung:** Die Daten dürfen weiterverwendet werden, wenn **EUDA (früher EMCDDA) und SCORE** als Quelle genannt werden.

### 3.2 Eigenschaften der Daten (aus der Vorab-Prüfung)
- Einheit: mg Rückstand pro Tag pro 1000 Einwohner, **nicht** mit Ausscheidungsfaktoren korrigiert (für Skalierung innerhalb einer Substanz egal).
- Werte unter der Bestimmungsgrenze (LOQ) stehen als **0** im Datensatz; die LOQ selbst ist nicht angegeben.
- Werktagsmittel = Di/Mi/Do, Wochenendmittel = Fr/Sa/So/Mo.
- Tagesspalten in der Reihenfolge Mi, Do, Fr, Sa, So, Mo, Di.
- Datei-Encoding: **latin-1** (Umlaute in Städtenamen).
- Einwohnerzahl: **eine** Zahl pro Kläranlage (zeitlich konstant), laut EUDA „nur Richtwert, nicht unbedingt der bei der Messung verwendete Wert“.
- Substanzen: `cocaine` (als Benzoylecgonin), `MDMA`, `amphetamine`, `methamphetamine`, `cannabis` (THC-COOH), `ketamine` (ab 2022), `cot`, `ets` (nur 2025).
- `cot` und `ets` sind sehr wahrscheinlich **Cotinin** (Nikotin-Marker, typisch ~900 mg/Tag/1000 Einw., flach über die Woche) und **Ethylsulfat** (Alkohol-Marker, deutlicher Wochenendanstieg). **Vor Verwendung in der EUDA-Dokumentation bestätigen.**
- Cannabis fehlt 2014–2017 weitgehend.

### 3.3 Bekannte Datenprobleme (gefunden, müssen in der Bereinigung gelöst werden)
1. **Ländercode „H“** statt „HU“ (z. B. Debrecen) → zu „HU“ korrigieren.
2. **Städtenamen ändern sich** zwischen Jahren (z. B. „Berlin (4)“ vs. „Berlin (IV)“, „Brussels“ vs. „Brussels (2)“) → Identität über **Site ID** führen; prüfen, ob Site IDs über die Jahre stabil sind, und eine Zuordnungstabelle (crosswalk) anlegen.
3. **Mehrere Kläranlagen pro Stadt** („(2)“, „(4)“ = bevölkerungsgewichteter Mittelwert): Prüfen, welche Einwohnerzahl dazu in der Site-Tabelle steht. Diese Fälle markieren (`multi_plant = TRUE`) und in einer Robustheitsprüfung ausschließen.
4. **Finnland** misst nur in geraden Jahren, dafür viele Kleinstädte mit sehr niedrigen Kokainwerten → verursacht starke Sprünge in Jahresmittelwerten (Zusammensetzungseffekt!). Nie ungewichtete Jahresmittel über wechselnde Städte vergleichen.
5. Für **267 Zeilen** weicht das Werktagsmittel in der Datei von dem aus den Tagesspalten berechneten Mittel ab (z. B. Rotterdam (2) 2025). → Primär den Datei-Wert „Daily mean“ verwenden, neu berechnete Werte als Prüfung; Abweichungen dokumentieren.
6. **Nicht-europäische Standorte** (AU, NZ, US, CA, BR, CL, KR) und europäische Nicht-EU-Länder (CH, GB, IS, RS, BA) sind enthalten → Stichprobendefinition siehe §4.1.
7. Doppelte Einträge prüfen: Schlüssel (Year, Metabolite, Site ID) muss eindeutig sein.

---

## 4. Analyseplan

### 4.1 Stichprobe und Definitionen (vor finaler Rechnung fixieren)
- **Hauptstichprobe:** EU27 + Norwegen + Türkei (entspricht der EUDA-Definition „European cities“).
- **Zeitraum je Substanz:** alle verfügbaren Jahre 2011–2025 (Ketamin ab 2022; Cotinin/Ethylsulfat nur 2025).
- **Beobachtungseinheit:** Kläranlage × Jahr × Substanz.
- **Outcome:** `log_load = log(Daily mean)` für Werte > 0.
- **Prädiktor:** `log_pop_c = log(Population) − log(100 000)` (zentriert, damit der Achsenabschnitt eine Stadt mit 100 000 Einwohnern beschreibt).
- **Zeit:** `t = (Year − 2018) / 10` (Effekte pro Jahrzehnt).
- **Nullwerte (unter LOQ):** im Hauptmodell ausgeschlossen; separat in einem Zwei-Teile-Modell (§4.7) und einer Ersatzwert-Sensitivität (R10) behandelt.

### 4.2 Datenbereinigung (`01_import_clean.R`)
1. CSVs mit `encoding = "latin1"` einlesen.
2. Ländercode-Korrektur (H → HU), Spaltennamen in `snake_case`.
3. Site-Tabelle per Site ID anhängen; **Abbruch mit Fehlermeldung**, wenn Messungen ohne Einwohnerzahl übrig bleiben.
4. Flags anlegen: `is_main_sample`, `multi_plant`, `is_zero`, `n_days_missing`.
5. Eindeutigkeit von (year, metabolite, site_id) prüfen (`stopifnot`).
6. Neu berechnete Werktags-/Wochenend-/Tagesmittel vs. Datei vergleichen, Abweichungen in `output/logs/` schreiben.
7. Ergebnis als `data/processed/ww_clean.rds` speichern.
**Fertig, wenn:** alle Prüfungen laufen ohne Fehler, ein kurzer Bericht zeigt Zeilen pro Substanz und Jahr, Anzahl Kläranlagen, Anteil Nullwerte.

### 4.3 Daten-Audit und Deskriptive Statistik (`02_audit_descriptives.R`)
- Tabelle 1: Anzahl Messungen, Kläranlagen, Länder, Einwohner (Median, Spannweite) je Substanz.
- Verteilung der Einwohnerzahlen (Histogramm, log-Skala).
- Anteil Nullwerte je Substanz × Jahr.
- Teilnahmemuster: Wie viele Kläranlagen sind wie viele Jahre dabei (Panelstruktur)?
- Erste Streudiagramme log(Last) vs. log(Einwohner) je Substanz.

### 4.4 RQ1 – Skalierung (`03_scaling_main.R`)
**Primärmodell (pro Substanz):**
```r
fixest::feols(log_load ~ log_pop_c | country + year,
              data = d, cluster = ~site_id)
```
δ = Koeffizient von `log_pop_c`. Ländereffekte fangen nationale Unterschiede (Konsumniveau, Laborunterschiede) ab; Vergleich also **innerhalb** der Länder.

**Mehrebenenmodell (Hauptergebnis für die Abbildungen, gibt länderspezifische Steigungen):**
```r
lme4::lmer(log_load ~ log_pop_c + factor(year) +
           (1 + log_pop_c | country) + (1 | site_id), data = d)
```
(p-Werte über `lmerTest`, Konfidenzintervalle per Profil oder parametrischem Bootstrap.)

**Tests:**
- H1: einseitig δ > 0 für Kokain, MDMA, Ketamin; Holm-Korrektur über alle 8 Substanzen.
- H1b (Negativkontrollen): **Äquivalenztest** (TOST) mit Grenze ±0,10: Linearität gilt als gezeigt, wenn das 90-%-KI von δ vollständig in [−0,10; +0,10] liegt. Ein nicht-signifikantes δ allein beweist **keine** Linearität.
- Immer 95-%-Konfidenzintervalle berichten, nicht nur p-Werte.

### 4.5 RQ2 – Diffusion über die Zeit (`04_diffusion.R`)
**Primärtest (robust gegen wechselnde Stichprobe):**
```r
fixest::feols(log_load ~ log_pop_c:t | site_id + country^year,
              data = d_cocaine, cluster = ~site_id)
```
- Kläranlagen-Effekte: Es wird nur die **Veränderung innerhalb derselben Kläranlage** genutzt → neu hinzukommende Kleinstädte (Finnland!) können das Ergebnis nicht verzerren.
- Land×Jahr-Effekte: fangen nationale Trends ab.
- Interaktion < 0 heißt: Kleine Städte holen auf (Diffusion). Benötigt Kläranlagen mit ≥ 2 Messjahren.

**Ergänzend:**
- Jahresweise δ-Schätzungen (Modell aus §4.4 getrennt pro Jahr) als Zeitreihe mit KI plotten.
- Länder mit langen Reihen (z. B. AT, BE, DE, FI) einzeln.
- Dieselbe Analyse für MDMA, Methamphetamin, Amphetamin als Vergleich (explorativ).

### 4.6 RQ3 – Sättigung (`05_saturation.R`)
Die nationale Kokain-Verbreitung wird **extern** gemessen, damit der Test nicht zirkulär ist (eine aus denselben Abwasserdaten berechnete Landesmittel enthält ja die großen Städte selbst):
```r
lmerTest::lmer(log_load ~ log_pop_c * prev_c + factor(year) +
               (1 + log_pop_c | country) + (1 | site_id), data = d_cocaine)
```
- `prev_c` = zentrierte nationale 12-Monats-Prävalenz Kokain (15–34 J.) aus dem EUDA Statistical Bulletin, jeweils letzter verfügbarer Wert.
- H3: Interaktion `log_pop_c:prev_c` < 0.
- Sensitivität: nationales Abwasser-Mittel **ohne** die jeweilige Kläranlage (leave-one-out); Zwei-Stufen-Variante (δ je Land schätzen, dann gewichtete Meta-Regression auf die Prävalenz).
- **Vorsicht:** nur ~15–20 Länder → als sekundär/vorsichtig berichten, Rangkorrelation zusätzlich angeben.

### 4.7 Nullwerte: Zwei-Teile-Modell (`06_robustness.R`, Teil A)
- Teil 1: Wahrscheinlichkeit, überhaupt über der LOQ zu liegen: `glmer(detected ~ log_pop_c + factor(year) + (1 | country), family = binomial)`.
- Teil 2: Höhe, falls nachgewiesen = Hauptmodell.
- Besonders relevant für Ketamin und Methamphetamin (viele Nullwerte).

### 4.8 Robustheitsprüfungen (`06_robustness.R`)
| Nr. | Prüfung | Zweck |
|---|---|---|
| R1 | ohne Finnland | Finnlands vielen Kleinstädte |
| R2 | nur 2025 (Querschnitt) | einfachste Version |
| R3 | Standardfehler nach Land geclustert, zusätzlich Wild-Cluster-Bootstrap | wenige Cluster |
| **R4** | **Cotinin-normiert:** log(Droge/Cotinin) gegen log_pop_c (nur 2025) | **Schlüsselprüfung** gegen Pendler/Touristen und falsche Einwohnerzahlen: Cotinin ist ein chemischer Marker für die tatsächlich anwesende Bevölkerung. Steigung = δ_Droge − δ_Cotinin |
| **R5** | **Simulation Messfehler in Einwohnerzahlen** | zeigen, in welche Richtung Fehler verzerren (siehe unten) |
| R6 | ohne Mehrfach-Kläranlagen (`multi_plant`) | unklare Einwohnerzahl |
| R7 | robuste Regression / ohne oberste 1 % | Ausreißer, z. B. mögliche direkte Entsorgung von Drogen |
| R8 | erweiterte Stichprobe: alle europäischen Länder inkl. CH, GB, IS, RS, BA | Stichprobendefinition |
| R9 | Länder gleich gewichtet (Gewicht 1 / Anzahl Kläranlagen im Land) | Dominanz großer Teilnehmerländer |
| R10 | Nullwerte durch ½ × kleinsten positiven Wert (Substanz × Jahr) ersetzen | LOQ-Problem |

**Zu R5 – warum das wichtig ist:** Die Last ist bereits durch die Einwohnerzahl geteilt. Ist die Einwohnerzahl fehlerhaft, steht derselbe Fehler auf beiden Seiten der Regression. Mathematisch drückt das δ **nach unten** (Richtung „unterproportional“), kann also keinen falschen Großstadt-Effekt erzeugen. Die Simulation soll das zeigen: Erzeuge Daten mit wahrem δ = 0 und mit wahrem δ = 0,3, versieh die Einwohnerzahl mit log-normalem Fehler (SD 0,1 / 0,2 / 0,3 auf log-Skala) und schätze δ erneut (`set.seed` setzen, 1000 Wiederholungen).

**Zusätzlich gilt:** Wäre der Effekt nur ein Artefakt der Normierung, müsste er bei **allen** Substanzen auftreten. Dass Amphetamin, Cotinin und Ethylsulfat flach sind, ist ein eingebauter Gegenbeweis.

### 4.9 Berichtsregeln
- Primäre Tests: H1 (Kokain, MDMA, Ketamin), H1b (Amphetamin, Cotinin, Ethylsulfat), H2 (Kokain), H3 (Kokain). Alles andere als „explorativ“ kennzeichnen.
- **Keine** Analyse weglassen, weil das Ergebnis nicht passt. Jede Abweichung vom Plan in `DECISIONS.md` mit Datum und Begründung.
- Effektgrößen immer zusätzlich übersetzen („10-mal größere Stadt → x-mal mehr pro Kopf“).
- Aussagen nur über **Bevölkerungen**, nie über Einzelpersonen (ökologischer Fehlschluss).

---

## 5. Alternativerklärungen und wie wir sie prüfen

| Alternative | Warum plausibel? | Prüfung |
|---|---|---|
| Pendler, Touristen, Nachtleben-Besucher erhöhen die Last großer Städte | Normierung nutzt Wohnbevölkerung | R4 (Cotinin), Negativkontrollen (Pendler würden auch Nikotin/Alkohol mitbringen) |
| Fehlerhafte Einwohnerzahlen | EUDA: nur Richtwerte | R5 (Verzerrung geht gegen den Effekt) |
| Wechselnde Städte über die Jahre | Teilnahme freiwillig, Finnland nur gerade Jahre | Kläranlagen-Effekte in RQ2, R1 |
| Unterschiede zwischen Laboren/Ländern | verschiedene Institute | Länder-Effekte, Mehrebenenmodell |
| Direkte Entsorgung von Drogen (z. B. Hafenstädte) | einzelne extreme Werte | R7 |
| Medizinischer Gebrauch (Ketamin in Kliniken) | Kliniken eher in großen Städten | im Text diskutieren; Ketamin-Ergebnis vorsichtig deuten |
| Eine Woche pro Jahr ist nicht repräsentativ | Stichprobenrauschen | mehrere Jahre gepoolt, KI ehrlich berichten |

---

## 6. Vorab-Ergebnisse (explorativ, in Python berechnet – zur Kontrolle in R reproduzieren)

**Spezifikation:** EU27+NO+TR, H→HU korrigiert, Daily mean > 0, Population > 0, Jahre 2022–2025, OLS `log(Daily mean) ~ log(Population) + Jahr-FE + Land-FE`, SE nach Site ID geclustert.

| Substanz | δ = β − 1 | 95-%-KI | Messungen | Kläranlagen |
|---|---|---|---|---|
| Kokain | +0,391 | [+0,26; +0,52] | 425 | 169 |
| MDMA | +0,357 | [+0,27; +0,44] | 410 | 165 |
| Ketamin | +0,425 | [+0,26; +0,59] | 224 | 128 |
| Methamphetamin | +0,401 | [+0,23; +0,57] | 366 | 157 |
| Cannabis | +0,131 | [+0,08; +0,18] | 269 | 105 |
| Amphetamin | +0,047 | [−0,05; +0,15] | 395 | 162 |
| Ethylsulfat (Alkohol, 2025) | +0,107 | [−0,07; +0,28] | 33 | 33 |
| Cotinin (Nikotin, 2025) | +0,060 | [−0,02; +0,14] | 48 | 48 |

→ Die R-Version (`fixest`) sollte δ bis auf ca. ±0,01 treffen; Konfidenzintervalle können wegen anderer Kleinstichproben-Korrekturen leicht abweichen. **Erst weiterarbeiten, wenn das reproduziert ist.**

**Robustheit (Vorab):** ohne Finnland Kokain +0,28 [+0,19; +0,37]; nur 2025 Kokain +0,21 [+0,10; +0,32]; MDMA in allen Varianten +0,32 bis +0,36.

**Diffusion (Vorab, Kokain 2011–2025):** δ im Jahr 2018 ≈ +0,43; Veränderung **−0,16 pro Jahrzehnt** [−0,32; −0,01], p = 0,04. Bei MDMA, Methamphetamin und Amphetamin keine Veränderung.
⚠️ Dieser Vorab-Test nutzte **keine** Kläranlagen-Effekte und ist daher anfällig für Zusammensetzungseffekte. Der Primärtest in §4.5 kann anders ausfallen – das ist dann das ehrliche Ergebnis.

**Sättigung (Vorab, Kokain 2022–2025, Länder mit ≥ 6 Kläranlagen):**

| Land | Kläranlagen | geom. Mittel Last | δ im Land |
|---|---|---|---|
| FI | 29 | 17 | +0,82 |
| SE | 8 | 112 | +0,45 |
| CZ | 7 | 157 | +0,40 |
| DE | 17 | 201 | +0,39 |
| AT | 20 | 226 | +0,28 |
| SI | 8 | 390 | +0,23 |
| DK | 6 | 462 | +0,18 |
| ES | 8 | 763 | −0,19 |
| BE | 17 | 800 | −0,07 |
| NL | 8 | 872 | +0,19 |

Spearman-Korrelation Landesniveau vs. δ: **−0,92** (n = 10). ⚠️ Zirkulär, weil das Landesniveau aus denselben Daten stammt → deshalb in §4.6 externe Prävalenzdaten.

---

## 7. Geplante Abbildungen und Tabellen

- **Abb. 1:** Streudiagramme log(Pro-Kopf-Last) vs. log(Einwohner), eine Kachel pro Substanz, mit Regressionslinie.
- **Abb. 2 (Kernabbildung):** Forest-Plot: δ mit 95-%-KI für alle 8 Substanzen, Linie bei 0, grauer Äquivalenzbereich [−0,1; +0,1].
- **Abb. 3:** δ für Kokain pro Jahr 2011–2025 (Diffusion).
- **Abb. 4:** Länderspezifisches δ (Mehrebenenmodell) gegen nationale Kokain-Prävalenz.
- **Abb. S1–S…:** Robustheitsprüfungen als Forest-Plot, Simulation R5, Karte der Kläranlagen.
- **Tab. 1:** Datenübersicht. **Tab. 2:** Hauptmodelle. **Tab. S:** alle Robustheitsprüfungen.

Stil: einheitlich, farbenblind-tauglich, Achsen auf log-Skala korrekt beschriftet, als PDF und PNG (300 dpi) speichern.

---

## 8. Projektstruktur und Arbeitsweise

```
kokain-skalierung/
├── CLAUDE.md            # Regeln für Claude Code
├── PROJEKTPLAN.md       # dieses Dokument
├── DECISIONS.md         # Logbuch aller Entscheidungen und Abweichungen
├── README.md            # wie man alles reproduziert
├── run_all.R            # führt alle Skripte der Reihe nach aus
├── renv.lock            # feste Paketversionen
├── data/
│   ├── raw/             # Originaldateien – NIE verändern
│   └── processed/
├── R/
│   ├── 00_setup.R
│   ├── functions.R
│   ├── 01_import_clean.R
│   ├── 02_audit_descriptives.R
│   ├── 03_scaling_main.R
│   ├── 04_diffusion.R
│   ├── 05_saturation.R
│   ├── 06_robustness.R
│   └── 07_figures.R
├── output/
│   ├── figures/
│   ├── tables/
│   └── logs/
└── paper/
```

**R-Pakete:** readr, dplyr, tidyr, stringr, ggplot2, here, fixest, lme4, lmerTest, broom.mixed, modelsummary, patchwork, renv.

**Arbeitsweise:**
- Git von Anfang an; nach jedem fertigen Schritt ein Commit.
- `renv::init()` am Anfang, `renv::snapshot()` nach jeder neuen Paketinstallation.
- Jedes Skript liest nur aus `data/processed/` bzw. `data/raw/` und schreibt nach `output/`.
- `set.seed(2026)` für alles mit Zufall.
- Am Ende von `run_all.R`: `sessionInfo()` nach `output/logs/` schreiben.

---

## 9. Zeitplan mit Meilensteinen

| Phase | Inhalt | Dauer (nebenher) | Fertig, wenn … |
|---|---|---|---|
| 0 | Setup: Ordner, Git, renv, Daten nach `data/raw/` | 1 Tag | `run_all.R` läuft leer durch |
| 1 | Bereinigung + Audit (§4.2–4.3) | 1 Woche | Prüfungen grün, Audit-Bericht verstanden |
| 2 | Literatur-Check (§1.4), externe Prävalenzdaten holen, `cot`/`ets` klären, **Spezifikationen in §4 final fixieren** | 2–3 Tage | Eintrag in `DECISIONS.md` |
| 3 | RQ1 (§4.4) inkl. Reproduktion der Vorab-Werte (§6) | 1 Woche | Tabelle 2 + Abb. 2 |
| 4 | RQ2 + RQ3 (§4.5–4.6) | 1 Woche | Abb. 3 + 4 |
| 5 | Robustheit (§4.7–4.8) | 1–2 Wochen | alle R1–R10 berichtet |
| 6 | Schreiben (Englisch) | 3–4 Wochen | vollständiger Entwurf |
| 7 | Gegenlesen, Code-Check auf frischem Rechner, Preprint, Einreichung | 1–2 Wochen | eingereicht |

Gesamt: etwa 2–3 Monate nebenher.

---

## 10. Paper

**Gliederung (Englisch):** Title · Abstract · Introduction (urban scaling, diffusion, WBE, gap) · Methods (data, cleaning, models, robustness, ethics) · Results · Discussion (interpretation, mechanisms, prevention implications, limitations) · Conclusion · Data and code availability · Declaration of AI use · Acknowledgements (EUDA, SCORE) · References.

**Zieljournals (in dieser Reihenfolge prüfen):** *Addiction* · *International Journal of Drug Policy* · *Drug and Alcohol Dependence* · *Royal Society Open Science*. Vorher Preprint (z. B. medRxiv oder OSF Preprints), sofern das Journal es erlaubt.

**Pflichtangaben:**
- Datenquelle: EUDA und SCORE nennen.
- KI-Nutzung offenlegen (Claude Code für Programmierung; du prüfst und verantwortest jede Zeile).
- Code und bereinigte Daten öffentlich (GitHub + Zenodo-DOI).
- Unterschätzte Kleinigkeit: Bei Lizenz-/Copyright-Verträgen mit dem Verlag rechtzeitig klären, wer unterschreiben muss und welche Zustimmungen nötig sind.
- Nur Literatur zitieren, die du selbst geöffnet und geprüft hast.

---

## 11. Risiken und Plan B

| Risiko | Was dann? |
|---|---|
| Effekt verschwindet in R4 (Cotinin) oder R5 | Paper wird zu „Der Großstadt-Effekt ist größtenteils ein Normierungsartefakt“ – ebenfalls publizierbar und wichtig für die Methodik |
| RQ2-Primärtest (Kläranlagen-Effekte) nicht signifikant | Diffusion als „nicht nachweisbar“ berichten; Fokus auf RQ1 + RQ3 |
| Jemand hat es schon veröffentlicht | Auf den Teil ausweichen, der fehlt (z. B. Sättigung RQ3 oder Negativkontrollen) und die Studie zitieren |
| Zu wenige Länder für RQ3 | als explorativ berichten |
| Reviewer: „nur eine Woche pro Jahr“ | ehrlich als Limitation; Pooling über Jahre als Gegenargument |

---

## 12. Vor dem Start erledigen

- [ ] Literatur-Check (§1.4) und Ergebnis in `DECISIONS.md` notieren
- [ ] EUDA Statistical Bulletin 2026 – Prävalenz Kokain herunterladen
- [ ] Bedeutung von `cot` und `ets` bestätigen
- [ ] Prüfen, ob die Site IDs über die Jahre stabil sind
- [ ] Spezifikationen in §4 final festlegen und datieren

---

### Quellen (geprüft am 22.10.2026)
- Bettencourt, L. et al. (2007). Growth, innovation, scaling, and the pace of life in cities. *PNAS* 104(17).
- González-Mariño, I. et al. (2020). Spatio-temporal assessment of illicit drug use at large scale: evidence from 7 years of international wastewater monitoring. *Addiction* 115. https://pmc.ncbi.nlm.nih.gov/articles/PMC6973045/
- ter Laak, T. et al. (2025). Mapping consumptions and market size of cocaine, amphetamine and MDMA through wastewater analysis: a Dutch case study. *Addiction*. https://onlinelibrary.wiley.com/doi/10.1111/add.16649
- ESR New Zealand: Illicit drug consumption estimated using wastewater analysis and compared by settlement size in New Zealand.
- EUDA (2026). Wastewater analysis and drugs — a European multi-city study. https://www.euda.europa.eu/publications/pods/waste-water-analysis_en
- EUDA Datenkatalog: Drugs in municipal wastewater in Europe: source data. https://www.euda.europa.eu/data/drugs-municipal-wastewater-europe-source-data_en
