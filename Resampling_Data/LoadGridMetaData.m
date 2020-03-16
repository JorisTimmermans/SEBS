function [TileMeta,EmptyTiles,NTiles_tot] = LoadGridMetaData(Static,Location,diTile)
global datadir flog
pathname                                                            =   [datadir.output,filesep,'Tiles', filesep];
fprintf(flog,'[INFO   ] LoadGridMetaData: Loading Triangulation Metadata...\n');
locationstr                                                         =   sprintf('(%03.0f-%03.0f,%03.0f-%03.0f)',Location.minlon,Location.maxlon, Location.minlat,Location.maxlat);
names                                                               =   fieldnames(Static);
EmptyTiles                                                          =   0;
for iname=1:length(names)
    name                                                            =   names{iname};
    
    switch name        
        case 'ECMWF'
            filestr                                                 =   sprintf(['Tiles*ECMWF',locationstr,'*(diTile=%05.0f)*TileMeta*'],diTile);
            fileECMWF                                               =   dir([pathname,filestr]);
            TileMetaECMWF                                           =   load([pathname, fileECMWF.name]);
            TileMeta.ECMWF                                          =   TileMetaECMWF.TileMeta;
            EmptyTiles                                              =   EmptyTiles + 2^0 * TileMeta.ECMWF.EmptyTileError;
       	case 'MODIS_Tile'            
            filestr                                                	=   sprintf(['Tiles*MODIS_Tile',locationstr,'*(diTile=%05.0f)*TileMeta*'],diTile);
            fileMODIS_Tile                                       	=   dir([pathname,filestr]);
            TileMetaMODIS_Tile                                      =   load([pathname, fileMODIS_Tile.name]);
            TileMeta.MODIS_Tile                                     =   TileMetaMODIS_Tile.TileMeta;
            EmptyTiles                                              =   EmptyTiles + 2^1 * TileMeta.MODIS_Tile.EmptyTileError;
        case 'MODIS_CMG'                        
            filestr                                                	=   sprintf(['Tiles*MODIS_CMG',locationstr,'*(diTile=%05.0f)*TileMeta*'],diTile);
            fileMODIS_CMG                                           =   dir([pathname,filestr]);
            TileMetaMODIS_CMG                                      	=   load([pathname, fileMODIS_CMG.name]);
            TileMeta.MODIS_CMG                                      =   TileMetaMODIS_CMG.TileMeta;
            EmptyTiles                                              =   EmptyTiles + 2^2 * TileMeta.MODIS_CMG.EmptyTileError;    
        
        case 'GLAS'                        
            filestr                                                	=   sprintf(['Tiles*GLAS',locationstr,'*(diTile=%05.0f)*TileMeta*'],diTile);
            fileGLAS                                                =   dir([pathname,filestr]);
            TileMetaGLAS                                            =   load([pathname, fileGLAS.name]);
            TileMeta.GLAS                                           =   TileMetaGLAS.TileMeta;
            EmptyTiles                                              =   EmptyTiles + 2^3 * TileMeta.GLAS.EmptyTileError;    
            
        case 'MERIS_cover'
            filestr                                             	=   sprintf(['Tiles*MERIS_cover',locationstr,'*(diTile=%05.0f)*TileMeta*'],diTile);
            fileMERIS_cover                                         =   dir([pathname,filestr]);
            TileMetaMERIS_cover                                     =   load([pathname, fileMERIS_cover.name]);
            TileMeta.MERIS_cover                                    =   TileMetaMERIS_cover.TileMeta;
            EmptyTiles                                              =   EmptyTiles + 2^4 * TileMeta.MERIS_cover.EmptyTileError;    
    end

end
                                                                   
NTiles_tot                                                          =   size(EmptyTiles,2);      %number of Tiles

% clear TileMetaECMWF TileMetaLandSAF TileMetaMODIS fileECMWF fileLandSAF fileMODIS
% clear filestr pathname
