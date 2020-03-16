function [Tiles,Ntiles] = MODIS_Data_Select_Tiles(Location)
%% Select Tiles that cover the Selected Area.
% Define Download Area (to be bigger than study area).  The Area should be larger then the actual location to reduce interpolation errors at the boundaries. 
alpha                                                   =   2;
lat_start                                               =   max(Location.minlat - alpha,-090);
lat_end                                                 =   min(Location.maxlat + alpha,+090);
lon_start                                               =   max(Location.minlon - alpha,-180);
lon_end                                                 =   min(Location.maxlon - alpha,+360);

%% Define boundaries for tiles
deg2rad                                                 =   pi/180;
h_                                                      =   0:35;
v_                                                      =   0:17;
[H,V]                                                   =   meshgrid(h_,v_);
[lat_min, lon_min,lat_max,lon_max]                      =   deal(zeros(length(v_),length(h_)));
for ih=1:length(h_)
    for iv=1:length(v_)
        v                                               =   v_(iv);
        h                                               =   h_(ih);

        % Bounding coordinates of MODIS Grid Tile
        lat_min(iv,ih)                                  =   (00 - 10*(v - 08));                                             % correct
        lat_max(iv,ih)                                  =   (10 - 10*(v - 08));                                             % correct
        lon_min(iv,ih)                                  =   (00 + 10*(h - 18))./cos(lat_min(iv,ih)*deg2rad);            	% correct
        lon_max(iv,ih)                                  =   (10 + 10*(h - 18))./cos(lat_max(iv,ih)*deg2rad);                % more or less
    end
end
ierror                                                  =   abs(lon_min)>180 | abs(lon_max)>180 | abs(lat_max)>90 | abs(lat_min)>90;
lat_min(ierror)                                         =   NaN;
lat_max(ierror)                                         =   NaN;
lon_min(ierror)                                         =   NaN;
lon_max(ierror)                                         =   NaN;

%% Select Tiles
ilon                                                    =   (lon_end>= lon_min & lon_start<= lon_max) | (lon_end>= (lon_min+360) & lon_start<= (lon_max+360));
ilat                                                    =   (lat_end>= lat_min & lat_start<= lat_max) | (lat_end>= (lat_min+000) & lat_start<= (lat_max+000));
ilatlon                                                 =   ilon & ilat;

Tiles                                                   =   [H(ilatlon) V(ilatlon)];
Ntiles                                                  =   size(Tiles,1);

%% Rearrange Tiles 
% resort the tiles in order to start (global) downloading from the equator (this helps in identifiying missing dates)
ilat                                                    =   Tiles(:,2)+1;
lat_c                                                   =   mean([nanmax(lat_max(ilat,:),[],2), nanmin(lat_min(ilat,:),[],2)],2);
[~,is]                                                  =   sort(abs(lat_c));
Tiles                                                   =   Tiles(is,:);