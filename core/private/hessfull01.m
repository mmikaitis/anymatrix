function [A,properties] = hessfull01(n)
%HESSFULL01 Totally nonnegative binary lower Hessenberg Toeplitz matrix.
%   HESSFULL01(n) is an n-by-n totally nonnegative binary lower Hessenberg
%   Toeplitz matrix. All its eigenvalues are real. It has rank n-1,
%   floor(n/2)zero eigenvalues, which appear in a single Jordan
%   block, and largest eigenvalue 2*(1+cos(2*pi/(n+2))).
%   The positive eigenvalues are distinct.
%   The condition numbers of the largest eigenvalues grow with n.

%   See also gallery/chow.

%   References:
%   Richard Brualdi and Steve Kirkland, Totally nonnegative (0,1)-matrices, 
%     Linear Algebra Appl. 432, 1650-1662, 2010.
%   Shaun M. Fallat and Michael I. Gekhtman and Charles R. Johnson,
%     Spectral Structures of Irreducible Totally Nonnegative Matrices,
%     SIAM J. Matrix Anal. Appl. 22 (2), 627-645, 2000.

properties = {'hessenberg', 'toeplitz', 'binary', 'totally nonnegative', ...
              'rank deficient', 'eigenvalues'};
if nargin == 0, A = []; return, end

A = tril(ones(n),1);
