function [Datai] = ResampleProducts(Var, Data , Static , Location, tile)
Lat                                                         =   double(Static.Lat.Values);
Lon                                                         =   double(Static.Lon.Values);

%%Use the subimage (slightly larger than the desired Tile) (increasing speed griddata)
Ilat                                                        =   (Lat >= min(tile.lati)-1) & (Lat <= max(tile.lati)+1);
Ilon                                                        =   (Lon >= min(tile.loni)-1) & (Lon <= max(tile.loni)+1);
Ilatlon                                                     =   Ilat & Ilon;

if sum(Ilatlon(:))>5
    ilat                                                  	=   any(Ilatlon,1);
    ilon                                                    =   any(Ilatlon,2);


    %% Products resampling
    for ivar = 1:size(Var,2)
        varname                                             =   Var(ivar).Varname;        
        Values                                              =   double(Data.(varname).Values);
        
        %Cut away the pixels outside the range
        try
            % subset grid
            Lonc                                          	=   Lon(ilon , ilat);
            Latc                                            =   Lat(ilon , ilat);
            Valuesc                                         =   Values(ilon, ilat);
            
        catch
         	fprintf(1,'ResampleProducts: no values found for region of interest\n');
            return;
        end

        %Remove duplicate coordinate values from the image (for example MODIS-gridded overlap)
        Coordinates                                         =   [Lonc(:),Latc(:)];
        valuesc                                             =   Valuesc(:);
        
        [Coordinates,Is]                                    =   unique(Coordinates, 'rows');                        %#ok<*ASGLU>
        Valuess                                             =   valuesc(Is);

        %% Remove pixels designated as NaN (sea/erroroneous)
        ierror                                          	=   any(isnan(Coordinates),2);
        Coordinates                                         =   Coordinates(~ierror,:);
        Valuess                                             =   Valuess(~ierror);
        
        %% Resampling Grid
        loni                                                =   tile.loni;
        lati                                                =   tile.lati;
        [Loni,Lati]                                         =   meshgrid(loni,lati);
%         
        %%
        switch Static.resampling
            case 'nearest'
%              	% Triangulation (is performed offline)
%               tile.Triangulation.Inearest                 =   uint32(zeros(size(Loni)));
%               tri                                         =   DelaunayTri(Coordinates);
%               tile.Triangulation.Inearest(:)              =   uint32(tri.nearestNeighbor(Loni(:),Lati(:)));
                    
%               %Resample Data
                try
                Valuesi                                     =   Valuess(tile.Triangulation.Inearest);
                catch                    
                    Valuesi                                 =   NaN*zeros(size(Loni));
                end
                
%                     keyboard
            case {'linear', 'natural'}
                T                                           =   tile.Triangulation.t;
                
%              	% Triangulation (is performed offline)
%               dummy                                       =   zeros(size(Loni));
%               dummys                                      =   dummy(Is);
%               T                                           =   TriScatteredInterp(Coordinates,dummys,Static.resampling);

                %Resample Data
                T.V                                         =   Valuess;                        
                Valuesi                                     =   T(Loni,Lati);
            
%                 keyboard
            otherwise
%                 keyboard
					fprintf(1,'ResampleProducts: no triangulation values found for region of interest\n');
					return;
				
        end                
        Datai.(varname).Values                              =   single(Valuesi);
        
%         switch varname
%             case 'Albedo'
%                 %%
%                 lati                                     	=   double(tile.Location.start_lat:tile.Location.resolution:tile.Location.end_lat);
%                 loni                                        =   double(tile.Location.start_lon:tile.Location.resolution:tile.Location.end_lon);
%                 [Lati,Loni]                                 =   meshgrid(lati, loni);
% 
%                 close all
%                 figure('Position',[150 100 1024 800])
%                 ILatLon                                     =   0.2+0.8*((Lon >tile.start_lon    & Lon < tile.end_lon) & (Lat >tile.start_lat    & Lat < tile.end_lat));
%                 ILatcLonc                                   =   0.2+0.8*((Lonc>min(Loni(:))      & Lonc< max(Loni(:))) & (Latc>min(Lati(:))      & Latc< max(Lati(:))));
%                 
%                 subplot(5,2,01), imagesc(Values,[0 1])          , axis equal tight, set(gca,'Xticklabel','','Yticklabel',''),   ylabel('Full image'), title('image')
%                 subplot(5,2,02), imagesc(Lat)                   , axis equal tight, set(gca,'Xticklabel','','Yticklabel',''),                         title('lat')
%                 subplot(5,2,03), imagesc((0.3+0.7*Values).*ILatLon,[0 1]) , axis equal tight, set(gca,'Xticklabel','','Yticklabel',''),   ylabel('Sel. in Full Im.')
%                 
%                 subplot(5,2,04), imagesc(Lat.*ILatLon)          , set(gca,'Xticklabel','','Yticklabel',''),
%                 subplot(5,2,05), imagesc(Valuesc,[0 1])         , set(gca,'Xticklabel','','Yticklabel',''),   ylabel('Cutout of Full Im.'), colorbar
%                 subplot(5,2,06), imagesc(Latc)                  , set(gca,'Xticklabel','','Yticklabel','')
%                 subplot(5,2,07), imagesc(Valuesc.*ILatcLonc)    ,axis equal tight, set(gca,'Xticklabel','','Yticklabel',''),   ylabel('Sel. in Cutout'), colorbar
%                 subplot(5,2,08), imagesc(Latc.*ILatcLonc)       ,axis equal tight, set(gca,'Xticklabel','','Yticklabel','')
% 
%                 subplot(5,2,09), imagesc(flipud(Valuesi'))              ,axis equal tight, set(gca,'Xticklabel','','Yticklabel',''),   ylabel('Resampled Im.'), colorbar
%                 subplot(5,2,10), imagesc(flipud(Lati'))                 ,axis equal tight, set(gca,'Xticklabel','','Yticklabel','')
%                 subplot(4,3,10),imagesc(Loni)           , axis equal off, subplot(4,3,11),imagesc(Lati)             , axis equal off, subplot(4,3,12),imagesc(Valuesi)          , axis equal off, 
% 
%                 %%
%                 keyboard
%         end
    end
else
    loni                                                    =   tile.loni;
    lati                                                    =   tile.lati;
	
    [dummy]                                                 =   NaN*meshgrid(loni, lati);
        
    for ivar = 1:size(Var,2)
        varname                                             =   Var(ivar).Varname;
        Datai.(varname).Values                              =   dummy;
    end
%     plot(Lat([1 end],:)',Lon([1 end],:)','b.',Lati([1 end],:)',Loni([1 end],:)','r.')
%     keyboard
    
    
end
