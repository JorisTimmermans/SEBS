Constants
Parameters

LAI                         =   2.0;
fc                          =   0.8;
hc                          =   3.0;
Albedo                      =   0.2;
Emissivity                  =   0.95;
LST_K                       =   295;
Zref                        =   2;
Zref10                      =   10;
Hpbl                        =   1000;
Tref_K                      =   300;
qaref                       =   6.06; %g/kg
Pref_Pa                     =   1000;
Ps_Pa                       =   1000;
P0_Pa                       =   1000;
Uref10                      =   2;
SWd                         =   800;
LWd                         =   400;
SWd24                       =   6400;
day_angle                   =   30;
lat_rad                     =   52*pi/180;
Ta_av_K                     =   295;
Ns                          =   8;
                                 
[Edaily,E0daily, Rndaily]   =   SEBS(LAI,fc, hc, Albedo, Emissivity, LST_K,                    	...
                                     Zref, Zref10, Hpbl,                                        ...
                                     Tref_K,qaref, Pref_Pa,Ps_Pa,P0_Pa, Uref10,                 ...
                                     SWd,  LWd, SWd24,                                          ...
                                     day_angle, lat_rad, Ta_av_K,Ns);
