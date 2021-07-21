%% Start to prepare data and other information to place into NWB structure

registration_mod = types.core.ProcessingModule( ...
    'description',  'contains values after registration') % create registration module for experiment through ProcessingModule template

xpixel_by_ypixel = strcat(num2str(NpixelsX), ',', num2str(NpixelsY));

% Loading the reg_tifs into cell array
reg_tif_list = dir(fullfile(path_to_regtif, '*.tif'));...
    dir(fullfile(path_to_regtif, '*.tiff'));

if isempty(reg_tif_list) == 1
    fprintf('\nreg tif not found in path_to_regtif directory\n %s');
    return
end
       
reg_tif_names = [];
ii = 1;
for ii=1:length(reg_tif_list)
    reg_tif_names{ii} = reg_tif_list(ii).name;
end 
reg_tif_names = natsort(reg_tif_names);

% this is inserting the actual tif files into the cell array
reg_tifs = [];
i = 1;
fprintf('\nLoading Reg Tifs... \n %s');
for i=1:length(reg_tif_names)
    reg_tifs{i} = loadtiff(fullfile(path_to_regtif, reg_tif_names{i}));
end 

% concatenate all of them and get other information
reg_tifs_final = [];
ii = 1;
fprintf('\nConcatenating Reg Tifs... %s');
for ii = 1:length(reg_tifs)
    reg_tifs_final = cat(3, reg_tifs_final, reg_tifs{ii});
end

rate_per_tif = (Nframes / (length(reg_tif_list))) / framerate;
timestamps_for_reg_tifs = []; 
for i=1:length(reg_tif_list)
    timestamps_for_reg_tifs(i) = rate_per_tif * i;
end 

%% start constructing relevant NWB structures and putting data into them
% corrected ImageSeries containing the registration tifs
corrected = types.core.ImageSeries(...
        'format', 'tif',...
        'external_file_starting_frame', '0',...
        'dimension', xpixel_by_ypixel,... % number of pixels on x and y axis for each frame
        'data', reg_tifs_final,...
        'comments', 'this is the corrected registration tifs outputted from suite2p',...
        'starting_time', 0.0,...
        'starting_time_rate', rate_per_tif,...
        'timestamps', timestamps_for_reg_tifs,...
        'data_unit', 'tif_number')
% original ImageSeries containing the original raw tifs 
original = types.core.ImageSeries(...
    'format', 'tif',...
    'external_file_starting_frame', '0',...
    'dimension', xpixel_by_ypixel,...
    'data', concat_raw_tifs,...
    'starting_time', 0.0, ...
    'starting_time_rate', 0.0, ...
    'data_unit', 'tif_number')

load(fullfile(path_to_suite2pfolder_contents, 'Fall.mat'));
load('Fall.mat', 'ops');

Xoff = ops.xoff;
Yoff = ops.yoff;
xyoffset_values = vertcat(Xoff, Yoff)';   % horizontally concat the
                                          % x and y offsets for 2x24000
                                          % structure
                                          
% I just put everything in-terms of seconds
xy_translation = types.core.TimeSeries(...
    'starting_time_unit', 'seconds',...
    'timestamps_interval', rate_per_tif,... % I put all of the x and y pixel offset information in here 
    'timestamps_unit', 'seconds',...
    'data', xyoffset_values,...
    'data_unit', 'pixel')

% the original, corrected, and xy_translation classes (from above) are placed into the
% CorrectedImageStack class
CorrectedImageStack = types.core.CorrectedImageStack(...
    'corrected', corrected,...
    'original', original,...
    'xy_translation', xy_translation) % for this last input , need to put the x-y offset values from Suite2p output

%% Place the CorrectedImageStack Class into into registration module under nwbdatainterface. Finally, place the entire module under processing within NWB

registration_data = types.core.ProcessingModule(...
    'description', 'contains the registration tif data')

registration_data.nwbdatainterface.set(...
    'CorrectedStack', CorrectedImageStack)
    
nwb.processing.set('corrected_tifs', registration_data)

%% try reading the loaded data within CorrectedImageStack 
nwbExport(nwb, fullfile(nwb_path, 'demo_test.nwb')); % export the NWB file in the directory in previous line
