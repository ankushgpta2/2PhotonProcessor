function run_registration_4_swarm(expdir_array, path_to_python_suite2p_folder)
%% RUN REGISTRATION 
% either open Suite2p for registration or run it from MATLAB
% batch processing option possible on MouseLand 

%% prep arrays 
names_of_raw_tiffs = expdir_array;
ext_of_raw_tiffs = expdir_array;
num_of_tiffs_array = [];
tau_array = [];
fs_array = []; % framerate
nchannels_array = [];
nplanes_array = [];
path_to_raw_tiffs_array = expdir_array;
num_of_experiments = length(expdir_array);

%% place information for each experiment
for z = 1:length(expdir_array)
    expdir = char(string(expdir_array(z)));
    path_to_raw_tiffs = fullfile(expdir, 'raw_data/tiffs');
    path_to_raw_tiffs_array(z) = cellstr(path_to_raw_tiffs); % just so it is the same size as num of experiments...
    num_of_tiffs_array(z) = length(dir(fullfile(path_to_raw_tiffs, '*.tiff')));
    
    load(fullfile(expdir, 'rec_params.mat'));
    tau_array(z) = tau;
    fs_array(z) = framerate; % framerate
    nchannels_array(z) = Nchannels;
    nplanes_array(z) = Nplanes;
    
    check_raw = dir(fullfile(expdir, 'raw_data', '*.raw'));
    check_tiff = dir(fullfile(expdir, 'raw_data', '*.tif'));
    if isempty(check_raw) == 0
        names_of_raw_tiffs(z) = cellstr(check_raw.name);
        ext_of_raw_tiffs(z) = cellstr('.raw');
    else
        try
            names_of_raw_tiffs(z) = cellstr(check_tiff.name);
            ext_of_raw_tiffs(z) = cellstr('.tif');
        catch 
            fprintf('\n.Raw or .Tif Original File Cannot Be Found\n');
            return
        end
    end
end

% run the swarm script for generating swarmfile and running swarm
cd(path_to_python_suite2p_folder);
try
    run_swarm_4_reg(expdir_array, tau_array, fs_array, nchannels_array, nplanes_array,...
        path_to_raw_tiffs_array, num_of_experiments, num_of_tiffs_array, names_of_raw_tiffs,...
        ext_of_raw_tiffs, path_to_python_suite2p_folder);
catch
    try 
        !bash activate_suite2p
        fprintf('\nOpening Up Suite2p\n');
    catch
        fprintf('\nPease Open Up Suite2p\n');
    end
end

% move suite2p folder outside of the tiffs folder
for z = 1:length(expdir_array)
    expdir = char(string(expdir_array(z)));
    try
        movefile(fullfile(expdir, 'raw_data/tiffs/suite2p'), fullfile(expdir, 'raw_data'));
    catch
    end
end

fprintf('\nMoving Onto Next Script!\n')
