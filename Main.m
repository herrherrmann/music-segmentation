clear variables;
clc;

% Add paths to custom functions and third-party libraries.
addpath ACA-Code;
addpath Functions;
addpath SM-Toolbox_1.0/SMtoolbox_functions;
addpath SM-Toolbox_1.0/MATLAB-Chroma-Toolbox_2.0;

%% Read Audio and Dataset Files.
fs = 44100;
FOLDER_AUDIO   = 'Audio';
FOLDER_DATASET = 'Dataset';
[names, audios, datasets] = read_files(FOLDER_AUDIO, FOLDER_DATASET);

%% Global Parameters.
% Feature Extraction:
block_size = 4096;
hop_size   = 2048;
pitch_params.winLenSTMSP = block_size;
pitch_params.winOvSTMSP  = hop_size;
CENS_params.downsampSmooth   = 1; % 10
CENS_params.winLenSmooth     = 1; % 41

%% Iterate through all found audio files and compute according features, SM, novelty, clusters and evaluate the results.
% Initialization.
songs = cell(1, length(audios));
for i = 1:length(audios)
    %% Inform about the current song.
    info_temp = sprintf('Handling file %d out of %d: %s', i, length(audios), names{i});
    disp(info_temp);
    
    %% Assign song meta data to single song cell.
    songs{i}.name    = names{i};
    songs{i}.audio   = audios{i};
    songs{i}.dataset = datasets{i};
   
    %% Feature Extraction.
    [songs{i}.MFCCs, songs{i}.MFCCs_time] = ComputeFeature('SpectralMfccs', songs{i}.audio, fs, [], block_size, hop_size);

    % Remove first column (higher order MFCCs, acc. to Foote: "Visualizing Music and Audio using Self-Similarity", p. 2).
    songs{i}.MFCCs = songs{i}.MFCCs(2:end,:);

    %% Prepare Segments Array (feature-sample-based) for Comparison
    if (~isempty(songs{i}.dataset))
        % Extract segment beginnings from first column in dataset.
        songs{i}.dataset_segments_secs = cellfun(@(x) str2double(x), songs{i}.dataset(:,1));
        [songs{i}.dataset_segments_highlights, songs{i}.dataset_segments_samples] = get_sample_vector_with_highlights(songs{i}.dataset_segments_secs, songs{i}.MFCCs_time);
    end

    %% Similarity Matrix Creation.
    SM_params.smoothLenSM = 10;
    songs{i}.SM_MFCCs = vector_similarity(songs{i}.MFCCs, 15, 1);

    %% SM Visualization.
    % clear SMVis_params;
    % SMVis_params.titleVisible = true;
    % SMVis_params.colormapPreset = 1; % linear
    % SMVis_params.title = 'SSM (MFCCs)';
    % visualizeSM(songs{i}.SM_MFCCs, SMVis_params);
    % SMVis_params.title = 'SSM (Vector)';
    % visualizeSM(songs{i}.SM_MFCCs, SMVis_params);

    %% Creation of normalized Novelty Curves.
    % https://ccrma.stanford.edu/workshops/mir2009/references/Foote_00.pdf, p. 454
    kernel_size = 32;
    songs{i}.novelty_MFCCs_vector = get_novelty(songs{i}.SM_MFCCs, kernel_size, true);

    %% Find peaks (maxima) of novelty curve.
    % http://de.mathworks.com/help/signal/ref/findpeaks.html

    % Time Factor to convert seconds to feature samples.
    songs{i}.time_factor = length(songs{i}.SM_MFCCs) / (length(songs{i}.audio) / fs);

    findpeak_params = {
        'NPeaks', 100, ...
        'SortStr', 'descend', ...
        'Annotate', 'extents', ...
        'MinPeakProminence', 0.1, ...
        'MinPeakDistance', (2 * songs{i}.time_factor)
        % 'MinPeakWidth', 0, ...
        % 'Threshold', 0, ...
    };
    
    % Plot novelty curves with their peaks.
    %     y_lim_params = [0 1.2];
    %     figure;    
    %     findpeaks(songs{i}.novelty_MFCCs_vector, findpeak_params{:});
    %     title('Novelty');
    %     hold on;
    %     plot(songs{i}.dataset_segments_highlights, '-g');
    %     ylim(y_lim_params);

    % Retrieve peaks' indices and sort them.
    [~, songs{i}.peaks_indices] = findpeaks(songs{i}.novelty_MFCCs_vector, findpeak_params{:});
    songs{i}.peaks_indices = sort(songs{i}.peaks_indices);
    [ 
        songs{i}.peaks_seconds, ...
        songs{i}.time_vector ] = transform_peaks_to_seconds(songs{i}.peaks_indices, songs{i}.novelty_MFCCs_vector, songs{i}.audio, fs);
    
    %% Retrieve Clusters.
    songs{i}.clusters = get_clusters(songs{i}.peaks_indices, songs{i}.peaks_seconds, songs{i}.time_vector, songs{i}.MFCCs);
    
    %% Compare our Clusters with the Dataset.
    % Get numeric and ABC label structure for dataset segments.
    songs{i}.dataset_abc = get_dataset_abc( songs{i}.dataset );
    
    %% Evaluating Boundary retrieval.
    % Find matching hits and compare them to the dataset.
    [ 
        songs{i}.boundaries_precision, ...
        songs{i}.boundaries_recall, ...
        songs{i}.boundaries_f_measure, ...
        songs{i}.boundaries_misc ] = eval_boundaries(songs{i}.dataset_abc, songs{i}.clusters);
    [ 
        songs{i}.label_precision, ...
        songs{i}.label_recall ...
        songs{i}.label_f_measure ] = eval_labeling(songs{i}.boundaries_misc.matched_segments);
