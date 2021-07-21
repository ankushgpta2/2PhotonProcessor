function flour_extract_4_deepinterpol(expdir_array, delete_denoised_h5_avi, delete_denoised_h5, path_to_python_script_4_deepinterpol_data)

%% prep array
tau_array = [];
fs_array = []; % framerate
nchannels_array = [];
nplanes_array = [];
num_of_tiffs_array = [];
h5_location_array = expdir_array;

%% place info in arrays
for z = 1:length(expdir_array)
    expdir = char(string(expdir_array(z)));
    load(fullfile(expdir, 'rec_params.mat'));
    tau_array(z) = tau;
    fs_array(z) = framerate; % framerate
    nchannels_array(z) = Nchannels;
    nplanes_array(z) = Nplanes;
    num_of_tiffs_array(z) = length(dir(fullfile(expdir, 'raw_data/denoised_tiffs', '*.tiff')));
    h5_location_array(z) = cellstr(fullfile(expdir, 'raw_data/denoised.h5'));
end
num_of_experiments = length(expdir_array); 

%% save MATLAB variables to proper location
cd(path_to_python_script_4_deepinterpol_data); 
save('matlab_variables', 'h5_location_array', 'num_of_tiffs_array','tau_array', 'fs_array', 'nchannels_array', 'nplanes_array', 'num_of_experiments', '-v6'); 

%% try running python scripts for suite2p
try
    !python3.7 flour_extract_4_deepinterpol_data_h5.py
catch 
    try 
        cd '/vf/users/guptaa12/temp/pre_processing/scripts';
        !bash activate_suite2p
        fprintf('\nOpening Up Suite2p\n');
    catch 
        fprintf('\nPlease Open Up Suite2p\n');
    end
end

%% delete a few things
% delete the matlab_variables.mat file from script location
delete(fullfile(path_to_python_script_4_deepinterpol_data, 'matlab_variables.mat'));

% delete the denoised tiffs 
for z = 1:length(expdir_array)
    expdir = char(string(expdir_array(z)));
    if delete_denoised_h5 == 1
        delete(fullfile(expdir, 'raw_data/denoised.h5'));
        fprintf('\nDenoised H5 Was Deleted for Experiment as Requested\n');
    end
    if delete_denoised_h5_avi == 1
        delete(fullfile(expdir, 'raw_data/denoised.avi'));
        fprintf('\nDenoised H5 Avi Was Deleted for Experiment as Requested\n');
    end
end
    
fprintf('\nFinished with Flour Extraction for DeepInterpolation .H5 File, Moving Onto ML Spike!\n');
