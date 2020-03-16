function [Rn, G0, H, LE, LE0, EF,EF0]	=   SEBS_EnergyBalance(d0, z0m, z0h,                                    ...
                                                                LAI,fc, hc, Albedo, Emissivity, LST_K,          ...
                                                                Zref, Zref10, hpbl,                             ...
                                                                Tref_K,qaref, Pref_Pa,Ps_Pa,P0_Pa, Uref10,      ...
                                                                SWd, LWd)

%% NOTES
%---------------------------------------------------------------------
% [outputs]=EnergyBalance(inputs)
% syntax: outputs [ ustar, LE, LE0, G0, Rn, H_DL, H_WL, H_i, evap_fr, re_i]= EnergyBalance( d0, z0m, z0h, fc, ..., 
%         inputs:[ albedo, emissivity, LST_K, SWd, LWd,hpbl, Zref, Tref_K, Uref, Earef, qaref, Pref, Ps, ri_i)
%---------------------------------------------------------------------
% Description of parameters
% Zref      -> Reference height                         (m)
% hpbl       -> Height of the PBL                        (m)
%              (if not available, use 1000m)
% d0        -> Zero plane displacement height           (m)
% z0m       -> Roughness height for momentum tranfer    (m)
% z0h       -> Roughness height for heat tranfer        (m)
% fc        -> Fractional vegetaion cover               (-)
% Uref      -> Wind speed at reference height           (m/s)
% Tref_K    -> Air temperature at reference height      (K)
% Pref      -> Pressure at reference height             (Pa)
% qaref     -> Specific humidity at reference height    (kg/kg)
% LST_K     -> Surface temperature                      (K)
% Ps        -> Surafce pressure                         (Pa)
% SWd       -> Downward Solar Radiation                 (Watt/m^2)
% LWd       -> Downward long wave radiation             (Watt/m^2)",
% albedo    -> Albedo                                   (-)
% emissivity-> Emissivity of the surface                (-)
%---------------------------------------------------------------------
% Solving of 3 equations
% Nots: Here we start to solve the system of three equations
% i.e. the equation of momentum transfer, the equation of heat transfer, and the equation for the stability length.
% We use ASL functions of Brutsaert, 1999, if Zref < hst, the ASL height
% We use BAS functions of Brutsaert, 1999, if Zref > hst, Zref <= hpbl, the PBL height.

% Note: We will determine the Monin-Obukhov length using the definition
% given by Brutsaert (1982), P.65, eqn. 5.25.
% i.e. L = - ustar^3*rhoa/(k*g*((H/Ta*Cp_J_kg_K)+0.61*E))
% By using the quantity, ef=Le*E/(Rn-G0), we can write
% H = (1-ef)*(Rn-G0) and E = ef/Le*(Rn-G0)
% So that L =-ustar^3*rhoam/(k*g*((1-ef)/(Ta*CP)+0.61*ef/Le)*(Rn-G0))
% From this eqn., it is obvious that L=f(ustar^3) and L=f(ef^-1)


% LIMITING CASES: A good idea could be to take L_DL and L_WL respectively as
% the max and min stability length.
% This has the advantage that the feedback effects between land
% surface and the hpbl are considered.
% For theoretical limits, H=Rn-G0, and E=Rn-G0 respectively.
% (Note: For wet surfaces in a dry climate, E may be bigger than
% Rn-G0 due to negative H,
% i.e. the Oasis effect. In this case, a small modification of
% L_WL can be expected. This is ignored for the time being)
% Previously, we interpolated mu_i between mu_i(0) and
% mu_i(-1500), by means of temperature difference
% Though other factors may aslo have influences as seen in the
% calculation of T0Ta_l and T0Ta_u,
% the uncertainties associated to those factors do not warrant
% their adequate applications for this case.
% This is consistant with the definition of resistences for the
% limiting cases, that is, that we ignore the stable case
% over the whole region.

%% Prechecks
if all(isnan(Albedo(:)))
    [Rn, G0, H, LE, LE0, EF,EF0, re_i]   =   deal(zeros(size(LAI),'single')*NaN);   
% 	Write_ErrorsFile('WARNING, All Pixels flagged for Cloud covered,skipping SEBS calculations.',2)
    return
end

%% Constants
global g k Sigma_SB L_e 
global Cpw Cpd
global Rv Rd gamma
% global ri_i
dummy                                   =   fc*0;                                                           % dummy filled with ones with same format(!) as fc;

%% Meteorological Parameters
% Nu                                      =   1.327e-5 * (P0_Pa./ Pref_Pa) .* ((Tref_K / T0).^1.81);         	% Kinematic viscosity of air (Massman 1999b) (10 cm^2/s)
Earef_Pa                                = 	Pref_Pa .* qaref * (Rv / Rd);                                   % actual vapour pressure (based on Pressure at reference height)

% Temperatures (Brutsaert 2008, P32, Eq. 2.23 )  
Theta_a                                 =   Tref_K .*((P0_Pa./Pref_Pa ).^0.286);                           	% potential Air temperature [K]
Theta_s                                 =   LST_K  .*((P0_Pa./Ps_Pa   ).^0.286);                            % potential surface temperature [K]
Theta_av                                =   Theta_a.* (1 + 0.61 * qaref);                                   % virtual potential air temperature [K]

% air densities (Brutsaert 2008, p25 , Eq 2.4,2.6 )
rhoa_m                                  =   (Pref_Pa - 0.378 * Earef_Pa)./ (Rd * Tref_K);                	% density of moist air [kg/m3]
rhoa_WL                                 =   (Pref_Pa - 1.000 * Earef_Pa)./ (Rd * LST_K);                    % density of dry air. [kg/m3]

% NOTE: rhoa_WL is only used for the wet-limit. To get a true upperlimit for the sensible heat
% the Landsurface Temperature is used as a proxy instead of air temperature.

% moist air density (Brutsaert 2008, p29)
Cp_J_kg_K                               =   qaref* Cpw + (1-qaref)*Cpd;                                     % Specific heat for constant pressure []
rhoa_m_Cp                               =   rhoa_m .* Cp_J_kg_K;                                          	% specific air heat capacity [J K-1 m-3]
rhoa_WL_Cp                              =   rhoa_WL .* Cp_J_kg_K;                                           % specific air heat capacity [J K-1 m-3]

% saturated vapor pressure at wet limit (WL) (Campbell & Norman, 1998, p41, eq 3.8 and 3.9)
LST_C                                   =   LST_K - 273.15;                                                 % Landsurface temperature[C].
A                                       =   611;                                                            % constant [Pa] %610.8
B                                       =   17.502;                                                         % constant [- ] %17.27
C                                       =   240.97;                                                         % constant [C ] %237.3
esat_WL_Pa                              =   A * exp(B * LST_C./(LST_C + C));                                % saturated vapor pressure [Pa] 
slope_WL                                =   B * C * esat_WL_Pa ./ ((C + LST_C).^2);                     	% Slope of saturation vapor pressure [Pa C-1]

% NOTE: esat_WL is only used for the wet-limit. To get a true upperlimit for the sensible heat
% the Landsurface Temperature is used as a proxy instead of air temperature.

%% Net Radiation and Ground Heat flux
% keyboard
% Net Radiation
SWnet                                   =   (1.0 - Albedo) .* SWd;                                          % Shortwave Net Radiation [W/m2]
LWnet                                   =   Emissivity.*LWd - Emissivity.*Sigma_SB.*LST_K.^4;               % Longwave Net Radiation [W/m2]
Rn                                      =   SWnet+LWnet;                                                    % Total Net Radiation [W/m2]

% Ground Heat Flux
Lambda_c                                =   0.050;
Lambda_s                                =   0.315;  
G0                                      =   Rn .* (Lambda_c + (1-fc)*(Lambda_s - Lambda_c));


%% Sensible Heat flux
% ASL height
% hst= alfa*hpbl, with alfa=0.10~0.15 over moderately rough surfaces, or hst=beta*z0, with beta= 100~150.
alfa                                    =   0.12;                                                           % These are mid values as given by Brutsaert,1999
beta                                    =   125;                                                            % These are mid values as given by Brutsaert,1999
hst                                     =   max(alfa * hpbl, beta * z0m);                                   % height of ASL

% U* and L (Brutsaert 2008, P47, Eq. 2.46, 2.54 and 2.55 and 2.56)
% Initial guess: (Brutsaert 2008, p46 and p57, Eq. 2.54, 2.55 and 2.46)
% MOS (Brutsaert 2008, p46 and p57, Eq. 2.54, 2.55 and 2.46)
% BAS (Brutsaert 2008, p46 and p52, Eq. 2.67, 2.68 and 2.46)
dTheta                                  =   Theta_s - Theta_a;
CH                                      =   (dTheta) .* k .* rhoa_m_Cp;
CL                                      =   -rhoa_m_Cp .* Theta_av/ (k * g);                                % in this formula

z_d0                                    =   Zref - d0;
z10_d0                                  =   Zref10 - d0;

ku10                                    =   k * Uref10;
log_z10_d0_z0m                          =   log(z10_d0 ./ z0m);
log_z_d0_z0h                            =   log(z_d0 ./ z0h);

% Initial guess for u*, H and L assuming neutral stability
L                                       =   dummy;                                                          % initial L is zero for neutral condition
ustar                                   =   ku10 ./ log_z10_d0_z0m;                                           	% U* in neutral condition when stability factors are zero
H                                       =   CH .* ustar ./ log_z_d0_z0h;                                    % H  in neutral condition when stability factors are zero
H0                                      =   H;                                                              % H0 is H in neutral condition
steps                                   =   0;

IMOS                                    =   Zref <= hst;
IBAS                                    =   Zref >  hst;
bw                                      =   dummy;
cw                                      =   dummy;

% tall vegetation parameterization
Itall                                   =   hc>5 & LAI>2;
l                                       =   0.027;
o                                       =   0.69;
%   kB_1                                =   log(z0m./ z0h);
    
errorH                                  =   10;
%%
while (nanmean(errorH(:))>1e-4  && (steps< 50) && sum(errorH(:)>1)/length(errorH(:))>1e-5)
    %Stability Function
    L                                   =   CL .* (ustar.^3)./ (H);                                         % Obukhov Stability length

    %update z0h and z0m for % tall vegeation                
    z0h(Itall)                          =   z0m(Itall).*max(1./ exp( 52*sqrt(l*ustar(Itall))./LAI(Itall) - o),0.1);     % tall vegetation (timmermans et al, in prep)        
    log_z_d0_z0h(Itall)                 =   log(z_d0(Itall) ./ z0h(Itall));

    % Stability functions
    bw(IBAS)                            =   Bw(hpbl(IBAS), L(IBAS), z0m(IBAS), d0(IBAS));                   % BAS stability functions
    cw(IBAS)                            =   Cw(hpbl(IBAS), L(IBAS), z0m(IBAS), z0h(IBAS),d0(IBAS));         % BAS stability functions

    bw(IMOS)                            =   PSIm(z10_d0(IMOS)./L(IMOS))  - PSIm(z0m(IMOS)  ./L(IMOS));       % MOST stability functions
    cw(IMOS)                            =   PSIh(z_d0(IMOS)  ./L(IMOS))  - PSIh(z0h(IMOS)  ./L(IMOS));       % MOST stability functions        

    % Friction velocity
    ustar                               =   ku10./ (log_z10_d0_z0m  - bw);                                  % Friction Velocity

    % Sensible Heat
    H                                   =   CH .* ustar ./ (log_z_d0_z0h  - cw);                            % Sensible Heat

    % Error
    errorH                              =   abs(H0 - H);
    H0                                  =   H;
    steps                               =   steps + 1;    
end


% Post iteration 
[C_i1,C_i2]                             =   deal(dummy);
C_i1(IMOS)                              =   PSIh(z_d0(IMOS)./ L(IMOS));                                     % 1st Stability correction term for heat (BAS  condition)
C_i2(IMOS)                              =   PSIh(z0h(IMOS) ./ L(IMOS));                                     % 2nd Stability correction term for heat (BAS  condition)
C_i1(IBAS)                              =   Cw(Zref((IBAS)), L(IBAS), z0m(IBAS), z0h(IBAS), d0(IBAS));      % 1st Stability correction term for heat (BAS  condition)
C_i                                     =   C_i1 - C_i2;

% Sensible heat Flux, resistances (Su 2002, eq 17)
I_1                                     =   (log_z_d0_z0h>  C_i);                                           % classification of pixels
I_2                                     =   (log_z_d0_z0h<= C_i);                                           % classification of pixels

re_i                                    =   zeros(size(I_1),'single')*NaN;
re_i(I_1)                               =   (log_z_d0_z0h(I_1) - C_i(I_1))./(k * ustar(I_1));  % Actual resistance to heat transfer [s/m]
re_i(I_2)                               =   (log_z_d0_z0h(I_2)           )./(k * ustar(I_2));  % Actual resistance to heat transfer [s/m]

H_i                                     =   rhoa_m_Cp.* (Theta_s-Theta_a)./re_i;                            % Sensible heat flux
    
%% Evaporative Fraction
% Sensible heat flux at theoretical Dry limit
% Dry limit
%L_dry                                  = 	0;
H_DL                                    =   Rn - G0;                                                         %Sensible heat at Dry Limit

%% Sensible heat flux at theoretical wet limit
% Dry air is assumed.. eact=0, and we need to take the density of dry air
L_WL                                    =   -(ustar.^3).* rhoa_WL./(k*g*(0.61* (Rn - G0)/L_e));             %Obukhov stability length at Wet Limit

% Bulk Stability Corrections
I_MOS                                   =   (Zref < hst);                                                   % classification of pixels
I_BAS                                   =   (Zref >= hst);                                                  % classification of pixels
[C_WL1,C_WL2]                           =   deal(zeros(size(I_MOS),'single')*NaN);
C_WL1(I_MOS)                            =   PSIh(Zref(I_MOS)./ L_WL(I_MOS));                                % Stability correction term for heat (MOS  condition)
C_WL2(I_MOS)                            =   PSIh(z0h( I_MOS)./ L_WL(I_MOS));                                % 2nd Stability correction term for heat (BAS  condition)
C_WL1(I_BAS)                            =   Cw(Zref(I_BAS),L_WL(I_BAS),z0m(I_BAS),z0h(I_BAS),d0(I_BAS));    % Stability correction term for heat (BAS  condition)

% Calculating Resistances (Su 2002, p 88, eq 18)    
I_1                                     =   (log_z_d0_z0h>C_WL1);                                            % classification of pixels
I_2                                     =   (log_z_d0_z0h<=C_WL1);                                           % classification of pixels

re_WL                                   =   zeros(size(I_1),'single')*NaN;
re_WL(I_1)                              =   (log_z_d0_z0h(I_1) - C_WL1(I_1) + C_WL2(I_1))./(k * ustar(I_1));  % Actual resistance to heat transfer [s/m]
re_WL(I_2)                              =   (log_z_d0_z0h(I_2)                          )./(k * ustar(I_2));  % Actual resistance to heat transfer [s/m]

H_WL                                    =   ((Rn-G0) - (rhoa_WL_Cp./re_WL).*((esat_WL_Pa-Earef_Pa)/ gamma))./(1.0 + slope_WL/gamma);    % Sensible heat at Wet Limit [W/m2](Su 2002, p88, eq 16)

%% Evaporative fraction
H_i                                     =   min(H_i, H_DL);                                                 %set lower limit for sensible heat [W/m2]
H_i                                     =   max(H_i, H_WL);                                                 %set upper limit for sensible heat [W/m2]

% Relative evaporation
I_w                                     =   (H_DL <= H_WL);                                                 % classification of pixels
I_l                                     =   (H_DL > H_WL);                                                  % classification of pixels
evap_re                                 =   single(zeros(size(I_w)));
evap_re(I_w)                            =   1;                                                              % relative evaporation for water & wet surfaces []
evap_re(I_l)                            =   1 - (H_i(I_l)-H_WL(I_l)) ./ (H_DL(I_l)-H_WL(I_l));              % relative evaporation for land surface []

% Evaporative fraction
I_1                                     =   ((Rn - G0) ~= 0);                                               % classification of pixels
I_2                                     =    ((Rn - G0) == 0);                                           	% classification of pixels

EF                                      =   single(zeros(size(I_1))).*NaN;
EF(I_1)                                 =   evap_re(I_1).*(Rn(I_1)-G0(I_1)-H_WL(I_1))./(Rn(I_1)-G0(I_1));  	% evaporative fraction []
EF(I_2)                                 =   1;                                                              % evaporative fraction upper limit [] (for negative available energy)

EF                                      =   max(EF,0);
EF                                      =   min(EF,1);
EF(isnan(Rn))                           =   NaN;

%% Latent heat
LE                                      =   EF .* (Rn - G0);                                                % Latent heat flux [W/m2]


%% referentie verdampings
ri                                      =   0;
gammaR                                  =   gamma*(1+ri./re_i);
LE0                                     =   ((Rn-G0).*slope_WL + (rhoa_m_Cp).*(esat_WL_Pa-Earef_Pa)./re_i) ./(gammaR + slope_WL) ; %Penman Monteith

%calculate potential evaporative fraction
EF0                                     =   LE0./(Rn-G0);
EF0                                     =   max(EF0,0);
EF0                                     =   min(EF0,1);
EF0(isnan(Rn))                          =   NaN;



function [psim] = PSIm(zeta)
Y                                   =   -zeta;                                                          %coordinate system change (Brutsaert 2008, p500
% Integrated stability function
% 1a. Stability correction function for momentum, eq.(16) Y=-z/L, z is the height, L the Obukhov length, 
% both specified in the calling statement. For stable conditions we use the expressions proposed by 
% Beljaars and Holtslag (1991)and evaluated by Van den Hurk and Holtslag (1995) can be used.

a_s                                 =   1.0;                                                            % constants, p. 122, van der Hurk & Holtslag (1997)
b_s                                 =   0.667;                                                          % constants, p. 122, van der Hurk & Holtslag (1997)
c_s                                 =   5.0;                                                            % constants, p. 122, van der Hurk & Holtslag (1997)
d_s                                 =   0.35;                                                           % constants, p. 122, van der Hurk & Holtslag (1997)% QUESTION: In page 24, d_s=1 

a_u                                 =   0.33;                                                           % constants, p. 49, Brutsaert(2008)
b_u                                 =   0.41;                                                           % constants, p. 49, Brutsaert(2008)

psim                                =   single(zeros(size(zeta)));

% STABLE conditions (According to Beljaars & Holtslag, 1991, eq. 13)
I_s                                 =   ((Y < 0.0));                                              %classify stable pixels
y_s                                 =   -Y;                                                             %coordinate change due to formulation of Beljaars and Holtslag 1991
psim(I_s)                           =   -(a_s*y_s(I_s)+b_s*(y_s(I_s)-c_s/d_s).*exp(-d_s*y_s(I_s))+b_s*c_s/d_s); 

% UNSTABLE conditions(% According to Brutsaert 2008, p50)
% For unstable conditions Kader and Yaglom reasoned that the surface layer should be subdivided into
% three sublayers. Brutsaert (1992, 1999) combined the functional behaviour of each of these three
% sublayers and proposed the two regions.
I_u                                 =   (Y >= 0.0);
I_u1                                =   ((Y <= b_u^(-3)) & I_u);
I_u2                                =   ((Y >  b_u^(-3)) & I_u);

y_u                                 =   single(zeros(size(I_u1)));
y_u(I_u1)                           =   Y(I_u1);
y_u(I_u2)                          	=   b_u.^(-3);

x_u                                 =   (y_u/a_u).^(1/3);    

PSI0                                =   -log(a_u) + sqrt(3)*b_u*(a_u^(1/3))*pi/6; 

psim(I_u)                           =   log(a_u+y_u(I_u)) - 3*b_u*(y_u(I_u).^(1/3))                         + ...
                                         b_u*a_u^(1/3)/2 * log((1+x_u(I_u)).^2 ./ (1-x_u(I_u)+x_u(I_u).^2)) + ...
                                         sqrt(3)*b_u*a_u^(1/3)*atan((2*x_u(I_u)-1)/sqrt(3))                 + ...
                                         PSI0;

return

function [psih] = PSIh(zeta) 
Y                                   =   -zeta;                                                          % coordinate change due to formulation of Brutsaert 2008, p50
% Integrated stability function 1b.
% Stability correction function for heat, eq.(17)
% Y=-z/L, z is the height, L the Obukhov length, both specified in the calling statement.
% For stable conditions
% we use the expressions proposed by Beljaars and Holtslag (1991)
% and evaluated by Van den Hurk and Holtslag (1995) can be used.

a_s                                 =   1.0;                                                            % constants, p. 122, van der Hurk & Holtslag (1995)
b_s                                 =   0.667;                                                          % constants, p. 122, van der Hurk & Holtslag (1995)
c_s                                 =   5.0;                                                            % constants, p. 122, van der Hurk & Holtslag (1995)
d_s                                 =   0.35;                                                           % constants, p. 122, van der Hurk & Holtslag (1995)% QUESTION: d_s=1 in page 34 of SEBS document of Su

c_u                                 =   0.33;                                                           % constants, p. 443, Brutsaert, 2008
d_u                                 =   0.057;                                                          % constants, p. 443, Brutsaert, 2008
n                                   =   0.78;                                                           % constants, p. 443, Brutsaert, 2008

psih                                =   single(zeros(size(zeta)));

% STABLE conditions (According to Beljaars & Holtslag, 1991 eq. 13    )    
I_s                                 =   (Y < 0);                                                  % Classify pixels
y                                   =   -Y;                                                             % sign change (formulation of Beljaars and Holtslag 1991)
psih(I_s)                           =   -((1 + 2*a_s/3 * y(I_s)).^1.5                  ...              % MOS Stability functions for unstable conditions
                                        +b_s * (y(I_s) - c_s / d_s).*exp(-d_s * y(I_s))...
                                        +b_s * c_s / d_s - 1);


% UNSTABLE conditions (According to Brutsaert 2008, p50)
I_u                                 =   (Y >= 0);                                                 % Classify pixels
psih(I_u)                           =   ((1 - d_u) / n) * log((c_u + (Y(I_u).^ n)) / c_u);              % MOS Stability functions for unstable conditions

return

function [bw] = Bw(hpbl, L, z0m, d0) 
% NOTES:
% Bulk Stability function for momentum, eq.(22), (26)
% PBL:          Height of ABL or PBL
% L:            The Obukhov length
% z0m:          Surface roughnes height for momentum
% 
% The ASL height
% hst = alfa*PBL, with alfa=0.10~0.15, over moderately rough surfaces, or hst=beta*z0m, with beta= 100~150.
% 
% Typical values:
% The equations describe the Free convective conditions in the mixed layer,
% provided the top of the ABL satisfies the condition -hst > 2L.
%  
% For a surface with moderate roughness and PBL=1000m, alfa=0.12, this
% is -PBL/L > 17 and -L <60 (and similar values over very rough terrain).
% NOTE: The minus (-) sign infront of B1, B11, B22 are necessary,though not
% clearly specified by Brutsaert, 1999. This is consistent with the integral
% form given in (16)&(17) in which y, the variable is defined as -z/L.
%   (z0m LT (alfa/beta)*PBL): Bw = -ALOG(alfa) + PSIm(alfa*PBL/L) - PSIm(z0m/L) ;(22)
%   (z0m GE (alfa/beta)*PBL): Bw = ALOG(PBL/(beta*z0m)) + PSIm(beta*z0m/L)- PSIm(z0m/L) ;(26)
% B0 = (alfa / beta) * hpbl;
% B1 = -z0m / L;
% B11 = -alfa * hpbl / L;
% B21 = PBL / (beta * z0m);
% B22 = -beta * z0m / L;

alpha                               =   0.12;                                                           % These are mid values as given by Brutsaert, 1999
beta                                =   125;                                                            % These are mid values as given by Brutsaert, 1999

bw                                  =   single(zeros(size(L)));

% STABLE conditions (Brutsaert, 1982, Eq. 4.93, p.84)
I_s                                 =   ((-z0m ./ L) < 0);                                              % classify pixels (Stable)
bw(I_s)                             =   -2.2 * log(1 + (-(-(hpbl(I_s)./L(I_s)))));                      % BAS stability function for stable conditions


% UNSTABLE conditions (Brutsaert 2008, p53)
I_u                                 =   ((-z0m./L) >= 0);                                               % classify pixels (Unstable)
I_umr                               =   ((z0m<((alpha/ beta) * hpbl))   & I_u);                         % classify pixels (moderately rough terrain)
I_uvr                               =   ((z0m>=((alpha / beta) * hpbl)) & I_u);                         % classify pixels (moderately rough terrain)

bw(I_umr)                           =   PSIm(alpha*(hpbl(I_umr)-d0(I_umr))./L(I_umr))   - ...           % BAS stability function for unstable conditions for moderately rough terrain
                                        PSIm(z0m(I_umr)./L(I_umr))                      - ...
                                        log(alpha);

bw(I_uvr)                           =   PSIm(beta *(z0m(I_uvr)    )./L(I_uvr))          - ...           % BAS stability function for unstable conditions for very rough terrain
                                        PSIm(z0m(I_uvr)./L(I_uvr))                      + ...           % 
                                        log((hpbl(I_uvr)-d0(I_uvr))./(beta* z0m(I_uvr)));


%%
return

function [cw] = Cw(hpbl, L, z0m, z0h, d0) 
% Bulk Stability function for heat tranfer, eq.(23), (27)
% hpbl:         Height of ABL or PBL
% L:            The Obukhov length
% z0:           Surface roughnes height for momentum
% z0h:          Surface roughnes height for height transfer
% 
% The ASL height
% hst = alfa*hpbl, with alfa=0.10~0.15 over moderately rough surfaces, or hst=beta*z0, with beta= 100~150.

alfa                                =   0.12;                                                           % These are mid values as given by Brutsaert, 1999
beta                                =   125 ;                                                           % These are mid values as given by Brutsaert, 1999

cw                                  =   single(zeros(size(L)));

% STABLE conditions (Brutsaert, 1982, Eq. 4.93,p.84)
I_s                                 =   (((-z0h ./ L) < 0));                                              % classify pixels (Stable)
cw(I_s)                             =   -7.6 * log(1 + (-(-hpbl(I_s) ./ L(I_s))));                       % BAS stability functions for stable atmosphere

% UNSTABLE conditions (Brutsaert 2008, p53)       
I_u                                 =   ((-z0h ./ L) >=0);                                        % classify pixels (Unstable)
I_umr                               =   ((z0m < ((alfa / beta) * hpbl)) & I_u);                   % classify pixels (moderately rough terrain)
I_uvr                               =   ((z0m >=((alfa / beta) * hpbl)) & I_u);                   % classify pixels (very rough terrain)


cw(I_umr)                           =   PSIh(alfa * (hpbl(I_umr)-d0(I_umr))./L(I_umr)) - ...            % BAS stability functions for stable atmosphere (mod. rough terrain)
                                        PSIh(z0h(I_umr)./L(I_umr))              - ...
                                        log(alfa);   
cw(I_uvr)                           =   PSIh(beta * (z0m(I_uvr)    )./L(I_uvr)) - ...                   % BAS stability functions for stable atmosphere (very rough terrain)
                                        PSIh(z0h(I_uvr)./L(I_uvr))              + ...
                                        log((hpbl(I_uvr)-d0(I_uvr))./(beta*z0m(I_uvr)));           

return