end

%% Sumerization of results into overall average values.
clear statistics;
statistics = cell(length(songs) + 1, 7);
statistics(1,     1) = cellstr('Song');
statistics(2:end, 1) = cellfun(@(song) (song.name), songs, 'UniformOutput', false);
statistics(1,     2) = cellstr('Boundaries Precision');
statistics(2:end, 2) = num2cell(cellfun(@(song) (song.boundaries_precision), songs));
statistics(1,     3) = cellstr('Boundaries Recall');
statistics(2:end, 3) = num2cell(cellfun(@(song) (song.boundaries_recall), songs));
statistics(1,     4) = cellstr('Boundaries F-Measure');
statistics(2:end, 4) = num2cell(cellfun(@(song) (song.boundaries_f_measure), songs));
statistics(1,     5) = cellstr('Label Precision');
statistics(2:end, 5) = num2cell(cellfun(@(song) (song.label_precision), songs));
statistics(1,     6) = cellstr('Label Recall');
statistics(2:end, 6) = num2cell(cellfun(@(song) (song.label_recall), songs));
statistics(1,     7) = cellstr('Label F-Measure');
statistics(2:end, 7) = num2cell(cellfun(@(song) (song.label_f_measure), songs));

overall.boundaries_precision = nanmean(cellfun(@(song) (song.boundaries_precision), songs));
overall.boundaries_recall    = nanmean(cellfun(@(song) (song.boundaries_recall),    songs));
overall.boundaries_f_measure = get_f_measure(overall.boundaries_precision, overall.boundaries_recall);
overall.label_precision = nanmean(cellfun(@(song) (song.label_precision), songs));
overall.label_recall    = nanmean(cellfun(@(song) (song.label_recall),    songs));
overall.label_f_measure = get_f_measure(overall.label_precision, overall.label_recall);

disp('Done! You can find the results in songs (all details for each song), statistics (songs and their evaluation results) and overall (mean evaluation results).');

%% Clean up workspace.
clear names audios datasets audioStereo *_params *_temp *_sideinfo;