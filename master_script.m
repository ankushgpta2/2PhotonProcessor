tic;
clearvars; 
clc; 

%% STORING EXPDIR FOR MULTIPLE EXPERIMENTS INTO AN ARRAY
expdir1 = 'insert path to data location';
expdir2 = 'insert path to data location';
expdir3 = 'insert path to data location';
expdir4 = 'insert path to data location';
expdir_array = {expdir1, expdir2, expdir3, expdir4};

%% PREP OTHER ARRAYS FOR THE RELEVANT PARAMETERS TO TRANSFER TO DOWNSTREAM SCRIPTS
path_to_raw_tiffs_array = expdir_array; % just so it is the same size as num of experiments... 
                                       % replaced with actual path_to_raw_tiff dir and num of 
                                       % tiffs
num_of_tiffs_array = [];
names_of_raw_tiffs = expdir_array; 
ext_of_raw_tiffs = expdir_array;

%% RUNNING THE FIRST SCRIPT ---> REC_PARAMS, CONVERT2TIFF, INITIALIZES NWB, AND PREPS NECESSARY DATA FOR REGISTRATION
z = 1;
for z = z:length(expdir_array)
    expdir = string(expdir_array(z));
    expdir = char(expdir);
    
    [path_to_raw_tiffs, num_of_tifs, raw_file_name, ext] = rec_params2registration(expdir);

    path_to_raw_tiffs_array(z) = cellstr(path_to_raw_tiffs);
    num_of_tiffs_array(z) = num_of_tifs;
    names_of_raw_tiffs(z) = cellstr(raw_file_name);
    ext_of_raw_tiffs(z) = cellstr(ext);
end
fprintf('\nProceeding to Registration!\n');
%% RUNNING REGISTRATION 
num_of_experiments = length(path_to_raw_tiffs_array);
run_registration(path_to_raw_tiffs_array, num_of_experiments, num_of_tiffs_array, names_of_raw_tiffs, ext_of_raw_tiffs);

%% OPTION FOR VIDEO GENERATION FOR NEXT SCRIPT 
proceed_with_video_generation = 'N'; % optional to generate AVI of registration
                                    % put 'Y' for prompt to always proceed OR
                                    % 'N' to always not proceed OR 'P' to
                                    % always display prompt 

%% RUNNING THE SECOND SCRIPT ---> GENERATES AVI, REG FIGURES, AND STORES REGISTRATION OUTPUT IN NWB
z = 1;
for z = z:length(expdir_array)
    expdir = string(expdir_array(z));
    expdir = char(expdir);
    
    registration2deepinterpolation(expdir, proceed_with_video_generation);
end
fprintf('\nProceeding to DeepInterpolation!\n');
%% RUN DEEPINTERPOLATION
run_deepinterpolation(expdir_array);
 
%% RUNNING THIRD SCRIPT ---> ROI INFORMATION AND CORRESPONDING FLOUR TRACES ARE STORED IN NWB 
z = 1;
for z = 1:length(expdir_array)
    expdir = char(string(expdir_array(z)));
    deepinterpolation2MLSpike(expdir); 
end
fprintf('\nProceeding to MLSpike!\n');
%% OPTION FOR MATLAB VERSION REMINDER PROMPT 
MATLAB_version_reminder_option = 'N'; % whether or not you want a reminder to 
                                     % have MATLAB 2019A open for ML Spike
                                     
%% RUN ML SPIKE ON EXPERIMENTS 
run_MLSpike(expdir_array, MATLAB_version_reminder_option);
toc;
