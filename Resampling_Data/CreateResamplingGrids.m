function []            =   CreateResamplingGrids(Static,Location)
global diTile
global datadir flog

fprintf(flog,'[INFO   ] CreateResamplingGrids: Creation of grid for Tiling and triangulation...\n');

% make the output directory, check on s (status) which should be one
Tiledir                                                 =   [datadir.output,filesep,'Tiles', filesep];
[s,mess]                                                =   mkdir(Tiledir);
if s ~= 1
	error('CreateResamplingGrids failed to create directory %s/Tiles, error message %s', datadir.Output, mess);
end
locationstr                                             =   sprintf('(%03.0f-%03.0f,%03.0f-%03.0f)',Location.minlon,Location.maxlon, Location.minlat,Location.maxlat);
%%
Ntiles_tot                                              =   Location.Tile.nr;
HalfTilesize                                            =   Location.Tile.size/2;

% Create Template
triangulation                                           =   struct('tri',[],'t',[],'Inearest',[]);
location                                                =   struct( 'start_lon'      , [], ...
                                                                             'end_lon'        , [], ...
                                                                             'start_lat'      , [], ...
                                                                             'end_lat'        , [], ...
                                                                             'resolution_x'   , [], ...
                                                                             'resolution_y'   , []);


TileTemplate(1:diTile)                                  =   struct( 'Nr'            , []     ,  ...
                                                                            'Location'       , location, ...
                                                                            'Triangulation'  , triangulation);                             

%%
names                                                   =   fieldnames(Static);
for iname=1:length(names)
    name                                                =   names{iname};
    static                                              =   Static.(name);
    TileMeta.EmptyTileError                             =   -ones(1,Ntiles_tot);

    tic
    
    %% Start Loop
    warning off
    TileMeta.EmptyTileError                             =   zeros(1,Ntiles_tot);
    for itile=0:diTile:(Ntiles_tot-1);
        NTiles                                          =   min(diTile,Ntiles_tot-itile);
        iTile_start                                     =   max(1,itile+1);
        iTile_end                                       =   min(Ntiles_tot,itile+NTiles);

        %Creating path to Metadata-file
        TileMeta.Tilefilestr{ceil((itile+1)/diTile)}	=   sprintf(['Tiles ',name,locationstr,' (diTile=%03.0f), Tilenr=%05.0f-%05.0f.mat'],[diTile iTile_start, iTile_end]);
        TileMeta.Directorystr{ceil((itile+1)/diTile)}   =   [datadir.output filesep 'Tiles' filesep];
        fullpath2file                                  	=   [TileMeta.Directorystr{ceil((itile+1)/diTile)} TileMeta.Tilefilestr{ceil((itile+1)/diTile)}];
        
        Tile                                            =   TileTemplate;
        %% Computing the Tile sizes
        for Itile=1:NTiles
            counter                                     =   itile+Itile;

            Tile(Itile).Nr                              =   counter;
            
            Tile(Itile).start_lon                       =   Location.Tile.Lon(counter) - HalfTilesize;      %#ok<*AGROW>
            Tile(Itile).end_lon                         =   Location.Tile.Lon(counter) + HalfTilesize;
            Tile(Itile).start_lat                       =   Location.Tile.Lat(counter) - HalfTilesize;
            Tile(Itile).end_lat                         =   Location.Tile.Lat(counter) + HalfTilesize;
            
            %% Define which coordinates are in the Tile
            ilon                                        =   Location.lon> Tile(Itile).start_lon & Location.lon<= Tile(Itile).end_lon;
            ilat                                        =   Location.lat> Tile(Itile).start_lat & Location.lat<= Tile(Itile).end_lat;
            
            Tile(Itile).loni                         	=   double(Location.lon(ilon));
            Tile(Itile).lati                            =   double(Location.lat(ilat));
            
            %% Create empty container for triangulation matrices
            Tile(Itile).Triangulation.tri               =   [];
            Tile(Itile).Triangulation.t                 =   [];
            Tile(Itile).Triangulation.Inearest          =   [];
            
        end

        %% reduce the amount of data per set of tiles (to reduce data transfer to cores
        minlon_Tiles                                    =   min([Tile.loni])-2;
        maxlon_Tiles                                    =   max([Tile.loni])+2;
        minlat_Tiles                                    =   min([Tile.lati])-2;
        maxlat_Tiles                                    =   max([Tile.lati])+2;
                
        ilat                                            =   any(static.Lat.Values>minlat_Tiles & static.Lat.Values<=maxlat_Tiles,2);
        ilon                                            =   any(static.Lon.Values>minlon_Tiles & static.Lon.Values<=maxlon_Tiles,1);
        
        TileMeta.ilat{ceil((itile+1)/diTile)}           =   ilat;
        TileMeta.ilon{ceil((itile+1)/diTile)}           =   ilon;
        
        %% Parallel computation
        static_tiles.Lon.Values                     	=   static.Lon.Values(ilat,ilon);
        static_tiles.Lat.Values                     	=   static.Lat.Values(ilat,ilon);        
        static_tiles.resampling                         =   static.resampling;
        
      
        %the triangulation is split into two parts enabling parallel processing of the heavy duty part
        clear EmptyTileError
        for Itile=1:NTiles
            %Triangulation
            [Tile(Itile),ilatlon]                       =   Triangulation(static_tiles,   Location, Tile(Itile));

            % Resampling
%             var.name='Lat';
%             [datai]                                     =   ResampleProducts(var, static_tiles, static_tiles,  Location, Tile(Itile));

            % PostProccesing
            EmptyTileError(Itile)                       =    ~any(ilatlon(:));
        end
        TileMeta.EmptyTileError((1:NTiles)+itile)       =   EmptyTileError;

        %% Saving the Triangulation
        save(fullpath2file,'Tile')
    end
    
    warning on

    %% Saving MetaData
    TileMeta.diTile                                   	=   diTile;
    filename                                          	=   sprintf(['Tiles ',name,locationstr,' (diTile=%05.0f), TileMeta.mat'],diTile);
    fullpath                                          	=   [datadir.output filesep 'Tiles' filesep filename];
    save(fullpath,'TileMeta')

end

return