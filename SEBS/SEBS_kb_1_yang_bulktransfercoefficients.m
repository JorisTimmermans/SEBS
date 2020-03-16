function [C_D,C_H]=SEBS_kb_1_yang_bulktransfercoefficients(L,z0m,z0h,Zref_m,Zref_h)
% Note: 
%  PURPOSE:
%     Compute C_u and C_pt for both unstable and stable surface layer based on Monin-Obukhov similarity theory. The univeral profile form 
%     was proposed Hogstrom (1996) and the analytical solution was developed by Yang (2000)1
%     C_D:  Bulk Transfer Coefficient of momentum
%     C_H:  Bulk Transfer Coefficient of heat

global k 
global Pr_u Pr_s


z0m                 =   z0m.*ones(size(L));
z0h                 =   z0h.*ones(size(L));
Zref_m              =   Zref_m.*ones(size(L));
Zref_h              =   Zref_h.*ones(size(L));

[C_D,C_H]           =   deal(zeros(size(L)));
%%
[psim]              =   Psim(Zref_m,z0m,L);
[psih]              =   Psih(z0h,Zref_h,L);

log_z_z0m           =   log(Zref_m./z0m);
log_z_z0h           =   log(Zref_h./z0h);

I_u                 =   L<0.0;
%Unstable case
uprf( I_u)          =   max(log_z_z0m( I_u) - psim(I_u) , 0.50*log_z_z0m (I_u) );
ptprf( I_u)        	=   max(log_z_z0h( I_u) - psih(I_u) , 0.33*log_z_z0h( I_u) ); 

%Stable case
uprf(~I_u)      	=   min(log_z_z0m(~I_u) -psim(~I_u) , 2.00*log_z_z0m(~I_u) );
ptprf(~I_u)         =   min(log_z_z0h(~I_u) -psih(~I_u) , 2.00*log_z_z0h(~I_u) );

%
C_D( I_u)       	=   k.^2        ./( uprf( I_u).^2           );                                          % eq 160a p, 1651
C_D(~I_u)       	=   k.^2        ./( uprf(~I_u).^2           );                                       	% eq 160a p, 1651

C_H( I_u)           =   k.^2./Pr_u ./ ( uprf( I_u).*ptprf( I_u) );                                          % eq 160b p, 1651
C_H(~I_u)           =   k.^2./Pr_s ./ ( uprf(~I_u).*ptprf(~I_u) );                                          % eq 160b p, 1651

% keyboard
%%
% subplot(2,2,1);colormap('default');c=colormap;c(1,:)=1;colormap(c),imagesc(log_z_z0m,[min(log_z_z0m(:))-1 max(log_z_z0m(:))]), title('log z/z0m')   ,axis equal tight,colorbar
% subplot(2,2,2);colormap('default');c=colormap;c(1,:)=1;colormap(c),imagesc(log_z_z0h,[min(log_z_z0m(:))-1 max(log_z_z0m(:))]), title('log z/z0h')     ,axis equal tight,colorbar
% subplot(2,2,3);colormap('default');c=colormap;c(1,:)=1;colormap(c),imagesc(psim,[min(psim(:))-1 max(psim(:))]), title('psim')   ,axis equal tight,colorbar
% subplot(2,2,4);colormap('default');c=colormap;c(1,:)=1;colormap(c),imagesc(psim,[min(psih(:))-1 max(psih(:))]), title('psih')     ,axis equal tight,colorbar

function [psim]=Psim(Zref_m, z0m,L)
psim                =   zeros(size(Zref_m));
betam               =   5.3;
gammam              =   19.0;

I_u                 =   L<0.0;
    
%unstable
xx2                 =   ( 1-gammam* Zref_m( I_u)./L( I_u) ).^(1/4);                                            %sqrt(sqrt( 1-gammam* Zref_m( I_u)./L( I_u) ));   
xx1                 =   ( 1-gammam* z0m( I_u)./L( I_u) ).^(1/4);                                            %sqrt(sqrt( 1-gammam* z0m( I_u)./L( I_u) ));
psim( I_u)          =   2 * log((1+xx2)./(1+xx1))+ log((1+xx2.*xx2)./(1+xx1.*xx1))- 2*atan(xx2) + 2 * atan(xx1);

%stable
psim(~I_u)          =   -betam * (Zref_m(~I_u) - z0m(~I_u))./L(~I_u);    
psim(~I_u)         	=   max( -betam, psim(~I_u));   
    
function [psih]=Psih(z0h,Zref_h,L)
psih                =   zeros(size(Zref_h));
betah               =   8.0;
gammah              =   11.6;
I_u                 =   L<0.0;
    
% Unstable
yy2                 =   sqrt(1-gammah* Zref_h( I_u)./L( I_u));  
yy1                 =   sqrt(1-gammah* z0h( I_u)./L( I_u));
psih( I_u)      	=   2 * log((1+yy2)./(1+yy1)); 

%stable
psih(~I_u)         	=   -betah * (Zref_h(~I_u) - z0h(~I_u))./L(~I_u);
psih(~I_u)          =   max( -betah, psih(~I_u));