day.start   =1;
day.end     =366;
%% Plot Instantaneous fluxes
minv                                                        =   nanmin(InstantaneousData.Rn.Values(:));
maxv                                                        =   nanmax(InstantaneousData.Rn.Values(:));
h1                                                          =   figure('Position',[20 20 1024 800 ]);
h11                                                         =   axes('nextplot','add');

varnames                                                    =   fieldnames(InstantaneousData);
for ivar=1:length(varnames)
    varname                                                 =   varnames{ivar};
    
    for iday=day.start:day.end  
        h111                                                =   imagesc(lon,lat,InstantaneousData.(varname).Values(:,:,iday),[minv maxv]);
        xlabel('Longitude [degrees]')
        ylabel('Latitude [degrees]')
        title(sprintf(['Average ',varname,' between 09:00 and 12:00 localtime [W/m2] on 2008-%03.0f'],iday))
        axis([-181 181 -61 91])
        colorbar
        drawnow,pause(0.1)    
        delete(h111)
    end
end
close(h1)

return
%% Plot Daily fluxes
minv                                                        =   nanmin(DailyData.Edaily.Values(:));
maxv                                                        =   nanmax(DailyData.Edaily.Values(:));
h2                                                          =   figure('Position',[20 20 1024 800 ]);
h21                                                         =   axes('nextplot','add'); 
for iday=day.start:day.end
    h211                                                    =   imagesc(lon,lat, DailyData.Edaily.Values(:,:,iday),[minv maxv]);
    xlabel('Longitude [degrees]')
    ylabel('Latitude [degrees]')
    title(sprintf('Daily total evapotranspiration Values [mm/day] on 2008-%03.0f', iday))
    axis([-181 181 -61 91])
    
    colorbar
    pause(0.1)
    drawnow
    delete(h211)
end
close(h2)

minv                                                        =   nanmin(DailyData.Rndaily.Values(:));
maxv                                                        =   nanmax(DailyData.Rndaily.Values(:));
h3                                                          =   figure('Position',[20 20 1024 800 ]);
h31                                                         =   axes('nextplot','add'); 
for iday=day.start:day.end
    h311                                                    =   imagesc(lon,lat, DailyData.Rndaily.Values(:,:,iday),[minv maxv]);
    xlabel('Longitude [degrees]')
    ylabel('Latitude [degrees]')
    title(sprintf('Total daily net radiation Values [W/m2] on 2008-%03.0f', iday))
    axis([-181 181 -61 91])
    
    colorbar
    pause(0.1)
    drawnow
    delete(h311)
end
close(h3)