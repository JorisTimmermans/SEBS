fprintf('Running Dynamic\n')    


%% Delete Previous Data


%% Download Dynamic Data
% Download_ECMWF_Data(VarECMWF.Dynamic,Location, startdate,enddate);
% Download_MODIS_Data(VarMODIS.Dynamic_CMG,Location, startdate,enddate);
% Download_MODIS_Data(VarMODIS.Dynamic_Tile,Location, startdate,enddate);

%% time
[Time.yyyy,Time.mm,Time.dd]                                 =   datevec(startdate);
Time.doy                                                	=   startdate - datenum(Time.yyyy,01,00);

%% Read Dynamic Data
[FullData.ECMWF]                                            =   Read_ECMWF_Data_Dynamic(VarECMWF.Dynamic,Sub.ECMWF,Location,startdate);
[FullData.MODIS_CMG]                                        =   Read_MODIS_Data_Dynamic_CMG(VarMODIS.Dynamic_CMG,Sub.MODIS_CMG,Location,startdate);
[FullData.MODIS_Tile]                                       =   Read_MODIS_Data_Dynamic_Tile(VarMODIS.Dynamic_Tile,Sub.MODIS_Tile,Location,startdate);

%% Load Tiles
[TileMeta,EmptyTiles,NTiles_tot]                            =   LoadGridMetaData(FullStatic,Location,diTile);

%% Define Static Data to be resampled
var.ECMWF                                                   =   VarECMWF.Dynamic;
var.MODIS_CMG                                              	=   VarMODIS.Dynamic_CMG;
var.MODIS_Tile                                             	=   VarMODIS.Dynamic_Tile;
            
%% Resample Dynamic Data
tic
h                                               	=   waitbar(0,'Please wait...');
clear Datai
for itile=0:diTile:(NTiles_tot-1)
    % display progress
    waitbar(itile/NTiles_tot,h,sprintf('%02.0f%%',itile/NTiles_tot*100))
    fprintf(flog,'\n- Processing Tiles: (%03.0f ~ %03.0f)',[itile, itile+diTile-1]);

    % Load Correct Tile
    [Tile,Data]                                 =   LoadTiles(FullData,TileMeta,itile,Location);        
    [~,Static]                                  =   LoadTiles(FullStatic,TileMeta,itile,Location);        
    
    Ntiles_loaded                               =   min(diTile,size(itile:(NTiles_tot-1),2));

    clear datai statici
    statici(1:Ntiles_loaded)                    =   Statici((1:Ntiles_loaded) + itile);
    parfor Itile=1:Ntiles_loaded
        
        [datai(Itile)]                          =   ParallelExecution(var,Static, Data, Time, Location, Tile(Itile),statici(Itile));
        
    end
    Datai((1:Ntiles_loaded) + itile)            =   datai(1:Ntiles_loaded);
end
close (h)    

toc

%% Save Data
save(['ET_',datestr(startdate,'yyyymmdd'),'.mat'],'Datai')                          %20Mb


%% View Output
fprintf('\nPrinting the output\n')
vmin                            =   NaN;
vmax                            =   NaN;

h1                              =   figure('Position',[0 0 1024 800]);
h11                             =   subplot(2,2,3,'nextplot','add','Fontsize',15);
h112                            =   title('Daily Net Radiation [MJ day^-1]');
h113                            =   xlabel(['Longitude [',char(176),']']);
h114                            =   ylabel(['Latitude [',char(176),']']);
h115                            =   colorbar;
for j=1:length(Datai)
    imagesc(Statici(j).lon,Statici(j).lat,Datai(j).Rndaily.Values)    
    vmin                        =   nanmin([Datai(j).Rndaily.Values(:); vmin]);
    vmax                        =   nanmax([Datai(j).Rndaily.Values(:); vmax]);
end
set(h11,'CLim',[vmin-0.1 vmax])
c=colormap; c(1,:)=1; colormap(c)
axis equal tight

vmin                            =   NaN;
vmax                            =   NaN;
h12                             =   subplot(2,2,1:2,'nextplot','add','Fontsize',15) ;
h122                            =   title('Actual ET [mm day^-1]');
h123                            =   xlabel(['Longitude [',char(176),']']);
h124                            =   ylabel(['Latitude [',char(176),']']);
h125                         	=   colorbar;
for j=1:length(Datai)
    vmin                        =   nanmin([Datai(j).Rndaily.Values(:); vmin]);
    vmax                        =   nanmax([Datai(j).Rndaily.Values(:); vmax]);
    imagesc(Statici(j).lon,Statici(j).lat,abs(Datai(j).Edaily.Values))        
end
set(h12,'CLim',[vmin-0.1 10])
c=colormap; c(1,:)=1; colormap(c)
axis equal tight

vmin                            =   NaN;
vmax                            =   NaN;
h13                             =   subplot(2,2,4,'nextplot','add','Fontsize',15);
h132                            =   title('Potential ET [mm day^-1]');
h133                            =   xlabel(['Longitude [',char(176),']']);
h134                            =   ylabel(['Latitude [',char(176),']']);
h135                            =   colorbar;
for j=1:length(Datai)
    vmin                        =   nanmin([Datai(j).Rndaily.Values(:); vmin]);
    vmax                        =   nanmax([Datai(j).Rndaily.Values(:); vmax]);
    imagesc(Statici(j).lon,Statici(j).lat,abs(Datai(j).E0daily.Values))    
end
set(h13,'CLim',[vmin-1 10])
c=colormap; c(1,:)=1; colormap(c)
axis equal tight

print(h1,['ET_',datestr(startdate,'yyyymmdd'),'.png'],'-dpng','-r300')




