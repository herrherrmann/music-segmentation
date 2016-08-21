function [ f_measure ] = get_f_measure( precision, recall )
%get_f_measure Calculate the f_measure out of specified precision and
%recall. Will be 0 if precision and recall are 0.

if (precision + recall) > 0
    f_measure = 2 * (precision * recall / (precision + recall));
else 
    f_measure = 0;
end

end

