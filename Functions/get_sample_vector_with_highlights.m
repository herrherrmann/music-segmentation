function [ highlights, indices ] = get_sample_vector_with_highlights( highlights_in_seconds, time_vector )
%get_highlights_with_highlights Returns an array containing zeroes with
%highlights at the sample-based indices of the first specified vector.

% Prepare vector for feature-rate-based indices.
indices = zeros(1, length(highlights_in_seconds));

% Prepare vector for feature-rate-based "highlights" (value: 1) at indices.
highlights = zeros(1, length(time_vector));

for index = 1:length(highlights_in_seconds)
    [~, indices(index)] = min(abs(time_vector - highlights_in_seconds(index)));
    highlights(indices(index)) = 1;
end

end

