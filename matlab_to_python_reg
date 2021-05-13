function run_registration(path_to_raw_tiffs_array, num_of_experiments, num_of_tiffs_array, names_of_raw_tiffs, ext_of_raw_tiffs)

%% RUN REGISTRATION 
% either open Suite2p for registration or run it from MATLAB

% export the expdir variable as .mat file to upload into python script
path_to_python_suite2p_script = '/vf/users/guptaa12/temp/pre_processing/NWB_Scripts_test';
cd(path_to_python_suite2p_script);
save('matlab_variables', 'path_to_raw_tiffs_array', 'num_of_experiments', 'num_of_tiffs_array', 'names_of_raw_tiffs', 'ext_of_raw_tiffs', '-v7');

try
    !python3.7 registration_through_MATLAB.py
catch 
    try 
        cd '/vf/users/guptaa12/temp/pre_processing/scripts';
        !bash activate_suite2p
        fprintf('\nOpening Up Suite2p for Registration\n');
    catch 
        fprintf('\nPlease Open Up Suite2p for Registration\n');
    end
end

% delete the matlab_variables.mat file from script location
delete(fullfile(path_to_python_suite2p_script, 'matlab_variables.mat'));

fprintf('\nMoving Onto Next Script - Registration Figures and Video\n')
