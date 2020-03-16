function [Datai] =   a(var, FullStatic, FullData, Location)
[TileMeta,EmptyTiles,NTiles_tot]                =   LoadGridMetaData(FullStatic,Location,diTile);

%% Running Dynamic
tic
h                                               =   waitbar(0,'Please wait...');
for itile=0:diTile:(NTiles_tot-1)
    % display progress
    waitbar(itile/NTiles_tot,h,sprintf('%02.0f%%',itile/NTiles_tot*100))
    fprintf(flog,'\n- Processing Tiles: (%03.0f ~ %03.0f)',[itile, itile+diTile-1]);
    

    % Load Correct Tile
    [Tile,Data,Static]                          =   LoadTiles(FullData,FullStatic,TileMeta,itile,Location);
    Ntiles_loaded                               =   min(diTile,size(itile:(NTiles_tot-1),2));

    clear datai
    parfor Itile=1:Ntiles_loaded
        [datai(Itile)]                         =   ResampleProducts(var.MODIS, Data.MODIS_Tile , Static.MODIS_Tile , Location, Tile(Itile).MODIS_Tile);

%         [datai2(Itile)]                         =   ResampleProducts(var.MODIS, Data.MODIS_CMG , Static.MODIS_CMG , Location, Tile(Itile).MODIS_CMG);                
% 
%         [datai3(Itile)]                         =   ResampleProducts(var.GLAS, Data.GLAS , Static.GLAS , Location, Tile(Itile).GLAS);                            
    end

    Datai((1:Ntiles_loaded) + itile)           =   datai(1:Ntiles_loaded);
%     Data2i((1:Ntiles_loaded) + itile)           =   datai2(1:Ntiles_loaded);
%     Data3i((1:Ntiles_loaded) + itile)           =   datai3(1:Ntiles_loaded);

end
close (h)
