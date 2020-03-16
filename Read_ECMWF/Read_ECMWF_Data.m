function [StaticECMWF,DataECMWF,MissingID] = Read_ECMWF_Data(VarECMWF,Time)

%% Read Static (Coordinates, Time and Order)
[StaticECMWF]                                               =   Read_ECMWF_Data_Static(VarECMWF);

%% Read Dynamic
% Location                                                    =   [];
% itime                                                       =   randi(length(Time.acquisitions));               
[DataECMWF,MissingID]                                       =   Read_ECMWF_Data_Dynamic(VarECMWF,StaticECMWF);
 



imagesc(DataECMWF.Rin_s.Values(1:end/2,:,:)')
colorbar
