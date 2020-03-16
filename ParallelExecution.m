function [output]=ParallelExecution(var,Static, Data, Time, Location, Tile,statici)

productnames                                    =   fieldnames(Data);        

%% Run Constants
Constants

%% Resample products
for iprod=1:length(productnames)
    productname                                 =   productnames{iprod};
    
    [datai.(productname)]                       =   ResampleProducts(var.(productname),Data.(productname),Static.(productname),  Location, Tile.(productname));
end
clear Data Static

%% preprocessing
[LAI,fc, hc, Albedo, Emissivity, LST_K,                    	...
Zref, Zref10, Hpbl,                                        ...
Tref_K,qaref, Pref_Pa,Ps_Pa,P0_Pa, Uref10,                 ...
SWd,  LWd, SWd24,                                          ...
day_angle, lat_rad, Ta_av_K,Ns,I]                       =   ParallelExecution_PreProcessing(statici, datai, Time);
clear datai statici

%% Run SEBS
[Edaily,E0daily, Rndaily]                               =   deal(zeros(size(LAI),'single')*NaN);
[Edaily(I),E0daily(I), Rndaily(I)]                   	=   SEBS(LAI(I),fc(I), hc(I), Albedo(I), Emissivity(I), LST_K(I),                    	...
                                                                 Zref(I), Zref10(I), Hpbl(I),                                        ...
                                                                 Tref_K(I),qaref(I), Pref_Pa(I),Ps_Pa(I),P0_Pa(I), Uref10(I),                 ...
                                                                 SWd(I),  LWd(I), SWd24(I),                                          ...
                                                                 day_angle, lat_rad(I), Ta_av_K(I),Ns(I));

%% Saving data to Output Variable
output.Edaily.Values                    =   Edaily;
output.E0daily.Values                   =   E0daily;
output.Rndaily.Values                	=   Rndaily;

    