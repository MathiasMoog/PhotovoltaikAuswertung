% Class for simple html output

% Copyright 2019 bei Mathias Moog, Hochschule Ansbach, Deutschland
% Dieser Code steht unter der Creative-Commons-Lizenz Namensnennung - Nicht-kommerziell - 
% Weitergabe unter gleichen Bedingungen 4.0 International. 
% Um eine Kopie dieser Lizenz zu sehen, besuchen Sie http://creativecommons.org/licenses/by-nc-sa/4.0/

% Diesen Code habe ich für die Verwendung in meinen Lehrveranstaltungen und für Studierende
% an der Hochschule Ansbach geschrieben. Ich kann nicht garantieren, dass er fehlerfrei funktioniert.
% Für Hinweise und Verbesserungsvorschläge bin ich dankbar.

% Ich selbst arbeite vorwiegend mit Octave, https://www.gnu.org/software/octave/, da dies freie 
% Software ist und sie auf jedem Rechner installiert werden kann. 
% Diese Code läuft auch in Matlab. Die wichtigsten zu beachtenden Punkte sind:
% - Keine spezifischen end Befehle wie endfor oder endfunction sondern immer end verwenden
% - Texte in einfachen Anführungszeichen
% - Matlab Dokumentationsstil verwenden


classdef html_output  < handle
  % Class for simple html output.
  % Create an instance with obj = html_output( ... )
  % This starts an html file. Afterwards you add text, figurs etc. to the
  % html page. You can open the html page after you called close().
  % 
  % Use only basic HTML commands.
  % See https://www.w3schools.com/html/default.asp
  
  properties ( Access = public )
    % Pointer to output file
    fp=-1; 
  end
  
  methods
    
    function obj = html_output(file, title, author)
      % Create Instance, open output file and create the title.
      %   obj = htm_output( file, title
      %
      % file - file name without extension
      % title - title of html page
      % author - Author
      %
      % Create / Overwrite the html file. Start the html code add
      % a line with the Autor name and the date.
      %
      % There is a simlar class latex_output with the same methods.
      % Up to now I had not found the time to create a superclass.
      % The method names in this class are simlar to latex commands.
      
      % open file, override existing file
      obj.fp = fopen( [file,'.html'] , 'w' );
      if (obj.fp==-1)
        error('Could not open file');
      end
      % print header Endodings: 8859-1 oder UTF-8
      fprintf(obj.fp, '<!DOCTYPE html>\n<html>\n<head>\n <meta charset="UTF-8">\n<title>%s</title>\n</head>\n<body>\n\n',title);
      % use title as main title on level h1
      fprintf(obj.fp, '\n<h1>%s</h1>\n\n',title);
      % Add author and creation dat.
      fprintf(obj.fp, '<p>%s %s</p>\n\n', author, datestr(now(),'dd.mm.yyyy'));
     end
    
    function close(obj)
      % Close HTML file.
      %  obj.close()
      % 
      % You must close the html file befor you open it in a web browser.
      % This method writes the thml footer and closes the output file. You
      % must not write anything to the file after closing.
      
      % print footer
      fprintf(obj.fp, '</body>\n</html>\n');
      fclose(obj.fp);
      obj.fp=-1;
    end
    
    function clean(obj)
      % Only for compatibility tiwh latex_output class.
      % Does nothing.
    end
    
    function chapter(obj, title)
      % Start a new chapter.
      %
      %  obj.chapter( title )
      %
      % title - chapter title
      %
      % Use h2 in thml code for the chapter title
      
      fprintf(obj.fp, "\n<h2>%s</h2>\n\n",title);
    end
    
    function section(obj, title)
      % Start a new section.
      %
      %  obj.section( title )
      %
      % title - section title
      %
      % Use h3 in thml code for the section title
      
      fprintf(obj.fp, "\n<h3>%s</h3>\n\n",title);
    end
    
    function subsection(obj, title)
      % Start a new subsection.
      %
      %  obj.subsection( title )
      %
      % title - subsection title
      %
      % Use h3 in thml code for the subsection title
      
      fprintf(obj.fp, "\n<h4>%s</h4>\n\n",title);
    end
    
    function par( obj, format, varargin )
      % Add a (short) paragraph.
      %  obj.part( format, varargin )
      %
      % format - format string as in printf
      % varargin - additional arguments for printf
      %
      % Create a Paragraph enclosed in <p> </p>. Use printf
      % for formated output.
      %
      % See also html_output.begin_par, html_output.end_par,
      % html_output.text
      
      fprintf(obj.fp,"<p>\n");
      fprintf(obj.fp,format,varargin{:});
      fprintf(obj.fp,"<p>\n");
    end
    
    function begin_par( obj)
      % Begin a new paragraph
      % obj.begin_par()
      %
      % This method prints <p> to the html file and starts a new pragraph.
      % You can use the text and the end_par Method to add text to the
      % paragraph and to close the paragraph.
      %
      % See also html_output.par, html_output.end_par,
      % html_output.text
      
      fprintf(obj.fp,"<p>\n");
    end
    
    function end_par( obj)
      % End a paragraph.
      % obj.end_par()
      %
      % This method prints </p> to the html file and closes a pragraph.
      %
      % See also html_output.par, html_output.begin_par,
      % html_output.text
      
      fprintf(obj.fp,"</p>\n");
    end
    
    function text( obj, format, varargin )
      % Add text to a paragraph
      % obj.text( format, varargin )
      %
      % format - format string as in printf
      % varargin - additional arguments for printf
      %
      % Use printf for formated output.
      %
      % You might use any html code here, but the basic idea was to have
      % a simple format independend output interface for html and latex
      % code.
      %
      % See also html_output.par, html_output.begin_par,
      % html_output.par_end
      
      fprintf(obj.fp," "); % add a white space 
      fprintf(obj.fp,format,varargin{:});
    end
    
    
    
    % list with bullets
    function begin_itemize( obj )
      % Start a List with bullets.
      %  obj.begin_itemize
      %
      % Use <ul> for html list without numbers
      %
      % See also html_output.end_itemize, html_output.item,
      % html_output.begin_enumerate
      
      fprintf(obj.fp,"<ul>\n");
    end
    
    function end_itemize( obj )
      % Terminate a List with bullets.
      %  obj.end_itemize
      %
      % Use </ul> to end html list without numbers
      %
      % See also html_output.begin_itemize, html_output.item,
      % html_output.begin_enumerate
      
      fprintf(obj.fp,"</ul>\n");
    end
    
    function begin_enumerate( obj )
      % Start a List with numbers.
      %  obj.begin_enumerate
      %
      % Use <ol> for html list with numbers
      %
      % See also html_output.end_enumerate, html_output.item,
      % html_output.begin_itemize
      
      fprintf(obj.fp,"<ol>\n");
    end
    
    function end_enumerate( obj )
      % End a List with numbers.
      %  obj.end_enumerate
      %
      % Use </ol> for html list with numbers
      %
      % See also html_output.begin_enumerate, html_output.item,
      % html_output.begin_itemize
      
      fprintf(obj.fp,"</ol>\n");
    end
    
    % list item, used printf
    function item( obj, format, varargin )
      % End a List with numbers.
      %  obj.end_enumerate
      %
      % format - format string as in printf
      % varargin - additional arguments for printf
      %
      % Add an item to a list with or without numbers. Use printf for
      % formated output.
      %
      % See also html_output.begin_enumerate, html_output.begin_itemize
      
      fprintf(obj.fp,"  <li> ");
      fprintf(obj.fp,format,varargin{:});
      fprintf(obj.fp," </li>\n");
    end
	
    % list item, begin
    function begin_item( obj)    
      fprintf(obj.fp,"  <li> ");
    end
	
    % list item, end
    function end_item( obj)    
      fprintf(obj.fp,"  </li> ");
    end
    
    function cell2table( obj, tab )
      % Convert a 2D cell arry of strings to an table.
      %  obj.cell2table( tab )
      %
      % tab - 2D cell array of strings
      %
      % The first row in the cell arrray is used as header line.
      % Use the html table environment.
      
      fprintf(obj.fp,"\n\n<table>\n");
      for i=1:size(tab,1) % rows
        fprintf(obj.fp,"  <tr>\n");
        for j=1:size(tab,2) % columns  
          if( i==1)
            fprintf(obj.fp,"    <th> %s </th>\n",tab{i,j});
          else
            fprintf(obj.fp,"    <td> %s </td>\n",tab{i,j});
          end
        end
        fprintf(obj.fp,"  </tr>\n");
      end
      fprintf(obj.fp,"</table>\n\n");
    end
    
    % table from description (1d cell array of strings), matrix with numbers, and format string for the numbers
    function matrix2table( obj, desc, matrix, format )
      % Convert a matrix to an table.
      %  obj.matrix2table( desc, matrix, format )
      %
      %  desc - 1D cell array with column titles. Must have the same number
      %  of colums as matrix
      %  matrix - 2 D matrix with numbers
      %  format - format string for printf to format the numbers.
      %
      %  Use the html table environment.
      
      assert(length(desc)==size(matrix,2));
      
      fprintf(obj.fp,"\n\n<table>\n");
      % title, descr cell array
      fprintf(obj.fp,"  <tr>\n");
      for j=1:length(desc) % columns
        fprintf(obj.fp,"    <th> %s </th>\n",desc{j});
      end
      fprintf(obj.fp,"  </tr>\n");
      % Matrix
      for i=1:size(matrix,1) % rows
        fprintf(obj.fp,"  <tr>\n");
        for j=1:size(matrix,2) % columns  
          fprintf(obj.fp,"    <td> ");
          fprintf(obj.fp,format,matrix(i,j));
          fprintf(obj.fp," </td>\n");
        end
        fprintf(obj.fp,"  </tr>\n");
      end
      fprintf(obj.fp,"</table>\n\n");
    end
        
    function file2image( obj, file, description )
      % Add an image file.
      %  obj.file2image( file, description )
      %
      %  file - file name, must be a valid graphic file (png etc.)
      % description - description text, used as alt text in html
      %
      % Add the Image with the html src command.
      
      fprintf(obj.fp,'\n<p>\n<img src=\"%s\" alt=\"%s\" style=\"width:100%%\">\n</p>\n',file, description);
    end
    
    function code = code( obj, text )
      % Escape special latex characters, nothing to do for html code return text
      
      code = text;
    end
    
    function label( obj, id )
      % Add a label using the id attribute
      
      fprintf(obj.fp,'<a id=\"%s\"></a>',id);
    end
    
    function ref( obj, id, text )
      % Add a internal reference to a label using <a href=# ...      
      fprintf(obj.fp,'<a href=\"#%s\">%s</a>',id,text);
    end
    
    function url( obj, url, text )
      % Add a external reference to a label using <a href= ...      
      fprintf(obj.fp,'<a href=\"%s\">%s</a>',id,text);
    end
    
    
    
  end
  
end
    
    
    
      
        