function [missingfile]=Download_MODIS_Data_FileTransfer(URLdir,filestr,path2file)
if ~exist(path2file,'dir')
    mkdir(path2file)
end
missingfile                       	=   0;

try
    string                          =   urlread(URLdir);   
    Write_ErrorsFile(['SUCCESS. Data found, trying to download '],4)
    
    %find markers 
    istart                          =   strfind(string,filestr);    
    istart                          =   istart(1:2:end);            %seperate textname + link

    for j=1:length(istart)
        %reduce string
        substring                   =   string((0:50)+ istart(j));

        % find end marker (hdf") within the substring
        iend                        =   strfind(substring,'.hdf"');
        if ~isempty(iend)
            filename_hdf            =   substring(1:(iend+3));
            url2file                =   [URLdir,filename_hdf];

            %save file to disk
            try
                file                =   dir([path2file,filename_hdf]);
                if ~isempty(file)
                    Write_ErrorsFile('File already exists, skipping download',2)
                else
                    Write_ErrorsFile(sprintf('Downloading Data to %s:',[path2file filename_hdf]),4)
                    urlwrite(url2file,[path2file,filename_hdf]);
                end

                Write_ErrorsFile('SUCCESS.',5)
                missingfile                         =   -Inf;
            catch
                
                Write_ErrorsFile('FAIL, stream interrupted',0)                
                missingfile                         =   0;
            end
        end
    end
catch
    missingfile                                     =   1;
    Write_ErrorsFile('WARNING, NO Data found',2)
end