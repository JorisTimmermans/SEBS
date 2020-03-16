function Write_ErrorsFile(Diagnostics_msg,Diagnostics_value)
filename                            =   'diagnostics.xml';

%% remove file
switch Diagnostics_msg
    case 'clear'
        try
            delete(filename)
        end
end

%% open file
fid                                 =   fopen(filename,'a+');

%% Write to file
switch Diagnostics_msg    
    case 'clear'
    case 'new'        
        fprintf(fid,'<?xml version="1.0" encoding="utf-8"?>\r\n');
        fprintf(fid,'<Diag xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ');
        fprintf(fid,'xsi:schemaLocation="http://www.wldelft.nl/fews/PI http://fews.wldelft.nl/schemas/version1.0/pi-schemas/pi_diag.xsd" ');
        fprintf(fid,'version="1.2" xmlns="http://www.wldelft.nl/fews/PI">');
        fprintf(fid,'\r\n');
    case 'end'
        fprintf(fid,'</Diag>');
    otherwise
        try
        fprintf(fid,'\t<line level="%01.0f" description="%s"/>\r\n',Diagnostics_value,Diagnostics_msg);
        catch
            keyboard
        end
end

%% verbose
switch Diagnostics_msg
    case {'clear','new','end'}
    otherwise
        if Diagnostics_value==3
            fprintf('%s\n',Diagnostics_msg)
        else
            fprintf('\t-%s\n',Diagnostics_msg)
        end
end
%% close file
% fprintf('close file')
try
    fclose all;
end


%% 
% All model diagnostics output that is generated during and at the end of a run by a module should go in this file.
% Each line/mesasage contains the actual text and a warning level. each message/line has a level attached to it
% 4 = SUCCESS (information, all is well, e,g, :"SOBEK: program ended")
% 3 = info (information, all is well, e,g, :"SOBEK: program ended")
% 2 = warn (warning information. e.g. "SOBEK: high number of iterations")
% 1 = error (critical problems. e.g. "SOBEK: no convergence")
% 0 = fatal (full module crash. e.g. "SOBEK: ooops, what now?")
% All levels higher than 3 are regarded as non-essential (debug) information
% use this field as a notebook to add comments, suggestions description of data entered etc.
				
			
		