%testing to make sure that the decomposed structured subset scheme works
rng(500, 'twister')

m = 80;
nBlk = 15;
BlkSize = 10;
ArrowHead = 10;


[model, model_split] = blockArrowSplit(m,nBlk,BlkSize,ArrowHead);


SP = spones(spones(model.c) + sparse(sum(spones(model.At),2)));  % vector of 1s and 0s
mask = reshape(SP, model.K.s, model.K.s);
%spy(mask)


%% SDP optimization


%now try the chordal decomposition
parCoLO.domain    = 1;  % dConvCliqueTree  ---> equalities 
parCoLO.range     = 2;   % rConvMatDecomp   ---> equalities 
parCoLO.EQorLMI   = 1; % CoLOtoEQform     ---> equality standard form
parCoLO.SDPsolver = []; % CoLOtoEQform     ---> equality standard form       
parCoLO.quiet     = 1; % Some peace and quiet       
J.f = length(model.b);

[~,~,~,cliqueDomain,cliqueRange,LOP] = sparseCoLO(model.At',model.b,model.c,model.K,J,parCoLO); 

mask_CoLO = sparse(size( mask, 1), size( mask, 2));
for i = 1:cliqueDomain{1,1}.NoC
    cli = cliqueDomain{1,1}.Set{i};
    mask_CoLO(cli, cli) = 1;
end
% 
figure(1)
hold on
spy(mask_CoLO , 'm');
spy(mask);
hold off
title('Block Arrow Sparsity + Fill-in', 'fontsize', 14)



LOP.At = LOP.A';


%cone_list = {'sdd', 5, 10, 'psd'};
%cone_list = {'dd', 'sdd', 2, 5, 10, 'psd'};
cone_list = {'psd'};
model_list = {model, LOP, model_split};
model_name = {'K', 'K(E_colo, ?)', 'K(E_sparse, ?)'};
Cost_Matrix = zeros(length(cone_list), length(model_list));
Time_Matrix = zeros(length(cone_list), length(model_list));
Info_Matrix = cell(length(cone_list), length(model_list));

for i = 1:length(cone_list) 
    for j = 1:length(model_list)            
        {model_name{j}, cone_list{i}}
        [cost, info, time] = run_model(model_list{j}, cone_list{i});
        Cost_Matrix(i, j) = cost;
        Info_Matrix{i, j} = info;
        Time_Matrix(i, j) = time;
    end 
end

%save('block_arrow.mat', 'model_list', 'cone_list', 'cliqueDomain', 'Cost_Matrix', 'Info_Matrix')

function  [cost, info, time] = run_model(model, cone)
    tic
    [A, b, c, K, ~] = decomposed_subset(model.At,model.b,model.c,model.K, cone);
    time = toc;
    pars.fid = 0;
    [x, ~, info] = sedumi(A, b, c, K, pars);
    cost = c'*x;
end