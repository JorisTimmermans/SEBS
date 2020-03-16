function [StaticECMWF,Sub]   =   Read_ECMWF_Data_Static(VarECMWF,Location )
global datadir flog
% path(path,[cd,'/read_grib'])
fprintf(flog,'[INFO   ] ReadStatic_ECMWF: Loading ECMWF data from %s \n',datadir.ECMWF);

%% Extract Coordinates
filename                            =   VarECMWF(1).filestr;
% is a bit slow because the whole file needs to be read! 
raw                                 =   read_grib([datadir.ECMWF,filename],-1,'Paramtable','ECMWF128','ScreenDiag',0,'DataFlag',0);   

StaticECMWF.nr_pix_x                =   raw(1).gds.Ni;
StaticECMWF.nr_pix_y                =   raw(1).gds.Nj;

maxlat                              =   raw(1).gds.La1;
minlon                              =   raw(1).gds.Lo1;

minlat                              =   raw(1).gds.La2;
maxlon                              =   raw(1).gds.Lo2;

StaticECMWF.lat.Values              =   linspace(maxlat,minlat,StaticECMWF.nr_pix_y);
StaticECMWF.lon.Values              =   linspace(minlon,maxlon,StaticECMWF.nr_pix_x);

[LatValues, LonValues]               =   meshgrid(StaticECMWF.lat.Values, StaticECMWF.lon.Values);

%% Subsetting
LatValues                           =   permute(LatValues,[2 1 3 4]);
LonValues                           =   permute(LonValues,[2 1 3 4]);

LatValues2                          =   [LatValues     , LatValues];                            %creation of circular boundary
LonValues2                          =   [LonValues-360 , LonValues];                            %creation of circular boundary

ilon                                =   any(LatValues2>=Location.minlat & LatValues2<=Location.maxlat,2);
ilat                                =   any(LonValues2>=Location.minlon & LonValues2<=Location.maxlon,1);

% keyboard
LatValues                           =   LatValues2(ilon,ilat);
LonValues                           =   LonValues2(ilon,ilat);

%% Write to Variable
StaticECMWF.Lat.Values              =	LatValues; 
StaticECMWF.Lon.Values              =   LonValues; 
StaticECMWF.resampling            	=   VarECMWF(1).resampling;

Sub.ilat                            =   ilat;
Sub.ilon                            =   ilon;
%% Old

