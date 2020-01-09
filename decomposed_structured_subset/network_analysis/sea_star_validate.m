load('sea_star_Hinf_med.mat')

%gamma = [    2.4331    1.6710    0.2955    0.9732];
%gamma_med = [5.9351    2.7972    1.4517    0.0974    0.9592];

epsilon = 0.01;
P = [];
N = length(Sys.A);
for i = 1:N
    P = blkdiag(P,sdpvar(n(i)));
end


i = 4;
%gamma = gamma_med(i);
gamma = Hinf;
Constraint1 = [P - epsilon*eye(sum(n)) >= 0];
Constraint2 = [[P*Sys.globalA+Sys.globalA'*P, P*Sys.globalB, Sys.globalC'; 
                           Sys.globalB'*P, -gamma*eye(sum(m)), Sys.globalD';
                           Sys.globalC, Sys.globalD, -gamma*eye(sum(d))] + epsilon*eye(sum(n)+sum(m)+sum(d)) <= 0];
Constraint = [Constraint1, Constraint2];
Cost = 0;

opts          = sdpsettings('verbose',1,'solver','sparsecolo','sparsecolo.domain',1,'sparsecolo.range',0,'sparsecolo.EQorLMI',1,'sparsecolo.SDPsolver','sedumi');
solSparseCoLO = optimize(Constraint,Cost,opts);
%H2colo = sqrt(value(Cost));
PV = value(P);
check(Constraint)

plot(log10(eig(PV)))