%LR test 
%CSP
sos= 0;
if sos
    load('LR_120_sos.mat', 'model_dual')
    outname = 'LR120_output_uncons_sos_dual_aug.mat';
    thresh = [0, 100];
    %cones = {'dd', 'sdd', 2, 3, 5, 11, 21, 40, 'psd'};
    cones = {8, 14, 17};
    %model = model_csp;
    %model.c = -model.C;
    model_dual.c = -model_dual.C;
    support_LR(model_dual, outname, cones, thresh);

else
    load('LR_120.mat', 'model_c')
    %load('LR120_box_1_2.mat', 'model_cons_trans')
    %load('LR_24.mat', 'model_cons_trans')
    %cones = {'dd', 'sdd', 2, 3, 5, 6, 11, 20, 30, 40, 'psd'};
    %cones = {'dd', 'sdd', 2, 3, 5, 6, 10, 15, 20, 'psd'};
    %cones = {'dd', 20, 'psd'};
    cones = {'dd'};
    %thresh = [0 ,10, 20];
    thresh = [0, 4, 12, 45, 100];
    %thresh = [0, 100];
    %thresh = [100];
    %model_dual_unc.c = model_dual_unc.C;
    
%     outname_unc = 'LR120_output_uncons.mat';
%     support_LR(model_unc, outname_unc, cones, thresh);
    model = model_cons_trans;
    %it just gives values of zero. i don't know why, is that actually the
    %optimum?
    %model.c = -model.c;
    
    outname_c = 'LR120_tester_1_2.mat';
    %outname_c = 'LR120_output_uncons_dual_TSSOS.mat';
    support_LR(model, outname_c, cones, thresh);

end



%cones = {20};

%thresh = 100;

% figure(1)
% hold on
% model_unc = model_dual_unc;
% [N_h_unc,edges_unc] = histcounts(model_unc.K.s, 'BinMethod','integers');
%  yl_unc = [0, max(N_h_unc)];
%  %plot([11,11], yl_unc,'k--')
%  plot([100,100], yl_unc, 'k-')
%  
%  stem([1, edges_unc([N_h_unc 0] ~= 0)+0.5], [model_unc.K.l, N_h_unc(N_h_unc ~= 0)], '.', 'MarkerSize', 40)
%  title('Unconstrained CSP clique sizes', 'FontSize', 18, 'Interpreter', 'latex')
%  hold off
% xlabel('Size of Clique')
% ylabel('Number of Cliques')

function support_LR(model, outname, cones, thresh)
    Ncones = length(cones);
    Nthresh = length(thresh);

    CONE = cell(Ncones, Nthresh);
    RES  = cell(Ncones, Nthresh);

    for i = 1:Ncones
        for j = 1:Nthresh
            CONE{i,j} = struct;
            CONE{i,j}.cone = cone_list(model.K.s, thresh(j), cones{i});
        end
    end

    use_mosek = 1;

    cost = NaN*ones(Ncones, Nthresh);

    for i = 1:Ncones
        for j = 1:Nthresh
            fname = strcat(outname(1:end-4), '_', num2str(cones{i}), '_', num2str(thresh(j)), '.txt');
            [CONE{i,j}.cost, RES{i,j}, CONE{i,j}.time_solve, CONE{i,j}.time_convert]...
                = run_model_LR(model, CONE{i,j}.cone, use_mosek, fname);              

            cost(i, j) = CONE{i,j}.cost;
                  %output
                 %{cones{i}, thresh(j), output(i,j)}
             fprintf('Cone: %s \t Thresh:  %d \t Cost: %0.3f \t \t Time Solve: %0.1f \t Time Convert: %0.1f\n', ...
                 num2str(cones{i}), thresh (j), cost(i,j), CONE{i,j}.time_solve, CONE{i,j}.time_convert)
    %         else
    %             CONE{i,j}.Hout = NaN;        
    %         end
    save(outname, 'CONE', 'cones', 'thresh')
        end
    end
end
% 
% CONE0 = struct;
% RES0 = struct;
% 
% [CONE0.Hout, RES0, CONE0.time_solve, CONE0.time_convert]...
%             = run_model_star(model, 'psd', use_mosek);
% fprintf('Cone: PSD \t Hinf: %3f\n', CONE0.Hout)
% save(outname, 'CONE', 'CONE0', 'cones', 'thresh')

