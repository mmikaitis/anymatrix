function [A,properties] = gfpp(T,c)
%GFPP   Matrix giving maximal growth for Gaussian elim. with pivoting.
%   GFPP(N) is Wilkinson's example of a matrix for which Gaussian
%   elimination with partial pivoting yields a growth factor 2^(N-1).
%   GFPP(T), where T is an arbitrary nonsingular upper triangular matrix of
%   order N-1, has the same grwoth factor.
%   GFPP(T,C) sets all the multipliers to C (0 <= C <= 1)
%   and gives growth factor (1+C)^(N-1). But note that for T ~= EYE
%   it is advisable to set C < 1, else rounding errors may cause
%   computed growth factors smaller than expected.

%   Reference:
%   N. J. Higham and D. J. Higham, Large growth factors in
%      Gaussian elimination with pivoting, SIAM J. Matrix Analysis and
%      Appl., 10 (1989), pp. 155-164.
%   N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%     Second edition, Society for Industrial and Applied Mathematics,
%     Philadelphia, PA, 2002; sec. 9.4.

properties = {'parameter-dependent'};
if nargin == 0, A = []; return, end

if ~isequal(T,triu(T)) || any(~diag(T))
   error('First argument must be a nonsingular upper triangular matrix.')
end

if nargin == 1, c = 1; end

if c < 0 || c > 1
   error('Second parameter must be a scalar between 0 and 1 inclusive.')
end

m = length(T);
if m == 1    % Handle the special case T = scalar
   n = T;
   m = n-1;
   T = eye(n-1);
else
   n = m+1;
end

A = zeros(n);
L = eye(n) - c*tril(ones(n), -1);
A(:,1:n-1) = L*[T; zeros(1,n-1)];
theta = max(abs(A(:)));
A(:,n) = theta * ones(n,1);
A = A/theta;
