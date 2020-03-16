function [StaticMODIS_CMG,Sub]   =   Read_MODIS_Data_Static_CMG(VarMODIS,Location)
global datadir 

%% Coordinates data
fprintf(1,'Reading CMG Coordinates\n');
% CMG
res                                                                     =   0.05;                                       %degree
lon_                                                                    =   single(-(180-res/2):res:(180-res/2));
lat_                                                                    =   fliplr(single(-(090-res/2):res:(090-res/2)));

[StaticMODIS_CMG.Lon.Values,StaticMODIS_CMG.Lat.Values]                 =   meshgrid(lon_,lat_);

ierror                                                                  =   abs(StaticMODIS_CMG.Lon.Values)>180 | abs(StaticMODIS_CMG.Lat.Values)>90;
StaticMODIS_CMG.Lat.Values(ierror)                                      =   NaN;
StaticMODIS_CMG.Lon.Values(ierror)                                      =   NaN;

%% Read Data (LC)
fprintf(1,'Reading CMG Static Data\n');
clear ierror

for j        =1:length(VarMODIS)    
    IdSDS                                                               =   VarMODIS(j).IdSDS;    
            
    filestr                                                             =   [VarMODIS(j).Productnames,'*.hdf'];


    subdir                                                              =   VarMODIS(j).name;
    file                                                                =	dir([datadir.MODIS,subdir,'/',filestr]);

    info                                                                =  	hdfinfo([datadir.MODIS,subdir,'/',file.name]);
    SDS                                                                 =   info.Vgroup.Vgroup(1).SDS(IdSDS);            
%             Attributes                                                  =   SDS.Attributes;

    StaticMODIS_CMG.LC.Values                                           =   hdfread(SDS);
    StaticMODIS_CMG.LC.Values(StaticMODIS_CMG.LC.Values==255)           =   0;
        
end


%% Create Mask from Erroneous/water pixels
Mask                                                                    =   imfilter(single(StaticMODIS_CMG.LC.Values==0),fspecial('average',[9 9]));
iOcean                                                                  =   round(Mask*100)/100==1;
% iLand                                                                   =   Mask==0;
% iCoast                                                                  =   Mask>0 & Mask<1;

%% Subsetting
Sub.ilon                                                                =   any(StaticMODIS_CMG.Lat.Values>=Location.minlat & StaticMODIS_CMG.Lat.Values<=Location.maxlat,2);
Sub.ilat                                                                =   any(StaticMODIS_CMG.Lon.Values>=Location.minlon & StaticMODIS_CMG.Lon.Values<=Location.maxlon,1);

StaticMODIS_CMG.Lat.Values                                              =	StaticMODIS_CMG.Lat.Values(Sub.ilon,Sub.ilat);
StaticMODIS_CMG.Lon.Values                                              =   StaticMODIS_CMG.Lon.Values(Sub.ilon,Sub.ilat);
StaticMODIS_CMG.LC.Values                                               =   StaticMODIS_CMG.LC.Values(Sub.ilon,Sub.ilat);

%% Apply mask to Coordinates
iOcean                                                                  =   iOcean(Sub.ilon,Sub.ilat);
StaticMODIS_CMG.Lat.Values(iOcean)                                      =   NaN;
StaticMODIS_CMG.Lon.Values(iOcean)                                      =   NaN;
StaticMODIS_CMG.LC.Values(iOcean)                                       =   NaN;

%% Resampling
StaticMODIS_CMG.resampling                                              =   'nearest';