function [ precision, recall, f_measure, misc ] = eval_boundaries( dataset, clusters )
%get_hits evaluate the segment boundaries for the specified song.

tol  = 3;
hits = 0;

for i= 1:length(dataset)
    a = str2num(dataset{i, 2});
    for j= 1:length(clusters)
        b(j,1)  = clusters{j,2};
        if (abs(a-b(j)) <= tol)
            diff_hits(hits+1) = abs(a - b(j));
            diff_all(i) = abs(a - b(j));
            matched(hits+1, :) = [dataset{i, 3}, clusters{j, 3}];
            hits = hits + 1;
        end
    end
    diff_all(i) = min(abs(ones(length(clusters), 1) * a - b(:))); 
end

% Store misc. statistics in the misc cell for further inspection later on.
misc.difference_hits  = diff_hits; % Zeit-differenz bei hits
misc.difference_all   = diff_all; % allg. kleinste Segmentgreznen-differenz zwischen Dataset und Analyse
misc.matched_segments = matched; % Überblick der Treffer-paare
misc.hits   = hits; % Anzahl der hits
misc.missed = length(dataset)  - hits; % Anzahl der fehlenden Segmentgrenzen
misc.failed = length(clusters) - hits; % Anzahl der falschen Segmentgrenzen

% Calculate main results.
precision = hits / length(clusters);
recall    = hits / length(dataset);
f_measure = get_f_measure(precision, recall);

end