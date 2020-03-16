fprintf('Running Startup\n')

%% Download Static Data
%     Download_ECMWF_Data(VarECMWF.Static,Location, datenum(yyyy,01,01),datenum(yyyy,01,01));
%     Download_MODIS_Data(VarMODIS.Static_Tile,Location, datenum(yyyy,01,01),datenum(yyyy,01,01));
%     Download_GLAS_Data(VarGLAS.Static,Location, datenum(yyyy,01,01),datenum(yyyy,01,01));

%% Read Static Data    
% 	load('temp.mat','FullStatic')    
[FullStatic.ECMWF,      Sub.ECMWF       ]       =   Read_ECMWF_Data_Static(VarECMWF.Static,    Location);
[FullStatic.MODIS_Tile, Sub.MODIS_Tile  ]       =   Read_MODIS_Data_Static_Tile(VarMODIS.Static_Tile,    Location);        %500Mb
[FullStatic.MODIS_CMG,  Sub.MODIS_CMG  	]       =   Read_MODIS_Data_Static_CMG(VarMODIS.Static_CMG,    Location);          %223Mb
[FullStatic.GLAS,       Sub.GLAS        ]       =   Read_GLAS_Data_Static(VarGLAS.Static,    Location);          %223Mb    
%   save('temp.mat','FullStatic')


%% Create Resampling Grids (get parfor to work again)
fprintf('Creating Resamplings\n')
CreateResamplingGrids(FullStatic,Location);
[TileMeta,EmptyTiles,NTiles_tot]                =   LoadGridMetaData(FullStatic,Location,diTile);


%% Define Static Data to be resampled
clear Fullstatic Fulldata var
Fullstatic.GLAS                                 =   FullStatic.GLAS;
Fullstatic.MODIS_CMG                           	=   FullStatic.MODIS_CMG;

Fulldata.GLAS                                   =   FullStatic.GLAS;
Fulldata.MODIS_CMG                           	=   FullStatic.MODIS_CMG;

%     var                                           =   VarMODIS.Static(1);
var.GLAS.Varname                                =   'hc_forest';    
var.MODIS_CMG.Varname                           =   'LC';    

%% Processing Static Data
tic
h                                               =   waitbar(0,'Please wait...');
clear Datai
for itile=0:diTile:(NTiles_tot-1)
    % display progress
    waitbar(itile/NTiles_tot,h,sprintf('%02.0f%%',itile/NTiles_tot*100))
    fprintf(flog,'\n- Processing Tiles: (%03.0f ~ %03.0f)',[itile, itile+diTile-1]);

    % Load Correct Tile
    [Tile,Data]                                 =   LoadTiles(Fulldata,TileMeta,itile,Location);        
    [~,Static]                                  =   LoadTiles(Fullstatic,TileMeta,itile,Location);        

    Ntiles_loaded                               =   min(diTile,size(itile:(NTiles_tot-1),2));

    clear datai 
    parfor Itile=1:Ntiles_loaded
        productnames                            =   fieldnames(Data);
        for iprod=1:length(productnames)
            productname                         =   productnames{iprod};

            [datai(Itile).(productname)]     	=   ResampleProducts(var.(productname),Data.(productname),Static.(productname),  Location, Tile(Itile).(productname));
        end
        datai(Itile).lat                        =   Tile(Itile).MODIS_CMG.lati;
        datai(Itile).lon                        =   Tile(Itile).MODIS_CMG.loni;

    end
    Statici((1:Ntiles_loaded) + itile)           =   datai(1:Ntiles_loaded);
end
close (h)

%% View Output
fprintf('\nPrinting the output\n')

figure(1)
subplot(2,1,2,'nextplot','add') 
for j=1:length(Statici)
    imagesc(Statici(j).lon,Statici(j).lat,Statici(j).MODIS_CMG.LC.Values)
end
axis equal tight

subplot(2,1,1) 
imagesc(Fulldata.MODIS_CMG.LC.Values)
axis equal tight

figure(2)

subplot(2,1,2,'nextplot','add') 
for j=1:length(Statici)
    imagesc(Statici(j).lon,Statici(j).lat,Statici(j).GLAS.hc_forest.Values)    
end
axis equal tight

subplot(2,1,1) 
imagesc(Fulldata.GLAS.hc_forest.Values)
axis equal tight


%% Clear left overs
clear Fulldata Fullstatic
    
    


%% extra et 
    % SSEBop (USGS)
    % CMRSET
