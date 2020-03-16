%% parameters
global datadir scriptdir flog 
datadir.home                                                =   '/home/j_timmermans/Simulations/Matlab/SEBS/SEBS4SIGMA/Data/';
datadir.TMP                                                 =   [datadir.home,'TMP/'];
datadir.ECMWF                                               =   [datadir.TMP,'ECMWF/'];
datadir.MODIS                                               =   [datadir.TMP,'MODIS/'];
datadir.GLAS                                                =   [datadir.TMP,'GLAS/'];

datadir.output                                              =   [datadir.home,'Output/'];
datadir.resampling                                          =   [datadir.home,'Resampling/'];

%% create directories if required
subdirs                                                     =   fieldnames(datadir);
for j=1:length(subdirs)
    subdir                                                  =   subdirs{j};
    if ~exist(datadir.(subdir),'dir')
        mkdir(datadir.(subdir))
    end
    
    path(path,datadir.(subdir))
end

%% Scripts
scriptdir.home                                              =   '/home/j_timmermans/Simulations/Matlab/SEBS/SEBS4SIGMA/code/';
scriptdir.home                                              =   'E:/Simulations/Matlab/SEBS/SEBS4SIGMA/code/';

scriptdir.Download_MODIS                                    =   [scriptdir.home,'Download_MODIS/'];
scriptdir.Download_ECMWF                                    =   [scriptdir.home,'Download_ECMWF/'];
scriptdir.Download_GLAS                                     =   [scriptdir.home,'Download_GLAS/'];

scriptdir.Resample_Data                                     =   [scriptdir.home,'Resampling_Data/'];
scriptdir.Read_MODIS                                        =   [scriptdir.home,'Read_MODIS/'];
scriptdir.Read_GLAS                                         =   [scriptdir.home,'Read_GLAS/'];
scriptdir.Read_ECMWF                                        =   [scriptdir.home,'Read_ECMWF/'];
scriptdir.SEBS                                              =   [scriptdir.home,'SEBS/'];
scriptdir.read_grib                                         =   [scriptdir.Read_ECMWF,'read_grib/'];
% keyboard
flog                                                        =   1;

%% create directories if required
subdirs                                                     =   fieldnames(scriptdir);
for j=1:length(subdirs)
    subdir                                                  =   subdirs{j};
    path(path,scriptdir.(subdir))
end

% 
% scriptdir
% path(path,scriptdir.home)
% path(path,scriptdir.Download_ECMWF)
% path(path,scriptdir.Download_MODIS)
% 
% path(path,scriptdir.Read_ECMWF)
