# Spezifikationen der Analysen (vor den Rechnungen festgelegt)

**Version 1 · 2026-10-23 · Status: freigegeben (D013)**

Dieses Dokument legt alle Analysen fest, **bevor** sie gerechnet werden
(Plan §2 und §4, Phase 2). Es folgt `PROJEKTPLAN.md` und füllt nur die
Stellen, an denen der Plan Spielraum ließ; diese sind als **Präzisierung**
markiert. Nach der Freigabe wird nichts mehr geändert. Abweichungen kommen mit
Datum und Begründung in `DECISIONS.md` und ins Paper. Der Git-Commit der
Freigabe belegt öffentlich, wann die Spezifikationen feststanden.

## Übersicht: was über den Plan hinaus festgelegt wird

| Nr. | Punkt | Abschnitt |
|---|---|---|
| P1 | Alle Tests zu H1/H1b und die Kernabbildung (Abb. 2) beruhen auf dem `fixest`-Modell; das Mehrebenenmodell liefert die Länder-Steigungen und dient als Vergleich | §3 |
| P2 | H2 und H3 werden wie H1 einseitig getestet (α = 0,05), immer mit zweiseitigem 95-%-KI | §4, §5 |
| P3 | RQ3 nutzt die Jahre 2022–2025 (passend zu den Umfragejahren); alle Jahre als Sensitivität | §5 |
| P4 | Vorsichtsregel für `cot`/`ets`, solange ihre Bedeutung nicht bestätigt ist | §7 |
| P5 | Feste Ausweichregeln, falls ein Mehrebenenmodell nicht konvergiert | §3 |
| P6 | Welche Robustheitsprüfung für welche Forschungsfrage gilt, und Details zu R3, R4, R5, R7 | §8 |
| D010 | 15–64 Jahre (GPS-29) als zusätzliche Sensitivität für RQ3 | §5 |

## 0. Was vor diesen Spezifikationen schon bekannt war

- Die Hypothesen stammen aus einer explorativen Vorab-Analyse derselben Daten
  (Plan §6). Das wird im Paper offen gesagt.
- Phase 1 hat die Daten bereinigt und beschrieben (Audit), einschließlich
  Streudiagrammen mit einfachen Regressionslinien ohne Länder- und
  Jahreseffekte (`output/figures/audit_scatter_load_population`). Keine der
  unten festgelegten Analysen wurde bisher gerechnet.

## 1. Daten und Variablen

1. Daten: EUDA/SCORE-Release 2026, bereinigt mit `R/01_import_clean.R` zu
   `data/processed/ww_clean.rds` (Entscheidungen D001–D009).
2. Hauptstichprobe: Länder EU27 + Norwegen + Türkei (`is_main_sample`), alle
   Jahre 2011–2025; Fort-de-France gehört dazu (D008).
3. Beobachtungseinheit: Site ID × Jahr × Substanz. Site IDs werden nie
   zusammengelegt (D005).
4. Substanzen: Kokain (Benzoylecgonin), MDMA, Ketamin (2022–2025),
   Methamphetamin, Cannabis (THC-COOH; 2014–2017 keine Daten), Amphetamin,
   `cot` und `ets` (nur 2025; siehe §7).
5. Variablen (wie Plan §4.1): `log_load` = ln(Tagesmittel aus der Datei) für
   Werte > 0 (D007); `log_pop_c` = ln(Einwohner) − ln(100 000);
   `t` = (Jahr − 2018) / 10. Natürlicher Logarithmus; δ hängt nicht von der
   Basis ab.
6. Nullwerte (unter der Bestimmungsgrenze): im Hauptmodell ausgeschlossen;
   Zwei-Teile-Modell (§6) und Robustheitsprüfung R10.

## 2. Zuerst: Reproduktion der Vorab-Ergebnisse (Regel 4)

- Spezifikation genau wie Plan §6: Hauptstichprobe, Jahre 2022–2025,
  Tagesmittel > 0, je Substanz
  `feols(log_load ~ log_pop_c | country + year, cluster = ~site_id)`.
