function run_deepinterpolation(expdir_array)

%% THIS IS THE MASTER SCRIPT FOR DEEPINTERPOLATION (CALLS THE TWO OTHER SCRIPTS - RUN_DEEPINTERPOLATION 2/3

out_path_array = expdir_array;
swarmpath_array = expdir_array;
jobid_array = expdir_array;


z = 1 
for z = 1:length(expdir_array)
    
    expdir = char(string(expdir_array(z)));
    
    %% do deepinterpolation

    % Run the DeepInterpolation Script 
    root_path = '/vf/users/guptaa12/temp/pre_processing/scripts/deepinterpolation'; % path to deepinterpolation folder

    reg_tif_path    = fullfile(expdir, 'raw_data/tiffs');          % path to registered tifs
    out_path        = fullfile(expdir, 'raw_data'); % output path for denoised h5
    remove_reg_tifs = 0;                                   % remove registered tifs after denoising (0/1)

    [swarmpath, jobid] = run_deepinterpolation2(reg_tif_path, out_path);
    
    out_path_array(z) = cellstr(out_path);
    swarmpath_array(z) = cellstr(swarmpath);
    jobid_array(z) = cellstr(jobid);
    
end

fprintf('\nDone Submitting DeepInterpolation SwarmJob for each Experiment\n')

%% Run the Third Script of DeepInterpolation on Each File Separately --> Checks Whether or Not Each One Is Finished
run_deepinterpolation3(expdir_array, swarmpath_array, out_path_array, jobid_array);


%% Store the outputs for each file in corresponding NWB structure
z = 1;
for z = 1:length(expdir_array)
    
    % make sure variables are present for the NWB
    out_path = char(string(out_path_array(z)));
    path = fullfile(out_path, 'denoised.h5');
    denoised_data = h5read(path, '/data');
    
    expdir = char(string(expdir_array(z)));
    
    load(fullfile(expdir, 'rec_params.mat'));
    timestamps = 1:(Nframes); 
    
    nwb = nwbRead(fullfile(expdir, 'nwb/demo_test.nwb'));
    imagingplane = nwb.acquisition.get('raw_data').imaging_plane;
    
    FOV = nwb.acquisition.get('raw_data').field_of_view

    % specify information for deepinterpolation...
    deepinterpolation_storage = types.core.TwoPhotonSeries(...
        'field_of_view', FOV, ... % this is the FOV in meters 
        'format', 'h5',...
        'data', denoised_data,...
        'data_unit', 'lumens',...
        'timestamps', timestamps,... % data acquired (512x512) corresponds per frame temporal resolution
        'imaging_plane', imagingplane)

    deepinterpolation_data = types.core.ProcessingModule(...
        'description', 'this contains TwoPhotonSeries which contains the actual deepinterpolation data')

    deepinterpolation_data.nwbdatainterface.set('deepinterpolation_storage', deepinterpolation_storage)
    
    nwb.processing.set('DeepInterpolation', deepinterpolation_data)

    % export the NWB structure with the DeepInterpolation data inside 
    nwbExport(nwb, fullfile(expdir, 'nwb/demo_test.nwb')); % export the NWB file in the proper directory
end
    
