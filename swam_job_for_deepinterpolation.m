function [swarmpath, jobid] = run_deepinterpolation2(reg_tif_path,out_path)


%% THIS SUBMITS THE ACTUAL SWARMJOB FOR ALL EXPERIMENTS

tic
%% deal with inputs
if ~exist(out_path,'dir')
    mkdir(out_path)
end

if nargin==2
    remove_reg_tifs = 0;
    make_avi        = 0;
    avi_frames      = [0 0];
end
if nargin==3
    make_avi   = 0;
    avi_frames = [0 0];
end
if nargin==4
    avi_frames          = input('Please input [start stop] frames to write to avi: ');
    avi_ops.quality     = 30;
    avi_ops.framerate   = 45.5;
    avi_ops.dataprctle  = [];
    avi_ops.outfile     = fullfile(out_path,'denoised.avi');
end
if nargin==5
    avi_ops.quality     = 30;
    avi_ops.framerate   = 45.5;
    avi_ops.dataprctle  = [];
    avi_ops.outfile     = fullfile(out_path,'denoised.avi');
end

%% set denoising model path and general params
fprintf('\n------Denoising with DeepInterpolation------\n')

model_path  = ['/vf/users/guptaa12/temp/pre_processing/scripts/deepinterpolation/models/pretrained/',...
               '2019_09_11_23_32_unet_single_1024_mean_absolute_error_Ai93-0450.h5'];
startup_cmd = ['source /data/guptaa12/conda/etc/profile.d/conda.sh && ',...
               'conda activate deepinterpolation && module load CUDA/10.1 && ',...
               'module load cuDNN/7.6.5/CUDA-10.1'];
script_path = '/data/guptaa12/temp/pre_processing/scripts/deepinterpolation/functions/2P_inference_swarm.py';

out_file    = 'denoised.h5';
save_raw    = 'False'; 
pre_post_frames = 30; % must match number of pre_post_frames frames used during model training
frames_per_node = 50; % frames/subjob

%% write motion corrected tifs to h5
fprintf('writing motion corrected h5 file...\n');

tif_files = dir(fullfile(reg_tif_path,'*.tiff'));
tif_names = {};
for ii = 1:length(tif_files)
    tif_names{ii} = tif_files(ii).name;
end
[~,sort_idxs] = natsort(tif_names);

NpixelsX = 512;
NpixelsY = 512;

%%uncomment this block if using model trained off dimensions other than 512x512%%
% temp = loadtiff(fullfile(tiffiles(1).folder,tiffiles(1).name)); 
% [NpixelsX,NpixelsY,~] = size(temp);
% clear temp

% write tifs to single H5 file
reg_movie  = fullfile(reg_tif_path,'motion_corrected.h5');

if exist(reg_movie,'file')
    delete(reg_movie);
end
h5create(reg_movie,'/data',[NpixelsX NpixelsY Inf],...
    'Datatype','int16',"Chunksize",[NpixelsX NpixelsY 100]);

for tif_idx = 1:length(tif_files)    
    if tif_idx==1
        write_start = 1;
    end
    
    temp = loadtiff(fullfile(tif_files(sort_idxs(tif_idx)).folder,...
                             tif_files(sort_idxs(tif_idx)).name));
                         
    h5write(reg_movie,'/data',temp,[1 1 write_start],size(temp));
    write_start = write_start+size(temp,3);
end

Nframes = write_start-1;

fprintf([repmat('\b',1),'finished!\n']);

%% generate swarm file
fprintf('generating swarm file..............\n');
         
Nnodes = ceil(Nframes/frames_per_node);

swarmfile       = fullfile(out_path,'swarmjob','denoise.swarm');
[swarmpath,~,~] = fileparts(swarmfile);

try
    if exist(swarmpath,'dir')
        rmdir(swarmpath,'s');
    else
    end
end

mkdir(swarmpath);

fileID = fopen(swarmfile,'w');
for ii = 1:Nnodes
    if ii==1
        start_frame = pre_post_frames; % account for pre_post_frames at the beginning
        
    else
        start_frame = (ii-1)*frames_per_node;
    end
    if ii<Nnodes
        end_frame   = ii*frames_per_node-1;
    else
        
        end_frame   = -1; % tells DeepInterpolation to go to the end of file
    end
    
    swarm_outfile  = fullfile(swarmpath,[num2str(ii-1),'.h5']);
    path_generator = fullfile(swarmpath,['generator_',num2str(ii-1),'.json']); % generator script
    path_infer     = fullfile(swarmpath,['inferrence_',num2str(ii-1),'.json']); % inferrence script
    swarm_text     = [startup_cmd,' && python ',script_path,' ',reg_movie,... % write to swarm file
                      ' ',num2str(start_frame),' ',num2str(end_frame),' ',...
                      save_raw,' ',model_path,' ',swarm_outfile,' ',...
                      swarmpath,' ',path_generator,' ',path_infer];

    fprintf(fileID,'%s\n',swarm_text);
end
fclose('all');

GB_per_subjob = round((frames_per_node/100)*6,1);
if GB_per_subjob<3
    GB_per_subjob = 3;
end

swarm_options = [' -g ',num2str(GB_per_subjob),' -b 1']; % -g=GB/cpu, -b=bundle frames/subjob
    
addpermissions = strcat('chmod +rwx',{' '},swarmfile);
system(addpermissions{1}, '-echo');

fprintf([repmat('\b',1),'finished!\n'])

%% run swarm job
cd(swarmpath) % batch system writes swarm .e & .o files to current working directory, keeps things clean
[~,jobid] = system(['swarm -f ',swarmfile,swarm_options]);
 
