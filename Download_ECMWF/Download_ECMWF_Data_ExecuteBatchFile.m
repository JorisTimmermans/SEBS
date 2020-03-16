
tic
eval(['!python ',batchfile])
toc

try
    filename_new            =   [filename(1:end-5),'.grib'];
%     movefile(filename,[outputdir,dirname,filename_new])
    movefile(batchfile,[outputdir,dirname,'batchfiles',filesep,batchfile])
catch errormsg
    
end