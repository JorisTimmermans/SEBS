function [Tile_tot,Data] =   LoadTiles(FullData,TileMeta,itile,Location)
global diTile
global datadir flog
fprintf(flog,'\n\t Computing Triangulation:\n\t\t');
productnames                                                    =   fieldnames(FullData);
Tile_tot                                                        =   struct([]);

pathname                                                        =   [datadir.output filesep 'Tiles' filesep];

%% Load Tile and subset Data to the boundaries of this tile
for iprod=1:length(productnames)
    productname                                             	=   productnames{iprod};
    
    % Load Tile Data
    filename                                                    =   TileMeta.(productname).Tilefilestr{ceil((itile+1)/diTile)};    
    Tiles                                                       =   load([pathname, filename]);
    Tile                                                        =   Tiles.Tile;
    
%     precomputed                                                 =   zeros(size(Tiles.Tile,2),1);
    for j=1:size(Tile,2)
        Iempty(j)                                               =   isempty(Tile(j).Nr);
        
        Tile_tot(j).Nr                                        	=   Tile(j).Nr;        
        Tile_tot(j).Location                                    =   Tile(j).Location;
        Tile_tot(j).(productname)                            	=   Tile(j);                     %#ok<SAGROW>
        
        % Load Cutting for the tiles
        i                                                       =   ceil((itile+1)/diTile);
        Ilatlon.(productname).ilat                              =   TileMeta.(productname).ilat{i};
        Ilatlon.(productname).ilon                              =   TileMeta.(productname).ilon{i};

    end
    Tile_tot                                                    =   Tile_tot(~Iempty);
end

%% Cut the Dynamic Data
% [Static]                                                    	=   SelectSubset4Tile(FullStatic,Ilatlon);
[Data]                                                          =   SelectSubset4Tile(FullData,Ilatlon);

return


function [Data] = SelectSubset4Tile(FullData,Ilatlon)
Data                                                            =   FullData;
productnames                                                    =   fieldnames(FullData);
for iprod=1:length(productnames)
    productname                                                 =   productnames{iprod};

    ilat                                                        =   Ilatlon.(productname).ilat;
    ilon                                                        =   Ilatlon.(productname).ilon;
    
    varnames                                                    =   fieldnames(FullData.(productname));
    for ivar=1:length(varnames)
        varname                                                 =   varnames{ivar};
        switch varname
            case {'MissingID','resampling','nr_pix_x','nr_pix_y','lat','lon'}
            otherwise
                try
                Data.(productname).(varname).Values             =   FullData.(productname).(varname).Values(ilat,ilon);
                catch
                    keyboard
                end
        end
    end
end