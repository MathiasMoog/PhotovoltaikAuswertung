% Photovoltaik Ertragsdaten
% Einfache Klasse, die die monatlichen Ertragsdaten einer Phototovoltaik Anlage verwaltet.
% Die Daten liegen in einer CSV Datei (Dezimaltrenner . und Spaltentrenner ,) vor. Spalten 
% wie in der load Methode beschrieben.



% Copyright 2019 bei Mathias Moog, Hochschule Ansbach, Deutschland
% Dieser Code steht unter der Creative-Commons-Lizenz Namensnennung - Nicht-kommerziell - 
% Weitergabe unter gleichen Bedingungen 4.0 International. 
% Um eine Kopie dieser Lizenz zu sehen, besuchen Sie http://creativecommons.org/licenses/by-nc-sa/4.0/

% Diesen Code habe ich für die Verwendung in meinen Lehrveranstaltungen und für Studierende
% an der Hochschule Ansbach geschrieben. Ich kann nicht garantieren, dass er fehlerfrei funktioniert.
% Für Hinweise und Verbesserungsvorschläge bin ich dankbar.

% Ich selbst arbeite vorwiegend mit Octave, https://www.gnu.org/software/octave/, da dies freie 
% Software ist und sie auf jedem Rechner installiert werden kann. 
% Diese Code läuft nur in Octave. Für die Nutzung in Matlab muss er angepasst werden.




% Definiton der Ertragsdaten Klasse
classdef Ertragsdaten  < handle
  
  properties ( Access = public )
    % Anlagengröße (Installierte DC Leistung) in kWp
    power=NA;
    % Year, Array mit den Jahren
    year=[];
    % Month
    month=[];
    % Ertrag, Energie in kWh / month
    energy=[]
    % Einstrahlung, optional falls eine lokale Einstrahlungsmessung vorhanden ist
	% Einstrahlung in kWh/Monat m^2 auf einer ebenen Fläche
    radiation = [];
  endproperties
  
  methods
    % Konstruktor, benötigt die Anlagengröße
	% power_dc - Installierte DC Leistung in kWp
    function obj = Ertragsdaten( power_dc )
      obj.power = power_dc;
    endfunction
    
    
    % Lade die monatlichen Ertragsdaten aus einer CSV Datei 
    % Spalten:
    %  1 - Jahr -> year
    %  2 - Monat -> month
    %  3 - Energie -> energy
    %  (4 - Einstrahlung, optional -> radiation) 
    function ok = load(obj, file_name )
      % Lese CSV Datei, erwarte genau eine Kopfzeile
      M=dlmread(file_name,",",1,0);
      if (size(M,2)<3)
        error("Erwarte mindestens drei Spalten (Jahr, Monat, Energie)");
        ok=false;
        return
      endif
      obj.year = M(:,1);
      obj.month = M(:,2);
      obj.energy = M(:,3);
      if (size(M,2)>3)
        obj.radiation = M(:,4);
      else
        obj.radiation=[];
      endif
      ok = true;
    endfunction
    
    % Die die Zeiten (year, month) im datenum Format (Tage sei Christi Geburt) 
    function d = datenum(obj)
      n = length(obj.year);
      dv = [ obj.year, obj.month, ones(n,1), zeros(n,3) ]; % Datevec matrix
      d = datenum( dv );
    endfunction
    
    % Spezifische Energie, teile die Energie durch die Anlagengröße
    function se = specific_energy(obj)
      se = obj.energy / obj.power;
    endfunction
    
    % Erster Zeitpunkt zu dem Messdaten vorliegen, als datenum
    function d = first_time( obj )
      d = datenum( [ obj.year(1), obj.month(1), 1, 0,0,0] );
    endfunction
    
    % Letzter Zeitpunkt zu dem Messdaten vorliegen als datenum
    function d = last_time( obj )
      d = datenum( [ obj.year(end), obj.month(end), 1, 0,0,0] );
    endfunction
    
    % Prüfe ob lokale Strahlungsdaten vorliegen
    function ok = has_radiation( obj )
      ok = size(obj.radiation,1)>0;
    endfunction;
	
	% Zeichne die vorliegenden Daten 
	function plot( obj )
	  % Zeichne den spezifischen Ertrag (normiert auf die Anlagengröße)
	  plot(obj.datenum(),obj.specific_energy(),'o');
	  %Falls lokale Eintrahlungsdaten vorliegen, dann zeichne diese ebenfalls
      if ( obj.has_radiation() )
	    hold on;
        plot(obj.datenum(),obj.radiation,"x");
        hold off;
        legend("Spezifischer Ertrag in kWh/kWp/Monat", "Einstrahlung in kWh/m^2/Monat" );
      else
        legend("Spezifischer Ertrag in kWh/kWp/Monat" );
      endif
      title("Spezifischer monatlicher Ertrag");
      xlabel("Monat.Jahr");
      datetick("mm.yyyy","keeplimits");
      ylabel("")
    endfunction;
	
  endmethods  
      
endclassdef  