- Kriterium: δ trifft für jede Substanz den Wert aus Plan §6 auf ±0,01.
  Zahl der Messungen und Anlagen wird mit §6 verglichen; die KIs dürfen wegen
  anderer Kleinstichproben-Korrekturen leicht abweichen.
- Weicht ein δ um mehr als 0,01 ab: Ursache suchen und dokumentieren, bevor es
  weitergeht. Die Daten werden **nicht** angepasst, um die Vorab-Werte zu
  treffen.

## 3. RQ1 – Skalierung (H1, H1b)

**3.1 Primärmodell** je Substanz (Hauptstichprobe, alle Jahre der Substanz):

```r
fixest::feols(log_load ~ log_pop_c | country + year,
              data = d, cluster = ~site_id)
```

Standardfehler: `fixest`-Standard für Cluster (Kleinstichproben-Korrektur,
t-Verteilung mit G − 1 Freiheitsgraden). Bei `cot`/`ets` (ein Jahr) entfällt
der Jahreseffekt von selbst.

**3.2 Präzisierung P1.** Alle Tests zu H1 und H1b sowie die Kernabbildung
(Abb. 2) beruhen auf dem Primärmodell 3.1. Das Mehrebenenmodell 3.3 liefert die
länderspezifischen Steigungen (für RQ3 und Abb. 4) und wird als Vergleich
berichtet. *Grund:* Plan §4.4 nennt das `fixest`-Modell „Primärmodell“, das
Mehrebenenmodell aber „Hauptergebnis für die Abbildungen“; zwei verschiedene
Hauptschätzer für dieselbe Frage wären widersprüchlich.

**3.3 Mehrebenenmodell** je Substanz:

```r
lmerTest::lmer(log_load ~ log_pop_c + factor(year) +
               (1 + log_pop_c | country) + (1 | site_id), data = d)
```

REML; p-Werte nach Satterthwaite (`lmerTest`); 95-%-KIs als Profil-KIs, falls
diese nicht berechenbar sind per parametrischem Bootstrap (1000
Wiederholungen, `set.seed(2026)`). Bei Substanzen mit nur einem Messjahr
(`cot`, `ets`) entfallen `factor(year)` und `(1 | site_id)`, weil jede Anlage
nur eine Messung hat.

**3.4 Präzisierung P5 (Konvergenz).** Meldet `lme4` Nicht-Konvergenz oder eine
singuläre Anpassung, wird in dieser festen Reihenfolge vereinfacht, bis das
Modell sauber läuft: (a) Korrelation zwischen zufälligem Achsenabschnitt und
zufälliger Steigung weglassen (`(1 + log_pop_c || country)`), (b) zufällige
Steigung weglassen (`(1 | country)`). Jede Vereinfachung wird berichtet.

**3.5 H1** (wie Plan): einseitiger Test δ > 0 im Primärmodell für alle acht
Substanzen; Holm-Korrektur über diese acht p-Werte. H1 gilt für Kokain, MDMA
bzw. Ketamin als bestätigt, wenn deren Holm-korrigierter p-Wert < 0,05 ist.

**3.6 H1b** (wie Plan): Äquivalenztest (TOST) mit Grenzen ±0,10 für
Amphetamin, `cot` und `ets`. Linearität gilt als gezeigt, wenn das 90-%-KI von
δ (Primärmodell) vollständig in [−0,10; +0,10] liegt. Keine Mehrfachkorrektur.
Ein nicht signifikantes δ allein gilt **nicht** als Linearität.

**3.7 Berichtet** wird je Substanz: δ, 95-%-KI, 90-%-KI, einseitiger p-Wert
(roh und nach Holm), Zahl der Messungen, Anlagen und Länder sowie die
Übersetzung 10^δ („eine 10-mal größere Stadt hat x-mal so viel pro Kopf“).

## 4. RQ2 – Ausbreitung über die Zeit (H2)

**4.1 Primärtest** (Kokain, Hauptstichprobe, 2011–2025, Werte > 0, nur Anlagen
mit mindestens zwei Messjahren):

