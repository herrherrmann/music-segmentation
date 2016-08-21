function [ precision, recall, f_measure ] = eval_labeling( matched_segments )
%eval_labeling Evaluate the existing matched_segments in the specified
%song.

%% Preparation of Variables.
len = length(matched_segments);
pairs_expected = 0;
pairs_data     = 0;
pairs_found    = 0;

%% Iterate through all matched segments and find pairs accordingly.
if (len > 2)
    for i = 1:len
        [m, ~] = find(matched_segments(:, 2) == matched_segments(i, 2));
        [n, ~] = find(matched_segments(:, 1) == matched_segments(i, 1));
        if (length(m) > 1 && i == min(m))
            pairs_expected = pairs_expected + 1;
        end

        if (length(n) > 1 && i == min(n))
            pairs_data = pairs_data + 1;
            if all(matched_segments(n, 2) == matched_segments(i, 2))
                pairs_found = pairs_found + 1;
            end
        end
    end
end

%% Calculate the results.
if(pairs_expected > 0)
    precision = pairs_found / pairs_expected;
else
    precision = NaN;
end

if(pairs_data > 0)
    recall = pairs_found / pairs_data;
else
    recall = NaN;
end

f_measure = get_f_measure(precision, recall);

end