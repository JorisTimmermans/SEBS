function [VarMODIS] = Parameters_MODIS_Data_Dynamic(resampling)
varid                           =   0;

%% Tiled data % 1km, Tile, daily
varid                           =   varid +1;
VarMODIS(varid).Productnames	  =   'MOD15A2'; 
VarMODIS(varid).name            =   'LAI';  
VarMODIS(varid).Varname         =   'LAI';
VarMODIS(varid).Dirnames        =   'MOLT';
VarMODIS(varid).Versionnames    =   '.005';
VarMODIS(varid).Grid            =   'Tile';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   8;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   2;
