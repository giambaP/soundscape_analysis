disp("----  single  -----");
tic
n = 100;
A = 100;
a = zeros(1,n);
for i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
toc

disp("----  parallel  -----");
tic
n = 100;
A = 100;
a = zeros(1,n);
parfor i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
toc