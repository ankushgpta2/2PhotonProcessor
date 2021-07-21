function run_swarm_4_reg(expdir_array, tau_array, fs_array,...
    nchannels_array, nplanes_array, path_to_raw_tiffs_array,...
    num_of_experiments, num_of_tiffs_array, names_of_raw_tiffs,...
    ext_of_raw_tiffs, path_to_python_suite2p_folder)

% create the comprehensive swarmfile for all subjobs
path_to_actual_script = fullfile(path_to_python_suite2p_folder, 'registration_through_MATLAB_4_swarm.py');
folder_4_swarmfiles = fullfile(path_to_python_suite2p_folder, 'e_and_o_swarm_files_4_reg');
swarmfile = fullfile(folder_4_swarmfiles, 'reg_swarmfile.swarm'); 

if ~isfile(folder_4_swarmfiles)
        mkdir(folder_4_swarmfiles);
        addpath(folder_4_swarmfiles);
else
    try
        if ~isempty(folder_4_swarmfiles)
            delete(fullfile(folder_4_swarmfiles, '*'));
        end
    catch
        error('\nUnable to Make Directory For Swarmfiles or Delete Old Files In folder_4_swarmfiles Path\n');
    end
end
            
fileID = fopen(swarmfile, 'w');
startup_command = ['source /data/$USER/conda/etc/profile.d/conda.sh && ',...
    'conda activate suite2p'];

for z = 1:length(expdir_array)
    text_4_swarmfile = [startup_command,' && python3.7 ', path_to_actual_script, ' ',...
        char(string(expdir_array(z))), ' ', char(string(tau_array(z))), ' ', char(string(fs_array(z))),...
        ' ', char(string(nchannels_array(z))), ' ', char(string(nplanes_array(z))), ' ', char(string(path_to_raw_tiffs_array(z))),...
        ' ', char(string(num_of_experiments)), ' ', char(string(num_of_tiffs_array(z))), ' ', char(string(names_of_raw_tiffs(z))),...
        ' ', char(string(ext_of_raw_tiffs(z)))];
    
    fprintf(fileID, '%s\n', text_4_swarmfile); 
end
fclose(fileID);

% run the following swarm command in biowulf 
addpermissions = strcat('chmod +rwx',{' '},swarmfile);
system(addpermissions{1}, '-echo');
cd(folder_4_swarmfiles);
[~, jobid] = system(['swarm --file reg_swarmfile.swarm -g 200 -t 16 --partition=norm']);
fprintf('\nSwarmJob is Submitted!\n');

% periodically check to see if it is done running 
pause(300); % pause for 5 minutes prior to querying biowulf
[~, status] = system('squeue -n swarm -u $USER');
status2 = strfind(string(status), jobid);

clc;
output_string = fprintf('\nRegistration Outputs are Not Ready After 5 Minute(s)\n');
i = 5;
limit = 200; % in minutes
while i < limit
    if length(status2) == 0 || i == (limit - 1)
        fprintf('\nVerifying Registration is Complete...\n');
        for ii = 1:num_of_experiments
            if exists(fullfile(path_to_raw_tiffs_array(ii), 'suite2p'))
                fprintf(strcat([expdir_array(ii), ' Was Registered!'])); 
            else
                fprintf(strcat([expdir_array(ii), ' Was Not Properly Registered!'])); 
            end  
        end
        i = limit;
    else
        pause(60);
        i = i + 1;
        if i < 10
            fprintf([(repmat('\b', 1, output_string)), strcat(['Registration Outputs are Not Ready After ', num2str(i), ' Minute(s)'])]);
        else
            if i < 100
                fprintf([(repmat('\b', 1, output_string+1)), strcat(['Registration Outputs are Not Ready After ', num2str(i), ' Minute(s)'])]);
            else 
                fprintf([(repmat('\b', 1, output_string+2)), strcat(['Registration Outputs are Not Ready After ', num2str(i), ' Minute(s)'])]);
            end
        end
        [~, status] = system('squeue -n swarm -u $USER');
        status2 = strfind(string(status), jobid);
    end
end 
 
