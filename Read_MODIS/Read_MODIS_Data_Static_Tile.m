function [StaticMODIS_Tile,Sub]   =   Read_MODIS_Data_Static_Tile(VarMODIS,Location)
global deg2rad
global datadir 

[Tiles]                                                         =   MODIS_Data_Select_Tiles(Location);
h_                                                              =   unique(Tiles(:,1));
v_                                                              =   unique(Tiles(:,2));
clear Tiles

Nr_pix_Tile_Output                                             	=   0300;                                                               %Nr of Pix per Tile (corresponding to a res of 4km)
% Nr_pix_Tile_Output                                             	=   1200;                                                               %Nr of Pix per Tile (corresponding to a res of 1km)

%% Coordinates data
fprintf(1,'Reading Coordinates\n');
Nr_pix_Tile_1000                                            	=   1200;
% Tile
for ih=1:length(h_)
    for iv=1:length(v_)        
        % Bounding Coordinates of Tile
        lat_min                                                 =   (00 - 10*(v_(iv) - 08));                                           % correct
        lat_max                                                 =   (10 - 10*(v_(iv) - 08));                                           % correct
        lon_min                                                 =   (00 + 10*(h_(ih) - 18))./cos(lat_min*deg2rad);                     % correct
        lon_max                                                 =   (10 + 10*(h_(ih) - 18))./cos(lat_max*deg2rad);                     % more or less

        ymin_s                                                  =   lat_min;
        ymax_s                                                  =   lat_max;
        xmin_s                                                  =   lon_min.*cos(lat_min*deg2rad);
        xmax_s                                                  =   lon_max.*cos(lat_max*deg2rad);

        x                                                       =   single(linspace(xmin_s,xmax_s,Nr_pix_Tile_1000));
        y                                                       =   single(linspace(ymax_s,ymin_s,Nr_pix_Tile_1000)');
        
        [X,Y]                                                   =   meshgrid(x,y);  
        
        StaticMODIS_Tile.Lat.Values{iv,ih}                  	=   single(Y);
        StaticMODIS_Tile.Lon.Values{iv,ih}                      =   single(X./cos(Y*deg2rad));
    end
end

StaticMODIS_Tile.Lat.Values                                     =   single(cell2mat(StaticMODIS_Tile.Lat.Values));
StaticMODIS_Tile.Lon.Values                                     =   single(cell2mat(StaticMODIS_Tile.Lon.Values));

% Postprocessing
vstep                                                           =   floor(Nr_pix_Tile_1000./Nr_pix_Tile_Output);
StaticMODIS_Tile.Lat.Values                                     =   StaticMODIS_Tile.Lat.Values(1:vstep:end,1:vstep:end);
StaticMODIS_Tile.Lon.Values                                     =   StaticMODIS_Tile.Lon.Values(1:vstep:end,1:vstep:end);

ierror                                                          =   abs(StaticMODIS_Tile.Lon.Values)>180 | abs(StaticMODIS_Tile.Lat.Values)>90;
StaticMODIS_Tile.Lat.Values(ierror)                             =   NaN;
StaticMODIS_Tile.Lon.Values(ierror)                             =   NaN;



clear x y ih iv X Y Lat Lon
clear ierror

%% Read Data (LC) 
% note that LC has double the resolution of the Lat/Lon coordinates
Nr_pix_Tile_0500                                               	=   2400;
fprintf(1,'Reading Data\n');
for j=1:length(VarMODIS)        
    IdSDS                                                       =   VarMODIS(j).IdSDS;    
    
    for ih=1:length(h_)
        for iv=1:length(v_)
            filestr                                     =   sprintf([VarMODIS(j).Productnames,'*h%02.0fv%02.0f*.hdf'],h_(ih),v_(iv));
            subdir                                      =   VarMODIS(j).name;
            file                                        =	dir([datadir.MODIS,subdir,'/',filestr]);

            if ~isempty(file)
                info                                    =  	hdfinfo([datadir.MODIS,subdir,'/',file(1).name]);
                SDS                                     =   info.Vgroup.Vgroup(1).SDS(IdSDS);
%                      	Attributes                              =   SDS.Attributes;                        

                Values                                  =   hdfread(SDS);
                Values(Values==255)                     =   0;

                LC(j).Values{iv,ih}                     =   Values;

            else
                LC(j).Values{iv,ih}                     =   uint8(zeros(Nr_pix_Tile_0500,Nr_pix_Tile_0500));
            end
        end                
    end            
    LC(j).Values                                       	=   cell2mat(LC(j).Values); %#ok<*AGROW>
            
        
end
clear Values

%% Resample LC 500 (Tiled LC has 500m in comparison Coordinates of 1km)
fprintf(1,'Post Processing\n');
% stack subpixels (that lie within one large pixel)
vstep                                                           =   floor(Nr_pix_Tile_0500./Nr_pix_Tile_Output);                           %difference in resolution of large pixel/subpixels (5.6km / 500m) => 10
[V_3D]                                                          =   deal([]);
bin                                                             =   unique(LC(1).Values(:));
for i=1:vstep
    for j=1:vstep
        V_3D                                                    =   cat(3,V_3D  ,   LC(1).Values( (0:vstep:end-vstep) + i , (0:vstep:end-vstep) + j ));
       
    end
end
clear LC

%Calculate histogram and Select class (of subpixel) that is most occuring in large pixel
[N]                                                             =   histc(V_3D,bin,3);
[~,I]                                                           =   max(N,[],3);

clear N V_3D Nmax
LC                                                              =   bin(I);


%% Masking Coordinates from Erroneous/water pixels
Mask                                                            =   imfilter(single(LC==0),fspecial('average',[9 9]));
iOcean                                                          =   round(Mask*100)/100==1;
% iLand                                                         =   Mask==0;
% iCoast                                                        =   Mask>0 & Mask<1;

% keyboard
%% Subsetting
Sub.ilon                                                      	=   any(StaticMODIS_Tile.Lat.Values>=(Location.minlat) & StaticMODIS_Tile.Lat.Values<=(Location.maxlat),2);
Sub.ilat                                                        =   any(StaticMODIS_Tile.Lon.Values>=(Location.minlon) & StaticMODIS_Tile.Lon.Values<=(Location.maxlon),1);

StaticMODIS_Tile.Lat.Values                                     =	StaticMODIS_Tile.Lat.Values(Sub.ilon,Sub.ilat);
StaticMODIS_Tile.Lon.Values                                     =   StaticMODIS_Tile.Lon.Values(Sub.ilon,Sub.ilat);
% LC                                                              =   LC(Sub.ilon,Sub.ilat);
iOcean                                                          =   iOcean(Sub.ilon,Sub.ilat);

StaticMODIS_Tile.Lat.Values(iOcean)                           	=   NaN;
StaticMODIS_Tile.Lon.Values(iOcean)                             =   NaN;

%%
StaticMODIS_Tile.resampling                                     =   'nearest';

return

