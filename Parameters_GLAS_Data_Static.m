function [VarGLAS] = Parameters_GLAS_Data_Static(resampling)
varid                           =   0;

%%
varid                           =   varid+1;
VarGLAS(varid).filename         =   'Simard_Pinto_3DGlobalVeg_JGR.tif.gz';
VarGLAS(varid).Varnames         =   'hc_forest'; 
VarGLAS(varid).weblocation      =   'http://lidarradar.jpl.nasa.gov/MAPS/';
VarGLAS(varid).Grid             =   'CMG';
VarGLAS(varid).resampling       =   resampling;

