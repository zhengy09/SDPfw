% head = 40;      %size of central 'head'
% knuckle = 10;    %size of each knuckle
% t = 4;          %#links between head and first knuckle
% t_k = 2;        %#links between subsequent knuckles
% N = 6;          %#tentacles
% k = 5;          %#knuckles per tentacle

load('sea_star.mat')
Ks = LOP.K.s';
cone = cell(length(Ks), 1);
% cone_thresh = 100;
%cone_alt = 40;
%cone_thresh = 120;
%cone_alt = 20;
cone_thresh = 0;
cone_alt = 'dd';
for i = 1:length(Ks)
    if Ks(i) <= cone_thresh
        cone{i} = 'psd';
    else
        cone{i} = cone_alt;
    end
end

[H2, res, time_solve, time_convert] = run_model(LOP, cone);

function  [H2, res, time_solve, time_convert] = run_model(model, cone)    
    tic
    [A, b, c, K, ~] = decomposed_subset(model.A,model.b,model.c,model.K, cone);
    %pars.fid = 0;
    %pars.fid = 1;    
    %[x, ~, info] = sedumi(A, b, c, K, pars);
    prob = sedumi2mosek(A', b, c, K);
    time_convert = toc;
    %[r,res] = mosekopt('minimize echo(0)',prob);
    tic;
    [r,res] = mosekopt('minimize',prob);
    time_solve = toc;
    cost = res.sol.itr.pobjval;
    H2 = sqrt(-cost);
    
end