```r
fixest::feols(log_load ~ log_pop_c:t | site_id + country^year,
              data = d_cocaine, cluster = ~site_id)
```

**4.2 Präzisierung P2.** H2 wird einseitig getestet: Koeffizient von
`log_pop_c:t` < 0, α = 0,05; dazu immer das zweiseitige 95-%-KI. *Grund:* Der
Plan legt die Richtung fest, aber nicht die Seitigkeit; einseitig wie bei H1.
Bedeutung des Koeffizienten: Veränderung von δ pro Jahrzehnt.

**4.3 Ergänzend** (beschreibend, ohne Entscheidungsfunktion): δ je Jahr
(Modell 3.1 getrennt pro Jahr, nur Ländereffekte) als Zeitreihe mit KI
(Abb. 3); Länder mit langen Reihen (AT, BE, DE, FI) einzeln; dieselbe Analyse
für MDMA, Methamphetamin und Amphetamin (explorativ).

## 5. RQ3 – Sättigung (H3)

**5.1 Prävalenz:** `prev` = nationale 12-Monats-Prävalenz Kokain, 15–34
Jahre, Spalte „Total“ aus `data/raw/GPS-30.xlsx` (jeweils letzte Umfrage pro
Land); `prev_c` = `prev` minus Mittelwert über die Länder der
Analysestichprobe (jedes Land einmal). Einheit: Prozentpunkte. Alle 28 Länder
der Hauptstichprobe haben einen Wert.

**5.2 Präzisierung P3.** Zeitraum 2022–2025. *Grund:* Die Umfragen stammen
überwiegend aus 2020–2024; δ kann sich über die Zeit ändern (RQ2); auch die
Vorab-Analyse (Plan §6) nutzte 2022–2025. Alle Jahre 2011–2025 als
Sensitivität (5.4 d).

**5.3 Modell** (Kokain, Hauptstichprobe, Werte > 0):

```r
lmerTest::lmer(log_load ~ log_pop_c * prev_c + factor(year) +
               (1 + log_pop_c | country) + (1 | site_id), data = d)
```

H3: Interaktion `log_pop_c:prev_c` < 0, einseitig wie P2, α = 0,05; 95-%-KI
und Konvergenzregeln wie 3.3 und 3.4.

**5.4 Sensitivitäten:**

- (a) Statt der Umfrage: Abwasser-Landesmittel **ohne** die jeweilige Anlage
  (Leave-one-out; Mittel von `log_load` der übrigen Anlagen des Landes,
  2022–2025), zentriert.
- (b) Zwei Stufen: δ je Land (Modell 3.1 mit Jahreseffekten, nur Länder mit
  mindestens 6 Anlagen wie in Plan §6), dann gewichtete Meta-Regression von δ
  auf `prev` (Gewicht 1/SE²) und zusätzlich die Spearman-Rangkorrelation.
- (c) **D010:** Prävalenz für 15–64 Jahre (`data/raw/GPS-29.xlsx`) statt
  15–34.
- (d) Alle Jahre 2011–2025.

**5.5 Vorsicht:** nur 28 Länder; einige Umfragen sind älter (GR und HR 2015,
TR 2017, LU 2019) und einige Stichproben klein (GR, EE, HU). RQ3 wird als
sekundär und vorsichtig berichtet.

## 6. Nullwerte: Zwei-Teile-Modell (Plan §4.7)

Für jede Substanz mit Nullwerten, Hauptstichprobe, alle Jahre:

```r
lme4::glmer(detected ~ log_pop_c + factor(year) + (1 | country),
            family = binomial, data = d)   # detected = !is_zero
```

Teil 2 ist das Primärmodell 3.1. Berichtet wird das Odds Ratio für
`log_pop_c` mit 95-%-KI. `ets` hat keine Nullwerte (nicht schätzbar); bei sehr
wenigen Nullwerten (z. B. `cot`: 3) wird das Modell nur berichtet, wenn es
konvergiert.

## 7. `cot` und `ets` – Präzisierung P4

