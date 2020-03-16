function [L]=SEBS_kb_1_yang_MOlength(Zref_m,Zref_h,z0m,z0h,Uref,Theta_s,Theta_a)
% Monin Obuhkov length
% Computes L for both unstable and stable surface layer based on Monin-Obukhov similarity theory. 
% The univeral profile form was proposed Hogstrom (1996) and the anlytical solution was 
% developed by Yang (2001)

% REFERENCE: Similarity analytical solution:Yang, K., Tamai, N. and Koike, T., 2001: Analytical Solution of Surface Layer Similarity Equations, J. Appl. Meteorol. 40, 
% 1647-1653. Profile form: Hogstrom (1996,Boundary-Layer Meteorol.)
global g
global Pr_u Pr_s
% Allocate Memory
zeta                     =   zeros(size(Uref))*NaN;

%% Parameters
gammam                  =   19.0;                                                                         	%Stability function coefficient
gammah                  =   11.6;                                                                           %Stability function coefficient;

betam                   =   5.3;                                                                            %Stability function coefficient
betah                   =   8.0;                                                                            %Stability function coefficient    

Ri                      =   g.*(Zref_m-z0m)./(Uref.*2).*(Theta_a-Theta_s)./Theta_a;                        	% Bulk Richardson number eq 3, p1649 (T0 is replace by Theta_a)
I_u                     =   Ri<0.0;

log_z_z0m            	=   log(Zref_m./z0m);
log_z_z0h            	=   log(Zref_h./z0h);


%% Calcualtions
% Unstable case: calculated by an aproximate analytical solution proposed by Yang (2001,JAM)

Ri_u                    =   Ri( I_u);
Ri_u                    =   max(Ri_u,-10.0);

numerator               =   (Ri_u/Pr_u).*(log_z_z0m( I_u).^2  ./ log_z_z0h( I_u) ) .* (Zref_m( I_u)             ./(Zref_m( I_u)-z0m( I_u)));           %Part of eq 13 

p                       =   P( Ri_u/Pr_u, log_z_z0m( I_u) , log_z_z0h( I_u) );                                      %
denominator             =   1- ((Ri_u/Pr_u) * gammam^2./(8 *gammah) .* (Zref_m( I_u)-z0m( I_u))./ (Zref_h( I_u)-z0h( I_u))).*p;
zeta( I_u)              =   numerator./denominator;                                                                 % eq 13, p1650

%    Stable case: calculated by the exact analytical solution proposed by Yang (2001,JAM)%
% Ri_s                    =   min(Ri(~I_u), min(0.2,Pr_s*betah*(1-z0h(~I_u)/Zref_h)/betam^2./(1-z0m(~I_u)/Zref_m)-0.05));
Ri_s1                   =   Ri(~I_u);
Ri_s2                   =   min(0.2, Pr_s*betah*(1-z0h(~I_u)./Zref_h(~I_u)) / betam^2 ./(1-z0m(~I_u)./Zref_m(~I_u)) - 0.05);
Ri_s                    =   min(Ri_s1,Ri_s2);

a                       =   (Ri_s/Pr_s) * betam^2.* (1-z0m(~I_u)./Zref_m(~I_u)).^2  - betah*(1-z0m(~I_u)./Zref_m(~I_u)).*(1-z0h(~I_u)./Zref_h(~I_u)); 	% eq 9a, p1649
b                       =   (2*(Ri_s/Pr_s) * betam .* log_z_z0m(~I_u)  - log_z_z0h(~I_u)) .* (1-z0m(~I_u)./Zref_m(~I_u));        % eq 9b, p1649 
c                       =   (Ri_s/Pr_s) .* log_z_z0m(~I_u).^2 ;                                                       % eq 9c, p1649 
zeta(~I_u)             	=   (-b - sqrt(b.^2-4*a.*c)) ./ (2*a);                                                      % eq 8, p1649 

%% Monin Obukhov length
zeta(zeta==0)           =   1e-6;
L                    	=   Zref_m./zeta;                                                                               % p1648.
%    

function p = P(alpha, beta, gamma)
p                       =   0.03728                                                         - ...
                            0.093143*log(-alpha)            +   0.017131*log(-alpha).^2     - ...
                            0.240690*log(beta)              -   0.084598*log(beta).^2       + ...
                            0.306160*log(gamma)             -   0.125870*log(gamma).^2      + ...
                            0.037666*log(-alpha).*log(beta) -   0.016498*log(-alpha).*log(gamma)   + 0.1828*log(beta).*log(gamma) ;
p                       =   max(0.0,p) ;        