%load('sea_star_H2_small.mat')
%load('sea_star_Hinf0_small.mat')
%load('sea_star_Hinf0_medium.mat')

%fname = 'sea_star_H2_tiny';
%fname = 'sea_star_Hinf0_tiny';
%fname = 'sea_star_H2_small';
%fname = 'sea_star_Hinf0_medium';
%fname = 'sea_star_Hinf0_large';
%name = 'sea_star_Hinf0_verylarge';
%fname = 'sea_star_Hinf0_giant';
%fname = 'sea_star_Hinf0_wide_small';
fname = 'sea_star_Hinf0_wide_med';

%outname = strcat(filepath,'output_ifac_',name,ext);
outname = strcat(fname, '//output_ifac.mat');
load(strcat(fname, '//sea_star.mat'), 'model');


%running options
RUN_PSD = 0;
PRIMAL = 1;
DUAL = 1;
DRAW = 0;

if DRAW
    figure(1)
    clf
    hold on
    [N_h,edges] = histcounts(model.K.s, 'BinMethod','integers');
    edges = edges+0.5;
     yl = [0, max(N_h)];
     plot([11,11], yl,'k--')
     plot([60,60],  yl, 'k-.')
     plot([100,100], yl, 'k-')

    stem(edges([N_h 0] ~= 0), N_h(N_h ~= 0), '.', 'MarkerSize', 30)
    title(strcat('Sea Star LMI Clique Sizes $(p=', num2str(length(model.K.s)),')$'),'fontsize', 14, 'Interpreter', 'latex')


     legend({'Size 11', 'Size 60', 'Size 100','Cliques'},...
        'location', 'northeast')
    %legend({'Cliques'}, 'location', 'northeast', 'fontsize', 12)
    %hold off
    xlabel('Size of Clique')
    ylabel('Number of Cliques')
    %keyboard
end

%medium
%thresh = [0, 11, 35, 100];
%cones = {'dd', 1, 3, 5, 9, 18, 36};



%thresh = [0,11];
%cones = {'dd', 2, 4, 6};
%thresh = [0];
%cones =  {'dd'};
%large

thresh = [0, 11, 60, 100];
%thresh = [100];
%thresh = [0, 5, 11];
%thresh = [0, 11, 40];
%thresh = [0, 11, 41, 63];

%cones = {'dd', 1, 5, 7, 15, 30, 50};
%cones = {'dd', 1, 3, 5, 8, 15, 30, 55, 70};
cones = {'dd', 1, 3, 5, 8, 15, 30, 55};
%cones = {1, 3, 5, 8, 15, 30, 55, 70};
%cones = {73};
%cones = {'dd'};
%cones = {};
%cones = {'dd', 'sdd', 3, 6, 12, 18, Inf};
%cones = {'dd', 2, 4, 6};
%cones = {1,2,3,4,5, 6};
%cones = {1,2, 4, 5, 8, 10};
%thresh = [0, 22, 50, Inf];
%thresh = [0, 11, 35, Inf];
%thresh = [0, 11, 30, 50,  Inf];
%thresh = [0, 11, 33,  56,  Inf];
%thresh = [0, 11, 33,  56];

Ncones = length(cones);
Nthresh = length(thresh);

use_mosek = 1;
QUIET = 0;

output = NaN*ones(Ncones, Nthresh);

Ks = model.K.s;

CONE = cell(Ncones, Nthresh);




cone = cell(length(Ks), 1);
if exist(outname, 'file')    
    %save(outname,'-append', 'cones', 'thresh');
    load(outname)
else
    save(outname,'cones', 'thresh');
    for i = 1:Ncones
        for j = 1:Nthresh
            cl = cone_list(Ks, thresh(j), cones{i});
            CONE{i,j} = struct;
            CONE{i,j}.cone = cl;
        end
    end

end

%RES  = cell(Ncones, Nthresh);
%CONE_dual = cell(Ncones, Nthresh);
%RES_dual = cell(Ncones, Nthresh);
CONE_dual = CONE;

