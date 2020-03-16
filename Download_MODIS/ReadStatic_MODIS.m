function [StaticMODIS]                              =   ReadStatic_MODIS(VarMODIS,    Location)
global datadir
global deg2rad
global alpha flog
StaticMODIS                                        	=   [];

%% Latitude Longitude coordinate
yearstr                                             =   datestr(VarMODIS(1).acquisition.start/60/24,'yyyy');
monthstr                                            =   datestr(VarMODIS(1).acquisition.start/60/24,'mm');
subdirstr                                           =   'NDVI';
dirname                                             =   [datadir.MODIS, filesep, yearstr, filesep, subdirstr, filesep, monthstr, filesep];

Files                                               =   dir([dirname,'*.hdf']);
Nfiles              	                            =   size(Files,1);
MODIStiles                                          =   zeros(Nfiles,2);
for j=1:Nfiles
    MODIStiles(j,1)                                 =   str2double(Files(j).name(19:20));       %horizontal tile numbers
    MODIStiles(j,2)                                 =   str2double(Files(j).name(22:23));       %vertical   tile numbers
end
MODIStiles_u                                        =   unique(MODIStiles,'Rows');

% Bounding coordinates of MODIS Grid Tile
lat_min                	                            =   (00 - 10*(MODIStiles_u(:,2) - 08));                                           % correct
lat_max                                             =   (10 - 10*(MODIStiles_u(:,2) - 08));                                           % correct
lon_min                                             =   (00 + 10*(MODIStiles_u(:,1) - 18))./cos(lat_min*deg2rad);                     % correct
lon_max                                             =   (10 + 10*(MODIStiles_u(:,1) - 18))./cos(lat_max*deg2rad);                     % more or less

%Take an Area larger then the actual location to reduce interpolation errors at the boundaries. 
lat_start                                           =   Location.lat_start - Location.Tile.size*alpha.MODIS;
lat_end                                             =   Location.lat_end   + Location.Tile.size*alpha.MODIS;
lon_start                                           =   Location.lon_start - Location.Tile.size*alpha.MODIS;
lon_end                                             =   Location.lon_end   + Location.Tile.size*alpha.MODIS;

% Select Tiles that cover the Selected Area.
ilat                                                =   lat_max>= lat_start & lat_min<= lat_end;
ilon                                                =   lon_max>= lon_start & lon_min<= lon_end;
ilatlon                                             =   ilat & ilon;

lat_min_s                                           =   lat_min(ilatlon);
lat_max_s                                           =   lat_max(ilatlon);
lon_min_s                                           =   lon_min(ilatlon);
lon_max_s                                           =   lon_max(ilatlon);

ymin_s                                              =   lat_min_s;
ymax_s                                              =   lat_max_s;
xmin_s                                              =   lon_min_s.*cos(lat_min_s*deg2rad);
xmax_s                                              =   lon_max_s.*cos(lat_max_s*deg2rad);

Ntiles_s                                            =   sum(ilatlon);
Lat(1:Ntiles_s)                                     =   struct('Values',zeros(1200,1200,'single'));
Lon(1:Ntiles_s)                                     =   struct('Values',zeros(1200,1200,'single'));

for j=1:Ntiles_s
    x                                               =   linspace(xmin_s(j),xmax_s(j),1200);
    y                                               =   linspace(ymax_s(j),ymin_s(j),1200)';
    
    [X,Y]                                           =   meshgrid(x,y);    
    Lat(j).Values                                   =   (Y);
    Lon(j).Values                                   =   (X./cos(Y*deg2rad));
end

StaticMODIS.Ntiles                                  =   Ntiles_s;
StaticMODIS.Tilenrs                                 =   MODIStiles_u(ilatlon,:);
StaticMODIS.Lat.Values                              =   [Lat.Values];
StaticMODIS.Lon.Values                              =   [Lon.Values];
% keyboard
%% Static Data
% Istatic                                             =   find(isinf(res));
landcover_vars                                      =   {'Land_Cover_Type_1','Land_Cover_Type_2',...
                                                         'Land_Cover_Type_3','Land_Cover_Type_4',...
                                                         'Land_Cover_Type_5',....
                                                         'Land_Cover_Type_1_Assessment','Land_Cover_Type_2_Assessment',...
                                                         'Land_Cover_Type_3_Assessment','Land_Cover_Type_4_Assessment',...
                                                         'Land_Cover_Type_5_Assessment',...
                                                         'Land_Cover_Type_QC','Land_Cover_Type_1_Secondary','Land_Cover_Type_1_Secondary_Percent',...
                                                         'LC_Property_1','LC_Property_2','LC_Property_3'};
