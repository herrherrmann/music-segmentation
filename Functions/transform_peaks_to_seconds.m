function [ peaks_seconds, time_vector ] = transform_peaks_to_seconds( peaks_indices, novelty, audio, fs )
%transform_peaks_to_seconds Map peak indices to temporal vector (seconds).

%% Map peak indices to temporal vector (seconds).
time_vector   = (1:length(novelty)) * (1 / length(novelty) * length(audio)) / fs;
peaks_seconds = zeros(1, length(peaks_indices));

for index = 1:length(peaks_indices)
    peaks_seconds(index) = time_vector(1, peaks_indices(index));
end

end

