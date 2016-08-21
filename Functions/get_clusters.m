function [ clusters ] = get_clusters( peaks_indices, peaks_seconds, time_vector, feature_vector )
%get_clusters Retrieve summarized clusters for the specified peaks in time
%domain (seconds).

%% Sort segments and calculate statistical features 
% (covariance matrix cov_segment/mean cov_mean).
segment_begin = 0;
cov_segment  = cell(1, length(peaks_indices));
mean_segment = cell(1, length(peaks_indices));
for i = 1:length(peaks_indices)
    if i < length(peaks_indices)
        segment = feature_vector(:, segment_begin + 1:peaks_indices(i));
    else
        % Last segment reaches the end of the feature vector.
        segment = feature_vector(:, peaks_indices(end):end);
    end
    cov_segment{i}  = cov(segment');
    mean_segment{i} = mean(segment, 2)';
    % Prepare begin of next segment.
    segment_begin = peaks_indices(i) + 1;
end

%% Calculate the Kullback-Leibler distance between segments.
distance_KL = zeros(length(peaks_indices), length(peaks_indices));
for i = 1:length(peaks_indices)
    for j = 1:length(peaks_indices)
        distance_KL(i, j) = 1/2 * (trace(cov_segment{j} / cov_segment{i}) + ...
            trace(cov_segment{i} / cov_segment{j}) + ...
            (mean_segment{i} - mean_segment{j}) * ...
            (inv(cov_segment{i}) + inv(cov_segment{j})) * ...
            (mean_segment{i} - mean_segment{j})') - 12;
        trial = exp(-distance_KL(i, j));
        if (trial < realmax && trial > realmin)
            distance_segments(i, j) = trial;
        elseif (trial > realmax)
            distance_segments(i, j) = realmax;
        else
            distance_segments(i, j) = realmin;
        end
    end
end

% distance_segments = exp(-distance_KL);

%% Visualize the Similarity Matrix.
% SMVis_params.titleVisible = true;
% SMVis_params.colormapPreset = 1; % linear
% SMVis_params.title = 'SM (Audio Segments)';
% visualizeSM(distance_segments, SMVis_params);

%% Calculate the SVD (Singularwertzerlegung)
[U, singular_values, V] = svd(distance_segments);

%% Calculate the cluster matrices B
for i = 1:length(cov_segment)
    a = singular_values(i, i) * U(:, i) * V(:, i)';
    B(i)= {a};
    %% Calculate the cluster vectors b
    Bp = B{1, i};
    bp(i, :) = sum(Bp);
end

%% Extract Clusters via Maxima.
[~, clusters_all] = max(bp(2:end,:));

%% Summarize to unique clusters.
clusters_unique(1) = clusters_all(1);
n = 2;
for i = 2:length(clusters_all)
    if clusters_all(i) ~= clusters_all(i - 1)
        clusters_unique(n) = clusters_all(i);
        peaks_seconds_unique(n) = peaks_seconds(i - 1);
        n = n + 1;
    end
end

%% Visualize the cluster vectors.
% figure;
% plot(peaks_seconds, bp(1:cluster_max, :)');
% xlabel('segment timevalue in sec');
% ylabel('cluster value');
% legend;

%% Get ABC structure for audio segments in cluster_ABC.
t = 65; % Begin with character 'A'
for i = 1:length(clusters_unique)
    a = find(clusters_unique == clusters_unique(i));
    if length(a) > 1 && i == min(a)
        for j = 1:length(a)
            clusters_labels(a(j)) = char(t);
        end
        t = t + 1;
    elseif i == min(a)
        clusters_labels(a) = char(t);
        t = t + 1;
    end
end

%% Transform into Dataset Structure (starttime, endtime and segment label).
for j = 1:length(clusters_labels)
    if j < length(clusters_labels)
        % Use beginning of next segment for this segment's end.
        segment_end = peaks_seconds_unique(j + 1);
    else
        % Use end of audio file for last segment's end.
        segment_end = time_vector(end);
    end
    clusters(j, :) = {peaks_seconds_unique(j), segment_end, clusters_labels(j)};    
end

end

