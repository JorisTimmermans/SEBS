function [batchfile,filename]  =    Download_ECMWF_Data_WriteBatchFile(ECMWF,date,L)
global resolution datadir
Datestr                         =   datestr(date,'yyyymmdd');
Datestr1                        =   datestr(date+0,'yyyy-mm-dd');
Datestr2                        =   datestr(date+0,'yyyy-mm-dd');
locationstr                     =   sprintf('%02.0f/%02.0f/%02.0f/%02.0f',[L.maxlat,L.minlon,L.minlat,L.maxlon]);
batchfile                       =   ['DownloadBatchFile_',ECMWF.name,'_',Datestr,'.py'];


%%
filename                        =   [datadir.ECMWF,ECMWF.filestr];
fid                             =   fopen(batchfile,'w');

if isempty(strfind(ECMWF.name,'_profile'))
    
    fprintf(fid, 'from ecmwfapi import ECMWFDataServer\n');
    fprintf(fid, '\n');

    fprintf(fid, 'server = ECMWFDataServer()\n\n');
    fprintf(fid, 'server.retrieve({\n');
    fprintf(fid, '          ''use''     : "infrequent",\n');
    fprintf(fid, '          ''stream''  : "oper",\n');
    fprintf(fid, '          ''dataset'' : "interim",\n');
    fprintf(fid, '          ''step''    : "0/3/6/9/12",\n');
    fprintf(fid, '          ''levtype'' : "sfc",\n');
    fprintf(fid,['          ''date''    : "',Datestr1,'/to/',Datestr2,'",\n']);
    fprintf(fid, '          ''time''    : "00/06/12/18",\n');
    fprintf(fid, '          ''type''    : "an/fc",\n');
    fprintf(fid,['          ''param''   : "',ECMWF.ID,'",\n']);
    fprintf(fid,['          ''area''    : "',locationstr,'",\n']);
    fprintf(fid,['          ''grid''    : "',resolution,'/',resolution,'",\n']);
    fprintf(fid,['          ''target''  : "',filename,'"\n']);
    fprintf(fid, '          })');
    
else
    %% Profile data
    profilestr                      =   sprintf('%1.0f/',ECMWF.profile);profilestr=profilestr(1:end-1);
    
    fprintf(fid, 'from ecmwfapi import ECMWFDataServer\n');
    fprintf(fid, '\n');
    
    fprintf(fid, 'server = ECMWFDataServer()\n\n');
    fprintf(fid, 'server.retrieve({\n');
    fprintf(fid, '          ''use''     : "infrequent",\n');
    fprintf(fid, '          ''stream''  : "oper",\n');
    fprintf(fid, '          ''dataset'' : "interim",\n'); 
    fprintf(fid, '          ''step''    : "0",\n');
    fprintf(fid, '          ''levtype'' : "pl",\n');
    fprintf(fid,['          ''date''    : "',Datestr1,'/to/',Datestr2,'",\n']);
    fprintf(fid, '          ''time''    : "00/06/12/18",\n');
    
    fprintf(fid,['          ''levelist'': "',profilestr,'",\n']);
    fprintf(fid, '          ''type''    : "an",\n');
    fprintf(fid,['          ''param''   : "',ECMWF.ID,'",\n']);
    fprintf(fid,['          ''area''    : "',locationstr,'",\n']);
    fprintf(fid,['          ''grid''    : "',resolution,'/',resolution,'",\n']);
    fprintf(fid,['          ''target''  : "',filename,'"\n']);
    fprintf(fid, '          })');
end
fclose(fid);
