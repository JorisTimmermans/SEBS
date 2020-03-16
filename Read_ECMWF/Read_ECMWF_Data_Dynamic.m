function [DataECMWF,MissingID]   =   Read_ECMWF_Data_Dynamic(VarECMWF,Sub,Location,startdate)
global datadir
global g Rmax Rmin

% path(path,[cd,'/read_grib'])
       
%%
fprintf(1,'REading ECMWF Data \n');
MissingID                                                       =   0;
for ivar=1:size(VarECMWF,2)
    %% Open file   
% 	interval                                                    =   VarECMWF(ivar).acquisition.resstr;
    varname                                                     =   VarECMWF(ivar).Varname;
    filename                                                    =   VarECMWF(ivar).filestr;

    %% Read Grib
	values                                                      =   read_grib([datadir.ECMWF,filename],-1,'Paramtable','ECMWF128','ScreenDiag',0,'DataFlag',1);   
    Units                                                       =   values(1).units;
    Longname                                                    =   values(1).description;
    Nr_pix_x                                                    =   values(1).gds.Ni;
    Nr_pix_y                                                    =   values(1).gds.Nj;
    
    
    if ~isempty(strfind(varname,'_profile'))        
        Nr_profiles                                             =   length(VarECMWF(ivar).profile);
        Nr_obs                                                 	=   length(values)/Nr_profiles;        
    else
        Nr_profiles                                             =   1;
        Nr_obs                                                 	=   length(values)/Nr_profiles;
    end
        
        
%     if isempty(strfind(varname,'_profile'))
%         Nr_profiles                                             =   1;
%         Nr_obs                                                 	=   length(values)/Nr_profiles;
%         
%         
%         % Reshape Data to correct dimensions
%         Values                                               	=   zeros(nr_pix_x,nr_pix_y,length(values));
%         hours                                                   =   zeros(1,length(values));
%         forecast                                                =   zeros(1,length(values));
%         for j=1:Nr_obs
%             Values(:,:,j)                                     	=   reshape(values(j).fltarray,[nr_pix_x nr_pix_y]);            
%             
%             hours(j)                                            =   values(j).pds.hour; 
%             forecast(j)                                         =   values(j).pds.P1;
%         end
%         hours_all                                               =   hours+forecast;
%         hours_u                                                 =   unique(hours_all);
%         dt_h                                                    =   mean(diff(hours_u));
%         
%     else
%         Nr_profiles                                             =   length(VarECMWF(ivar).profile);
%         Nr_obs                                                 	=   length(values)/Nr_profiles;
                
        % Reshape Data to correct dimensions
        Values                                               	=   zeros(Nr_pix_x,Nr_pix_y,Nr_obs,Nr_profiles);
        hours                                                   =   zeros(1,Nr_obs);
        forecast                                                =   zeros(1,Nr_obs);
        
        for itime=1:Nr_obs
            for ilevel=1:Nr_profiles
                j                                             	=   Nr_profiles*(itime-1) + ilevel;
                Values(:,:,itime,ilevel)                        =   reshape(values(j).fltarray,[Nr_pix_x Nr_pix_y]);            
            
                hours(itime)                                   	=   values(j).pds.hour; 
                forecast(itime)                                 =   values(j).pds.P1;
%                 levels{ilevel}                                  =   values(j).level;
            end
        end
        
        hours_all                                               =   hours+forecast;
        hours_u                                                 =   unique(hours_all);
        dt_h                                                    =   mean(diff(hours_u));        
%     end
        
        %% Temporal 'Nearest Neighbor interpolation' for profile data
        if ~isempty(strfind(varname,'_profile'))        
            Values                                              =   cat(3,Values,Values,Values(:,:,1,:));
            hours                                               =   cat(2,hours,hours,24);
            forecast                                            =   cat(2,forecast,forecast+3,0);
            
            hours_all                                          	=   hours+forecast;
            clear Values2;
        end

