%%  test the usage of factorwitdth.m using sedumi

%clc;
clear; close all;
% Partition = [2:2:10];         % partition of blocks

Partition = [2,100];

file = 'SedumiDataEx10';
load(['SeDuMiData\', file '.mat']);

Tcon = zeros(length(Partition),1);
Time = zeros(length(Partition),1);
Cost = zeros(length(Partition),1);

x = zeros(length(c),length(Partition));
y = zeros(length(b),length(Partition));  % record original variables

for k = 1:length(Partition)
    opts.bfw  = 1;
    opts.nop  = Partition(k);
    opts.socp = 1;   % second-order cone constraints
    
    % reformulating the SDP
    Ts = tic;
    [Anew, bnew, cnew, Knew, infofw] = factorwidth(A,b,c,K,opts);
    Tcon(k) = toc(Ts);
    
    % solve the new SDP using sedumi
    Tsedumi    = tic;
    [xn,yn,info] = sedumi(Anew,bnew,cnew,Knew);
    Time(k)    = info.cpusec;
    Cost(k)    = cnew'*xn;

    % variables corresponds to the original SDP data, A, b, c, K
    %y(:,k) = yn;
    %x(:,k) = accumarray(infofw.Ech,xn);
end

figure
plot(Partition, Time,'*','markersize',10);hold on; plot(Partition, Time,'b','linewidth',1.2);
xlabel('Number of partition','interpreter','latex')
ylabel('Solver time consumption (s)','interpreter','latex')