% fprintf(flog,'[INFO   ] ReadStatic_ECMWF: Loading ECMWF data from %s \n',datadir.ECMWF);
% 
% for ivar=1:size(VarECMWF,2)    
%     interval                                        =   VarECMWF(ivar).acquisition.resstr;
%     varname                                         =   VarECMWF(ivar).name;
%     filestr                                         =   ['*',VarECMWF(ivar).filestr];
%     StaticECMWF.(varname).resampling                =   VarECMWF(ivar).resampling;
%     %subdir                                         =  VarECMWF(ivar).subdirstr;
%     
%     timestart                                       =   VarECMWF(ivar).acquisition.start/24/60;
%     yearstr                                         =   datestr(timestart,'yyyy');
%     switch lower(interval)
%         case {'static','time'}            
%             dirname                                =    [datadir.ECMWF,filesep,yearstr,'/'];
%             file                                   =    dir([dirname,filesep,filestr]); %dir([dirname,filesep,'*.nc']);
% 
%         	if (isempty(file))
%             	continue
%            	end
% 
%             ncid                                    =   netcdf.open([dirname,filesep,file(1).name],'NOWRITE');
% 
%             % Open NETcdf         
%             [info.ndims     ,...
%             info.nvars     ,...
%             info.ngatts    ,...
%             info.unlimdimid]                       =   netcdf.inq(ncid);         % information
% 
%             info.Conventions                        =   netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions');
%             info.History                            =   netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history');    
%             Raw                                     =   netcdf.getVar(ncid,VarECMWF(ivar).acquisition.varid,'single');
%             StaticECMWF.(varname).info              =   info;
% 
%             %             StaticECMWF.(varname).Raw               =   Raw;  % to save memory
%             StaticECMWF.(varname).Values            =   single(Raw);
%             StaticECMWF.(varname).Units             =   netcdf.getAtt(ncid,VarECMWF(ivar).acquisition.varid,'units');                      % units
%             StaticECMWF.(varname).Long_name         =   netcdf.getAtt(ncid,VarECMWF(ivar).acquisition.varid,'long_name');                  % units            
%         case 'Otherwise'
%             % see ReadDynamic_ECMWF
%     end
% end
% 
% 
% StaticECMWF.lat.Values                              =   StaticECMWF.Lat.Values;
% StaticECMWF.lon.Values                              =   StaticECMWF.Lon.Values;
% 
% [LatValues,LonValues]                               =   meshgrid(StaticECMWF.lat.Values,StaticECMWF.lon.Values);
% StaticECMWF.Lat.Values                              =   [LatValues     ; LatValues];                            %creation of circular boundary
% StaticECMWF.Lon.Values                              =   [LonValues-360 ; LonValues];                            %creation of circular boundary
%     
% StaticECMWF.nr_pix_x                                =   size(StaticECMWF.lon.Values,1);
% StaticECMWF.nr_pix_y                                =   size(StaticECMWF.lat.Values,1);
% 
% StaticECMWF.P.Values                                =   StaticECMWF.P_profile.Values*100;                      %convert from millibar -> Pa
% StaticECMWF.P.Units                                 =   'Pa';
% 
% %correction for time difference (ECMWF uses a numerical time marker that starts at 1900-01-01.)
% StaticECMWF.Time.correction                         =   datenum('1900-01-01 00:00');
% StaticECMWF.Time.string                             =   datestr(double(StaticECMWF.Time.Values/24+StaticECMWF.Time.correction));




%% Time
% for ivar=1:size(VarECMWF,2)
%     filename                            =   VarECMWF(ivar).filestr;
%     varname                            	=   VarECMWF(ivar).name;
%     % is a bit slow because the whole file needs to be read! 
%     raw                                 =   read_grib([datadir.ECMWF,filename],-1,'Paramtable','ECMWF128','ScreenDiag',0,'DataFlag',0);   
%     
% 
%     %% sortout time stamps
%     [Irec,Year,Month,Day,Hour,Min,Secon,P1,P2] = deal(zeros(length(raw),1));
%     for idate=1:length(raw)
%         Irec(idate)                     =   idate;
%         Year(idate)                     =   raw(idate).pds.year;
%         Month(idate)                    =   raw(idate).pds.month;
%         Day(idate)                      =   raw(idate).pds.day;
%         Hour(idate)                     =   raw(idate).pds.hour;
%         Min(idate)                      =   raw(idate).pds.min;
%         Secon(idate)                    =   0;
%         P1(idate)                       =   raw(idate).pds.P1;
%         P2(idate)                       =   raw(idate).pds.P2;
%     end
%     time_                               =   datenum(Year,Month,Day,Hour+P1,Min,Secon);
% 
%     %% Seperate between Analaysis and Forecast data
%     Ianalysis                           =   find(~P1);
%     Iforecast                           =   find(P1);
%     time_analaysis                      =   time_(Ianalysis);
%     time_forecast                       =   time_(Iforecast);
%     Irec_analysis                       =   Irec(Ianalysis);
%     Irec_forecast                       =   Irec(Iforecast);
% 
%     %% Replace Forecast record-id for Analaysis record-id for @00:00 and 12:00 hours
%     [~,ia,ib]                           =   intersect(time_analaysis,time_forecast);
%     Irec_final                          =   Irec_forecast;
%     Irec_final(ib)                      =   Irec_analysis(ia);
% 
%     StaticECMWF.(varname).Time.Values  	=   time_forecast;
%     StaticECMWF.(varname).Time.Irec     =   Irec_final;
% 
%     %%
%     StaticECMWF.(varname).resampling   	=   VarECMWF(ivar).resampling;    
% end