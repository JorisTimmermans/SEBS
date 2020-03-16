function [Error,Tiles] = Download_MODIS_Data(VarMODIS,Location, startdate,enddate)
global datadir

Write_ErrorsFile('Invoking function "Download_Data_MODIS"',3)
Error.Value                                 =   0;
Error.msg                                   =   '';


Write_ErrorsFile(sprintf('Downloading MODIS Data'),4)
clear URLdir

for ivar=1:length(VarMODIS)    
    subdir                                                =   VarMODIS(ivar).name;
    Productname                                         =   VarMODIS(ivar).Productnames;
    Versionname                                         =   VarMODIS(ivar).Versionnames;
    
    Dirname                                             =   VarMODIS(ivar).Dirnames;
    path2file                                           =   [datadir.MODIS,subdir,'/'];
	Grid                                                =   VarMODIS(ivar).Grid;
    TemporalRes                                       	=   VarMODIS(ivar).Frequency;
    
    %% Trace back data     
    Missingdate                                         =   1;
    pastday                                             =   0;
    
    while (Missingdate>0) && pastday<=TemporalRes
        %% Time of data to download 
        [year, month ,day,~,~]                          =   datevec(startdate - pastday);
       	if TemporalRes==0
            month                                       =   01;
            day                                         =   01;
        end
        
        doy                                         	=   datenum(year,month,day)-datenum(year,1,0);
        timestr                                         =   sprintf('%04.0f.%02.0f.%02.0f',year,month,day);
        timestr2                                        =   sprintf('%04.0f%03.0f',year,doy);
          
        %% Switch between tiled data and CMG format. 
        switch Grid
            case 'Tile'
                % Select tiles
                [Tiles,Ntiles]                          =   MODIS_Data_Select_Tiles(Location);
                
                missingfiles                            =   -1;
                h                                       =   waitbar(0,'Please wait...');
                for itile=1:Ntiles
                    if missingfiles<10
                        waitbar(itile/Ntiles,h,sprintf('Searching Online Repository, %02.0f%%',itile/Ntiles*100))
                        
                        %% Define filename to download
                        tileh                        	=   Tiles(itile,1);
                        tilev                           =   Tiles(itile,2);
                        tilestr                         =   sprintf('h%02.0fv%02.0f',tileh,tilev);
                        filestr                         =   [Productname,'.A',timestr2,'.',tilestr];

                        %URL search directory
                        URLdir                          =   ['http://e4ftl01.cr.usgs.gov/',Dirname,'/',Productname,Versionname,'/',timestr,'/'];

                        %% Find Filename and Download
                        Write_ErrorsFile(sprintf(['Searching Online Repository for ',subdir,'-Data']),4)
                        missingfile                     =   Download_MODIS_Data_FileTransfer(URLdir,filestr,path2file);
                        missingfiles                   	=   missingfiles + missingfile;

                    else
                        %% Skipping Rest of download, too many tiles missing
                        waitbar(itile/Ntiles,h,sprintf('Skipping Rest of download, too many tiles missing, %02.0f%%',itile/Ntiles*100))
                    end
                end
                Missingdate                             =   missingfiles>=10;
                close(h)
                pause(0.1)

            case 'CMG'
                
                %% Define filename to download
                filestr                                 =   [Productname,'.A',timestr2,'.'];

                %URL search directory
                URLdir                                  =   ['http://e4ftl01.cr.usgs.gov/',Dirname,'/',Productname,Versionname,'/',timestr,'/'];

                %% Find Filename and Download
                Write_ErrorsFile(sprintf(['Searching Online Repository for ',subdir,'-Data']),4)
                Missingdate                             =   Download_MODIS_Data_FileTransfer(URLdir,filestr,path2file);
        end
        
        pastday                                         =   pastday+1;
    end    
end


