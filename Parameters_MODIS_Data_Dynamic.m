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

%% 5600,
varid                           =   varid +1;
VarMODIS(varid).Productnames    =   'MCD43C3'; 
VarMODIS(varid).name            =   'Albedo';  
VarMODIS(varid).Varname        	=   'BSA';  
VarMODIS(varid).Dirnames        =   'MOTA';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   8;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   10;

varid                           =   varid +1;
VarMODIS(varid).Productnames    =   'MCD43C3'; 
VarMODIS(varid).name            =   'Albedo';
VarMODIS(varid).Varname         =   'WSA';
VarMODIS(varid).Dirnames        =   'MOTA';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   8;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   20;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD13C1'; 
VarMODIS(varid).name            =   'NDVI';
VarMODIS(varid).Varname        	=   'NDVI';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   8;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   01;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'LST';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   1;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'time';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   3;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'theta_v';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   3;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'Emissivity_29';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   12;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'Emissivity_31';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   13;

varid                           =   varid +1;
VarMODIS(varid).Productnames   	=   'MOD11C1'; 
VarMODIS(varid).name            =   'LST';
VarMODIS(varid).Varname        	=   'Emissivity_32';  
VarMODIS(varid).Dirnames        =   'MOLT';  
VarMODIS(varid).Versionnames    =   '.005'; 
VarMODIS(varid).Grid            =   'CMG';
VarMODIS(varid).acquisition     =   'Static';
VarMODIS(varid).Frequency       =   1;
VarMODIS(varid).resampling      =   resampling;
VarMODIS(varid).IdSDS           =   14;

%% old tiled
% varid                           =   varid +1;
% VarMODIS(varid).Productnames	=   'MCD43B3'; 
% VarMODIS(varid).name            =   'Albedo';
% VarMODIS(varid).Dirnames        =   'MOTA';
% VarMODIS(varid).Versionnames    =   '.005';
% VarMODIS(varid).Grid            =   'Tile';
% VarMODIS(varid).acquisition     =   'Static';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   0;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames	=   'MOD11A1'; 
% VarMODIS(varid).name            =   'LST';
% VarMODIS(varid).Dirnames        =   'MOTA';
% VarMODIS(varid).Versionnames    =   '.005';
% VarMODIS(varid).Grid            =   'Tile';
% VarMODIS(varid).acquisition     =   'Static';
% VarMODIS(varid).Frequency       =   1;
% VarMODIS(varid).resampling      =   resampling;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames	=   'MOD11B1'; 
% VarMODIS(varid).name            =   'LST';
% VarMODIS(varid).Dirnames        =   'MOLT';
% VarMODIS(varid).Versionnames    =   '.005';
% VarMODIS(varid).Grid            =   'Tile';
% VarMODIS(varid).acquisition     =   'Static';
% VarMODIS(varid).Frequency       =   1;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   ;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames	=   'MOD13A2'; 
% VarMODIS(varid).name            =   'NDVI';
% VarMODIS(varid).Dirnames        =   'MOLT';
% VarMODIS(varid).Versionnames    =   '.005';
% VarMODIS(varid).Grid            =   'Tile';
% VarMODIS(varid).acquisition     =   'Static';
% VarMODIS(varid).Frequency       =   16;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   ;

%% MOD13C1
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'NDVI';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8d;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   01;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'EVI';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   02;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'VI quality';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   03;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'rho_red';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   04;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'rho_nir';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   05;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'rho_blue';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   06;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =  'rho_mir';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   07;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'theta_s';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   08;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'std_NVDVI';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   09;
% 
% varid                           =   varid +1;
% VarMODIS(varid).Productnames   	=   'MOD13C1'; 
% VarMODIS(varid).name            =   'std_EVI';  
% VarMODIS(varid).Dirnames        =   'MOLT';  
% VarMODIS(varid).Versionnames    =   '.005'; 
% VarMODIS(varid).Grid            =   'CMG';
% VarMODIS(varid).Frequency       =   8;
% VarMODIS(varid).resampling      =   resampling;
% VarMODIS(varid).IdSDS           =   10;