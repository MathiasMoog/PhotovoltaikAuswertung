% Verwaltung der Monatsdaten der Globalstrahlung an einem Ort
%
% Verwendet GlobalstrahlungDwd um die Globalstrahlungsdaten des DWD auszuwerten.
% Der Ort der Auswertung ist im Konstruktor anzugeben. Die ausgewerteten Daten 
% werden in einer csv Datei gespeichert und aus dieser auch geladen werden.
% 
% Der Ort muss in Gauß-Krüger Koodinaten im 3. Streifen angegeben werden.
% Siehe Beschreibungsdatei auf dem FTP Server des DWD (GlobalstrahlungDwd.baseUrl)
% Koordinaten können z.B. mit https://epsg.io/ umgerechnet oder auf einer Karte 
% ausgewählt werden


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



classdef GlobalstrahlungMonatsdaten  < handle
  % Verwaltet monatlich Globalstrahlungsdaten
  
  properties ( Access = public )
    % Ort in Gauss Krueger Koordinaten
    position=[]
    % Jahre
    year=[];
    % Monate
    month=[];
    % Einstrahlung auf ebener Fläche in kWh/m^2/Monat
    radiation = [];
  endproperties
  
  methods
    
	% Konstruktor, ohne vorhandene Daten, nur Ort.
	% ort - Ort in Gauß Krüger Koodinaten 
    function obj = GlobalstrahlungMonatsdaten( ort )
      obj.position=ort;
    endfunction	  

    function update( obj, directory, del=true )
	  % Aktualisiere die vorhanende Zeitreihe.
	  % Es mus mit load oder create_time_line eine Zeitreihe angelegt worden sein.
	  % Diese wird bis zum aktuellen Datum aktualisiert (sofern Daten des DWD vorliegen).
	  % Für die Auswertung der Daten wird die GlobalstrahlungDwd Klasse verwendet.
	  % directory - Verzeichnis in dem die temporären Daten des DWD abgelegt werden
	  % del - Flag ob die temporären Daten gelöscht werden sollen
	  
	  % Prüfe übe Daten vorhanden sind.
	  if (isempty(obj.year))
	    error("Update nicht möglich, es sind noch keine Daten vorhanden.");
		return;
	  endif
	  % Letzter Eintrag
	  year=obj.year(end);
	  month=obj.month(end);
	  % Aktuelles Datum
      heute = clock();
      printf("Aktualisiere Zeitreihe von %d.%d bis %d.%d\n",year,month,heute(1),heute(2));      
      % Klasse zum Einlesen
      g = GlobalstrahlungDwd();
      % Alle Monate abarbeiten
      while ( (year<heute(1)) || ( (year==heute(1)) && (month<heute(2)) ) )        
        [year, month] = obj.next_month(year, month); % nächster Monate
        if (!g.read_ftp_file(year,month,directory, del)) % read data
          break;
        end
        % Interpolate and append Data
        obj.append(g);
      endwhile     
	  % Ende von update_time_line
    endfunction 	
    
    function create( obj, year, month, directory, del=true )    
      % Erzeuge eine neue Zeitreihe.
	  % Löscht etwaige vorhandene Daten, läd den Dateensatz zu dem angegebenen 
	  % Jahr und Monat mit der GlobalstrahlungDwd Klasse und führt im Erfolgsfall
	  % ein Update mit update durch.
            
      % Klasse zum Einlesen
      g = GlobalstrahlungDwd();
      if (!g.read_ftp_file(year,month,directory, del)) % read data
        error("Keine Daten des Wetterdienstes für den gewünschten Monat vorhanden.");
		return;
      end
	  % Lösche etwaige vorhandene Daten
	  year=[];
      month=[];
	  radiation=[];
      % Interpolate and append Data
      obj.append(g);
	  % Update
	  obj.update(directory,del)
    endfunction
    
    
    % Return datenum of year, month (beginning of month
    function d = datenum(obj)
      n = length(obj.year);
      dv = [ obj.year, obj.month, ones(n,1), zeros(n,3) ]; % Datevec matrix
      d = datenum( dv );
    endfunction
    
	% Zeichne die Einstrahlungsdaten
    function plot(obj)
      plot( obj.datenum(), obj.radiation, '*-');
      title( sprintf("Monatliche Globalstrahlung in %f, %f\n",obj.position(1),obj.position(2)) );
      xlabel("year.month");
      datetick("yyyy.mm","keeplimits");
      ylabel("Monthly radiation");
    endfunction
    
    % Speicher die Daten im CSV Format
	% Die erste Kopfzeile enhält den Standort in Gauß-Krüger Koodinaten
    function save( obj, filename )
      fp = fopen( filename, "w" );
      fprintf( fp, "Monatliche Globalstrahlung in %f, %f\n",obj.position(1),obj.position(2));
      fprintf( fp, "Jahr, Monat, Globalstrahlung in kWh/m^2/Monat\n");
      dlmwrite( fp, [obj.year, obj.month, obj.radiation], "," );
      fclose(fp);
    endfunction
    
    % Lade Datei mit Eintrahlungsdaten
    function ok = load( obj, filename)
	  % Öffne die Position
      fp = fopen( filename, "r" );
	  if (fp==-1)
	    ok=false;
		return;
	  endif
	  % Lese die Kopfzeile (Position)
      [ v, count] = fscanf( fp, "Monatliche Globalstrahlung in %f, %f\n");
      if (count!=2)
	    error("Keine Positionsangaben in der Kopfzeile!");
		ok=false;
		fclose(fp);
		return
	  endif
	  if (norm(obj.position-v')>1) 
	    warning("Positon stimmt nicht überein, überschreibe die Position");
	  endif
      obj.position=v';
      fgetl(fp); % Beschriftung der Spalten
	  % Lese die Daten
      M = dlmread( fp, "," );
      fclose(fp);
      obj.year = M(:,1);
      obj.month = M(:,2);
      obj.radiation = M(:,3);  
	  % Erfolgreich gelesen
	  ok=true;
    endfunction   
    
    function append( obj, g )
      % Interpolate radiation data and append 
      %  obj.append(g)
      % g - valid GlobalstrahlungDwd
      % Interpolate data and append. Does not check order. Take care.
      % Internal method.
      
      r = g.interp( obj.position(1), obj.position(2) );
      printf(" %04d/%02d - %5.1f kWh/m^2\n", g.year, g.month, r );
      obj.year = [obj.year; g.year];
      obj.month = [obj.month; g.month];
      obj.radiation = [ obj.radiation; r ];
    endfunction
    
    function [year, month] = previous_month(obj, y, m )
      % Vorangegangener Monat
      year = y;
      month = m-1;
      if (month<1)
        month=12;
        year--;
      endif
    endfunction
    
    function [year, month] = next_month(obj, y, m )
      % Nächster Monat
      year = y;
      month = m+1;
      if (month>12)
        month=1;
        year++;
      endif
    endfunction
    
    
  endmethods

endclassdef