Die Bedeutung ist durch die EUDA-Dokumentation **nicht** bestätigt (Suche am
2026-10-23, D011). Indizien in der Hauptstichprobe: `cot` Median 955 mg/Tag
pro 1000 Einw., flach über die Woche (Wochenende ÷ Werktag = 1,02); `ets`
Median 3321, deutlicher Wochenendanstieg (1,41). Das passt zu Cotinin
(Nikotin) und Ethylsulfat (Alkohol).

**Regel:** Analysen mit `cot`/`ets` werden wie geplant gerechnet. Ist die
Bedeutung bis zum Schreiben nicht bestätigt (EUDA-Dokumentation oder Auskunft
von EUDA/SCORE), werden H1b für `cot`/`ets` und R4 als „unter Vorbehalt“
berichtet und die Codes im Paper nur als „vermutlich Cotinin bzw. Ethylsulfat
(nicht dokumentiert)“ bezeichnet.

## 8. Robustheitsprüfungen (Plan §4.8) – Präzisierung P6

**Geltung:** Für RQ1 (δ je Substanz, Primärmodell) alle Prüfungen R1–R10,
soweit die Daten es zulassen. Für RQ2 (Kokain) R1, R3, R6 und R8.
Robustheitsprüfungen werden beschreibend berichtet (Richtung, Größe, KI); sie
sind keine neuen Hypothesentests und werden nicht nach Holm korrigiert.

| Nr. | Festlegung |
|---|---|
| R1 | ohne Finnland |
| R2 | nur 2025 (Querschnitt; nur Ländereffekte) |
| R3 | Standardfehler nach Land geclustert; zusätzlich Wild-Cluster-Bootstrap (Cluster = Land, Nullhypothese auferlegt, Rademacher-Gewichte, 9999 Wiederholungen, `set.seed(2026)`) für den p-Wert |
| R4 | nur 2025, Anlagen mit Wert > 0 für Droge **und** `cot`: `feols(log(Last_Droge / Last_cot) ~ log_pop_c \| country)` mit heteroskedastie-robusten Standardfehlern (eine Messung pro Anlage); Steigung = δ_Droge − δ_cot. Gilt für alle Substanzen außer `cot` selbst |
| R5 | Simulation (1000 Wiederholungen, `set.seed(2026)`): Struktur der Kokain-Hauptstichprobe (Anlagen, Länder, Jahre, Einwohner); wahres δ = 0 und 0,3; Länderstreuung und Restfehler wie im Primärmodell für Kokain; Fehler in ln(Einwohner) normalverteilt mit SD 0 / 0,1 / 0,2 / 0,3, je Anlage fest über die Jahre; die beobachtete Pro-Kopf-Last wird durch die fehlerhafte Einwohnerzahl geteilt; Schätzung mit dem Primärmodell; berichtet wird die mittlere Verzerrung |
| R6 | ohne `multi_plant` **und** ohne `multi_plant_unclear` (D006) |
| R7 | (a) ohne die obersten 1 % von `log_load` je Substanz; (b) robuste Regression `MASS::rlm` (Huber) mit Länder- und Jahres-Dummies |
| R8 | erweiterte Stichprobe: Hauptstichprobe plus CH, GB, IS, RS, BA |
| R9 | Länder gleich gewichtet: Gewicht je Messung = 1 / Zahl der Anlagen des Landes für diese Substanz |
| R10 | Nullwerte ersetzt durch ½ × kleinster positiver Wert derselben Substanz im selben Jahr (Hauptstichprobe) |

## 9. Explorativ

Alles, was nicht in §3.5, §3.6, §4.2 oder §5.3 steht, gilt als explorativ
(Plan §4.9) und wird so gekennzeichnet.

## 10. Technik

R 4.6.1; Paketversionen in `renv.lock`; `set.seed(2026)` direkt vor jedem
Zufallsschritt. Das Paket `readxl` (zum Einlesen der xlsx-Prävalenzdaten) wird
in Phase 4 ergänzt und im Logbuch vermerkt.

## Freigabe

Freigegeben am 2026-10-23 (D013). Maßgeblich ist der Stand im Git-Commit
„Freeze specifications (version 1)“.
