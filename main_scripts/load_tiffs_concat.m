%% loading and modifying raw tifs

% load the tiffs into a cell array
list_of_tifs = dir(fullfile(path_to_raw_tiffs, '*.tiff'));...
    dir(fullfile(path_to_raw_tiffs, '*.tif'));

if isempty(list_of_tifs) == 1
    try 
      list_of_tifs = dir(fullfile(path_to_raw_tiffs, '*.tif'));  
    catch 
        fprintf('\ncould not find a .tif file in path_to_raw_tiffs directory\n %s');
    end
end

list_of_tifs_names = [];
ii = 1;
for ii = 1:length(list_of_tifs)
    list_of_tifs_names{ii} = list_of_tifs(ii).name;
end
list_of_tifs_names = natsort(list_of_tifs_names);
num_of_tifs = length(list_of_tifs_names);

ii = 1;
actual_raw_tifs = {};
fprintf('\nLoading Raw Tifs... \n %s');
for ii=1:num_of_tifs;
    actual_raw_tifs{ii} = loadtiff(fullfile(path_to_raw_tiffs, list_of_tifs_names{ii}));
end

% concatenate so it can be stored (cell --> numeric)
concat_raw_tifs = [];
ii = 1;
fprintf('\nConcatenating Raw Tifs... %s');
for ii = 1:num_of_tifs
    concat_raw_tifs = cat(3, concat_raw_tifs, actual_raw_tifs{ii});
end
