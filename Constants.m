function []=Constants(var);
global flog
if nargin==1
fprintf(flog,'Loading Constants,...\n');
end
%% Constants
global deg2rad kel2deg 
global P0 Rd Rv g k Sigma_SB Cpw Cpd L_e 
global Cd Ct  gamma Rso 
global Pr Pr_u Pr_s
global ri_i T0
global Rmax Rmin
global rho_w

deg2rad =   pi/180;     % Degrees -> rad     
kel2deg	=	-273.15;	% Kelvin -> Celsius 

k       =   0.4;        % von Karman constant
Sigma_SB=   5.678E-8;   % Stefan-Boltzmann's constant (W/m2/K4)
T0      =   273.15;

Rso		=	1366;		% Solar Constant(W/m2)
g       =   9.81;       % Gravity accelaration (kg s-2)

Rmax    =   6378137;   % the earth's equatorial radius (m)
Rmin    =   6356752;   % the earth's polar radius (m)
                    
P0      =   101325.;    % Standard pressure (Pa)
Rd      =   287.04;     % Gas Constant for Dry air, from table 2.1 P25 of Brutsaert 2005 (J kg-1 K-1)
Rv      =   461.5;      % Gas Constant for Water vapor, from table 2.1 P25 of Brutsaert 2005 (J kg-1 K-1)

Cpw     =   1846;       % specific heat coefficient for water vapor, J Kg-1 K-1
Cpd     =   1005;       % specific heat coefficient for dry air, J Kg-1 K-1

Cd      =   0.2;        % Foliage drag coefficient
Ct      =   0.01;       % Heat transfer coefficient

gamma   =   67;         % psychometric constant (Pa K-1)


Pr      =   0.7;        % Prandtl Prandtl number
Pr_u    =   1.0;        % Turbulent Prandtl number for unstable case
Pr_s    =   0.95;       % Turbulent Prandtl number for stable case

ri_i    =   60;         % surface resistance of standard crop, s m-1

% The latent heat of vaporization at 30C from Brutsaert, 1982, p.41,tab. 3.4,
% more exact values can be obtained from eqn(3.22, 3.24a,b)
L_e     =   2.430;  	% MJ Kg-1 % (2501 - 2.375 * T(C))*1000
rho_w   =   0.998;      % density of water [kg/(m2 mm)]
