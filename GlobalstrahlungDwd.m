% Zugriff auf die Globalstrahlungsdaten des DWD (esri ascii grid format)

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

% Dieser Code nutzt die Wetterdaten vom Deutschen Wetterdienst (DWD)
% Nutzungsbedingungen und Referenzen siehe
% ftp://ftp-cdc.dwd.de/climate_environment/CDC/grids_germany/monthly/radiation_global/


classdef GlobalstrahlungDwd  < handle
  % Liest Globalstrahlungsdaten vom ftp Server des dWD im esri grid Format.
  %
  % Mit read_ftp_file() werden die Daten (eine Datei) heruntergeladen und in den Feldern
  % dieses Objektes gespeichert.
  %
  % Unter baseUrl finden sich zip Dateien. Diese können auch manuell herunter 
  % geladen werden. Auf lokalen Dateien arbeiten die Mehtoden 
  % read_zip_file und read_asc_file.
  %
  % Das Dateiformat ist dokumentiert, siehe 
  % BESCHREIBUNG_gridsgermany_monthly_radiation_global_de.pdf auf dem FTP Server.
  %
  % Diese Klasse verwendet "< handle" (handle class), damit werden Kopien der Gitter Daten
  % vermieden.
  
  properties (Constant = true)
    % Basis name, fest eingestellt auf Globalstrahlung
    baseName = "grids_germany_monthly_radiation_global_";
    % Basis url, Hier liegen die Daten und die Beschreibung
    baseUrl = "ftp://ftp-cdc.dwd.de/climate_environment/CDC/grids_germany/monthly/radiation_global/"
  end
  
  properties ( Access = public )
    % Year
    year=NaN;
    % Month
    month=NaN;
    % Number of columns
    ncols=NaN;
    % Number of rows
    nrows=NaN;
    % Lower Left x Position (West) in Gauss-Krüger Coordinates
    xllcorner=NaN;
    % Lower Left y Postion (South) in Gauss-Krüger Coordinates
    yllcorner=NaN;
    % Cellsize in m
    cellsize=NaN;
    % Value for Nodata
    nodata_value = NaN;
    % Grid data, Matrix of size nrows, ncols
    data = [];
    % X-Values of the underlying Grid (meshgrid)
    xgrid = [];
    % Y-Values of the unterlying Grid (meshgrid)
    ygrid = [];
  end
  
  methods
    
    function ok = read_ftp_file( obj, year, month, dir, del )
      % Get file from ftp server store local and read it.
      %  ok = read_ftp_file( obj, year, month, del = true )
      %
      % year - year, used to create filename
      % month - month, used to create filename
      % dir - directory to stor the file, default ist working directory (empty string)
      %  must end with /
      % del - delete file after reading
      
      zip = sprintf( '%s%04d%02d.zip', obj.baseName,year,month );
      file = strcat(dir, zip);
      % check if file exist  ....
      if (exist( file ) ~= 2 )
        % Does not exist, download
        % Achtung, Matlab will kein string Argument in urlwrite
        [f, s] = urlwrite( char(strcat(obj.baseUrl, zip)), char(file) );
        if (s==0)
          printf("Keine Daten fuer %d.%d\n", year,month );
          ok = false;
          return;
        end
      end
      % read zip file       
      ok = obj.read_zip_file( file, true );
      % delete if required
      if (del)
        delete( file );
      end
      end
    
      
    
    % Read grid data from zip file 
    % Unzip file in working directory and delete it afterwards
    function ok = read_zip_file( obj, fileName, del )
      % Achung, hier scheitert Matlab, unpack ist nur in Octave verfügbar.
      unpack(fileName);
      %asc_file_name = strrep( fileName, ".zip", ".asc" );
      [dir, name, ext] = fileparts ( fileName );
      asc_file_name = [ name, ".asc" ];
      ok = read_asc_file( obj, asc_file_name );
      if (del)
        delete(asc_file_name);
      end
    end
    
    
    % Read grid data from ascii file 
    % Tried with zip file and "rbz" mode, but this does not work on windows
    function ok = read_asc_file( obj, fileName )
      % empty all scalar fields
      obj.setempty()
      % open file for reading
      fd = fopen( fileName, "r");
      if (fd<0) 
        puts("Reading file failed");
        ok = false;
        return;
      end

      % Read Header, ignore all messages beside year and month
      % Hm, hier wollte ich eigentlich auch mit reflection arbeiten, aber isprop liefert immer
      % false.
      do
        str = fgetl( fd );
        [ values, count] = sscanf( str, "Jahr=%d" );
        if (count==1) 
          obj.year = values(1);
        end
        [ values, count] = sscanf( str, "Monat=%d" );
        if (count==1) 
          obj.month=values(1);
        end
        %printf("Header: %s \n",str);
      until ( strcmp(str, "[ASCII-Raster-Format]") );
      
      % Read section ASCII-Raster-Format, use reflection. Property names in the 
      % file in upper cases, in the class in lower cases.
      % Sorry fscanf with %s cause problems. It does not stop at white spaces
      % Assume fixed order ..
      %NCOLS 654
      %NROWS 866
      %XLLCORNER 3281000
      %YLLCORNER 5238000
      %CELLSIZE 1000
      %NODATA_VALUE -999
      
      %[v1, v2, count] = fscanf( fd, "%s %d", 6);
