if ~exist('expno') || ~strcmp(expno, 'exp2') || ~exist('allconditions')
    expno = 'exp2';
    getstructuredmaps;
    allconditions = cell2mat(allconditions);
    unstructuredconditions = cell2mat(unstructuredconditions);
end;
% DISTGROUPCOND = 1, FUNCGROUPCOND=3, COLGROUPCOND=2;

allcorrect = zeros(1, length(allconditions));
for i=1:structuredmapsno
    labels = alllabels{i};
    smaps = structuredmaps{i};
    cass = allcassignments{i};
    coords = allcoords{i};
    
    if ~iscell(labels) && length(labels)>1
        labels = cellstr(labels);
    end;
    
    memberships = [];
    for j=1:size(coords,1)
        mapid = -1;
        for k=1:numel(smaps)
            submap = smaps{k};
            if ~isnumeric(submap)
                if ~iscell(submap) && length(submap)>1
                    submap = cellstr(submap);
                end;
                if iscell(submap)
                    for l=1:length(submap)
                        if findstr(labels{j}, submap{l})
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
        memberships = [memberships mapid];
    end;
    memberships(find(memberships~=1))=2;
    %memberships
    cass = cass + 1;
    memberships;

    % % exact match
    if sum(memberships == cass) == length(cass) || sum(memberships == 3-cass) == length(cass)
        allcorrect(i) = 1;
    else
        allcorrect(i) = 0;
    end;

    %memberships = randi(2, 1, 5); %!!!!!!!

%     % % at least one of the groups on the same submap
%     cmap1idx = find(cass==1)
%     cmap2idx = find(cass==2)
%     map1idx = find(memberships==1)
%     map2idx = find(memberships==2)
%     % isSubset = all(ismember(b, a)); % is b in a?
%     if all(ismember(map1idx, cmap1idx)) || all(ismember(map1idx, cmap2idx)) || all(ismember(map2idx, cmap1idx)) || all(ismember(map2idx, cmap2idx))
%         allcorrect(i) = 1;
%     else
%         allcorrect(i) = 0;
%     end;
end;

%dist
idx = find(allconditions==1);
disp(['distance clustered: ' num2str(sum(allcorrect(idx))) ' / ' num2str(length(idx))]);
%col
idx = find(allconditions==2);
disp(['color clustered: ' num2str(sum(allcorrect(idx))) ' / ' num2str(length(idx))]);
%func
idx = find(allconditions==3);
disp(['function clustered: ' num2str(sum(allcorrect(idx))) ' / ' num2str(length(idx))]);