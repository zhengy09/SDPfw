lower = sdpvar(1,1);
rng( 40, 'twister');
%N = 64;
%N = 72;
%N = 120;
%N = 36;
N = 6;
b = floor(N/6);
CONSTRAINED = 1;

x = sdpvar(N, 1);

%f_R  = sum(100*(x(2:end ) - x(1:end-1) .^2).^2 +  (1 -x(1:end-1 )).^2);

xi = x(1:end-3);
xi1 = x(2:end-2);
xi2 = x(3:end-1);
xi3 = x(4:end);
f_R = sum(10*((xi2 + 2*xi1 - xi.^2).^2 + (1-xi -xi3).^2));

%mBasis = monolist(x(1:b),2);
%Q = rand(length(mBasis));

%Q = hadamard(
%c = rand(length(mBasis) ,1);
%Q = Q*Q';
%f_Q = (Q'*mBasis).^2  + c'*mBasis;
%f_Q = (Q'*mBasis).^2 ;
mBasis = x(1:b);
Q_P = gallery('lehmer', length(mBasis));
f_Q = mBasis' *Q_P * mBasis;
%f_Q = 0;
f = f_R + f_Q;
 

if CONSTRAINED  
    d_cons = 2;
    F_psatz = f - lower;
    %g = [1 + x; 1 - x];
    %g = [1 - sum(x(1:3).^2), 1 - sum(x(4:6).^2)];
    g = (1+x).*(1-x);
    F = [];    
    s = zeros(size(g));
    %c = cell(size(g));
    c = [];
    for i = 1:length(g)
        [si, ci] = polynomial(x, d_cons);
        F = [F; sos(si)];
        F_psatz = F_psatz - si*g(i);
        s(i) = si;
        c = [c; ci];
    end
    F = [sos(F_psatz), F];
else
    F = sos(f - lower);
    c = [];
end
obj =  -lower;

opts_csp = sdpsettings('solver','SEDUMI');
%[model, recoverymodel] = export(F , obj, opts);

%opts_csp = opts;
opts_csp.sos.csp = 1;
%[model_csp, recoverymodel_csp] = export(F, obj, opts_csp, [lower; c]);
%[model_csp, recoverymodel_csp] = export(F, obj, opts_csp);

[F_m, obj_m, monomials] = sosmodel(F, obj, opts_csp, [lower; c]);
[model_csp, recoverymodel_csp] = export(F_m, obj_m, opts_csp);
%[x_csp, y_csp, info_csp] = sedumi(model_csp.A', model_csp.b, model_csp.C, model_csp.K);
%cost_csp = model_csp.C'*x_csp;
Ks = model_csp.K.s';
mKs = max(model_csp.K.s);
%save('polynomial_big_clique.mat', 'N', 'b', 'model_csp')