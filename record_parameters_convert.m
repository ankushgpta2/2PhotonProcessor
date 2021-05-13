%% Get the recording parameters via rec_params script and/or conversion to tiff
GECI = 'gcamp';
[filepath,name,ext] = fileparts(path_to_raw_file);
if ext == '.raw'
    rec_params(expdir, GECI);
    fprintf('\nNow Converting .raw File Into .tif!\n');
    convert2tiff(expdir);
    path_to_raw_tiffs = fullfile(path_to_raw_folder, 'tiffs');
    addpath(path_to_raw_tiffs);
else
    if ext == '.tif'
        rec_params_for_tif(expdir, GECI);
        path_to_raw_tiffs = path_to_raw_folder;
    else
        fprintf('\ncannot run rec_params because neither .raw or .tif ext found\n');
        return
    end
end

% load output
load('rec_params.mat');

clearvars filepath name;
