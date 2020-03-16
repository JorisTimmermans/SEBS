function [DataMODIS_Tile]   =   Read_MODIS_Data_Dynamic_Tile(VarMODIS,Sub, Location, startdate)
global datadir 

[Tiles]                                                         =   MODIS_Data_Select_Tiles(Location);
h_                                                              =   unique(Tiles(:,1));
v_                                                              =   unique(Tiles(:,2));
clear Tiles

Nr_pix_Tile_Output                                             	=   0300;                                                                   %Nr of Pix per Tile (corresponding to a res of 4km)
% Nr_pix_Tile_Output                                             	=   1200;                                                               %Nr of Pix per Tile (corresponding to a res of 1km)

%% Read Data
% note that LC has double the resolution of the Lat/Lon coordinates
Nr_pix_Tile_1000                                               	=   1200;
fprintf(1,'Reading MODIS Dynamic (Tiled)  Data\n');
for j=1:length(VarMODIS)        
    IdSDS                                                       =   VarMODIS(j).IdSDS;
    subdir                                                      =   VarMODIS(j).name;
    varname                                                     =   VarMODIS(j).Varname;
    
    
    %% Find observations (up to 1day/8day/16day time delay)
    file                                                        =   [];
    timestep                                                    =   0;
    sampling                                                    =   VarMODIS(j).Frequency;
    while isempty(file) && (timestep<=sampling)
        timestep                                                =   timestep +1; 
        [yyyy,~,~,~,~,~]                                        =   datevec(startdate);
        doy                                                     =   startdate - datenum(yyyy,01,00) - (timestep-1);
        timestr                                                 =   sprintf('%04.0f%03.0f',yyyy,doy);    

        filestr                                                 =   [VarMODIS(j).Productnames,'*',timestr,'*.hdf'];
        file                                                    =	dir([datadir.MODIS,subdir,'/',filestr]);
    end


    for ih=1:length(h_)
        for iv=1:length(v_)
            try
                %% Read Find file
                filestr                                         =   sprintf([VarMODIS(j).Productnames,'*',timestr,'*h%02.0fv%02.0f*.hdf'],h_(ih),v_(iv));
                file                                            =	dir([datadir.MODIS,subdir,'/',filestr]);

                info                                            =  	hdfinfo([datadir.MODIS,subdir,'/',file(1).name]);
                SDS                                             =   info.Vgroup.Vgroup(1).SDS(IdSDS);

                %% Read Data and Attributes
                Raw                                             =   hdfread(SDS);
                Attributes                                      =   SDS.Attributes;
                scaling= 1; offset=0; fill =NaN;
                for iatt=1:length(Attributes), 
                    switch Attributes(iatt).Name 
                        case 'add_offset'
                            offset                              =   Attributes(iatt).Value;
                        case '_FillValue'
                            fill                                =   Attributes(iatt).Value;
                        case 'scale_factor'
                            scaling                             =   Attributes(iatt).Value;
                    end
                end

                %% Convert to Real Values
                switch varname
                    case {'LST','time','theta_v'}
                        Values                                  =   single(Raw).*scaling;
                        Values(Raw==fill)                       =   NaN;
                    case {'NDVI'}
                        Values                                  =   single(Raw)./scaling + offset;
                        Values(Raw==fill)                       =   NaN;
                    case {'BSA','WSA','Emissivity_29','Emissivity_31', 'Emissivity_32','LAI'}
                        Values                                  =   single(Raw).*scaling + offset;
                        Values(Raw==fill)                       =   NaN;
                    otherwise
                        keyboard
                end

                Values(Raw==fill)                               =  NaN;
                %%


                DataMODIS_Tile.(varname).Values{iv,ih}          =   Values;

            catch
                DataMODIS_Tile.(varname).Values{iv,ih}          =   single(ones(Nr_pix_Tile_1000,Nr_pix_Tile_1000).*NaN);
            end
        end                
    end            

    DataMODIS_Tile.(varname).Values                             =   cell2mat(DataMODIS_Tile.(varname).Values); %#ok<*AGROW>
        
end
clear Values

%% Post Process 
DataMODIS_Tile.LAI.Values(DataMODIS_Tile.LAI.Values>12)          =   NaN;

%% Resample Data (Tiled data has a resolution 1000m into the desired 4000 m)
fprintf(1,'Post Processing MODIS (Tiled) Data \n');
% stack subpixels (that lie within one large pixel)

varnames                                                       	=   fieldnames(DataMODIS_Tile);
for ivar=1:length(varnames)
    varname                                                     =   varnames{ivar};

    vstep                                                       =   floor(Nr_pix_Tile_1000./Nr_pix_Tile_Output);                           %difference in resolution of large pixel/subpixels (5.6km / 500m) => 10
    [V_3D]                                                      =   deal([]);
    for i=1:vstep
        for j=1:vstep
            V_3D                                                =   cat(3,V_3D  ,   DataMODIS_Tile.(varname).Values( (0:vstep:end-vstep) + i , (0:vstep:end-vstep) + j ));
        end
    end    
    DataMODIS_Tile.(varname).Values                          	=   nanmean(V_3D,3);

    %% subset
    DataMODIS_Tile.(varname).Values                             =	DataMODIS_Tile.(varname).Values(Sub.ilon,Sub.ilat);
    
    %% Resampling
    DataMODIS_Tile.(varname).resampling                         =   VarMODIS(ivar).resampling;
    DataMODIS_Tile.resampling                                   =   VarMODIS(ivar).resampling;

end

