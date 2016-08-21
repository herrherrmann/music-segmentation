function [ dataset_abc ] = get_dataset_abc( dataset )
%get_dataset_abc Retrieves ABC labels for dataset segments.

% Copy dataset, its third column will later be overridden.
dataset_abc = dataset;
% Start with capital character A
t = 65;
n =  1;
l = length(dataset(:,3));
[~, cluster_database_num] = ismember(dataset(:,3), dataset(:,3));

for m = 1:l
    a = find(cluster_database_num == cluster_database_num(m));
    if (length(a) > 1 && m == min(a))
        for k = 1:length(a)
            cluster_database_ABC(a(k)) = char(t);
        end
        t = t + 1;
    elseif m == min(a)
        cluster_database_ABC(a) = char(t);
        t = t + 1;
%             b(n)=a; % Vektor mit Stellen einzelner Segmente-> Intro/Outro/too many novelty Bereinigung
        n = n + 1;
    end
    dataset_abc{m, 3} = char(cluster_database_ABC(m));
end

end