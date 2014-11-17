function [ error ] = getLooError( data, classes )
%GETLOOERROR Summary of this function goes here
%   Detailed explanation goes here

    N = size(data, 1);
    tdata = [data ones(N, 1)];

    allerrors = zeros(1, N);
    for i=1:N
        idx = find(1:N~=i);
        
        try
            theta = mnrfit(data(idx, :), classes(idx, :));
        catch ex
            ex
        end;
        
        %model=svm('-t 0');
        %model = model.train(data(idx, :), classes(idx, :));
        %theta = [];
        %if ~isempty(model.wrappedModel.rho) && ~isempty(model.wrappedModel.sv_coef) && ~isempty(model.wrappedModel.SVs)
        %    theta = [model.wrappedModel.rho model.wrappedModel.sv_coef'*model.wrappedModel.SVs]';
        %end;
        
        if length(theta) == 4
            theta = [theta(2:4) ; theta(1)];

            %options = optimset('Display', 'off', 'GradObj', 'on', 'maxIter', 1000);
            %initial_theta = zeros(4, 1);
            %[theta] = fmincg (@(t)(logregCostFunction(t, tdata(idx, :), classes(idx))), initial_theta, options)

            testclass = (tdata(i, :)*theta)<0;
            testclass = testclass + 1;
            c = classes(i);

            try
                allerrors(i) = testclass~=c;
            catch ex
                ex
            end;
        else
            allerrors(i) = 1;
        end;
    end;
    
    error = mean(allerrors);
end