%% Post Processing
    switch varname
        case {'Wind_U','Wind_U_profile','Wind_V','Wind_V_profile'}
            % Step 1; Interpolating between timesetpes can go wrong if the winddirection ahs changed sign, therefore 
            % we remove the sign (as we are only interested in abs windspeeds;
            Values                                              =   abs(Values);
            
            
        case {'Rin24_s','Rin_s','Rin_l',...
              'Rns_cs','Rnt_cs',...
              'Rts','Rss',...
              'lE','H'}
            % Step 1; Transform the Cumulative Incoming radiation to Instantaneous Incoming Radiation                    
            % Processing in reverse order (otherwise the nth computation will  be effected by the nth-1 computation)
            dt                                                  =   dt_h * 60*60;      %=60*60*3                                                       
            Values(:,:,8:8:end-0)                               =   (Values(:,:,8:8:end-0,:)-Values(:,:,7:8:end-1,:))/dt;
            Values(:,:,7:8:end-1)                               =   (Values(:,:,7:8:end-1,:)-Values(:,:,6:8:end-2,:))/dt;
            Values(:,:,6:8:end-2)                               =   (Values(:,:,6:8:end-2,:)-Values(:,:,5:8:end-3,:))/dt;
            Values(:,:,5:8:end-3)                               =   (Values(:,:,5:8:end-3,:))/dt;
            Values(:,:,4:8:end-4)                               =   (Values(:,:,4:8:end-4,:)-Values(:,:,3:8:end-5,:))/dt;                    
            Values(:,:,3:8:end-5)                               =   (Values(:,:,3:8:end-5,:)-Values(:,:,2:8:end-6,:))/dt;
            Values(:,:,2:8:end-6)                               =   (Values(:,:,2:8:end-6,:)-Values(:,:,1:8:end-7,:))/dt;
            Values(:,:,1:8:end-7)                               =   (Values(:,:,1:8:end-7,:))/dt;
            Units                                               =   'W m-2';
    end

    %% Step 2a. Selecting (Forecast and analysis data) for observation times 
    hours_u                                                     =   3:3:24;
    Values_s                                                   	=   zeros(size(Values,1),size(Values,2),length(hours_u),Nr_profiles);
    for ihours=1:length(hours_u)
        hour                                                    =   hours_u(ihours);

        ianalysis                                               =   (hours_all==hour | (hours_all-24)==hour) & forecast==0;                  
        iforecast                                               =   (hours_all==hour | (hours_all-24)==hour)& forecast~=0;
        
        if any(ianalysis)
            Values_s(:,:,ihours,:)                            	=   Values(:,:,ianalysis,:);
        elseif any(iforecast)
            Values_s(:,:,ihours,:)                              =   Values(:,:,iforecast,:);
        else
            keyboard
        end
        
    end
    Values                                                      =   Values_s;
    
    %% Step 2b: merging the different instances during the day to the wanted variable at a specific time  (10 o clock)
    switch varname
        case {'Rin24_s','Ta_24','T_surface_av','T_profile_av'}
            Values                                              =   nanmean(Values,3);
        case {'Sunhours','Ns'}
            dt                                                  =   60*60;
            Values                                              =   (Values(:,:,4)+Values(:,:,8))/dt;
            Units                                               =   'h';
            
        otherwise
            T1200                                               =   [4 3 2 1 8 7 6 5]; %needed for calculating the Time-mask correctly. 
            T0900                                               =   [3 2 1 8 7 6 5 4]; %needed for calculating the Time-mask correctly. 
            
            Nlon                                                =   size(Values,1);
            Ntime                                               =   size(T1200,2);
            N                                                   =   Nlon/Ntime;

            % Create weights for combination of layers 
            [W0900,W1200]                                       =   CalculateWeights('sinusoidal');

            Mask1200                                            =   zeros(size(Values),'single');
            Mask0900                                            =   zeros(size(Values),'single');
            for j=1:Ntime
                Mask1200((1:N) +(j-1)*N,:,T1200(j),:)  	        =   W1200;
                Mask0900((1:N) +(j-1)*N,:,T0900(j),:)  	        =   W0900;
            end
            
            % Create weighted average for values taken at 09.00 or 1200=> 1030
            Values                                              =   nansum(Values.*Mask0900 + Values.*Mask1200,3);
    end

    %% Subsetting    
    Values                                                      =   permute(Values,[2 1 3 4]);
    Values2                                                    	=   [Values,Values];
    
    ilat                                                       	=   Sub.ilat;
    ilon                                                       	=   Sub.ilon;
    
    Values                                                      =	Values2(ilon,ilat);    
   
    %% write to variable    
    DataECMWF.(varname).Values                              =   Values;                                         %creation of circular boundary            
    DataECMWF.(varname).Units                               =   Units;                       
    DataECMWF.(varname).Long_name                           =   Longname;                                   % units

end


function [W0900,W1200]=CalculateWeights(method)

% Create weights for combination of layers 
% at x(10.30) from values at % x1(09:00) and x2(12:00)                    
t0900                                                       =   09.00;
t1030                                                       =   10.50;
t1200                                                       =   12.00;
                    

switch method
    case 'linear'
        % assuming linear behaviour between 9 and 12;
        % Note that in reality the values of temperature/radiation will be more closer to 1200 than 0900 values and that
        % equal weight-values might produce some uncertainties. 
        x1200                                               =   t0900;  
        x1030                                               =   t1030;
        x1200                                               =   t1200;
        
    case 'sinusoidal' %stepwise
        % % transformation to get sinusoidal diurnal shape to straight line.
        tprime0900                                          =   6 + 6*sin(t0900*pi/12 -pi/2);
        tprime1030                                          =   6 + 6*sin(t1030*pi/12 -pi/2);
        tprime1200                                          =   6 + 6*sin(t1200*pi/12 -pi/2);
        % 
        % % assuming linear behaviour between 9 and 12;
        x0900                                               =   tprime0900;
        x1030                                               =   tprime1030;
        x1200                                               =   tprime1200;
end
W0900                                                       =   (x1200-x1030)/(x1200-x0900);      
W1200                                                       =   1-W0900;

%% Move to ProcessingDynamic
% fprintf(1,'Post Processing ECMWF Data \n');
%     %% Step 3 in case of profile data 
%     switch varname
%         case {'Z_profile'}
% %             keyboard
%             Nlevels                                         =   size(Values,4);
%             h_gp                                            =   Values/g;                                   %Geopotential height [m] %seems to be in order (checked with internet forecasts)
% 
%             lat_rad                                         =   StaticECMWF.Lat.Values/180*pi;
%             lat_rad                                         =   lat_rad(1:end/2,:,:,ones(Nlevels,1));
%             gprime                                          =   g*(1 - ...
%                                                                    0.002637*cos(2*lat_rad) +... 
%                                                                    0.000059*cos(2*lat_rad).^2);             %g ratio;
%             gratio                                          =   gprime/g;
% 
%             Re                                              =   sqrt(1./( (cos(lat_rad)/Rmax).^2 + ...
%                                                                   (sin(lat_rad)/Rmin).^2));         %radius of the earth at specific latitude [m]
%             Values                                          =   h_gp.*Re./(gratio.*Re-h_gp);                %Geometric height [m]
%             Units                                           =   'm';
%             Longname                                        =   'Geometric height';                    
%     end
%     Values                                                  =   permute(Values,[1 2 4 3]);