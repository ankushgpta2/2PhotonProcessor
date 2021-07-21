%% IF anything looks strange from figures than run this option to generate video

if proceed_with_video_generation == 'y'
    proceed_with_video_generation = 'Y';
else
    if proceed_with_video_generation == 'P' || proceed_with_video_generation == 'p' 
        prompt = ('Generate Vid After Reg? Y/N [Y]:  ');
        proceed_with_video_generation = input(prompt, 's');
    else
        if proceed_with_video_generation == 'n' 
            proceed_with_video_generation = 'N';
        end
    end
end


if proceed_with_video_generation == 'Y'
    fprintf('\nVideo Will Be Generated...\n');
    tifpath = path_to_regtif
    tiflist = [dir(fullfile(tifpath,'*.tif'));...
           dir(fullfile(tifpath,'*.tiff'))];
    tifnames = {};
    for ii = 1:length(tiflist)
           tifnames{ii} = tiflist(ii).name;
    end
    [tifnames,sortidx] = natsort(tifnames);         % sort tifs
    numtifs = length(tifnames);
    
    A = {};
    B = {};
    numframes = 0;
    
    fprintf('loading tiffs...')
    cmdout = '\n';
    fprintf(cmdout)
    tic
    for tifidx = 1:numtifs
        fprintf(repmat('\b',1,length(cmdout)-1))
        cmdout = [num2str(tifidx),'/',num2str(numtifs),'\n'];
        fprintf(cmdout);
        A{1,tifidx} = loadtiff(fullfile(tifpath,tifnames{tifidx}));
        B{1, tifidx} = loadtiff(fullfile(path_to_regtif, reg_tif_names{tifidx})); 
        numframes   = numframes+size(A{1,tifidx},3);
    end
    fprintf([repmat('\b',1,length(cmdout)),'finished!\nloaded ', ...
    num2str(numframes),' frames in ',sprintf('%.2f',toc/60),' minutes\n'])
        
    fprintf('Starting to Make AVI...')
    options               = struct;
    options.outfile       = fullfile(expdir, 'avis/AVI_with_customparams.avi');
    options.framerate     = 60;
    options.quality       = 20;
    options.scalefactor   = 0.75;
    options.dataprctle    = [];

    reg_mat = [];
    original_mat = [];
    
    for ii = 1:numtifs
        reg_mat = cat(3,reg_mat,A{1,ii});
        original_mat = cat(3, original_mat, B{1, ii});
    end
    
    VideoArray{1,1} = original_mat;
    VideoArray{1,2} = reg_mat;

    AVI_with_customparams = write2avi(VideoArray,options);
    
    fprintf('\nVideo is Done Generating...\n');
    addpath(fullfile(expdir, 'avis'));
    addpath(fullfile(expdir, 'avis', options.outfile));
else
    if proceed_with_video_generation == 'N'
        fprintf('\nVideo Will Not Be Generated As Requested...\n');
    else
        fprintf('\nValid Answer Was not Provided... Will Continue Anyways\n');
    end
end
