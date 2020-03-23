OPT  = 0;
DRAW = 1;
DUAL = 0; 

load('sos_quartic_200.mat', 'N', 'model', 'model_split', 'out')
model.c = model.C;
model.At = model.A';
model = rmfield(model, {'A','C'});
if OPT


th = linspace(0,2*pi, N);



ind_star = 80;
theta_star = th(ind_star);


%% Split model
model_split.c =model_split.C;
model_split.At = model_split.A';
model_split = rmfield(model_split, 'C');
model_split = rmfield(model_split, 'A');

reg_0 = draw_feasibility(model_split, 'dd', th, DUAL);

x1 = reg_0.x{ind_star};
y1 = reg_0.y{ind_star};
[model_split_1, x_fake] = basis_change(x1, y1, model_split, DUAL);
reg_1 = draw_feasibility(model_split_1, 'dd', th, DUAL);

x2 = reg_1.x{ind_star};
y2 = reg_1.y{ind_star};
[model_split_2, x_fake] = basis_change(x2, y2, model_split_1, DUAL);
reg_2 = draw_feasibility(model_split_2, 'dd', th, DUAL);

x3 = reg_2.x{ind_star};
y3 = reg_2.y{ind_star};
[model_split_3, x_fake] = basis_change(x3, y3, model_split_2, DUAL);
reg_3 = draw_feasibility(model_split_3, 'dd', th, DUAL);

x4 = reg_3.x{ind_star};
y4 = reg_3.y{ind_star};


csplit = model_split.c'*[x1 x2 x3 x4];

%% Standard model
% model_split.c =model_split.C;
% model_split.At = model_split.A';
% model_split = rmfield(model_split, 'C');
% model_split = rmfield(model_split, 'A');

Sreg_0 = draw_feasibility(model, 'dd', th, DUAL);

sx1 = Sreg_0.x{ind_star};
sy1 = Sreg_0.y{ind_star};
[model_1, x_fake] = basis_change(sx1, sy1, model, DUAL);
Sreg_1 = draw_feasibility(model_1, 'dd', th, DUAL);

sx2 = Sreg_1.x{ind_star};
sy2 = Sreg_1.y{ind_star};
[model_2, x_fake] = basis_change(sx2, sy2, model_1, DUAL);
Sreg_2 = draw_feasibility(model_2, 'dd', th, DUAL);

sx3 = Sreg_2.x{ind_star};
sy3 = Sreg_2.y{ind_star};
[model_3, x_fake] = basis_change(sx3, sy3, model_2, DUAL);
Sreg_3 = draw_feasibility(model_3, 'dd', th, DUAL);

sx4 = Sreg_3.x{ind_star};
sy4 = Sreg_3.y{ind_star};

creg = model.c'*[sx1 sx2 sx3 sx4];

end

if DRAW
    C = linspecer(10);
    r = 0.8;
figure(1)
clf
hold on

if DUAL
    plot_region(reg_0, C(2, :)) 
    plot_region(reg_1, C(7, :))
    plot_region(out.psd, [0,0,0])   
else
    plot_region(out.psd, [0,0,0])
    plot_region(reg_0, C(2, :))
    plot_region(reg_1, C(7, :))
    plot_region(reg_2, C(8, :))
    plot_region(reg_3, C(1, :))
end
%h = quiver(0.5, 2.5, cos(theta_star)*0.8, sin(theta_star)*0.8, 'k', 'MaxHeadSize', 2, 'LineWidth', 2);
%h.Head.LineStyle = 'solid'; 
% headWidth = 8;
% headLength = 8;
%         ah = annotation('arrow',...
%             'headStyle','cback3','HeadLength',headLength,'HeadWidth',headWidth);
%         set(ah,'parent',gca);
%         set(ah,'position',[0, 2.5, cos(theta_star)*r, sin(theta_star)*r]);

A0 = [0, 2.5];
A1 = A0 + [cos(theta_star)*r, sin(theta_star)*r];
arrow(A0, A1, 'width', 2, 'Length', 40);
text(0., 2.5, '$\langle C, X \rangle$', 'Interpreter', 'latex', 'Fontsize', 50)

axis square
axis off
hold off

figure(2)
clf
hold on

if DUAL
    plot_region(Sreg_0, C(2, :)) 
    plot_region(Sreg_1, C(7, :))
    plot_region(out.psd, [0,0,0])   
else
    plot_region(out.psd, [0,0,0])
    plot_region(Sreg_0,[0.9047    0.1918    0.1988])
    plot_region(Sreg_1, C(7, :))
    plot_region(Sreg_2, C(8, :))
    plot_region(Sreg_3, C(1, :))
end

A0 = [0, 2.5];
A1 = A0 + [cos(theta_star)*r, sin(theta_star)*r];
arrow(A0, A1, 'width', 2, 'Length', 40);
text(0., 2.5, '$\langle C, X \rangle$', 'Interpreter', 'latex', 'Fontsize', 50)

axis square
axis off
hold off

end