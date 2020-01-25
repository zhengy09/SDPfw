
read_first = 'read(C:\\Users\\Jared\\Documents\\Matlab\\TSSOS\\src\\';
read_last = ')';

%read_name = 'LR8_1';
%read_name = 'LR120_trans_box_cons_3';
read_name = 'LR24_trans_box_cons_2';
read_file = strcat(read_first, read_name, '.task.gz', read_last);


read_out = strcat(read_name, '.mat');
[r, res_cons_trans] = mosekopt(read_file);

model_cons_trans = struct;
[model_cons_trans.A, model_cons_trans.b, model_cons_trans.c, model_cons_trans.K] = convert_mosek2sedumi(res_cons_trans.prob);

[F, obj] = sedumi2yalmip(model_cons_trans.A',model_cons_trans.b,model_cons_trans.c,model_cons_trans.K);

[Fd,objd,X,t,err] = dualize(F,obj,0);
[model_cons_trans_dual, ~] = export(Fd, objd, sdpsettings('solver','sedumi'));

save('LR_24.mat', 'model_cons_trans', 'res_cons_trans', 'model_cons_trans_dual')