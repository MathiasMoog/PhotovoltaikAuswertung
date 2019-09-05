# PhotovoltaikAuswertung #
Bewertung der Erträge von Photovoltaik Anlagen anhand der Wetterdaten


Mit diesen [GNU Octave](https://octave.org/ "GNU Octave") Skripten lässt sich der monatliche Ertrag eine Photovoltaik Anlage bewerten. 

## Überblick ##

Die Basis der Auswertung bilden die monatlichen Ertragsdaten. Diese müssen für die jeweilige Anlagwe bereitgestellt werden. Viele Wechselrichter bieten diese Daten digital am Gerät selbst oder über Web Portale an. Selbst eine manuelle Erfassung der monatlichen Ertragsdaten ist möglich. Zusätzlich werden nur die Anlagengröße und der Standort benötigt.

Mit diesen Daten kann die Auswertung durchgeführt werden. Das Ergebnis ist ein monatlicher Vergleich der Erträge mit den Einstrahlungsdaten des Wetterdienstes. Monate in denen der Ertrag deutlich unter den Erwartungen liegt werden so schnell erkannt. Besonders in den Wintermonaten kann dies an Witterungseinflüssen, wie schneebedeckten Anlagen liegen. Bleiben die Ertragseinbußen bestehen deutet dies auf Defekte oder Verschmutzungen hin.

Die Auswertungen erfolgen rein statistisch. Die Orientierung der Anlage geht nicht explizit in die Auswertung ein. Über mehrere Jahre ergibt sich ein anlagentypischer jahreszeitlicher Verlauf. Wird dieser berücksichtigt sind sogar langfristige Ertragseinbußen, wie sie z.B. durch Degradation der Solarmodule verursacht werden, erkennbar.

Die Auswertung erfolgt durch Octave Skripte, die die Einstrahlungsdaten des Wetterdienstes abfragen und diese mit den Erträgen der Anlage vergleichen. Das Ergebnis des Vergleichs wird in Form einer HTML Seite abgelegt.

## Anwendung ##

Für die Auswertung wird [GNU Octave](https://octave.org/ "GNU Octave") mit dem statistics Paket benötigt.

In dem `Beispiel` Ordner sind einige Beispiele und ein Datensatz enthalten. `AuswertungBeispiel.m` zeigt wie eine Auswertung durchgeführt wird.

Für die Auswertung einer eigenen Photovoltaik Anlage wie folgt vorgehen:

1. Montatliche Erträge der PV Anlage in einer csv Datei ablegen, Format wie in `Beispiele/ErtragFeu.csv`
2. Das `Beispiele/AuswertungBeispiel.m` kopieren und anpassen
    * Den Standort der Anlage eintragen. Der Standort muss als Koodinaten im Gauß-Krüger System, Zone 3 angegeben werden, Umrechnungen z.B. auf der [epsg](https://epsg.io/map "Koordinaten umrechnen mit epsg") Seite.
	* Die Anlagengröße (Installierte DC Leistung in kWp eintragen
	* Die Datei in der die monatlichen Erträge abgelegt sind eintragen
	* Einen Dateinamen für die Datei in der die Eintrahlungsdaten abgeleg werden sollen angeben
	* In dem Aufruf `ertrag.evaluate( ... )` den Dateinamen der HTML Datei eintragen
3. Das Skript starten ...  
   Der erste Aufruf dauert etwas länger, da die Einstrahlungsdaten vom Wetterdienst abgerufen werden.
   Wenn alles gut geht entsteht eine HTML Datei mit der Auswertung
4. Auswertung ansehen

Für die restlichen Klassen sind jeweils Beispiele verfügbar.
