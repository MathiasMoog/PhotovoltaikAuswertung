% Ertragsauswertung für Phototvoltaik Anlagen

% Der Monatliche Ertrag der Anlage wird mit den Einstrahlungsdaten des Deutschen Wetterdienstes 
% verglichen. 

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

classdef Auswertung  < handle
  % Ertragsauswertung für Phototoltaik Anlagen.
  % 
  % 
  % Einfache Anwendung: Instanz erzeugen und evaluate aufrufen
  %
  % Siehe Auswertung.Auswertung und Auswertung.evaluate
  
  properties (Constant = true)
    % Namen der Monate, Octave kann sie nur auf englisch.
	monatsnamen={"Januar";"Februar";"März";"April";"Mai";"Juni";"Juli";"August";"September";"Oktober";"November";"Dezember"};
	% Anteil Schlechte Monate
	q_schlecht = 0.4;
  endproperties
  
  properties ( Access = public )
    % Monatliche Einstrahlungsdaten, Instanz der Klasse GlobalstrahlungMonatsdaten
    ra = [];
    % Monatliche Ertragsdaten der Photovoltaik Anlage, Instanz der Klasse Ertragsdaten 
    pv = [];
    % Monatliche Ausbeute, wird in eval_monthly_performance berechnet
    % struct mit den Elementen:
    % M  - Ausbeute, Matrix, Zeilen Monate 1-12, Spalten Jahre
    % P  - Korrekturen, Matrix, Zeilen Monate 1-12, Spalten 1 mean, 2 std der besten 60% Ausbeute Daten des jeweiligen Monats
    % years - Vektor mit den Jahren zu denen in M Daten vorliegen
    M = [];
    % Ausbeute Auswertung, wird in eval_performance berechnet
    % Stuct mit den Elementen:
    %  month - Vektor der Monate zu deenen Ausbeute (performance) Informationen berechnet wurden
    %  performance - Ausbeute (Ertrag/Anlagengröße/Einstrhalung)
    %  performance_corrected - Korrigierte Ausbeute mit den Korrekturfaktoren aus M.P
    %  month_selected - Monate die für die regression ausgewählt wurden
    %  performance_corrected_selected - ausgewählte korrigierte Ausbeute Daten
    %  p - Lineare Regression (Polynomkoeffizienten, siehe polyfit)
    %  p_std - Standardabweichung der Polynomkoeffizienten
    %  p_rest - Standardabweichung nach der Reggression
    %  yearly_decrease - Ertragsminderung pro Jahr
    %  bad_month_count - Vektor, enthält für jeden Monat (1..12) die Anzahl der Monate mit schlechter Ausbeute
    P = [];
    %  HTML Ausgabe, Instanz der Klasse html_output 
    out = [];
    %  Name der Einstrahlungsdatei (Konstruktor)
    radiation_file_name = "";
  endproperties
  
  methods
    
    function obj = Auswertung( position, power, yield_file, radiation_file )
	  % Erzeuge eine Instanz der Klasse. 
	  %
	  % Erzeuge eine Instanz und lade die Daten.
	  %   
	  % Benötigte Daten
      %  position - Standort der Anlage in Gauß-Krüger Koordinaten, siehe GlobalstrahlungDWD
      %  power  - Größe der Anlage, installierte DC Leistung in kWp
	  %  yield_file - Datei mit den monatlichen Ertragsdaten, siehe Klasse Ertragsdaten
	  %  radiation_file - Datei mit den monatlichen Einstrahlungsdaten des Wetterdienstes.
	  %   Falls die Datei nicht existiert wird sie neu angelegt

      % Lade das statistics Paket, ggf. nachinstallieren.
      pkg load statistics
	  
	  % Initialisiere Ertragsdaten
	  obj.pv = Ertragsdaten( power );
      obj.pv.load( yield_file );
	  
      % Initialisiere die Einstrahlungsklasse
      obj.ra = GlobalstrahlungMonatsdaten( position );
      obj.radiation_file_name = radiation_file;
	  % Versuche die Einstrahlungsdaten zu laden
      if (!obj.ra.load( radiation_file )) 
	    % Da keine gefunden wurden, lege eine neue Datei an.
		obj.ra.create( obj.pv.year(1), obj.pv.month(1), "", true );
		obj.ra.save( radiation_file );
	  endif
    endfunction
    
    function update( obj, directory, del=true )
      % Update der Einstrahlungsdaten.
	  % Die Argumente directory und del genau wie in GlobalstrahlungDWD.read_ftp_file
      obj.ra.update( directory, del );
      % Speichern
      obj.ra.save(obj.radiation_file_name);
    endfunction
    
    
    function evaluate(obj, report_name, author="Niemand")
      % Führe alle Auswertungen durch und erzeuge einen html Bericht.
      %  obj.evaluate( report_name, author )
      %
      % report_name - Name der HMTL Datei ohne die .html Endung
      % autor - Name des Autors, siehe Klasse html_output
      %
      % Optisch nicht ganz so hübsch, aber es funktioniert.
      %
      % See also html_output
	  
	  % Farben für bar plots setzen
      colormap('rainbow')
	  % HTML Ausgabe starten
      obj.out = html_output( report_name, "Ertragsbewertung für die Photovoltaik Anlage", author );
      
      % Some information about the plant and the data
      obj.out.begin_itemize();
      obj.out.item( "Installierte DC Leistung %.1f kWp", obj.pv.power );
      obj.out.item( "Monatliche Ertragsdaten von %02d.%d bis %02d.%d", ...
        obj.pv.month(1), obj.pv.year(1), obj.pv.month(end), obj.pv.year(end ) );
      g = GlobalstrahlungDwd();
      obj.out.item( "Verwende die Einstrahlungsdaten des DWD, siehe <a href=\"%s\">%s</a>", g.baseUrl, g.baseUrl );
      obj.out.item( "Einstrahlungsdaten von %02d.%d bis %02d.%d", ...
        obj.ra.month(1), obj.ra.year(1), obj.ra.month(end), obj.ra.year(end) );
      obj.out.end_itemize();
	  
	  obj.out.section("Inhalt")
	  obj.out.begin_itemize();
      obj.out.begin_item(); obj.out.ref("Ueberblick","Überblick Ertrag und Einstrahlung"); obj.out.end_item()
      obj.out.begin_item(); obj.out.ref("UeberblickAusbeute","Überblick monatliche Ausbeute"); obj.out.end_item()
      obj.out.begin_item(); obj.out.ref("Ausbeute","Ausbeute über die Lebensdauer"); obj.out.end_item()
      obj.out.begin_item(); obj.out.ref("SchlechteMonate","Monate mit schlechtem Ertrag"); obj.out.end_item()
      obj.out.begin_item(); obj.out.ref("MonatsDetails","Details der Auswertung der einzelnen Monate"); obj.out.end_item()
      obj.out.end_itemize();
	  
	  obj.out.ref(sprintf("Monat_%02d",obj.pv.month(end)),"Link zur Auswertung des letzten Monats");
	  
	  % todo, Auswertung für den letzten Monat, ggf. Referenz auf MonatsDetails ...
      
      obj.out.section("Überblick Ertrag und Einstrahlung");
	  obj.out.label("Ueberblick")
      plot_yield_radiation(obj);
      
      obj.out.section("Überblick monatliche Ausbeute");
      obj.out.label("UeberblickAusbeute")
      obj.eval_monthly_performance();
      obj.plot_performance_month();
      
      obj.out.section("Ausbeute über die Lebensdauer");
      obj.out.label("Ausbeute")
      obj.eval_performance( )
      obj.plot_performance_corrected( );
      
      obj.out.section("Monate mit schlechtem Ertrag");
      obj.out.label("SchlechteMonate")
      obj.eval_bad_month( );
      obj.plot_bad_month( );
      
      obj.out.section("Details der Auswertung der einzelnen Monate");
      obj.out.label("MonatsDetails")
      for i=1:12
        obj.eval_energy_month(i);
      endfor
      
            
      obj.out.close();
      
    endfunction
  
    % Zeichne den spezifischen Ertrag und die Einstrahlung
    function plot_yield_radiation(obj)
	  obj.ra.plot(); % Einstrahlung zeichnen
      hold on;
      plot(obj.pv.datenum(),obj.pv.specific_energy(),'o'); % spezifischen Ertrag zeichnen
      xlim( [obj.pv.first_time(), obj.pv.last_time() ] ); % Nur für Anlagen Lebensdauer ...
      if ( obj.pv.has_radiation() )
        % Falls vorhanden, lokale Messdaten der Einstrahlung
        plot(obj.pv.datenum(),obj.pv.radiation,"x");
        legend("Einstrahlung Satellit", "Spezifischer Ertrag", "Einstrahlung Lokal" );
      else
        legend("Einstrahlung Satellit", "Spezifischer Ertrag" );
      endif
      hold off;
      title("Einstrahlung und spezifischer Ertrag");
      xlabel("Monat.Jahr");
      datetick("mm.yyyy","keeplimits");
      ylabel("Einstrahlung und spezifischer Etrag")
      print("EinstrahlungErtrag.png");
      obj.out.file2image( "EinstrahlungErtrag.png", "Einstrahlung und spezifischer Ertrag" );
    endfunction
    
    % Zeichne den Etrag für einen Monat, interne Hilfsfunktion
	% m - Nummer des Monats der ausgewertet werden soll
    function eval_energy_month( obj, m )
      % Führe die Auswertung durch - falls noch nicht geschehen
      obj.eval_performance();
      % Jahre für die Daten vorliegen
      years = obj.M.years';
      n = size(years,1);
      d = datenum( [years, m*ones(n,1), ones(n,1), zeros(n,3)] ); 
      energy = interp1( obj.pv.datenum(), obj.pv.energy, d, 'nearest');
      % Wähle die Monate mit Einträgen aus
      sel = isfinite(energy);
      years = years(sel);
      d = d(sel);
      energy = energy( sel );
      n = length(years);
      average = mean( energy );
      obj.out.subsection( sprintf("%s - mittlerer Ertrag %.0f kWh.", obj.monatsnamen{m}, average ) ); 
	  obj.out.label( sprintf("Monat_%02d",m) );
      % Prüfe ob überhaut Daten vorhanden sind
      if (isempty(energy))
        % Passiert nur im ersten Betriebsjahr
        obj.out.par("Monat %s, ignoriert, da keine Daten vorliegen.\n",obj.monatsnamen{m});
        return;
      endif
      % OK, es liegen daten vor, werte aus.
	  bar( years, energy );          
      hold on;
      plot( years, average*ones(n,1) );
      if ( isnan(obj.P.p) )
        % Es liegen noch nicht genügend Daten for, siehe obj.P.p
        legend( "Ertrag", "Mittelwert" );        
      else 
        % Vergleiche mit der statistischen Auswertung (prediction)
        s = obj.M.P(m)*obj.pv.power*interp1( obj.ra.datenum(), obj.ra.radiation, d );
        performance = polyval(obj.P.p,d-obj.P.month_selected(1));
        prediction = performance.*s;
        pred_std   = obj.P.p_rest * s;
        errorbar( years, prediction, pred_std, "*");
        legend( "Ertrag", "Mittelwert", "Erwartet" );
        obj.out.begin_itemize();
		% Schleife über alle Jahre
		for i=1:length(years)
		    if (isnan(prediction(i)))
			  obj.out.item("Es liegen keine Einstrahlungsdaten für %d vor.",years(i));
			  continue; % Für den letzten Monat liegen ggf. noch keine Einstrahlungsdaten vor.
			endif
		    obj.out.begin_item();
			h = 100*energy(i)/prediction(i);
			obj.out.par("In %d Ertrag %.0f kWh, erwartet %.0f kWh, relativ %.1f %%.", ...
			  years(i),energy(i),prediction(i),h );
			p_ref  = performance(i);
			p_real = interp1( obj.P.month, obj.P.performance_corrected, d(i), 'nearest');
			p_text = "OK";
			check = false;
			if (p_real>p_ref+2*obj.P.p_rest)
			  p_text = "sehr gut";
			elseif (p_real>p_ref+obj.P.p_rest)
			  p_text = "gut";
			elseif (p_real<p_ref-2*obj.P.p_rest)
			  p_text = "schlecht";
			  check = true;
			elseif (p_real<p_ref-obj.P.p_rest)
			  p_text = "schlecht";
			endif
			obj.out.par("Ausbeute %.2f, Erwartung %.2f, dies ist %s.", ...
			  p_real, p_ref, p_text );
			if (check)
			  if (obj.is_bad_month(m))
				obj.out.text("Der Monat %s fällt häufiger schlecht aus. Lag eventluell Schnee auf der Anlage?.", ...
				obj.monatsnamen{m} );
			  else
				obj.out.text("Das ist nicht typisch, prüfe die Anlage.");
			  endif
			endif
            obj.out.end_item();
		endfor
		obj.out.end_itemize();
      endif
      hold off;
      tit = sprintf("Ertrag für den Monat %s",obj.monatsnamen{m});
      title( tit );
      ylabel("Ertrag in kWh/month");
      xlabel("Jahre");
      file = sprintf("EnergieMonat_%02d.png",m)
      print( file );
      obj.out.file2image( file, tit );
    endfunction
    
    
    % Zeichne die korrigierte Ausbeute
    function plot_performance_corrected( obj )
      % todo, check correction and regression !
      % evaluate performance
      obj.eval_performance();
       
      plot( obj.P.month, obj.P.performance, "o");
      leg = { "Ausbeute" };
      hold on;
      if (obj.has_corrections())
        plot( obj.P.month, obj.P.performance_corrected, "+" );
        leg = [ leg; "... korrigiert" ];
      endif
      
      if (isfinite(sum(obj.P.p)))
        plot( obj.P.month_selected, obj.P.performance_corrected_selected, "*",
            obj.P.month, polyval(obj.P.p,obj.P.month-obj.P.month_selected(1)),
            obj.P.month, ones(size(obj.P.month))*(obj.P.p(2)-obj.P.p_rest*2) );
        leg = [ leg; {"... ausgewählt"; "Regression"; "Grenze"} ];
      endif
      hold off;
      title("Ausbeute und Regressionsanalyse");
      xlabel("Monat.Jahr");
      datetick( "mm.yyyy", "keeplimits");
      ylabel("Ausbeute");
      legend( leg , "location", "NorthEastOutside" );
      print("AusbeuteKorrigiert.png");
      obj.out.file2image("AusbeuteKorrigiert.png","Ausbeute und Regressionsanalyse");
    endfunction
    
    function plot_bad_month( obj )
      % Visualisiere die Monate in denen die Ausbeute häufig schlecht ausfällt.
	  % Dies sind typischerweise die Wintermonate
      obj.eval_performance()              
      
      bar( obj.P.bad_month_count );
      hold on;
      plot( 1:12, ones(1,12)*obj.P.bad_month_limit);
      hold off;
      title(" Monate mit schlechter Ausbeute " );
      xlabel(" Monat " );
      ylabel("Anszahl Monate mit schlechter Ausbeute" );
      legend("Anzahl", "Mittelwert","location","north");
      print("SchlechteMonate.png");
      obj.out.file2image("SchlechteMonate.png", " Monate mit schlechter Ausbeute ");
    endfunction           
    
    % Zeichne die Ausbeute im Jahresverlauf 
    function plot_performance_month( obj )
      obj.eval_monthly_performance(); % evaluate if required
      %  bar plot
      bar(obj.M.M);
      hold on;
      errorbar( obj.M.P(:,1), obj.M.P(:,2) );
      hold off;
      title("Ausbeute im Jahresverlauf");
      ylabel("Ausbeute");
      xlabel("Monat");
      legend( [ cellstr( num2str(obj.M.years') ); "Beste Monate" ], "location", "NorthEastOutside");
      print("AusbeuteMonatlich.png");
      obj.out.file2image( "AusbeuteMonatlich.png", "Ausbeute im Jahresverlauf");
    endfunction
    
    % Auswertung der Ausbeute, Ergebnisse in P speichern
    function eval_performance( obj )
      % Prüfe ob die Auswertung schon einmal gelaufen ist
      if (! isempty(obj.P) )
        return
      endif
      % Werte die monatliche Ausbeute aus.
      obj.eval_monthly_performance(); 
      % Erzeuge die Datenstruktur
      obj.P = struct("month",[],"performance",[],"performance_corrected", [], ...
        "month_selected",[], "performance_corrected_selected", [], ...
        "p",[], "p_std",[], "p_rest", NA , "yearly_decrease", NA);
      % gemeinsame Monate für die Auswertung
      ra_d = obj.ra.datenum();
      pv_d = obj.pv.datenum();
      obj.P.month = intersect( ra_d, pv_d);
      spec_energy = interp1( pv_d, obj.pv.specific_energy(), obj.P.month);
      radiation = interp1( ra_d, obj.ra.radiation, obj.P.month );
      month_numbers = interp1( pv_d, obj.pv.month, obj.P.month);
      % Berechne die Ausbeute und die korrigierte Ausbeute
      obj.P.performance = zeros( size(spec_energy) );
      obj.P.performance_corrected = zeros( size(spec_energy) );
      for i=1:length(obj.P.performance);
        obj.P.performance(i)  = spec_energy(i)/radiation(i);
        obj.P.performance_corrected(i) = obj.P.performance(i)/obj.M.P( month_numbers(i) );
      end;
      % Ignoriere die schlechtesten 20 % der Ausbeute (Typisch Wintermonate mit Schnee)
      q = quantile( obj.P.performance_corrected, .2 );
      sel = obj.P.performance_corrected>=q;
      obj.out.par("Wähle %d Monate von %d mit einer Ausbeute >=%.2f aus.\n",...
        sum(sel),length(obj.P.performance_corrected),q);
      obj.P.performance_corrected_selected = obj.P.performance_corrected( sel );
      obj.P.month_selected = obj.P.month( sel );
      
      % correlation tests
      if (length(obj.P.performance_corrected)<6 || sum(sel)<3)
        obj.out.par("Nicht genügend Daten für eine Regressionsanalyse");
        obj.P.yearly_decrease      = NA;
        obj.P.p = [NA,NA];
        obj.P.p_std = [NA,NA];
        obj.P.p_rest = NA;
        obj.P.bad_month_count = zeros(12,1);
        obj.P.bad_month_limit = 0;
        return
      endif
      
      obj.out.subsection("Regressionsanalyse");
      [p, s] = polyfit(obj.P.month_selected-obj.P.month_selected(1),obj.P.performance_corrected_selected,1);
      p_std = sqrt (diag (s.C)/s.df)*s.normr; % octave manual, polyfit
      p_rest = std(polyval(p,obj.P.month_selected-obj.P.month_selected(1))-obj.P.performance_corrected_selected);
      obj.out.par(" Ausgewählte Monate:  Standardabweichung Achsenabschnitt %.3f, Standardabweichung der Steigung %.3f, Standardabweichung nach Regression %.3f\n",...
        p_std(2),p_std(1)*365,p_rest );

      % regression
      obj.P.yearly_decrease      = -p(1)*365;
      initial_performance  = p(2);
      obj.out.subsection("Regressionsanalyse anhand der ausgewählten Daten\n");
      obj.out.par(" Anfängliche Ausbeute %.2f +- %.2f\n",initial_performance, p_std(2));
      obj.out.par(" Jährliche Abnahme der Ausbeute %.3f +- %.3f\n",obj.P.yearly_decrease, p_std(1)*365);
      obj.out.par(" Relative jährliche Abnahme der Ausbeute %.1f %% +- %.1f %%\n", ...
        100*obj.P.yearly_decrease/initial_performance, 100*p_std(1)*365/initial_performance);

      % store regression
      obj.P.p = p;
      obj.P.p_std = p_std;
      obj.P.p_rest = p_rest;
    endfunction
    
    % run after eval_performance()
    function eval_bad_month( obj )  
      % make sure the eval_performanc had been run 
      obj.eval_performance();
      
      if ( obj.P.p_rest==NA )
        out.obj.par("Nicht genügend Daten für die Auswertung von Monaten mit geringer Ausbeute.");
        return;
      endif
      
      % list non selected month and count bad month ..
      sel = ( obj.P.performance_corrected - polyval(obj.P.p,obj.P.month-obj.P.month_selected(1)) )< -2*obj.P.p_rest;
      month_bad = obj.P.month( sel );
      perf_bad  = obj.P.performance( sel );
      perf_corr_bad  = obj.P.performance_corrected( sel );
      count = zeros(12,1); % count bad month
      n = length(month_bad);
      
      if (n>0)
        obj.out.subsection("Liste der Monate mit schlechter Ausbeute");
        obj.out.par([
          "Schlechte Monate sind die, in denen die Ausbeute mehr als zweimal die Standardabweichung "...
		  "unter dem Mittelwert liegt. "]);
        % Cell Array mit den Ergebnissen, die erste Spalte enthält die Beschriftung
        C = cell(1+length(month_bad), 5);
        C{1,1} = "Jahr";
        C{1,2} = "Monat";
        C{1,3} = "Ausbeute";
        C{1,4} = "Ausbeute korrigiert";
        C{1,5} = "Ausbeute erwartet";
        for i=1:n
          dv = datevec( month_bad(i));
          C{i+1,1} = num2str(dv(1));
          C{i+1,2} = num2str(dv(2));        
          C{i+1,3} = sprintf("%.2f",perf_bad(i));
          C{i+1,4} = sprintf("%.2f",perf_corr_bad(i));
          C{i+1,5} = sprintf("%.2f",polyval(obj.P.p,month_bad(i)-obj.P.month_selected(1)) );
          count( dv(2) )++;        
        endfor
        obj.out.cell2table( C );
		% Festlegen der Grenze
        % obj.P.bad_month_limit = mean( count(count>0) );  % Als Mittelwert der schlechten Monate 
		obj.P.bad_month_limit = obj.q_schlecht * (obj.pv.last_time()-obj.pv.first_time())/365; % In mehr als der Hälfte der Jahre
        obj.out.par("Die Grenze für schlechte Monate liegt bei %.2f", obj.P.bad_month_limit);
      else
       obj.out.par("Keine schlechten Monate erkannt.");
        obj.P.bad_month_limit = 0;
      endif
      obj.P.bad_month_count = count; 
    endfunction    
    
    % Prüfe auf schlechten Monat
    function bad = is_bad_month( obj, m );
      % Führe falls erforderlich die Auswertung druch
      obj.eval_performance();
      % Prüfe
      bad = obj.P.bad_month_count(m)>obj.P.bad_month_limit;
    endfunction

    % Monateliche Auswertung der Ausbeute, speichere in M
    function eval_monthly_performance( obj )
      if (! isempty(obj.M) )
        return
      endif
      % Erzeuge die Struktur M
      obj.M = struct("M",[],"P",[],"years",[]);
      % Erzeuge Matrix, Zeilen Monate, Spalten Jahre
      first_year = max( obj.ra.year(1), obj.pv.year(1));
      last_year = min( obj.ra.year(end), obj.pv.year(end));
      obj.M.years = first_year:last_year;
      obj.M.M  = zeros( 12,length(obj.M.years))*NA;
      % Specific Energie in Matrix
      se = obj.pv.specific_energy();      
      SE = zeros( 12,length(obj.M.years))*NA; 
      for i=1:length(se)
        SE( obj.pv.month(i), obj.pv.year(i)+1-first_year) = se(i);
      endfor
      % Performance (Ausbeute) in Matrix ( specific energy / radiation )
      for i=1:length(obj.ra.radiation)
        m = obj.ra.month(i);
        y = obj.ra.year(i)+1-first_year;
        if (y<1 || y>length(obj.M.years))
          continue;
        endif
        obj.M.M( m, y) = SE(m,y) / obj.ra.radiation(i);
      endfor
      % Ausbeute für jeden Monat auswerten
      % Es werden mindestens 3 Auswertungen benötigt damit eine Statistik gebildet werden kann.
      obj.M.P = zeros(12,2);
      % Die erste Spalte enthält die Beschreibungen
      fC = cell(13,5);
      C{1,1} = "Monat";
      C{1,2} = "Mittelwert (alle)";
      C{1,3} = "Standardabweichung(alle)";
      C{1,4} = "Mittelwert (gute)";
      C{1,5} = "Standardabweichung (gute)";
      % Werte die einzelnen Monate aus
      for i=1:12
        performance = obj.M.M(i,:); % Ausbeute im Monat i
        performance = performance( isfinite(performance) ); % Ignoriere NA werte (Inbetriebnahmejahr)
        if (length(performance)<3)
          obj.out.par("Es werden mindestens drei vollständige Betriebsjahre für die statistische Korrektur benötigt.");
          obj.M.P(:,1) = 1;
          obj.M.P(:,2) = NA;
          break;
        else
          q  = quantile( performance, obj.q_schlecht ); % 40 % Quanitil value
          pq = performance( performance>=q ); % best 60 % of performance data          
          obj.M.P(i,1) = mean(pq);
          obj.M.P(i,2) = std(pq);
          C{i+1,1} = datestr([2018,i,1,0,0,0],"mmmm");
          C{i+1,2} = sprintf("%.3f", mean(performance) );
          C{i+1,3} = sprintf("%.3f", std(performance) );
          C{i+1,4} = sprintf("%.3f", mean(pq) );
          C{i+1,5} = sprintf("%.3f", std(pq) );
        endif
      endfor
      if ( obj.has_corrections() )
        obj.out.par( [
          "Werte die Ausbeute (Ertrag/Anlagengröße/Einstrahlung) ", ...
          "für jeden Monat aus. Wähle die besten 60 %% der Ausbeuten jedes Monats ", ...
          "für die Berechnung der Korreturen (Mittelwert und Standardabweichung)." ]);
        obj.out.cell2table(C);
      endif
    endfunction
    
    % Check if monthly corrections exist, see eval_monthly_performance
    function ok = has_corrections( obj )
      ok = isfinite(sum(obj.M.P(:,2)));
    endfunction
    
  endmethods    
      
endclassdef  


