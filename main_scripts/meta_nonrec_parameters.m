function [path_to_raw_tiffs, num_of_tifs, raw_file_name, ext] = rec_params2registration(expdir)

%% Getting Relevant Variable Values for NWB and For Later On In Processing
    % read from text file and save under certain variables

try
    text_file = fileread(fullfile(expdir, 'sample_upload_text_file.txt'));
    text_file = strsplit(text_file, '\n');
catch
    fprintf('\nNo Text File with Subject Information Found... Will Still Proceed, But Please Input Values Later \n');
end

try
    general_notes1 = char(text_file(1));
    general_notes2 = split(general_notes1, ':');
    general_notes = char(general_notes2(2));
catch
    general_notes = 'N/A';
end

try
    sex1 = char(text_file(2));
    sex2 = split(sex1, ':');
    sex = char(sex2(2));
    sex = sex(find(~isspace(sex)));
catch
    sex = 'Please Input Sex Here';
end

try
    weight1 = char(text_file(3)); 
    weight2 = split(weight1, ':');
    weight = char(weight2(2));
    weight = weight(find(~isspace(weight)));
catch
    weight = 'Plase Input Weight Here';
end

try
    age1 = char(text_file(4)); 
    age2 = split(age1, ':');
    age = char(age2(2));
    age = age(find(~isspace(age)));
catch
    age = 'Please Input Age Here';
end

try
    genotype1 = char(text_file(5));
    genotype2 = split(genotype1, ':');
    genotype = char(genotype2(2));
    genotype = genotype(find(~isspace(genotype)));
catch 
    genotype = 'Please Input Genotype Here';
end
    
% hardcoded values to place into NWB 
general_experimenter = 'Ankush Gupta';
session_description = 'presented drifting gratings to mouse and recorded from V1 via 2PI';
general_stimulus = 'drifting orientation gratings';
general_surgery = 'V1 Craniotomy and Window';
general_virus = 'Crimson R';
general_experiment_description = 'critical dynamics in V1 of mouse during presentation of orientation gratings';
location = 'V1';
FOV = [0.00045, 0.00045]; % in meters

% get the opticalchannel value 
Experiment_xml = parseXML('Experiment.xml');

i = 1;
ii = 1;
iii = 1;
for i = 1:length(Experiment_xml.Children)
    if string(Experiment_xml.Children(i).Name) == 'Wavelengths'
        for ii = 1:length(Experiment_xml.Children(i).Children)
            if string(Experiment_xml.Children(i).Children(ii).Name) == 'Wavelength'
                opticalchannel = Experiment_xml.Children(i).Children(ii).Attributes;
                opticalchannel = struct2cell(opticalchannel);
                opticalchannel = opticalchannel(:,:,2);
                for iii = 1:length(opticalchannel)
                    if startsWith(opticalchannel{iii}, 'Chan') == 1 
                        opticalchannel = opticalchannel{iii};
                    end
                end
            end
        end
    end
end

% get the session start time 
i = 1; 
while i < length(Experiment_xml.Children)
    if string(Experiment_xml.Children(i).Name) == 'Date'
        session_start_time = Experiment_xml.Children(i).Attributes.Value;
        i = length(Experiment_xml.Children);
    else
        i = i + 1;
    end
end
session_start_time = char(session_start_time);
datetime1 = split(session_start_time);
date = split(datetime1(1), '/');
time = split(datetime1(2), ':');
datetime2 = strcat(date(3), ', ', date(1), ', ', date(2), ', ',...
time(1), ', ', time(2), ', ', time(3)); % stored in 1x1 cell
datetime3 = string(datetime2(1)); % store entire thing as string in new variable
datetime4 = str2num(datetime3); % convert into numeric

clearvars date time;

% get the excitation wavelength 
i = 1; 
ii = 1;
while i < length(Experiment_xml.Children)
    if string(Experiment_xml.Children(i).Name) == 'Wavelengths'
        excitation_lambda1 = Experiment_xml.Children(i).Attributes;
        excitation_lambda2 = struct2cell(excitation_lambda1);
        for ii = 1:length(excitation_lambda1)
            t = excitation_lambda2(:,:,ii);
            if string(t(1)) == 'nyquistExWavelengthNM'
                excitation_lambda3 = char(t(2));
                i = length(Experiment_xml.Children);
            else
                a = 5;
            end
        end
    else
         i = i + 1;
    end
end
