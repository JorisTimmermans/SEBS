function [StaticGLAS,Sub]	=   Read_GLAS_Data_Static(VarGLAS,    Location)
global datadir

%% Read Static Data
V_1km                                         	=   GEOTIFF_READ([datadir.GLAS,VarGLAS.filename(1:end-3)]);                 % 1km

lon                                             =   V_1km.x;
lat                                             =   V_1km.y;

V_1km                                           =   single(V_1km.z);
V_1km(V_1km==0)                                 =   NaN;

%% Postprocess data (aggregate to 4km)
V_1km_3d                                        =   cat(3,  V_1km(1:4:end-3,1:4:end-3), V_1km(2:4:end-2,1:4:end-3), V_1km(3:4:end-1,1:4:end-3), V_1km(4:4:end-0,1:4:end-3) , ...
                                                            V_1km(1:4:end-3,2:4:end-2), V_1km(2:4:end-2,2:4:end-2), V_1km(3:4:end-1,2:4:end-2), V_1km(4:4:end-0,2:4:end-2) , ...
                                                            V_1km(1:4:end-3,3:4:end-1), V_1km(2:4:end-2,3:4:end-1), V_1km(3:4:end-1,3:4:end-1), V_1km(4:4:end-0,3:4:end-1) , ...
                                                            V_1km(1:4:end-3,4:4:end-0), V_1km(2:4:end-2,4:4:end-0), V_1km(3:4:end-1,4:4:end-0), V_1km(4:4:end-0,4:4:end-0));

lon_4km                                         =   single(lon(1:4:end));
lat_4km                                         =   single(lat(1:4:end));
V_4km                                           =   nanmean(V_1km_3d,3);
clear V_1km


%% subset
ilat                                            =   lat_4km>=Location.minlat & lat_4km<=Location.maxlat;
ilon                                            =   lon_4km>=Location.minlon & lon_4km<=Location.maxlon;

lon_4km                                         =   lon_4km(ilon);
lat_4km                                         =   lat_4km(ilat);
V_4km                                           =   V_4km(ilat,ilon);


[Lon,Lat]                                       =   meshgrid(lon_4km,lat_4km);

%% clear coordinates for empty values
% Lon(isnan(V_4km))                               =   NaN;
% Lat(isnan(V_4km))                               =   NaN;

%% Subsetting
Sub.ilon                                            =   any(Lat>=Location.minlat & Lat<=Location.maxlat,2);
Sub.ilat                                            =   any(Lon>=Location.minlon & Lon<=Location.maxlon,1);

Lat                                                 =	Lat(Sub.ilon,Sub.ilat);
Lon                                                 =   Lon(Sub.ilon,Sub.ilat);
V_4km                                               =   V_4km(Sub.ilon,Sub.ilat);

%% Removing Coordinates from Erroneous/water pixels
% Mask                                           	=   imfilter(isnan(V_4km),fspecial('average',[3 3]));
% iOcean                                          =   Mask==1;
% % iLand                                       	=   Mask==0;
% % iCoast                                        =   Mask>0 & Mask<1;
% Lat(iOcean)                                     =   NaN;
% Lon(iOcean)                                     =   NaN;

%% store values into output variables
StaticGLAS.Lon.Values                           =   Lon;
StaticGLAS.Lat.Values                           =   Lat;
StaticGLAS.(VarGLAS.Varnames).Values            =   V_4km;
StaticGLAS.resampling                           =   VarGLAS.resampling;



%% visualise
% imagesc(V_4km,[0 50]), c=colormap; c(1,:)=1; colormap(c)

% disaggregation of SM  what are the results when upscaling only with NDVI? This is because disaggregation will have a less temporal varation and thererfore be more
% representative over time?!
% how about using Pt values to scale between different overpasses?
% have you compared to values of high resolution radar data?

% available for 
% 5km daily, ET ET monitor ,
% is this gap filled?
