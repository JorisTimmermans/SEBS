function    [LAI,fc, hc, Albedo, Emissivity, LST_K,                    	...
            Zref, Zref10, Hpbl,                                        ...
            Tref_K,qaref, Pref_Pa,Ps_Pa,P0_Pa, Uref10,                 ...
            SWd,  LWd, SWd24,                                          ...
            day_angle, lat_rad, Ta_av_K,Ns,Idata]           	=   ParallelExecution_PreProcessing(statici, datai, time)

global Rd kel2deg
global deg2rad

%% Static
[~,lat_deg]                                             =   meshgrid(statici.lon, statici.lat);
lat_rad                                                 =   lat_deg*deg2rad;

%%
doy                                                     =   time.doy;
day_angle                                               =   (2*pi/365) *(floor(doy)-1); 

%% Masking Ocean
Iocean                                                  =   statici.MODIS_CMG.LC.Values==0;
Ierror                                                  =   Iocean;
productnames = fieldnames(datai); 
for iprod=1:length(productnames), 
    productname=productnames{iprod}; 
    varnames = fieldnames(datai.(productname)); 
    for ivar =1:length(varnames), 
        varname=varnames{ivar}; 
        datai.(productname).(varname).Values(Iocean)    =   NaN;
        Ierror                                          =   any(cat(3,Ierror,isnan(datai.(productname).(varname).Values)),3);
    end
end

%% land surface parameters
% Albedo
BSA                                                     =   datai.MODIS_CMG.BSA.Values;
WSA                                                     =   datai.MODIS_CMG.WSA.Values;
D                                                       =   0.75;
Albedo                                                  =   BSA * D + WSA*(1-D);
Albedo(Albedo>0.4)                                      =   NaN;        %filter away any snow values (as ET =0).


% LAI
LAI                                                     =   datai.MODIS_Tile.LAI.Values;

% fractional Cover
NDVImin                                                 =   0.2;
NDVImax                                                 =   0.5;
NDVI                                                    =   datai.MODIS_CMG.NDVI.Values;
fc                                                      =   (NDVI-NDVImin)./(NDVImax-NDVImin);
ierror                                                  =   isnan(fc);
fc                                                      =   max(min(fc,1),0);
fc(ierror)                                              =   NaN;

% Emissivity
em29                                                    =   datai.MODIS_CMG.Emissivity_29.Values;
em31                                                    =   datai.MODIS_CMG.Emissivity_31.Values;
em32                                                    =   datai.MODIS_CMG.Emissivity_32.Values;
Emissivity                                              =   mean(cat(3,em29,em31,em32),3);

% Height of Canopy
NDVImin                                                 =   0.0;                                                        % h = 0.0012
NDVImax                                                 =   0.8;                                                        % h=2.5
hcMin                                                   =   0.0012;
hcMax                                                   =   2.5;

hc_crops                                               	=   hcMin + ((hcMax-hcMin)/(NDVImax-NDVImin)) * (NDVI-NDVImin);
hc_forest                                               =   statici.GLAS.hc_forest.Values;

% keyboard
hc                                                      =   hc_forest;
hc(isnan(hc))                                           =   hc_crops(isnan(hc));
hc                                                      =   max(0.0001,hc);                                            	%to circumvent numerical instability

% Land surface temperature
LST_K                                                   =   datai.MODIS_CMG.LST.Values;

%% Meteodata
% heights (reference + pl
Zref                                                    =   hc+2;
Zref10                                                  =   hc+10;
Hpbl                                                    =   datai.ECMWF.Habl.Values;


% Temperatures (2m)
Tref_K                                                  =   datai.ECMWF.Ta.Values;
Tdew_K                                                  =   datai.ECMWF.Tdew.Values;
Ta_av_K                                                 =   datai.ECMWF.Ta_24.Values;


% Windspeed (10m)
wind_V                                                  =   datai.ECMWF.Wind_V.Values;
wind_U                                                  =   datai.ECMWF.Wind_U.Values;
Uref10                                                  =   sqrt(wind_U.^2 + wind_V.^2);

% Pressures
Pref_Pa                                              	=   datai.ECMWF.Ps.Values;
Ps_Pa                                                   =   datai.ECMWF.Ps.Values;
P0_Pa                                                   =   datai.ECMWF.P0.Values;

% Specific Humidity (qaref)
Tdew_C                                                  =   Tdew_K + kel2deg;                                   % [C]
ea                                                      =   1000*exp(17.27*Tdew_C./(Tdew_C+237.3));             % Water Vapor Pressure (FAo56, p36, eq 11)
rho_d                                                   =   (Ps_Pa-ea)./(Rd*Tref_K);                                   % Density of dry air (Brutsaert, p2 eq 2.4)
rho_v                                                   =   0.622*ea./(Rd*Tref_K);                                 % Density of water vapor (Brutsaert, p25 eq 2.5)
qaref                                                   =   rho_v./(rho_v+rho_d);                               % Specific Humidity (Brutsaert, p24 eq 2.2)

%% Radiation
SWd                                                     =   datai.ECMWF.Rin_s.Values;
LWd                                                     =   datai.ECMWF.Rin_l.Values;
SWd24                                                   =   datai.ECMWF.Rin24_s.Values;

Ns                                                      =   datai.ECMWF.Ns.Values;

%% Postprocessing
LST_K(LST_K<Tref_K)                                     =   NaN;

%% Check values of Remote sensing data
IBB(:,:,1)                                          	=   LAI         < 0     |   LAI         > 10;
IBB(:,:,2)                                          	=   fc          < 0     |   fc          > 1;
IBB(:,:,3)                                          	=   hc          < 0     |   hc          > 200;
IBB(:,:,4)                                          	=   Albedo      < 0     |   Albedo      > 1;
IBB(:,:,5)                                          	=   Emissivity  < 0     |   Emissivity  > 1;
IBB(:,:,6)                                          	=   LST_K       < 263   |   LST_K       > 100;
IBB                                                     =   any(IBB,3);

%% Combine Mask for missing data with Mask for out of boundary
Iflag                                                   =   IBB | Ierror;
Iflag                                                   =   Iflag *0;
Idata                                                   =   ~Iflag;