for ivar=1:size(VarMODIS,2)
    varname                                         =   VarMODIS(ivar).name;
	interval                                        =   VarMODIS(ivar).acquisition.resstr;
    yearstr                                      	=   datestr(VarMODIS(1).acquisition.start/60/24,'yyyy');
    monthstr                                        =   datestr(VarMODIS(1).acquisition.start/60/24,'mm');

    switch lower(interval)
        case {'static', 'time'}
            switch varname
                case landcover_vars
                    if VarMODIS(1).acquisition.start/60/24>=datenum('2010-01-00')
                        fprintf('NO landclassification after 2010, defaulting back to 2009')
                        yearstr                    	=   '2009';
                        monthstr                    =   '01';
                    end
                case 'LWM'
                    yearstr                         =   '2000';
                    monthstr                        =   '01';
                otherwise
                    keyboard
            end
            
            subdirstr                               =   VarMODIS(ivar).subdirstr;
            dirname                                 =   [datadir.MODIS,filesep,yearstr,filesep,subdirstr,filesep,monthstr,filesep];
%             file                                    =   dir([dirname,'*hdf']);
            
            filename                                =   [VarMODIS(ivar).productstr,'.A'];
            for ifiles=1:StaticMODIS.Ntiles
                filter{ifiles}                      =   sprintf('*h%02.0fv%02.0f*',StaticMODIS.Tilenrs(ifiles,:));
                file                                =   dir([dirname,filename,filter{ifiles},'.hdf']);                    
                files(ifiles).name                  =   file.name;
            end
            
            dataid                              	=   VarMODIS(ivar).Dataid;           
            for ifiles=1:StaticMODIS.Ntiles
                Units                             	=   '';
                information                       	=   {''};
                scaling                             =   [1];
                offset                              =   [0]; 
                missingid                           =   NaN;
                try
                information                         =   hdfinfo([dirname,files(ifiles).name]); 
                catch
                    keyboard
                end
                SDS                                 =   information.Vgroup.Vgroup(1).SDS(dataid);      % Science Data Set
                Raw                                 =   single(hdfread(SDS));
                
                Nattributes                         =   size(SDS.Attributes,2);
                for iatt=1:Nattributes
                    if strcmp(SDS.Attributes(iatt).Name ,'units')
                        Units                    	=   SDS.Attributes(strcmp({SDS.Attributes.Name},'units')).Value;
                    end
                    if strcmp(SDS.Attributes(iatt).Name ,'scale_factor')
                        scaling                     =   single(SDS.Attributes(iatt).Value);                        
                    end
                    if strcmp(SDS.Attributes(iatt).Name ,'add_offset')
                        offset                       =   single(SDS.Attributes(iatt).Value);                        
                    end
                    if strcmp(SDS.Attributes(iatt).Name ,'_FillValue')
                        missingid                   =   single(SDS.Attributes(iatt).Value);                        
                    end
                end
                Raw(Raw==missingid)                 =   NaN;
                
%                 varname
%                 switch varname
%                     case 'LWM'
%                         % convert 4800x4800->1200x1200
%                         Raw                        	=   Raw(:,1:4:end)&Raw(:,2:4:end)&Raw(:,3:4:end)&Raw(:,4:4:end);
%                         Raw                         =   Raw(1:4:end,:)&Raw(2:4:end,:)&Raw(3:4:end,:)&Raw(4:4:end,:);
%                     case 'Land_Cover_Type_1'                        
%                 end
                
                Variable(ifiles).Values             =   single( Raw * scaling + offset);
                Variable(ifiles).nr_x              	= 	size((Variable(ifiles).Values),1);
                Variable(ifiles).nr_y               =   size((Variable(ifiles).Values),2);
            end
            
            StaticMODIS.(varname).info              =   information;
            
            StaticMODIS.(varname).Values            =   single([Variable.Values]);
            StaticMODIS.(varname).Units             =   Units;
            StaticMODIS.(varname).missing_id        =   NaN;
    end    
end

if isfield(StaticMODIS,'Land_Cover_Type_1')
StaticMODIS.Land_Cover_Type_1.Values(StaticMODIS.Land_Cover_Type_1.Values==254)=17;
A11                                     =   StaticMODIS.Land_Cover_Type_1.Values(1:2:end,1:2:end);
A12                                     =   StaticMODIS.Land_Cover_Type_1.Values(2:2:end,1:2:end);
A21                                     =   StaticMODIS.Land_Cover_Type_1.Values(1:2:end,2:2:end);
A22                                     =   StaticMODIS.Land_Cover_Type_1.Values(2:2:end,2:2:end);
bin                                     =  	0:17; 

Astacked                                =   cat(3,A11,A12,A21,A22);
[N]                                     =   histc(Astacked,bin,3);
% N                                       =   N/9*100;
                    
%Select class (of subpixel) that is most occuring in large pixel
[Nmax,I]                               	=   max(N,[],3);
StaticMODIS.Land_Cover_Type_1.Values    =   bin(I);    
StaticMODIS.Land_Cover_Type_1.Values(StaticMODIS.Land_Cover_Type_1.Values==17)=254;
end