%      [values, count] = fscanf( fd, "%s %d", 6);
%      if (count!=6) 
%        puts("Raster Format specification missing");
%        fclose(fd);
%        ok=false;
%        return;
%      endif
%      obj.ncols = values(1);
%      obj.nrows = values(2);
%      obj.xllcorner = values(3);
%      obj.yllcorner = values(4);
%      obj.cellsize = values(5);
%      obj.nodata = values(6);
      C = textscan(fd,"%s %d",6);
      n = size(C{1},1);
      for i=1:n
        obj.(tolower(C{1}{i})) = C{2}(i);
      end
      
      % read data
      obj.data = dlmread( fd, "emptyvalue", double(obj.nodata_value));
      obj.data = resize( obj.data, obj.nrows, obj.ncols); % sometimes one row more (empty line)
      obj.data( obj.data<=obj.nodata_value ) = NA; % be carefull ..
      
      % close file
      fclose(fd);
      
      % create meshgrid, take care to get double precision grids
      x = double(obj.xllcorner) + double(obj.cellsize)*linspace(0.0, obj.ncols-1, obj.ncols);
      y = double(obj.yllcorner) + double(obj.cellsize)*linspace( obj.nrows-1, 0.0, obj.nrows);
      assert(length(x)==obj.ncols);
      [obj.xgrid, obj.ygrid] = meshgrid(x,y);
      
      % check ..
      ok = ~obj.isempty();
      
    end % read_asc_file
    
    % Interpoliere die Gitterdaten. 
	% x und y in Gauß-Krüger Koodinaten im 3. Streifen
	% radiation (Rückgabe) - Monatliche Globalstrahlung in kWh/m^2/Monat
	% Siehe Beschreibungsdatei auf dem FTP Server des DWD (baseUrl)
	% Koordinaten können z.B. mit https://epsg.io/ umgerechnet oder auf einer Karte ausgewählt werden
    function radiation = interp( obj, x, y )
      radiation = interp2(obj.xgrid,obj.ygrid,obj.data, x, y);
    end
    
    % Plot data, view from top
    function plot_top(obj)
      surf(obj.xgrid,obj.ygrid,obj.data)
      view(0,90) % set view from top
    end
      
    % set all scalar fiels to NA
    function setempty(obj)
      obj.year=NA;
      obj.month=NA;
      obj.ncols=NA;
      obj.nrows=NA;
      obj.xllcorner=NA;
      obj.yllcorner=NA;
      obj.cellsize=NA;
      obj.nodata_value = NA;
    end
    
    % Check for empty data
    function empty = isempty( obj )
      empty = ( obj.year==NA) | (obj.month==NA) | (obj.ncols==NA) | (obj.nrows==NA) | ...
        (obj.xllcorner==NA) | (obj.yllcorner==NA) | (obj.cellsize==NA) | (obj.nodata_value==NA) ;
    end
  end 
  
end  