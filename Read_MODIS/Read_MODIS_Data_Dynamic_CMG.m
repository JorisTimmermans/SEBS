function [DataMODIS_CMG]   =   Read_MODIS_Data_Dynamic_CMG(VarMODIS,Sub,Location, startdate)
global datadir 

%% Read Data 
fprintf(1,'Reading MODIS (CMG) Static Data\n');
clear ierror

for j=1:length(VarMODIS)        
    IdSDS                                                       =   VarMODIS(j).IdSDS;
    varname                                                    	=   VarMODIS(j).Varname;
    
    subdir                                                      =   VarMODIS(j).name;

    %% Find observations (up to 1day/8day/16day time delay)
    file                                                        =   [];
    timestep                                                    =   0;
    sampling                                                 	=   VarMODIS(j).Frequency;
    while isempty(file) && (timestep<=sampling)
        timestep                                                =   timestep +1; 
        [yyyy,~,~,~,~,~]                                        =   datevec(startdate);
        doy                                                     =   startdate - datenum(yyyy,01,00) - (timestep-1);
        timestr                                                 =   sprintf('%04.0f%03.0f',yyyy,doy);    

        filestr                                                	=   [VarMODIS(j).Productnames,'*',timestr,'*.hdf'];
        file                                                    =	dir([datadir.MODIS,subdir,'/',filestr]);
    end

    %% Read Data and Attributes
     info                                                       =  	hdfinfo([datadir.MODIS,subdir,'/',file.name]);                        
    SDS                                                         =   info.Vgroup.Vgroup(1).SDS(IdSDS);
    Attributes                                                  =   SDS.Attributes;

    %Read Data
    Raw                                                         =   hdfread(SDS);

    % retrieve Attributes
    scaling= 1; offset=0; fill =NaN;
    for iatt=1:length(Attributes), 
        switch Attributes(iatt).Name 
            case 'add_offset'
                offset                                      	=   Attributes(iatt).Value;
            case '_FillValue'
                fill                                            =   Attributes(iatt).Value;
            case 'scale_factor'
                scaling                                         =   Attributes(iatt).Value;
        end
    end

    switch varname
        case {'LST','time','theta_v'}
            Values                                              =   single(Raw).*scaling;
            Values(Raw==fill)                                   =   NaN;
        case {'NDVI'}
            Values                                              =   single(Raw)./scaling + offset;
            Values(Raw==fill)                                   =   NaN;
        case {'BSA','WSA','Emissivity_29','Emissivity_31', 'Emissivity_32'}
            Values                                              =   single(Raw).*scaling + offset;
            Values(Raw==fill)                                   =   NaN;
        otherwise
            keyboard
    end
    DataMODIS_CMG.(varname).Values                              =   Values;


    %% Subsetting
    DataMODIS_CMG.(varname).Values                              =   DataMODIS_CMG.(varname).Values(Sub.ilon,Sub.ilat);

    %% Resampling
    DataMODIS_CMG.(varname).resampling                        	=   VarMODIS(j).resampling;
    DataMODIS_CMG.resampling                                    =   VarMODIS(j).resampling;
        
end

%% PostProcessing
fprintf(1,'Post Processing MODIS (CMG) Data \n');

%%