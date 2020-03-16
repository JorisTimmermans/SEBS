function [z0h]=  SEBS_kb_1_yang(z0m,Zref,Uref,LST_K,Tref_K,qa_ref,Pref,P0,Ps)
%use yang's model (2002,QJRMS)
global k
global T0
Zref_m          =   Zref;
Zref_h          =   Zref;


%%  calculate parameters
Theta_a         =   Tref_K .*((P0./Pref ).^0.286);                                  % potential Air temperature [K]
Theta_s         =   LST_K  .*((P0./Ps   ).^0.286);                                  % potential surface temperature [K]

c_u             =   k./log(Zref_m./z0m);
c_pt            =   k./log(Zref_h./z0m);
Thetastar       =   c_pt.*(Theta_a - Theta_s);
ustar           =   c_u .* Uref; 

Nu              =   1.328e-5 * (P0./Pref)   .* (Theta_a/T0).^1.754;                 % viscosity of air                                                                                


%% iteration over z0h
for i = 1:3      
    
    [z0h]       =   z0mz0h(Zref_h,Nu,ustar,Thetastar);
    
%   [C_D,C_H]   =   flxpar(Zref_m,Zref_h,z0m,z0h,Uref,Theta_s,Theta_a);
    [L]         =   SEBS_kb_1_yang_MOlength(Zref_m,Zref_h,z0m,z0h,Uref,Theta_s,Theta_a);
        
     
    [C_D,C_H]   =   SEBS_kb_1_yang_bulktransfercoefficients(L,z0m,z0h,Zref_m,Zref_h);
    
    ustar       =   sqrt(C_D.*Uref);                                                                 % eq 16a, p1651 update ustar  
    Thetastar   =   C_H.*(Theta_a-Theta_s)./sqrt(C_D);                                                % eq 16b, p1651 update Thetastar 
    
end

%%
function [z0h]=z0mz0h(Zref,Nu,ustar,Thetastar)
% Developed by River and Environmental Engineering Laboratory, University of Tokyo
%   input
%       Zref      ! reference level of air temperature (m)
%       z0m       ! aerodynamic roughness length
%       ustar     ! friction velocity
%       Thetastar ! friction temperature (=-H/(rhoair*cp*ustar))
%       Nu        ! kinematic viscousity 
% 
% real z0h	   ! roughness length for heat
%
% 2002, Zref_hang et al, Improvement of surface Flux parametrizations with a turbulence-related length

%%

beta        =   7.2;                                                                          %calibration coefficient [m^-1/2 s^1/2 K^1/4]
z0h         =   70 * Nu ./ ustar .* exp(-beta*ustar.^(0.5).*abs(-Thetastar).^(0.25) );             %eq 17, p2081.
z0h         =   min(Zref/10,max(z0h,1.0E-10));





