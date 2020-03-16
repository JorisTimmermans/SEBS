function [] = Download_ECMWF_Data(VarECMWF,Location, startdate,enddate)
global scriptdir
cd(scriptdir.Download_ECMWF)

%% Preperation4Downloading 
% copying account details to the homedir;
homedir                                                     =   '~/';
if ~exist([homedir,'.ecmwfapirc'],'file')
    copyfile('.ecmwfapirc',[homedir,'.ecmwfapirc'])
end

% set environmental variables 
eval(['!export PYTHONPATH="',cd,'"'])

%% Download Grb files
for date=startdate:enddate    
    for j=1:length(VarECMWF)

        [batchfile,filename]                                =    Download_ECMWF_Data_WriteBatchFile(VarECMWF(j),date,Location);
        
        Download_ECMWF_Data_ExecuteBatchFile

    end
end

%%
cd(scriptdir.home)