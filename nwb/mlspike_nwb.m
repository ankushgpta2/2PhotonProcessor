%% Store MLSpike Output in Proper Location 
z = 1;
for z = 1:length(expdir_array)
    
    expdir = char(string(expdir_array(z)));
    load(fullfile(expdir, 'rec_params.mat'));
    nwb_path = fullfile(expdir, 'nwb');
    nwb = nwbRead(fullfile(nwb_path, 'demo_test.nwb'));
    
    % create object mapping to the planesegmentation (ROI masks)
    load(fullfile(expdir, 'processed_data/suite2p/plane0/Fall.mat'), 'stat')
    n_rois = length(stat);
    
    plane_seg_object_view = types.untyped.ObjectView( ...
        '/processing/ROI_mod/ImageSegmentation/PlaneSegmentation')

    % create a dynamic table that maps onto the planesegementation 
    roi_table_region = types.hdmf_common.DynamicTableRegion( ...
        'table', plane_seg_object_view, ...
        'description', 'All ROIs and Corresponding Information', ...
        'data', [0 n_rois-1]')
    
    % load the probs and spikes in the output file  
    path_to_mlspike_output = fullfile(expdir, 'processed_data/2p_data');

    ml_spike_fluor_file = load(fullfile(path_to_mlspike_output, 'fluor_0.7npsub_denoised.mat'));
    probs = ml_spike_fluor_file.probs;
    spikes = ml_spike_fluor_file.spikes;

%% Place Outputs into Processing Section within NNWB
    
    % load the spikes into new ROI response series
    roi_response_series2 = types.core.RoiResponseSeries( ...
        'rois', roi_table_region, ...
        'data', spikes, ...
        'data_unit', 'binary 0 or 1', ...
        'starting_time_rate', framerate, ...
        'starting_time', 0.0,...
        'comments', 'this is the spiking data outputted from MLspike as 0 or 1')

    % load the probs into new ROI response series 
    roi_response_series3 = types.core.RoiResponseSeries( ...
        'rois', roi_table_region, ...
        'data', probs, ...
        'data_unit', 'between 0 and 1 representing probability of spike event', ...
        'starting_time_rate', framerate, ...
        'starting_time', 0.0,...
        'comments', 'this is the spiking data outputted from MLspike as prob')

    % now place the ROIResponseSeries class containing the data into
    % Flourescence class
    spikes_values = types.core.Fluorescence()
    spikes_values.roiresponseseries.set('ROISpikesResponses', roi_response_series2)

    probs_values = types.core.Fluorescence()
    probs_values.roiresponseseries.set('ROIProbsResponses', roi_response_series3)

    % now create a spiking and probs modules for the ROIs
    spikes_module = types.core.ProcessingModule( ...
    'description', 'contains spiking information for ROIs as 0 and 1 from MLSpike')

    probs_module = types.core.ProcessingModule( ...
    'description', 'contains probability information for spike events for ROIs between 0 and 1 from MLSpike')

    % place the ROI response series for probs and spikes respectfully into the
    % modules 
    spikes_module.nwbdatainterface.set('spikes_series', roi_response_series2)
    probs_module.nwbdatainterface.set('probs_series', roi_response_series3)

    % place modules into processing section of nwb file
    nwb.processing.set('spikes_from_MLSpike', spikes_module)
    nwb.processing.set('probs_from_MLSpike', probs_module)

    % export it to proper location 
    nwbExport(nwb, fullfile(expdir, 'nwb/demo_test.nwb')); % export the NWB file in proper directory 

end

fprintf('\nML Spike is Completed... Proceed to ROI Selection!\n')

