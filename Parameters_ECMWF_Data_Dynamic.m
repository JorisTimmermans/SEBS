function VarECMWF = Parameters_ECMWF_Data_Dynamic(resampling)
varid                           =   0;

%% Surface Meteorological Variables 
varid                           =   varid +1;
VarECMWF(varid).ID              =    '151.128';
VarECMWF(varid).Description     =   'Mean sea level pressure';
VarECMWF(varid).shortname       =   'msl';
VarECMWF(varid).filestr         =   'P0.grib';
VarECMWF(varid).Units           =   'Pa';
VarECMWF(varid).name            =   'P0';
VarECMWF(varid).Varname        	=   'P0';
VarECMWF(varid).resampling      = resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '134.128';
VarECMWF(varid).Description     =   'Surface pressure';
VarECMWF(varid).shortname       =   'sp';
VarECMWF(varid).filestr         =   'Ps.grib';
VarECMWF(varid).Units           =   'Pa';
VarECMWF(varid).name            =   'Ps';
VarECMWF(varid).Varname        	=   'Ps';
VarECMWF(varid).resampling      = resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '159.128';
VarECMWF(varid).shortname       =   'Description    =   Boundary layer height';
VarECMWF(varid).shortname       =   'blh';
VarECMWF(varid).filestr         =   'Habl.grib';
VarECMWF(varid).Units           =   'm';
VarECMWF(varid).name            =   'Habl';
VarECMWF(varid).Varname         =   'Habl';
VarECMWF(varid).resampling      = resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '165.128';
VarECMWF(varid).Description     =   '10 metre U wind component';
VarECMWF(varid).shortname       =   '10u';
VarECMWF(varid).filestr         =   'Wind_U.grib';
VarECMWF(varid).Units           =   'm s**-1';
VarECMWF(varid).name            =   'Wind_U';
VarECMWF(varid).Varname         =   'Wind_U';
VarECMWF(varid).resampling      =   resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '166.128';
VarECMWF(varid).Description     =   '10 metre V wind component';
VarECMWF(varid).shortname       =   '10v';
VarECMWF(varid).filestr         =   'Wind_V.grib';
VarECMWF(varid).Units           =   'm s**-1';
VarECMWF(varid).name            =   'Wind_V';
VarECMWF(varid).Varname         =   'Wind_V';
VarECMWF(varid).resampling      =   resampling;
% 
varid                           =   varid +1;
VarECMWF(varid).ID              =   '167.128';
VarECMWF(varid).Description     =   '2 metre temperature';
VarECMWF(varid).shortname       =   '2t';
VarECMWF(varid).filestr         =   'Ta.grib';
VarECMWF(varid).Units           =   'K';
VarECMWF(varid).name            =   'Ta';
VarECMWF(varid).Varname         =   'Ta';
VarECMWF(varid).resampling      =   resampling;

% 
varid                           =   varid +1;
VarECMWF(varid).ID              =   '167.128';
VarECMWF(varid).Description     =   'Daily 2 metre temperature';
VarECMWF(varid).shortname       =   '2t';
VarECMWF(varid).filestr         =   'Ta.grib';
VarECMWF(varid).Units           =   'K';
VarECMWF(varid).name            =   'Ta';
VarECMWF(varid).Varname         =   'Ta_24';
VarECMWF(varid).resampling      =   resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '168.128';
VarECMWF(varid).Description     =   '2 metre dewpoint temperature';
VarECMWF(varid).shortname       =   '2d';
VarECMWF(varid).filestr         =   'Tdew.grib';
VarECMWF(varid).Units           =   'K';
VarECMWF(varid).name            =   'Tdew';
VarECMWF(varid).Varname         =   'Tdew';
VarECMWF(varid).resampling      =   resampling;


% varid                         =   varid +1;
% VarECMWF(varid).ID            =   '182.128';
% VarECMWF(varid).Description   =   'Evaporation';
% VarECMWF(varid).shortname     =   'e';
% VarECMWF(varid).filestr       =   'E.grib';
% VarECMWF(varid).Units         =   'm';
% VarECMWF(varid).name          =   'E';
% VarECMWF(varid).Varname       =   'E';
% VarECMWF(varid).resampling    = resampling;

% varid                         =   varid +1;
% VarECMWF(varid).ID            =   '228.128';
% VarECMWF(varid).Description   =   'Total precipitation';
% VarECMWF(varid).shortname     =   'tp';
% VarECMWF(varid).filestr       =   'Pt.grib';
% VarECMWF(varid).Units         =   'm';
% VarECMWF(varid).name          =   'Pt';
% VarECMWF(varid).Varname      	=   'Pt';
% VarECMWF(varid).resampling    = resampling;

