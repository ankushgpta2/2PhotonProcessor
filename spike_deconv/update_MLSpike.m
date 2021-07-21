function update_MLSpike(expdir)

try
    new_mat = load(fullfile(expdir, 'processed_data/2p_data', 'fluor_0.7npsub_denoised_reference.mat'));
catch
    try 
        new_mat = load(fullfile(expdir, 'processed_data', 'fluor_0.7npsub_denoised_reference.mat'));
    catch
        try
            new_mat = load(fullfile(expdir, 'fluor_0.7npsub_denoised_reference.mat'));
        catch
            error('Unable to Load ML Spike .mat File... Please Make Sure It Is In processed_data/2p_data');
        end
    end
end
fields = fieldnames(new_mat);

try
    load(fullfile(expdir, 'processed_data/suite2p/plane0/Fall.mat'), 'iscell');
catch
    error('Unable to Load Iscell from Fall.mat File... Please Make Sure It Is in processed_data/suite2p/plane0');
end

% set up structure 
for i = 1:length(fields)
    selected_field = new_mat.(fields{i});
    if isstruct(selected_field)
        fields2 = fieldnames(new_mat.(fields{i}));
        for ii = 1:length(fields2)
            selected_sub_field = selected_field.(fields2{ii});
            if length(selected_sub_field) > 1
                if isnumeric(selected_sub_field) && length(selected_sub_field(:,1)) ~= length(find(iscell(:,1) == 1))
                    new_mat.(fields{i}).(fields2{ii}) = selected_sub_field(find(iscell(:,1)==1), :);
                end
            end     
        end
    else
        if length(selected_field) > 1
            if isnumeric(selected_field) && length(selected_field(:,1)) ~= length(find(iscell(:,1) == 1))
                new_mat.(fields{i}) = selected_field(find(iscell(:,1)==1), :);
            end
        end
    end
end

save(fullfile(expdir, 'processed_data/2p_data', 'fluor_0.7npsub_denoised.mat'), 'new_mat');
