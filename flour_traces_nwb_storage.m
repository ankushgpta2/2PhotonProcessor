%% Now Store Corresponding Flour Traces 

% create object mapping to the planesegmentation (ROI masks)
n_rois = length(stat);
plane_seg_object_view = types.untyped.ObjectView( ...
    '/processing/ROI_mod/ImageSegmentation/PlaneSegmentation')

% create a dynamic table that maps onto the planesegementation 
roi_table_region = types.hdmf_common.DynamicTableRegion( ...
    'table', plane_seg_object_view, ...
    'description', 'All ROIs and Corresponding Information', ...
    'data', [0 n_rois-1]')

% load the flour traces and put it into the ROIResponseSeries class
roi_response_series = types.core.RoiResponseSeries( ...
    'rois', roi_table_region, ...
    'data', F, ...
    'data_unit', 'lumens', ...
    'starting_time_rate', framerate, ...
    'starting_time', 0.0)

% now place the ROIResponseSeries class containing the data into Flour
% class
fluor = types.core.Fluorescence();
fluor.roiresponseseries.set('RoiResponseSeries', roi_response_series);

% now create a flour module for the ROIs
fluor_module = types.core.ProcessingModule( ...
    'description', 'contains flour information for ROIs');

fluor_module.nwbdatainterface.set('Fluor', fluor);
nwb.processing.set('fluor_mod', fluor_module)

% export the NWB file with the ROI Information + corresponding Flour
% Information 
cd(nwb_path);
nwbExport(nwb, 'demo_test.nwb'); % export the NWB file in the directory in previous line