if PRIMAL
for i = 1:Ncones
%for i = 8:Ncones
    for j = 1:Nthresh

        %upper bound
        [CONE{i,j}.Hout,~, CONE{i,j}.time_solve, CONE{i,j}.time_convert, CONE{i,j}.sdp_opt]...
            = run_model_star(model, CONE{i,j}.cone, 0, use_mosek, QUIET);              

        fprintf('Cone: %s \t Thresh:  %d \t Hinf upper: %0.3f \t \t Time Solve: %0.1f \t Time Convert: %0.1f \t  Optimal: %d\n', ...
            num2str(cones{i}), thresh (j), CONE{i,j}.Hout, CONE{i,j}.time_solve, CONE{i,j}.time_convert, CONE{i,j}.sdp_opt)
        save(outname,  '-append',  'CONE');
    end
end

end

if DUAL
    for i = 1:Ncones
        for j = 1:Nthresh
            %lower bound?
            [CONE_dual{i,j}.Hout, ~, CONE_dual{i,j}.time_solve, CONE_dual{i,j}.time_convert, CONE_dual{i,j}.sdp_opt]...
                = run_model_star(model, CONE_dual{i,j}.cone, 1, use_mosek, QUIET);

            fprintf('Cone: %s \t Thresh:  %d \t Hinf lower: %0.3f \t \t Time Solve: %0.1f \t Time Convert: %0.1f \t Optimal: %d\n', ...
            num2str(cones{i}), thresh (j), CONE_dual{i,j}.Hout, CONE_dual{i,j}.time_solve, CONE_dual{i,j}.time_convert, CONE_dual{i,j}.sdp_opt)
            save(outname,  '-append', 'CONE_dual');
        end
    end
end

RESULTS = struct;
if PRIMAL || DUAL
%     csvwrite(strcat(fname, '//thresh.csv'), thresh);
%     csvwrite(strcat(fname, '//cone.csv'), cones);
    RESULTS.thresh = thresh;
    RESULTS.cones = cones;
end


if PRIMAL
    cost_primal = cellfun(@(x) x.Hout, CONE);
    time_primal= cellfun(@(x) x.time_solve + x.time_convert, CONE);
    sdp_opt_primal = cellfun(@(x) x.sdp_opt, CONE);
    RESULTS.cost_primal = cost_primal;
    RESULTS.time_primal = time_primal;
    RESULTS.sdp_opt_primal = sdp_opt_primal;
    %csvwrite(strcat(fname, '//cost_primal.csv'), cost);
    %csvwrite(strcat(fname, '//time_primal.csv'), cost);
    save(outname, '-append', 'cost_primal', 'time_primal', 'sdp_opt_primal')
end

if DUAL
    cost_dual = cellfun(@(x) x.Hout, CONE_dual);
    time_dual = cellfun(@(x) x.time_solve + x.time_convert, CONE_dual);
    sdp_opt_dual = cellfun(@(x) x.sdp_opt, CONE_dual);
    RESULTS.cost_dual = cost_dual;
    RESULTS.time_dual = time_dual;
    RESULTS.sdp_opt_dual = sdp_opt_dual;
    %csvwrite(strcat(fname, '//cost_dual.csv'), cost_dual);
    %csvwrite(strcat(fname, '//time_dual.csv'), time_dual);
    save(outname, '-append', 'cost_dual', 'time_dual', 'sdp_opt_dual')
end

if RUN_PSD
    [CONE0.Hout, RES0, CONE0.time_solve, CONE0.time_convert, CONE0.sdp_opt]...
            = run_model_star(model, 'psd', use_mosek);
    fprintf('Cone: PSD \t Thresh: N\\A \t Hinf: %3f\t \t Time Solve: %0.1f \t Time Convert: %0.1f\n', ...
        CONE0.Hout,CONE0.time_solve, CONE0.time_convert )
    save(outname, '-append', 'CONE0')
    cost_psd = CONE0.Hout;
    time_psd = CONE0.time_solve + CONE0.time_convert;
    %csvwrite(strcat(fname, '//cost_psd.csv'), cost_psd);
    %csvwrite(strcat(fname, '//time_psd.csv'), time_psd);
    RESULTS.cost_psd = cost_psd;
    RESULTS.time_psd = time_psd;
end

%write the results to file
rjson = jsonencode(RESULTS, 'ConvertInfAndNaN', false);
fid = fopen(strcat(fname, '//sea_star_results.json'), 'w');
fwrite(fid, rjson, 'char');
fclose(fid);
