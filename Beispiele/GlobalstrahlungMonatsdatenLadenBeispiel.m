% Beispiel zum Umgang mit der GlobalstrahlungMonatsdaten Klasse
% In diesem Beispiel wird eine Zeitreihe geladen und aktualisiert.

% Copyright 2019 bei Mathias Moog, Hochschule Ansbach, Deutschland
% Dieser Code steht unter der Creative-Commons-Lizenz Namensnennung - Nicht-kommerziell - 
% Weitergabe unter gleichen Bedingungen 4.0 International. 
% Um eine Kopie dieser Lizenz zu sehen, besuchen Sie http://creativecommons.org/licenses/by-nc-sa/4.0/

% Diesen Code habe ich f�r die Verwendung in meinen Lehrveranstaltungen und f�r Studierende
% an der Hochschule Ansbach geschrieben. Ich kann nicht garantieren, dass er fehlerfrei funktioniert.
% F�r Hinweise und Verbesserungsvorschl�ge bin ich dankbar.

% Ich selbst arbeite vorwiegend mit Octave, https://www.gnu.org/software/octave/, da dies freie 
% Software ist und sie auf jedem Rechner installiert werden kann. 
% Diese Code l�uft nur in Octave. F�r die Nutzung in Matlab muss er angepasst werden.

% Dieser Code nutzt die Wetterdaten vom Deutschen Wetterdienst (DWD)
% Nutzungsbedingungen und Referenzen siehe
% ftp://ftp-cdc.dwd.de/climate_environment/CDC/grids_germany/monthly/radiation_global/

% Den Pfad erweitern damit die Klassen gefunden werden
addpath( "../" );

% vermeidet Probleme wenn die Klasse zur Laufzeit von Octave gen�ndert wurde.
clear classes; 

% Eine Instanz anlegen
% Wichtig, die Koordinaten m�ssen im Gau�-Kr�ger System, Zone 3 angegeben werden.
% Umrechnung z.B. mit
% https://epsg.io/map#srs=5683&x=3597369.280243&y=5449838.674227&z=16&layer=streets
% Hier ist der Campus Feuchtwangen der Hochschule Ansbach eingestellt
monatsdaten = GlobalstrahlungMonatsdaten( [3597369, 5449837])

% Daten laden
monatsdaten.load("GlobalstrahlungFeu.csv")

% aktualisieren
monatsdaten.update("", true )

% Daten visualisieren
monatsdaten.plot()

% Daten speichern
monatsdaten.save("GlobalstrahlungFeu.csv")


