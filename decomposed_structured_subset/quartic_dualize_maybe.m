x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);

lower = sdpvar(1);
obj = -lower;

f = 1 + x1^4 + x2^4 + x3^4 + x1*x2*x3 + x2;

F = sos(f - lower);

opts_csp = sdpsettings('solver','sedumi', 'verbose', 0);
opts_csp.sos.csp = 1;
opts_csp.sos.model = 2;

[F_m, obj_m, monomials] = sosmodel(F, obj, opts_csp, [lower]);
[model_csp, recoverymodel_csp] = export(F_m, obj_m, opts_csp);

%dualize the CSP program
[Fd,objd,X,t,err] = dualize(F_m,obj_m,0);
[model_dual, ~] = export(Fd, objd, opts_csp);

optimize(F_m, obj_m, opts_csp);
cost_m_out = value(obj_m);

%CSP
[x_csp, y_csp, info_csp] = sedumi(model_csp.A', model_csp.b, model_csp.C, model_csp.K);
cost_csp = -model_csp.C'*x_csp;

%Dualized
[x_dual, y_dual, info_dual] = sedumi(-model_dual.A, model_dual.b,model_dual.C,  model_dual.K);
cost_dual = model_dual.C'*x_dual;

%[r, res] = mosekopt('minimize', model_csp.prob);
%[rd, resd] = mosekopt('maximize', model_dual.prob);



% opts_mom = sdpsettings('solver', 'moment', 'moment.order', 2);
% [model_mom, recoverymodel_mom] = export([f-lower>=0, x1^2 + x2^2 + x3^2 <= 1000, lower^2 <= 10000], obj, opts_mom);

%[model_mom, recoverymodel_mom] = export([f-lower>=0], obj, opts_mom);
% [sol,x_extract,momentsstructure,sosout,Fnew,obj2] = ...
%     solvemoment([f-lower>=0, x1^2 + x2^2 + x3^2 <= 1000, lower^2 <= 10000], obj, [], 5);
%obj2 = value(obj);


% solvemoment([f-lower>=0, x1^2 + x2^2 + x3^2 <= 100, lower^2 <= 1000], obj, [], 3);
% obj3 = value(obj)
% solvemoment([f-lower>=0, x1^2 + x2^2 + x3^2 <= 100, lower^2 <= 1000], obj, [], 4);
% obj4 = value(obj)
% solvemoment([f-lower>=0, x1^2 + x2^2 + x3^2 <= 100, lower^2 <= 1000], obj, [], 5);
% obj5 = value(obj)
%F_POP = [f-lower >=0, norm(x, 2)^2 <= 1e3];