%% Radiation
varid                           =   varid +1;
VarECMWF(varid).ID              =   '169.128';
VarECMWF(varid).Description     =   'Surface solar radiation downwards';
VarECMWF(varid).shortname       =   'ssrd';
VarECMWF(varid).filestr         =   'Rin_s.grib';
VarECMWF(varid).Units           =   'J m**-2';
VarECMWF(varid).name            =   'Rin_s';
VarECMWF(varid).Varname         =   'Rin_s';
VarECMWF(varid).resampling      =   resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '169.128';
VarECMWF(varid).Description     =   'Daily Surface solar radiation downwards';
VarECMWF(varid).shortname       =   'ssrd';
VarECMWF(varid).filestr         =   'Rin_s.grib';
VarECMWF(varid).Units           =   'J m**-2';
VarECMWF(varid).name            =   'Rin_s';
VarECMWF(varid).Varname         =   'Rin24_s';
VarECMWF(varid).resampling      =   resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '175.128';
VarECMWF(varid).Description     =   'Surface thermal radiation downwards';
VarECMWF(varid).shortname       =   'strd';
VarECMWF(varid).filestr         =   'Rin_l.grib';
VarECMWF(varid).Units           =   'J m**-2';
VarECMWF(varid).name            =   'Rin_l';
VarECMWF(varid).Varname         =   'Rin_l';
VarECMWF(varid).resampling      = resampling;

varid                           =   varid +1;
VarECMWF(varid).ID              =   '189.128';
VarECMWF(varid).Description     =   'Sunshine duration';
VarECMWF(varid).shortname       =   'sund';
VarECMWF(varid).filestr         =   'Ns.grib';
VarECMWF(varid).Units           =   's';
VarECMWF(varid).name            =   'Ns';
VarECMWF(varid).Varname         =   'Ns';
VarECMWF(varid).resampling      = resampling;



%% Profile  Meteorological Variables 
% varid                           =   varid +1;
% VarECMWF(varid).ID              =   '129.128';
% VarECMWF(varid).Description     =   'Geopotential';
% VarECMWF(varid).shortname       =   'G';
% VarECMWF(varid).filestr         =   'Z_profile.grib';
% VarECMWF(varid).Units           =   'm';
% VarECMWF(varid).name            =   'Z_profile';
% VarECMWF(varid).Varname         =   'Z_profile';
% VarECMWF(varid).resampling      = resampling;
% VarECMWF(varid).profile         =   [750 775 800 825 850 875 900 925 950 1000];
% 
% varid                           =   varid +1;
% VarECMWF(varid).ID              =   '133.128';
% VarECMWF(varid).Description     =   'Specific Humidity';
% VarECMWF(varid).shortname       =   'qaref';
% VarECMWF(varid).filestr         =   'qa_profile.grib';
% VarECMWF(varid).Units           =   'kg/kg';
% VarECMWF(varid).name            =   'qa_profile';
% VarECMWF(varid).Varname         =   'qa_profile';
% VarECMWF(varid).resampling      =   resampling;
% VarECMWF(varid).profile         =   [750 775 800 825 850 875 900 925 950 1000];

% 
% varid                           =   varid +1;
% VarECMWF(varid).ID              =   '130.128';
% VarECMWF(varid).Description     =   'Temperature';
% VarECMWF(varid).shortname       =   'Tref';
% VarECMWF(varid).filestr         =   'Ta_profile.grib';
% VarECMWF(varid).Units           =   '[K]';
% VarECMWF(varid).name            =   'Ta_profile';
% VarECMWF(varid).Varname         =   'Ta_profile';
% VarECMWF(varid).resampling      = resampling;
% VarECMWF(varid).profile         =   [750 775 800 825 850 875 900 925 950 1000];
% 
% varid                           =   varid +1;
% VarECMWF(varid).ID              =   '131.128';
% VarECMWF(varid).Description     =   'Wind speed U component';
% VarECMWF(varid).shortname       =   'Uref';
% VarECMWF(varid).filestr         =   'Wind_U_profile.grib';
% VarECMWF(varid).Units           =   '[m/s]';
% VarECMWF(varid).name            =   'Wind_U_profile';
% VarECMWF(varid).Varname         =   'Wind_U_profile';
% VarECMWF(varid).resampling      =   resampling;
% VarECMWF(varid).profile         =   [750 775 800 825 850 875 900 925 950 1000];
% 
% varid                           =   varid +1;
% VarECMWF(varid).ID              =   '132.128';
% VarECMWF(varid).Description     =   'Wind speed V component';
% VarECMWF(varid).shortname       =   'Vref';
% VarECMWF(varid).filestr         =   'Wind_V_profile.grib';
% VarECMWF(varid).Units           =   '[m/s]';
% VarECMWF(varid).name            =   'Wind_V_profile';
% VarECMWF(varid).Varname         =   'Wind_V_profile';
% VarECMWF(varid).resampling      =   resampling;
% VarECMWF(varid).profile         =   [750 775 800 825 850 875 900 925 950 1000];
