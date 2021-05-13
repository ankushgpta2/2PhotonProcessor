%% Create new directories and move files into proper orientation 
% make raw_data directory 
path_to_raw_folder = fullfile(expdir, 'raw_data');
mkdir(path_to_raw_folder);
addpath(path_to_raw_folder);

% make nwb directory 
nwb_path = fullfile(expdir, 'nwb');
mkdir(nwb_path);
addpath(nwb_path);

% figure out the type and name of the raw data to move --> get the name of
% the folder from the experiment.xml 
ii = 1;
for ii = 1:length(Experiment_xml.Children)
    if string(Experiment_xml.Children(ii).Name) == 'Name'
        name_of_folder = Experiment_xml.Children(ii).Attributes.Value;
    end
end

try 
    cd(fullfile(expdir, name_of_folder));
    path_to_raw_file = fullfile(expdir, name_of_folder);
catch
    try
        cd(fullfile(expdir, 'Untitled_001'));
        path_to_raw_file = fullfile(expdir, 'Untitled_001');
    catch
        try
            cd(fullfile(expdir, 'Untitled'));
            path_to_raw_file = fullfile(expdir, 'Untitled');
        catch 
            frpintf('\nCould Not Find an Untitled or Untitled_001 or Folder Name in Experiment.xml within Expdir\n')
            return
        end
    end
end

find_raw = dir('*.raw');
find_tif = dir('*.tif');
try
    if isempty(find_tif) == 1
        find_name = dir('*.raw');
        raw_file_name = find_name.name;
    else
        find_name = dir('*.tif');
        raw_file_name = find_name.name;
    end
catch
    fprintf(strcat('\nA .Raw or .Tif File Was Not Found in...', path_to_raw_file));
    return
end
 
% move the raw data file under the raw_data folder, along with
% Experiment.xml
source1 = fullfile(path_to_raw_file, raw_file_name);
source2 = fullfile(path_to_raw_file, 'Experiment.xml');
movefile(source1, path_to_raw_folder);
movefile(source2, path_to_raw_folder);
path_to_raw_file = fullfile(path_to_raw_folder, raw_file_name);
