%ldata = loadjson(['logs/lognewC_39.txt']);
%d=ldata.exp5

if ~exist('doplot')
    doplot=1;
end;

if ~exist('expno') || ~exist('structuredmapsno') || ~strcmp(expno, 'exp5')
    %expno = 'exp3';
    expno = 'exp5';
    getstructuredmaps;
end;

%thetas = cell2mat(allthetas);
thetas = [];
j=1;
for i=1:size(allthetas, 2)
    if ~isempty(allthetas{i}) && length(allthetas{i}) == 4
        thetas(:, j) = allthetas{i};
        thetas(:, j) = abs(thetas(:, j) / thetas(1, j));
        j = j + 1;
    end;
    %thetas(:, i) = abs(thetas(:, i) / thetas(1, i));
end
%thetas=thetas(:, [1:12 14:16])
metatheta = mean(thetas')
metathetastd = std(thetas')


w = ceil(sqrt(structuredmapsno));

if doplot
    figure;
end;

wrong = 0;
iswrong = [];
wrongsubjects = [];

for i=1:structuredmapsno
    smaps = structuredmaps{i};
    colors = allcols{i};
    labels = alllabels{i};
    dp = 0;
    if i <= numel(allthetadatapoints)
        dp = allthetadatapoints(i);
    end;
    
    theta = allthetas{i};
    %theta = alljsthetas{i};
    
    if doplot
        figure(1);
        subplot(w, w, i);hold on;
        %figure(2);
        %subplot(w, w, i);hold on;  
    end;
    
    coords = allcoords{i};
    
    labels = alllabels{i};
    functions = zeros(1, length(labels));
    for j=1:length(labels)
        if findstr(labels{j}, 'shop')
            functions(j) = 1;
        end;
    end;
    
    %coords = allsketchmaps{i}; disp('sketchmap coord clustering');
    clustermap;
    
    clusterscorrect = 0;
    clustersincorrect = 0;
    memberships = [];
    for j=1:size(coords,1)
        mapid = -1;
        for k=1:numel(smaps)
            if iscell(smaps)
                submap = smaps{k};
            else
                submap = smaps(k, :);
            end;
            if ~isnumeric(submap)
                if iscell(submap) || (size(submap, 1) > 1 && size(submap, 2) > 1)
                    for l=1:length(submap)
                        if iscell(submap)
                            s = submap{l};
                        else
                            s = submap(l, :);
                        end;
                        if iscell(s)
                            s = s{1};
                        end;
                        if findstr(labels{j}, s)
                            mapid = k;
                            break;
                        end;
                    end;
                else
                    if findstr(labels{j}, submap)
                        mapid = k;
                        break;
                    end;
                end;
            end;
            if mapid >= 0
                break;
            end;
        end;
        if findstr(labels{j}, 'house')
            s='o';
        else
            s='s';
        end;
        c='b';
        if mapid == 1; 
            c='g'; 
        elseif mapid > 1; 
            mapid = 2;
            c='r'; 
        end;
        memberships = [memberships mapid];
        if mapid == cluster_memberships(j)
            clusterscorrect = clusterscorrect + 1;
        else
            clustersincorrect = clustersincorrect + 1;
        end;
        
        if doplot
            %coords = data2;
            scatter3(coords(j, 1), coords(j, 2), colors(j)/(256^3), 40, c, s, 'LineWidth', 3);

            text(coords(j, 1)-0.1, coords(j, 2), [num2str(j)]);
            text(coords(j, 1)+0.01, coords(j, 2), ['c' num2str(cluster_memberships(j))]);

            %text(coords(j, 1)-20, coords(j, 2), [num2str(j)]);
            %text(coords(j, 1)+2, coords(j, 2), ['c' num2str(cluster_memberships(j))]);

            %[col, fun] = meshgrid(0:0.02:1, 0:0.2:1);
            %surf(col, fun, (-theta(2)*col - theta(3)*fun - theta(4))/theta(1), 'EdgeColor', 'b');
        end;
    end;
    str = '';
    

    if clusterscorrect < 5 && clustersincorrect < 5
        str='wrong';
        wrong = wrong + 1;
        iswrong = [iswrong 1];
    else
        iswrong = [iswrong 0];
        str = 'ok';
    end;


% %         cmap1idx = find(cluster_memberships==1);
% %         cmap2idx = find(cluster_memberships==2);
% %         map1idx = find(memberships==1);
% %         map2idx = find(memberships==2);
% %         % isSubset = all(ismember(b, a)); % is b in a?
% %         if all(ismember(map1idx, cmap1idx)) || all(ismember(map1idx, cmap2idx)) || all(ismember(map2idx, cmap1idx)) || all(ismember(map2idx, cmap2idx))
% %             str = 'ok'
% %         else
% %             str='wrong';
% %             wrong = wrong + 1;
% %         end;

    
    if doplot
        if length(theta) > 2
            str = [str '; ' num2str(dp) '; d: ' num2str(round(theta(1)*10)/10) ' c: ' num2str(round(theta(2)*10)/10) ' f: ' num2str(round(theta(3)*10)/10)];
        end;
        title(str);
    end;
end;

disp(['wrong: ' num2str(wrong) '/' num2str(structuredmapsno) ' - ' num2str(wrong/structuredmapsno)])
disp('by subjects:');
allsubjectids(find(iswrong==1))

%title([t.mapstructure{1}(:)' '; ' t.mapstructure{2}(:)']');