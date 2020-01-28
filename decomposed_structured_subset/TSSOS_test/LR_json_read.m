%fname = 'LR12_trans_box.json';
%fname = 'LR120_trans_box.json';
%fname = 'LR120_uncons_3.json';
fname = 'LR120_cons_1.json';

%This is the golden file.
%Protect it at all costs
%fname = 'LR120_cons_3.json';
%fname = 'LR120_uncons_3.json';

data = jsondecode(fileread(fname));

disp("Read JSON")

N = data.n;

%N_f = length(data.fbasis)/N;
fbasis = sparse(reshape(data.fbasis, N, []));
gbasis = cell(N, 1);
for i = 1:N
    gb_curr = data.gbasis(i, :);
    gbasis{i} = sparse(reshape(gb_curr, N, []));
end


fblocks = data.fblocks;
gblocks = data.gblocks;
% 
% %formulas 22 and 23 in the TSSOS paper in order to get the Psatz in YALMIP
% %each block in fblocks indexes into the support set in fbasis
% %likewise for gblocks
% 
% 
 x = sdpvar(N, 1);
 lower = sdpvar(1);
%gb = mon_basis(x, gbasis{1})
%fb = mon_basis(x, fbasis);

%start with the Psatz expression
%f_ref = f - lower;

f_psatz = 0;
%F = [];
%s = [];
%c = [];
Q = [];
F = [];
% 
disp("Starting with f")
suppf = reshape(data.ssupp{1}, N, []);
f_basis = mon_basis(x, suppf);
coef  = data.coe{1};
f = coef'*f_basis;

f_ref = f - lower;

%unconstrained terms
for i = 1:length(fblocks)
    if mod(i, 100)==0
        disp(strcat("starting f", num2str(i)))
    end
    x_basis = mon_basis(x, fbasis(:, fblocks{i}));
    Qi = sdpvar(length(x_basis));
    F = [F; Qi >= 0];    
    pi = x_basis'*Qi*x_basis;
    f_psatz = f_psatz + pi;
    
    %[si,ci] = polynomial(x_basis,2);
    %s = [s; si];
    %c = [c; ci];
    %F = [F; sos(si)];
end

disp("finished with f")

%constrained terms
for j = 1:length(gblocks)
    gbasis_curr = gbasis{j};
    gblocks_curr = gblocks{j};
    pgj = 0;
    
    suppj = reshape(data.ssupp{j+1}, N, []);
    coej  = data.coe{j+1};
    g_basis = mon_basis(x, suppj);
    gj = coej'*g_basis;
    disp(strcat("starting g", num2str(j)))
    
    for i = 1:length(gblocks_curr)
        x_basis = mon_basis(x, gbasis_curr(:, gblocks_curr{i}));
        Qi = sdpvar(length(x_basis));
        F = [F; Qi >= 0];    
        pi = x_basis'*Qi*x_basis;
        %accumulated constrained multiplier
        pgj = pgj + pi;
        %f_psatz = f_psatz + pi;
    end
    
    f_psatz = f_psatz + pgj * gj;
end

disp("About to take Coefficients")
[cp] = coefficients(f_ref - f_psatz, x);
%F_lmi = F;
F = [F; cp == 0];


obj = -lower;

opts = sdpsettings('solver', 'mosek', 'savedebug', 1, 'savesolverinput', 1);
disp("Ready to Optimize")
diagnostics = optimize(F, obj, opts);
disp("Done Optimizing")
model = diagnostics.solverinput;
save("LR120_cons_trans_mosek_input.mat", "model")
%[model, recoverymodel] = export(F, obj, opts);
%optimize(F, obj, opts);
%[~,name, ~] = fileparts(fname);
%outname = strcat(name, "_sos.mat");
%save(outname, "model", "data")


