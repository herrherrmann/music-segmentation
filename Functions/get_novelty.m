function [ novelty ] = get_novelty( S, kernel_size, normalize )
%get_novelty Calculate the novelty of each row value in a self-similarity
%matrix by comparing submatrices with a gaussian checkerboard kernel.
%   https://ccrma.stanford.edu/workshops/mir2009/references/Foote_00.pdf

% Construct Kernel/Checkerboard (Default Kernel Size is 64.)
if nargin == 1
    kernel_size = 64;
end
[C] = get_gaussian_kernel(kernel_size);

length_C = length(C);
length_S = length(S);

% Zero Padding of Similarity Matrix
S_zero_padded = zeros(length_S+length_C, length_S+length_C);
padding_start = length_C/2 + 1;
padding_end   = length_C/2 + length_S;
S_zero_padded(padding_start:padding_end, padding_start:padding_end) = S;

noveltysums = zeros(length_C, length(S_zero_padded));

% Calculation of Novelty (p. 454)
for i = 1:length_S
    % Optional: Status Report for every index.
    % disp(['Current Novelty Index: ', num2str(i), ' / ', num2str(length_S)]);
    for m = 1:length_C
        for n = 1:length_C
            % Only one-half of the values under the double summation (those for m >= n ) need be computed because typically both S and C are symmetric.
            if (m >= n)
                noveltysums(m, i) = noveltysums(m, i) + C(m, n) * S_zero_padded((i+m), (i+n));
            end
        end
    end
end

% Aggregate sums.
novelty = sum(noveltysums);

% Reduce size to original size.
novelty = novelty(padding_start:padding_end)';

% Normalize to values between 0 and 1.
if nargin >= 3 && normalize == true
    novelty = novelty ./ max(novelty);
end

end