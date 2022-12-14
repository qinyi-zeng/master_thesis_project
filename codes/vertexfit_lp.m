function [ A_BEST ] = vertexfit_lp( u_mat, h_vec, lifting_dim, varargin )
%Fit a polyhedral set to support function measurements.  The output map
%defines a project of the simplex.  In otherwords, the fitted set is the
%image of the simplex under A_BEST.
%   u_mat: Directions of support function measurements
%   h_vec: Support function measurements
%   lifting_dim: Scalar, dimension
%The code is based on the Alternating Minimization implementation, with a
%Tikhonov regularization parameter specified by REG (set at 0.5).
%   Optional input are specified via the struct `params'.  The struct
%   specifies 'InnerIterates' for the number of Alternating Minimization
%   iterations, as well as 'OuterIterates' for the number of random 
%   initializations.


% Initialize
if nargin > 3
    params = varargin{1};
else
    params = {};
end

% Optional parameters

% Number of inner iterations
if isfield(params,'InnerIterates') == 1
    nInnIter = params.InnerIterates;
else
    nInnIter = 50;
end
% Number of outer iterations
if isfield(params,'OuterIterates') == 1
    nOutIter = params.OuterIterates;
else
    nOutIter = 20;
end

REG = 0.5;

% Launch the solver

q = lifting_dim;
[d,n] = size(u_mat);

ERR_BEST = -1;      % Init to -ve value.  +ve after 1 iterate
A_BEST = zeros(d,q);

% Outerloop
for ii = 1 : nOutIter
    % Perform the AM algorithm
    
    % Initialize with a random A
    A = randn(d,q);
    
    % Innerloop
    for jj = 1 : nInnIter
        % Construct the operator
        ope = REG*eye(d*q,d*q);
        vec = REG*A(:);
        
        % Update the empirical cov matrix
        for kk = 1 : n
            u = u_mat(:,kk);
            [~,emax] = vector_supp(A'*u);
            s1 = u*emax';
            s2 = s1(:);
            vec = vec + s2*h_vec(1,kk);
            ope = ope + s2*s2';
        end
        
        % Solve
        A = reshape(ope\vec,[d,q]);
    end
    
    % Compare with the best
    ERR_CURR = evaluatefit(A,u_mat,h_vec,'simplex');
    if ERR_CURR*ERR_BEST < ERR_BEST*ERR_BEST
        A_BEST = A;
        ERR_BEST = ERR_CURR;
        %%new print
        display("ERR CURR:");
        display(ERR_BEST);
    end
    
end

end

