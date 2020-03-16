function [z0m, d0, z0h]=  SEBS_kb_1(LAI, fc, hc,                    ...
                                    Zref, Zref10,                   ...
                                    Tref_K,qa_ref, Pref_Pa,Ps_Pa, P0_Pa,Uref10)
% output
% z0hM          Roughness height for heat transfer (m), 0.02
% d0            Displacement height
% z0h           Roughness height for momentum transfer (m), 0.2

% KB_1M by Massman, 1999, (24) This a surrogate for the full LNF model for describing the combined
% canopy and soil boundary layer effects on kBH_1. The formulation follows Su (2001), HESS
% zref:         reference height (2hc <= zref <= hst=(0.1 ~0.15)hi, (=za))
% Uref:         wind speed at reference height
% u_h:          wind speed at canopy height
% hc:           canopy height
% LAI:          canopy total leaf area index
% Cd:           foliage drag coefficient, = 0.2
% Ct:           heat transfer coefficient
% fc :          Fractional canopy cover (-)
% Ta:           ambient air temperature (0C)
% Pa:           ambient air pressure (Pa)
% hs:           height of soil roughness obstacles 
% Nu:           Kinematic viscosity of air, (m^2/s)
% Ta:           ambient temperature of the air, (0C)
% Pa:           ambient pressure of the air, (0C)

%% Constants
global Cd Ct 
global k Pr
global T0

dummy             	=   zeros(size(Ps_Pa),'single');                                           % dummy filled with ones with same format(!) as fc;
fs                  =   1 - fc;                                                             % fractional soil coverage
Nu                  =   1.327e-5 * (P0_Pa ./ Pref_Pa) .* ((Tref_K / T0).^1.81);                   % Kinematic viscosity of air (Massman 1999b) (10 cm^2/s)

%% U*/U(h)
c1                  =   0.320;                                                              % model constants (Massman 1997)
c2                  =   0.264;                                                              % model constants (Massman 1997)
c3                  =   15.1;                                                               % model constants (Massman 1997)
ust2u_h             =   c1 - c2 * exp(-c3 * Cd * LAI);                                      % Ratio of ustar and u(h) (Su. 2001 Eq. 8)
Cd_bs               =   2*ust2u_h.^2;                                                       % Bulk surface drag cofficient (Su 2001)

%% within-canopy wind speed profile extinction coefficient
n_ec                =   Cd * LAI ./ (Cd_bs);                                                % windspeed profile extinction coefficient (Su. 2002 Eq 7.)
In_ec               =   n_ec~=0;

d2h                 =   dummy;
d2h(~In_ec)         =   0;
d2h(In_ec)          =   1 - 1./(2*n_ec(In_ec)) .* (1 - exp(-2 * n_ec(In_ec)));              % Ratio of displacement height and canopy height (derived from Su 2002, eq 9)

%% Displacement height 
d0                  =   d2h .* hc;                                                          % displacement height

%% Roughness length for momentum
I_1                 =   (fc >  0);                                                          % classify pixels (lower limit roughness height)
z0m                 =   0.005*(1+dummy);                                                    % roughness height for bare soil
z0m(I_1)            =   hc(I_1).*(1 - d2h(I_1)) .* exp(-k * ust2u_h(I_1).^(-1));            % roughness height for vegetation (Eq 10 Su. 2001)
% z0m(I_1)            =   0.0002;                                                           % Fresh/Salt water 

%% KB-1 canopy only
I_1                 =   (n_ec ~= 0);                                                        % classify pixels (avoid devide by zero)
kB1_c               =   zeros(size(I_1));                                                   % KB-1 for Full canopy only lower limit
kB1_c(I_1)          =   k * Cd ./(4 * Ct .* ust2u_h(I_1) .* (1 - exp(-n_ec(I_1)/2)));       % KB-1 for Full canopy only (Choudhury and Monteith, 1988)

%% KB-1 mixed soil and canopy
Uref              	=   Uref10 .* (log((Zref-d0)./z0m)./log((Zref10-d0)./z0m));             % Estimate Windspeed at 2m reference height (assuming neutral conditions)

u_h                =    max(0,Uref.* log((hc-d0)./z0m)./log((Zref-d0)./z0m));               % (within canopy) Horizontal windspeed at the top of the canopy
ustar_m             =   ust2u_h .* u_h;                                                     % friction velocity 
% note that if Zref becomes smaller than d0, ustar becomes on-physical

I_1                 =   (Nu ~= 0);                                                          % classify pixels (mixed canopy and soil)
Re_m                =   zeros(size(I_1));                                                   % roughness Reynolds number lower limit
Re_m(I_1)           =   ustar_m(I_1) .* hc(I_1) ./ Nu(I_1);                                 % roughness Reynolds number for mixed canopy

Ct_m                =   Pr^(-2/3) * (Re_m.^(-1/2));                                         % heat transfer coefficient for soil
kB1_m               =   (k * ust2u_h) .* (z0m ./ hc) ./ Ct_m;                               % KB-1 for Mixed canopy (Choudhury and Monteith, 1988)

%% KB-1 soil only
d0_s                =   0.000;                                                              % displacement height for soil = 0
hs                  =   0.009;                                                              % momentum roughness parameter (0.009 ~ 0.024)(Su et al., 1997, IJRS, p.2105-2124.)
Ustar_s             =   Uref * k ./ log((Zref - d0_s)./ hs);                                % Friction velocity in case of soil only. (Brutsaert 2008, Eq 2.41 P43 )[m/2]

I_1                 =   (Nu ~= 0 );                                                         % classify pixels (avoid devide by zero)
Re_s                =   zeros(size(I_1));                                                   % roughness Reynolds number lower limit
Re_s(I_1)           =   Ustar_s(I_1).* hs ./ Nu(I_1);                                       % roughness Reynolds number, = hu*/v    

kB1_s               =   2.46 * (Re_s.^(1/4)) - log(7.4);                                    % KB-1 for Soil only (Brutsaert,1982)

% extra parameterization for bare soil and snow, according to Yang
% I_1                 =   fc==0;
% z0h(I_1)            =   SEBS_kb_1_yang(z0m(I_1),Zref(I_1),Uref(I_1),LST_K(I_1),Tref_K(I_1),qa_ref(I_1), Pref_Pa(I_1),P0_Pa(I_1),Ps_Pa(I_1));
% kB1_s(I_1)          =   log(z0m(I_1) ./ z0h(I_1));

%% KB-1 All
kB_1                =   (fc.^2)      .* kB1_c    +...                                       % canopy only (avoid devide by zero)
                        2*(fc.*fs)   .* kB1_m    +...                                       % mixed canopy and soil 
                        (fs.^ 2)     .* kB1_s;                                              % soil only 
                    
                    
%% roughness length for Heat
z0h                 =   z0m ./ exp(kB_1);                                                   %roughness height for heat (su 2002 eq 8)


return
