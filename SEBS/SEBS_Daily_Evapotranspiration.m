function [Rndaily,Edaily,E0daily]   =   SEBS_Daily_Evapotranspiration(EF, EF0, Albedo, SWd24_Wm, Ta_av_K, Ns, day_angle, lat_rad)
global Sigma_SB kel2deg rho_w  
DT                      =	60*60*24;                                                       % seconds per day		
		
% Solar irradiance parameters (FAO 1998, p46/p48) (eq24, eq25 eq31, eq34)
solar_decl 				= 	0.4093*sin(day_angle-1.405);                                    % solar declination P4.31		

omegas					= 	acos(-tan(solar_decl).*tan(lat_rad));                           % sunset hour angle in radiance
omegas                  =   real(omegas);                                                   % if sun is below horizon (at artic) than previous equation gives imag. numbers
Nt 						= 	24*omegas/pi;                                                   % total day length (h)

% e_es 					= 	1.0+0.033* cos(day_angle);                                      % Correction factor for eccentricity of earth orbit
% cosbeta					=	 cos(lat_rad).* cos(solar_decl).* sin(omegas)+...               % Daily zenith angles
% 										 sin(lat_rad).* sin(solar_decl).*omegas;
% omega					=	pi/12;                                                          % solar time angle at midpoint of period [rad/h]

%% Short wave net radiation	
% TOA Incoming Shortwave Radiation (Brutsaert 2005, p61, p62 eq 2.78)		
% Rin24_S0              =   440.0255*DT/1e6;                                             	% MJ m-2 day-1   should be based on Rso
% Rin24_Sse             =   Rin24_S0*e_es.*cosbeta;                                         % MJ m-2 day-1
% 
% % Bottom of atmosphere downwelling shortwave radiation (Hydrology Handbook 4.7, 4.2.6)
% as					=	0.25;                                                           % cloudiness/transmissivity coefficients 
% bs					=	0.5;                                                            % cloudiness/transmissivity coefficients		
% Rin24_St              =   (as+bs*Ns./Nt).*Rin24_Sse_TOA;

Rin24_St                =   SWd24_Wm*DT/1e6;                                                % MJ m-2 day-1 (calculated by integration of daily ECMWF)

% Net solar radation bottom of atmosphere
Rn24_Sse                =   Rin24_St.*(1-Albedo);                                           % MJ m-2 day-1 (Hydrology Handbook, 4.7, eq 4.2.5)

%% Thermal net radiation	
% Net BOA Long wave radiation (Hydrology Handbook 4.7 eq4.2.7, eq4.2.12 and eq4.2.9):
fcl						=	(0.1 + 0.9 * Ns./Nt);                                           % Cloudiness factor

Ta_av_C                 =   Ta_av_K +kel2deg;
enet					= 	-0.02+0.261* exp(-7.77e-4*Ta_av_C.^2);                          % Net (daily) emissivity
Rn24_L 					= 	-fcl.*enet.*(Sigma_SB*Ta_av_K.^4);                              % Net Longwave radiation (in W m-2)
Rn24_L                  =   Rn24_L*(DT/1e6);                                                % Net Longwave radiation (in MJ m-2 day-1)

%% Net Radiation 
%(Hydrology Handbook 4.2.13)
Rndaily                 =    Rn24_Sse + Rn24_L;                                            	% Net Radiation (MJ m-2 day-1)

%% Daily Evapotranspiration
L_e 					= 	2.501-0.002361*(Ta_av_K-273.15);                               	% latent heat of vaporation (MJ kg-1)
Edaily                  =   EF .* max(Rndaily,0) ./ (L_e*rho_w);                       	% Daily Evapotranspiration [mm day-1]
E0daily                 =   EF0 .* max(Rndaily,0) ./ (L_e*rho_w);                       	% Daily Evapotranspiration [mm day-1]
