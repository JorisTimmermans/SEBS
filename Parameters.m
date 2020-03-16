
%% Spatio Temporal Settings
Parameters_SpatioTemporal

VarECMWF.Static                             =   Parameters_ECMWF_Data_Static('natural');
VarGLAS.Static                             	=   Parameters_GLAS_Data_Static('nearest');
VarMODIS.Static_Tile                      	=   Parameters_MODIS_Data_Static_Tile('nearest');
VarMODIS.Static_CMG                         =   Parameters_MODIS_Data_Static_CMG('nearest');

% select data to be used
VarECMWF.Dynamic                            =   Parameters_ECMWF_Data_Dynamic('natural');
VarMODIS.Dynamic_Tile                       =   Parameters_MODIS_Data_Dynamic_Tile('nearest');
VarMODIS.Dynamic_CMG                        =   Parameters_MODIS_Data_Dynamic_CMG('nearest');

VarMODIS.Static                             =   [VarMODIS.Static_Tile,VarMODIS.Static_CMG];
VarMODIS.Dynamic                            =   [VarMODIS.Dynamic_Tile,VarMODIS.Dynamic_CMG];

% VarECMWF.Total                              =   [VarECMWF.Static,VarECMWF.Dynamic];
% VarMODIS.Total                              =   [VarMODIS.Static,VarMODIS.Dynamic];

%% Paths
Parameters_DefinePaths