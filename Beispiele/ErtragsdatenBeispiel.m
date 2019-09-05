% Beispiel f�r die Nutzung der Ertragsdaten Klasse

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

% Den Pfad erweitern damit die Klassen gefunden werden
addpath( "../" );

% vermeidet Probleme wenn die Klasse zur Laufzeit von Octave gen�ndert wurde.
clear classes; 

% Instanz anlegen, Anlagengr��e (48 kWp) angeben
ertrag = Ertragsdaten(48)

% Daten Einlesen
ertrag.load("ErtragFeu.csv")

% Daten zeichnen
ertrag.plot()