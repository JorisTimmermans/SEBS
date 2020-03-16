%% Define period
startdate                                                   =   datenum(2008,01,04);
enddate                                                     =   datenum(2008,01,04);

%% Define Location 
global resolution 
res                                                         =   single(0.05);                                       %degree
StudyArea.minlon                                          	=   -180; -180; 
StudyArea.maxlon                                          	=   +180; +180; 

StudyArea.minlat                                            =   -060; -090;
StudyArea.maxlat                                            =   +070; +090;

%ECMWF resolution
resolution                                                  =   '0.125';


%% Define Grid (CMG)
Grid.res                                                    =   0.05;
Grid.minlon                                                 =   single(-(180 - Grid.res/2)); 
Grid.maxlon                                                 =   single(+(180 - Grid.res/2));
Grid.minlat                                                 =   single(-(090 - Grid.res/2));
Grid.maxlat                                                 =   single(+(090 - Grid.res/2));

Grid.lon_                                                   =   Grid.minlon: res: Grid.maxlon;
Grid.lat_                                                   =   Grid.minlat: res: Grid.maxlat;
Grid.lat_                                                  	=   fliplr(Grid.lat_);

% reduce grid to cover the location coordinates with a border of 2
extra_border                                                =   res+2;
Location.lon                                                =   Grid.lon_(StudyArea.minlon - extra_border <= Grid.lon_ & StudyArea.maxlon + extra_border >= Grid.lon_);
Location.lat                                                =   Grid.lat_(StudyArea.minlat - extra_border <= Grid.lat_ & StudyArea.maxlat + extra_border >= Grid.lat_);

Location.minlon                                             =   min(Location.lon);
Location.maxlon                                             =   max(Location.lon);
Location.minlat                                             =   min(Location.lat);
Location.maxlat                                             =   max(Location.lat);

% [Location.Lon.Values,Location.Lat.Values]                   =   meshgrid(lon_,lat_);
Location.units                                              =   'degrees';
Location.resolution_x                                       =   Grid.res;                                                           % floor(1000/111.320)*1000;  % [degrees]   0.0001
Location.resolution_y                                       =   Grid.res;                                                           % floor(1000/110.574)*1000;  % [degrees]   0.0001

%% Define Tiles 
global diTile
diTile                                                      =   25;
Location.Tile.size                                         	= 	10;                                                             % [degrees]

lon_c                                                        =   single(-180 : Location.Tile.size : 180-Location.Tile.size) + Location.Tile.size/2;
lat_c                                                        =   single(-90  : Location.Tile.size : 090-Location.Tile.size) + Location.Tile.size/2;

% Define Tiles subset to fit around the study area
lon_w                                                       =   lon_c - Location.Tile.size/2;
lon_e                                                       =   lon_c + Location.Tile.size/2;
lat_s                                                       =   lat_c - Location.Tile.size/2;
lat_n                                                       =   lat_c + Location.Tile.size/2;


ilon                                                        =   lon_e>=Location.minlon & lon_w<=Location.maxlon; 
ilat                                                        =   lat_s>=Location.minlat & lat_n<=Location.maxlat;

lon_c                                                       =   lon_c(ilon);
lat_c                                                       =   lat_c(ilat);

% Store Tiles into variables
Location.Tile.lon                                           =   lon_c;         
Location.Tile.lat                                           =   lat_c;         

% setup grid
[Location.Tile.Lon,Location.Tile.Lat]                       =   meshgrid(Location.Tile.lon,Location.Tile.lat);
Location.Tile.nr                                            =   numel(Location.Tile.Lon);


