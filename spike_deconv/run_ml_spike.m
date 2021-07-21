function run_MLSpike(expdir_array, MATLAB_version_reminder_option)

% MAKE SURE THAT THE 2019A VERSION OF MATLAB IS OPEN TO RUN ML SPIKE 
if MATLAB_version_reminder_option == 'y' || MATLAB_version_reminder_option == 'Y' 
    prompt = ('IS MATLAB VERSION 2019A OPEN? [Y/N]:  ')
    answer = input(prompt, 's');
    if answer == 'n' || answer == 'N' 
        fprintf('\nPlease Open the Correct Version of MATLAB\n')
        return 
    else
        if answer == 'y' || answer == 'Y'
            fprintf('\nProceeding with ML Spike!\n')
        else 
            fprintf('\nValid Answer not Provided\n')
            return
        end
    end
else
    if MATLAB_version_reminder_option == 'n' || MATLAB_version_reminder_option == 'N'
    end
end

%% RUN ML SPIKE ON EXPERIMENTS
% Remember to make the npsub a numerical value and not a string for ML
% Spike to read it + when you run the collect_spikeoutput function, you may
% have to adjust the expdir for it to work properly 

z = 1;
for z = 1:length(expdir_array)
    
    expdir = char(string(expdir_array(z)));
    
    % make sure certain variables are present for rest of script
    path_to_raw_folder = fullfile(expdir, 'raw_data');
    path_to_raw_tiffs = fullfile(path_to_raw_folder, 'tiffs');
    
    % make new directory called processed data and move suite2p folder into
    % it
    mkdir(fullfile(expdir, 'processed_data', 'f'));
    addpath(fullfile(expdir, 'processed_data'));
    path_to_processed_data_file = fullfile(expdir, 'processed_data');

    source = fullfile(path_to_raw_tiffs, 'suite2p');
    movefile(source, path_to_processed_data_file, 'f');

    addpath(fullfile(path_to_processed_data_file, 'suite2p'), fullfile(path_to_processed_data_file, 'suite2p/plane0'), fullfile(path_to_processed_data_file,...
    'suite2p/plane0/reg_tif'));

% run ML Spike
    %mcc2 -m -R -nodisplay -R -singleCompThread swarm_MLspikes_v2_pkedit.m
    %mcc2 -m -R -nodisplay -R -singleCompThread MLspikes_parallel_v2_pkedit.m
    %mcc2 -m -R -nodisplay -R -singleCompThread groupMLspk_pkedit.m
% this block of code above is meant for compiling it if you have not done
% so before 

% remember, you need to change the two paths within the do_MLspike script
% to your own paths (swarmfile and compiled code path which points to the
% compiled code BEFORE you compile it with the commands above)
    npsub = 0.7;

    try 
        do_deconv(expdir, npsub, 8);
    catch 
        fprintf('Might Need to Switch MATLAB Versions to 2019A')
        return 
    end 
end

fprintf('Running MLSpike!')

% Check whether or not ML Spike is done running before doing
% collect_spikeoputput

[~, status] = system('squeue -n swarm_MLspk -u guptaa12');
status2 = strfind(string(status), 'swarm');

clc;
pause(60);
output_string = fprintf('\nML Spike Output is Not Ready After 1 Minute(s)\n');
i = 1;
while i < 200
    if length(status2) == 0
        fprintf('\nVerifying ML Spike Output is Ready...\n');
        pause(120);
        ii = 1;
        for ii = 1:length(expdir_array)
            expdir = char(string(expdir_array(ii)));
            collect_spikeoutput(expdir, 0.7);
            fprintf('\nCollect_SpikeOutput Was Ran!\n');
        end
        i = 200;
    else
        pause(60);
        i = i + 1;
        if i < 10
            fprintf([(repmat('\b', 1, output_string)), strcat(['ML Spike Output is Not Ready After ', num2str(i), ' Minute(s)'])]);
        else
            if i < 100
                fprintf([(repmat('\b', 1, output_string+1)), strcat(['ML Spike Output is Not Ready After ', num2str(i), ' Minute(s)'])]);
            else 
                fprintf([(repmat('\b', 1, output_string+2)), strcat(['ML Spike Output is Not Ready After ', num2str(i), ' Minute(s)'])]);
            end
        end
        [~, status] = system('squeue -n swarm_MLspk -u guptaa12');
        status2 = strfind(string(status), 'swarm');
    end
end

fprintf('\nNow Placing Output Into NWB\n');
