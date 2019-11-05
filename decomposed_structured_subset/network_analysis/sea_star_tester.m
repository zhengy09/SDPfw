%Sea star topology

%One big clique in the middle 'head'
%N different 'tentacles', each composed of k 'knuckles'
%knuckles communicate with each other across t <=k nodes.
%% Stability Test: Generating data
rng(62, 'twister')

head = 40;      %size of central 'head'
knuckle = 10;    %size of each knuckle
t = 4;          %#links between head and first knuckle
t_k = 2;        %#links between subsequent knuckles
N = 6;          %#tentacles
k = 5;          %#knuckles per tentacle

N_state = head + knuckle*N*k;

Gw = sparse(N_state, N_state);

%head is dense
Gw(1:head, 1:head) = 1;

i_incr = head;
t_incr = 0;
for i = 1:N
    %head to knuckle
    k_ind = i_incr + (1:knuckle);
    t_ind = t_incr + (1:t);
    Gw(k_ind, k_ind) = 3;
    Gw(k_ind, t_ind) = 0.2;
    Gw(t_ind, k_ind) = 0.2;
    i_incr = i_incr + knuckle;
    t_incr = t_incr + t;
    
    %knuckle to knuckle
    for j = 1:(k-1)
        i_prev = i_incr + ((1-t_k):0);
        i_next = i_incr + (1:t_k);
        
        i_k = i_incr + (1:knuckle);
        Gw(i_k, i_k) = 3;
        Gw(i_prev, i_next) = 0.2;
        Gw(i_next, i_prev) = 0.2;
        
        i_incr = i_incr + knuckle;
    end
end

figure(1)
subplot(1,2,1)
spy(Gw)
title('Sea Star Interactions', 'fontsize', 18)
subplot(1,2,2)
plot(graph(Gw, 'omitselfloops'), 'layout', 'force', 'Iterations', 500)
axis square
title('Sea Star Visualization', 'fontsize', 18)


G = (Gw > 0);
Mc    = maximalCliques(G);
%generate system
N = N_state;
n     = randi(10,1,N);
m     = randi(5,1,N);
d     = randi(5,1,N);
Flag  = 2;
Sys   = GenerateDynamics(G,[],n,m,d,Flag);

%% Call Yalmip to solve the problem
epsilon = 0.01;
P = [];
for i = 1:N
    P = blkdiag(P,sdpvar(n(i)));
end

Constraint = [P - epsilon*eye(sum(n)) >= 0];
Constraint = [Constraint, Sys.globalA*P + P*Sys.globalA' + Sys.globalB*Sys.globalB' + epsilon*eye(sum(n)) <= 0];
Cost = trace(Sys.globalC*P*Sys.globalC');

% by SeDuMi
opts      = sdpsettings('verbose',1,'solver','sedumi');
[model,~,~,~] = export(Constraint,Cost,opts);

% A = model.A;
% b = model.b;
% c = model.C;
% K.f = model.K.f;K.l = model.K.l;K.q = model.K.q;K.s = model.K.s;


parCoLO.domain    = 1;  % dConvCliqueTree  ---> equalities 
parCoLO.range     = 2;   % rConvMatDecomp   ---> equalities 
parCoLO.EQorLMI   = 1; % CoLOtoEQform     ---> equality standard form
parCoLO.SDPsolver = []; % CoLOtoEQform     ---> equality standard form       
parCoLO.quiet     = 1; % Some peace and quiet       
J.f = length(model.b);

[~,~,~,cliqueDomain,cliqueRange,LOP] = sparseCoLO(model.A',model.b,model.C,model.K,J,parCoLO); 

figure(2)
SP = spones(spones(model.C) + sparse(sum(spones(model.A),2)));  % vector of 1s and 0s
mask1 = reshape(SP(1:model.K.s(1)^2), model.K.s(1), model.K.s(1));
mask2 = reshape(SP(model.K.s(1)^2 + (1:model.K.s(2)^2)), model.K.s(2), model.K.s(2));

subplot(1,2,1)
spy(mask1)
title('$P \geq \epsilon I$', 'interpreter', 'latex', 'Fontsize', 18)
subplot(1,2,2)
spy(mask2)
title('$A^T P + P A^T + B B^T \leq -\epsilon I$', 'interpreter', 'latex', 'Fontsize', 18)

figure(3)
plot(sort(LOP.K.s), '.', 'Markersize', 10)
title('Sea Star Clique Sizes', 'fontsize', 18)

save('sea_star.mat', 'model', 'LOP', 'Sys', 'G', 'n', 'm', 'd')

% [x, y, info] = sedumi(LOP.A, LOP.b, LOP.c, LOP.K);
% H2cost = sqrt(-LOP.c'*x);
% 
% Ks = LOP.K.s';
% 
% % [x0, y0, info0] = sedumi(A, b, c, K);
% % H2cost0 = sqrt(-c'*x0);
% 
% % solSeDuMi = optimize(Constraint,Cost,opts);
% % H2SeDuMi = sqrt(value(Cost));
% 
% % by SeDuMi+SparseCoLO
% % opts          = sdpsettings('verbose',1,'solver','sparsecolo','sparsecolo.domain',1,'sparsecolo.range',0,'sparsecolo.EQorLMI',1,'sparsecolo.SDPsolver','sedumi');
% % solSparseCoLO = optimize(Constraint,Cost,opts);
% % H2colo = sqrt(value(Cost));
