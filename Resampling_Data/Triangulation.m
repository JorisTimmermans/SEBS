function [tile,Ilatlon] =   Triangulation(Static,Location, tile)
warning off
% Define Latitudes of products
Lat                                                             =   double([Static.Lat.Values]);
Lon                                                             =   double([Static.Lon.Values]);
% Values                                                          =   Lon;

%% Identify grid
Ilat                                                            =   (Lat >= min(tile.lati)-1) & (Lat <= max(tile.lati)+1);
Ilon                                                            =   (Lon >= min(tile.loni)-1) & (Lon <= max(tile.loni)+1);

Ilatlon                                                         =   Ilat & Ilon;

if sum(Ilatlon(:))>=5 % a triangulation can only be performed is there are at least 3 points to create 1 triangle
    ilat                                                        =   any(Ilatlon,1);
    ilon                                                        =   any(Ilatlon,2);
    
    %% subset coordinates of data
    Lonc                                                        =   Lon(ilon , ilat);
    Latc                                                        =   Lat(ilon , ilat);
%     Valuesc                                                     =   Values(ilon, ilat);

    %% Remove duplicate coordinates values from the image (for example MODIS-gridded overlap)    
    Coordinates                                                 =   [Lonc(:),Latc(:)];
%     valuesc                                                     =   Valuesc(:);
    
    [Coordinates,Is]                                            =   unique(Coordinates, 'rows');
%     Valuess                                                     =   valuesc(Is);

    %% Remove pixels designated as NaN (sea/erroroneous)
    ierror                                                   	=   any(isnan(Coordinates),2);
    Coordinates                                                 =   Coordinates(~ierror,:);
%     Valuess                                                     =   Valuess(~ierror);

    %% Resampling Grid
    [Loni,Lati]                                              	=   meshgrid(tile.loni,tile.lati);

    %% Triangulation
    switch Static.resampling
        case 'nearest'   
            % Interpolation            
            tile.Triangulation.Inearest                         =   uint32(zeros(size(Loni)));    
            tri                                                 =   DelaunayTri(Coordinates);
            if ~isempty(tri.Triangulation)
                tile.Triangulation.Inearest(:)                  =   uint32(tri.nearestNeighbor(Loni(:),Lati(:)));
                ierror                                          =   tile.Triangulation.Inearest==0;
                tile.Triangulation.Inearest(ierror)             =   NaN;
            else
                tile.Triangulation.Inearest(:)                  =   zeros(size(Loni))*NaN;  %new 29-11-2012
            end            
            
%           % Resampling            
%             Valuesi                                             =   Valuess(tile.Triangulation.Inearest);

        case {'linear', 'natural'}
            % Interpolation
            dummy                                               =   zeros(size(Lonc(:)));
            dummys                                              =   dummy(Is);
%             keyboard
            tile.Triangulation.t                               	=   TriScatteredInterp(Coordinates,dummys,Static.resampling);    
            
%           % Resampling
%           T                                                   =   tile.Triangulation.t;
%           T.V                                                 =   Valuess;                        
%           Valuesi                                             =   T(Loni,Lati);  
        otherwise
            keyboard
    end    

    
end

warning on
return
