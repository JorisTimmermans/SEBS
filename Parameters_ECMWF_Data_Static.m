function VarECMWF = Parameters_ECMWF_Data_Static(resampling)
varid                           =   0;

%% Surface levels
varid                           =   varid +1;
VarECMWF(varid).ID              =    '151.128';
VarECMWF(varid).Description     =   'Mean sea level pressure';
VarECMWF(varid).shortname       =   'msl';
VarECMWF(varid).filestr         =   'P0.grib';
VarECMWF(varid).Units           =   'Pa';
VarECMWF(varid).name            =   'P0';
VarECMWF(varid).Varname         =   'P0';
VarECMWF(varid).resampling      = resampling;