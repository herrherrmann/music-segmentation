function [ names, audio, dataset ] = read_files( folder_audio, folder_dataset )
%read_files Read audio files and their respective dataset files (in .lab
%format) from the specified folders. Returns file names (without file
%extension), audio information (stereo) and the dataset arrays.

% List audio files.
audio_dir = dir(folder_audio);

% Only keep supported audio files.
valid_indices = cellfun(@(x)(~isempty(x)), regexp({audio_dir.name}, '^.+((\.wav)|(\.mp3)|(\.m4a))$', 'match'));
audio_dir = audio_dir(valid_indices);

% Extract files' names and remove file extension.
audio_files = {audio_dir.name};
names = arrayfun(@(x) regexprep(x, '\.(...)$', ''), audio_files);

% Look for *.lab files in specified dataset folder.
audio   = cell(1, length(audio_files));
dataset = cell(1, length(audio_files));
for i = 1:length(audio_files)
    % Read audio information.
    audio_path = fullfile(folder_audio, audio_files{i});
    audio{i} = audioread(audio_path);
    
    % Create dataset file name and path.
    dataset_file_name = regexprep(audio_files{i}, '\.(...)$', '.lab');
    dataset_path = fullfile(folder_dataset, dataset_file_name);
    try
        % Open and read dataset file (if available).
        dataset_file = fopen(dataset_path, 'r');
        dataset_entry = textscan(dataset_file, '%s');
        dataset_entry = dataset_entry{1};
        fclose(dataset_file);        
    catch ME
        if strcmp(ME.identifier, 'MATLAB:FileIO:InvalidFid')
            errorMessage = sprintf('Dataset file for "%s" could not be found (tried "%s").', audio_files{i}, dataset_file_name);
            disp(errorMessage);
        else
            disp('Unknown Error when trying to read dataset files.');
            disp(ME);
        end
    end
    % Put start time in first column, end time in second column and
    % segment name in third column.
    dataset{i} = reshape(dataset_entry, 3, [])';
end

end

