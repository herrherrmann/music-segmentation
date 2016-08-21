function [ S ] = vector_similarity( features, window, resample_factor )
%vector_similarity Calculate similarity matrix of specified feature vector
%via vector correlation over a specified window 
% (acc. to Foote (1999), p. 3)

L = length(features);
S = zeros(L);

for i = 1:L
    for j = 1:L
        correlation = 0;
        for k = 0:(window - 1)
            correlation = correlation + (features(i+k) * features(j+k));
        end
        S(i,j) = (1 / window) * correlation;
    end
end

% Resample Matrix to a smaller matrix if specified.
if nargin >= 3
    S = imresize(S, 1/resample_factor);
end


end

