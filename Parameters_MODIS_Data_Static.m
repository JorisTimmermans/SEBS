function [VarMODIS] = Parameters_MODIS_Data_Static(resampling)
varid                           =   0;

%% Tiled Data
varid                           =   varid +1;
VarMODIS(varid).Productnames	=   'MCD12Q1'; 
VarMODIS(varid).name            =   'LandCover';
VarMODIS(varid).Varname        	=   'LC';  
VarMODIS(varid).Dirnames        =   'MOTA';
VarMODIS(varid).Versionnames    =   '.051';
VarMODIS(varid).Grid            =   'Tile';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   1;                  %

%% CMG Data
varid                           =   varid +1;
VarMODIS(varid).Productnames	=   'MCD12C1'; 
VarMODIS(varid).name            =   'LandCover';
VarMODIS(varid).Varname        	=   'LC';  
VarMODIS(varid).Dirnames        =   'MOTA';
VarMODIS(varid).Versionnames    =   '.051';
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   0;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   1;                  %Majority Land Cover Type 1

