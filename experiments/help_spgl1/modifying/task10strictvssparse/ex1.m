% if [Q,R] = qr(A',0);  A = Q';

%% addpath for PQN working
cd ../../../../functions;
addpath(genpath(pwd))
cd ../experiments/help_spgl1/modifying/task10strictvssparse

%% sample matrix
m = 120; n = 512; k = 20; % m rows, n cols, k nonzeros.
A  = randn(m,n); [Q,R] = qr(A',0);  A = Q';

opts.decTol = 1e-3;
opts.optTol = 1e-4;
opts.iterations = 100;
opts.nPrevVals = 1; % opt out the nonmonotone line search 
% 
% save temp A m n k opts
% clear;
% load temp

%% problem setting
% strict problem setting
p = randperm(n); x0 = zeros(n,1); x0(p(1:k)) = sign(randn(k,1));
h = figure;title('sparse signal')
plot(x0);
saveas(h,'sparse signal');
b0  = A*x0;

% compressible problem setting
nn = linspace(0,1,n);
x0_compress = exp(-nn.^.1);
x0_compress = x0_compress - min(x0_compress);
h = figure;title('compress signal')
plot(x0_compress)
saveas(h,'compress signal')
x0_compress = x0_compress(:);
b_compress  = A*x0_compress + 0.005 * randn(m,1);

%% reconstruct
tau = norm(x0,1);
% sparse
opts.fid = fopen('sparse_spg.txt','w');
[x_spg1,r_spgl,g_spgl,info_spg1] = spgl1(A, b0, tau, [], zeros(size(A,2),1), opts);
opts.fid = fopen('sparse_pqn.txt','w');
opts.optTol = info_spg1.rNorm;
[x_sparse,r_sparse,g_sparse,info_sparse] = pqnl1_2(A, b0, tau,[], zeros(size(A,2),1), opts); % Find BP sol'n.

h = figure;title('sparse resconstruct'); 
subplot(2,1,1);plot(x_spg1);title('spg');axis('tight')
subplot(2,1,2);plot(x_sparse);title('pqn');axis('tight')
saveas(h,'sparse resconstruct')

% compress
tau = norm(x0_compress,1);
opts.fid = fopen('compress_spg.txt','w');
[x_spg2,r_spg2,g_spg2,info_spg2] = spgl1(A, b_compress, tau,[], zeros(size(A,2),1), opts); % Find BP sol'n.
opts.fid = fopen('compress_pqn.txt','w');
opts.optTol = info_spg2.rNorm;
[x_compress,r_compress,g_compress,info_compress] = pqnl1_2(A, b_compress, tau, [], zeros(size(A,2),1), opts); % Find BP sol'n.

h = figure; title('compress resconstruct'); 
subplot(2,1,1);plot(x_spg2);title('spg');axis('tight')
subplot(2,1,2);plot(x_compress);title('pqn');axis('tight')
saveas(h,'compress resconstruct')


%% show result
info_sparse
info_spg1
info_compress
info_spg2

h = figure;title('strict sparse Solution paths')
plot(info_sparse.xNorm1,info_sparse.rNorm2,info_spg1.xNorm1,info_spg1.rNorm2);hold on
scatter(info_sparse.xNorm1,info_sparse.rNorm2);
scatter(info_spg1.xNorm1,info_spg1.rNorm2);hold off
legend('pqn','spg')
axis tight
saveas(h,'strict sparse Solution paths')

h = figure;title('compress signal Solution paths')
plot(info_compress.xNorm1,info_compress.rNorm2,info_spg2.xNorm1,info_spg2.rNorm2);hold on
scatter(info_compress.xNorm1,info_compress.rNorm2);
scatter(info_spg2.xNorm1,info_spg2.rNorm2);hold off
legend('pqn','spg')
axis tight
saveas(h,'compress signal Solution paths')



