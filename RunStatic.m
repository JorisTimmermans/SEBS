[yyyy,mm,dd]    =   datevec(startdate);
filename        =   sprintf('Static02 %04.0f (%03.0f_%03.0f,%03.0f_%03.0f).mat',[yyyy, Location.minlon,Location.maxlon,Location.minlat,Location.maxlat]);

try
    load([datadir.TMP,filename],'Statici','Sub','FullStatic')
    save([datadir.TMP,filename],'Statici','Sub','FullStatic')
catch
    FirstRunStartup
    
    %% Save Startup
    save([datadir.TMP,filename],'Statici','Sub','FullStatic')
toc        
end