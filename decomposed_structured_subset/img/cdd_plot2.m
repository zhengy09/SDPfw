%Plots of (decomposed) structured subsets

N = 150;
%rng(2019,'twister')
rng(200,'twister')
%rng(402, 'twister')

%Diagonal

D = [1 0 0;
     0 1 0;
     0 0 1;
     0 0 0;
     0 0 0];

%Diagonally Dominant 
 
DD_aug = [1  1 0  0;
      1  1 1  1;
      0  0 1  1;
      1 -1 0  0;
      0  0 1  -1]/2;

DD = [D DD_aug];  
  
  
CDD_aug = [1   1  1  1;
           1   1  1  1;
           1   1  1  1;
           1   1 -1 -1;
           1  -1  1 -1]/2;

CDD = [DD CDD_aug];   

%SDD
psi = linspace(0, 2*pi, 4*N);
x = cos(psi)';
y = sin(psi)';
zz = zeros(size(x));
SDD  = [x.*x, y.*y,   zz,  x.*y,  zz;
        x.*x, y.*y,   zz, -x.*y,  zz;
        zz,   y.*y, x.*x,    zz,  x.*y;
        zz,   y.*y, x.*x,    zz, -x.*y]';
    
CSDD_aug = [x.*x, y.*y, x.*x,  x.*y,  x.*y;
        x.*x, y.*y, x.*x,  x.*y, -x.*y;
        x.*x, y.*y, x.*x, -x.*y,  x.*y;
        x.*x, y.*y, x.*x, -x.*y, -x.*y]';

CSDD = [SDD CSDD_aug];    


%PSD
R = 1;
theta = linspace(0, 2*pi, N);
%z = linspace(-1, 1, N)';
%X = reshape(sqrt(R^2 - z.^2) * cos(theta), [], 1);
%Y = reshape(sqrt(R^2 - z.^2) * sin(theta), [], 1);
%Z = repmat(z, N, 1);

phi = linspace(-pi, pi, N);
Xr = cos(phi)'*cos(theta);
X = reshape(Xr, [], 1);
Yr = cos(phi)'*sin(theta);
Y = reshape(Yr, [], 1);
Z = repmat(sin(phi)', N, 1);

PSD = [X.*X, Y.*Y,  Z.*Z,  X.*Y,  Y.*Z]';

%Find affine subspace through I
I = [1; 1; 1; 0; 0];

%A = randn(5, 2);
%A0 = abs(randn(5, 1));
%b0 = A0'*I;

A = randn(5, 3);
b = A'*I;


%intersection of points in cone with affine subspace
% D_proj0    = D.*b0./(A0'*D);
% DD_proj0   = DD.*b0./(A0'*DD);
% CDD_proj0  = CDD.*b0./(A0'*CDD);
% SDD_proj0  = SDD.*b0./(A0'*SDD);
% CSDD_proj0 = CSDD.*b0./(A0'*CSDD);
% PSD_proj0  = PSD.*b0./(A0'*PSD);




%project onto subspace

D_proj = K'*( D - I);
DD_proj  = K'*( DD - I);
CDD_proj = K'*( CDD - I);
PSD_proj = K'*( PSD - I);
SDD_proj = K'*( SDD - I);
CSDD_proj = K'*( CSDD - I);
I_proj = K'*( I - I);


% take 2
D_proj = K'*( D - I);
DD_proj  = K'*( DD - I);
CDD_proj = K'*( CDD - I);
PSD_proj = K'*( PSD - I);
SDD_proj = K'*( SDD - I);
CSDD_proj = K'*( CSDD - I);
I_proj = K'*( I - I);


% A = [0 0;
%      0 0;
%      1 0;
%      0 1;
%      0 0];
% D_proj = A\D_proj0;
% DD_proj  = A\DD_proj0;
% CDD_proj = A\CDD_proj0;
% PSD_proj = A\PSD_proj0;
% SDD_proj = A\SDD_proj0;
% CSDD_proj = A\CSDD_proj0;
% I_proj = A\I;


% D_proj = A\D;
% DD_proj  = A\DD;
% CDD_proj = A\CDD;
% PSD_proj = A\PSD;
% SDD_proj = A\SDD;
% CSDD_proj = A\CSDD;

%convex hulls
kD =  convhull(D_proj(1, :),    D_proj(2, :));
kDD =  convhull(DD_proj(1, :),    DD_proj(2, :));
kCDD  = convhull(CDD_proj(1, :),  CDD_proj(2, :));
kPSD  = convhull(PSD_proj(1, :),  PSD_proj(2, :));
kSDD  = convhull(SDD_proj(1, :),  SDD_proj(2, :));
kCSDD = convhull(CSDD_proj(1, :), CSDD_proj(2, :));

%plot
C = linspecer(5);
figure(1)
clf
hold on

%scatter(PSD_proj(1, :), PSD_proj(2, :),'.k')
%plot(D_proj(1, kD), D_proj(2, kD),'color', C(5, :), 'linewidth', 2)
plot(DD_proj(1, kDD), DD_proj(2, kDD),'color', C(1, :), 'linewidth', 2)
%plot(CDD_proj(1, kCDD), CDD_proj(2, kCDD),'color', C(2, :),'linewidth', 2)
%plot(SDD_proj(1, kSDD), SDD_proj(2, kSDD),'color', C(3, :), 'linewidth', 2)
%plot(CSDD_proj(1, kCSDD), CSDD_proj(2, kCSDD),'color', C(4, :), 'linewidth', 2)
plot(PSD_proj(1, kPSD), PSD_proj(2, kPSD),'k', 'linewidth', 2)
text(I_proj(1), I_proj(2), 'I', 'interpreter', 'latex', 'Fontsize', 20)
%plot(2*PSD_proj(1, kPSD), 2*PSD_proj(2, kPSD),':k')

%scatter(DD_proj(1, :),DD_proj(2, :), 'b')
%scatter(CDD_proj(1, :),CDD_proj(2, :), 'r')
legend({'D', 'DD', 'DD(E, ?)', 'SDD', 'SDD(E, ?)', 'S_+'}, 'location', 'northwest', 'fontsize', 15)
%title('Random affine cut of structured subsets', 'Fontsize', 16)
hold off
axis square
axis off
