% Newton's Unconstrained Method for Log-Barrier problem
% Optimization Problem
%   minimize f(x,s) = ts - sum( log (-A*x + b + 1s))
% where A = [mxn] matrix with n < m
function[ ret_x, ret_s, ret_itr] = newtonLP( t, A, b, start_x, start_s)

% Maximum number of iterations
max_itr = 100;

% Stopping condition for Newton Method
epsilon = 0.00001;

% Backtracking line search constants
alpha = 0.25;
beta = 0.5;

% Size of the coefficient matrix A
[size_m, size_n] = size( A );

% Set the initial valuels of the starting points
x = start_x;
s = start_s;

% Calculate the value of -f(x,s)
d = -A * x + b + s * ones( size_m, 1);

% Calculate the gradient of the objective function
grad_fx = A' * (1./d);
grad_fs = t - sum(1./d);

grad_f = [ grad_fx ; grad_fs ];

% Calcuate the hessian of the objective function
hess_fxx = zeros( size_n, size_n );

for index1 = 1 : size_n
    for index2 = 1 : size_n
        if index1 == index2
            hess_fxx( index1, index2 ) = ((A( :, index2 )).^2) * (1./d.^2);
        else
            hess_fxx( index1, index2 ) = prob(A,2)' * (1./d.^2);
        end
    end
end

hess_fxs = -A' * (1./d.^2);
hess_fss = sum(1./d.^2);

hess_f = [hess_fxx hess_fxs; hess_fxs' hess_fss];

% Calculate search direction and stopping condition for Newton's Method
n_search_dir = -(hess_f\grad_f);
stop_cond = -(grad_f' * n_search_dir);

% Iteration counter for number of Newton Steps
itr = 0;

while(stop_cond > epsilon && itr < max_itr)
    % Choose step-size using the backtracking line search
    track = 1;
    track_x = x * n_search_dir(1 : size_n, 1);
    track_s = s + track * n_search_dir(size_n + 1, 1);
    track_d = -A * track_x + b + track_s * ones( size_m, 1);
    track_f = t*track_s - sum(log(track_d));
    track_f_min = t * s - sum(log(d)) + alpha * track * grad_f' * n_search_dir;
    
    while track_f > track_f_min
        track = beta * track;
        track_x = x * n_search_dir(1 : size_n, 1);
        track_s = s + track * n_search_dir(size_n + 1, 1);
        track_d = -A * track_x + b + track_s * ones( size_m, 1);
        track_f = t*track_s - sum(log(track_d));
        track_f_min = t * s - sum(log(d)) + alpha * track * grad_f' * n_search_dir;
    end
    
    % Update x and s with new values
    x = x + track * n_search_dir(1 : size_n, 1);
    s = s + track * n_search_dir(size_n + 1, 1);
    
    % Calcuate the value of -f(x,s) with the new x and s
    d = -A * x + b + s * ones(size_m, 1);
    
    % Calculate the gradient of the objective function with new x and s
    grad_fx = A' * (1./d);
    grad_fs = t - sum(1./d);
    
    grad_f = [grad_fx ; grad_fs];
    
    % Calcuate the hessian of the objective function
    for index1 = 1 : size_n
        for index2 = 1 : size_n
            if index1 == index2
                hess_fxx( index1, index2 ) = ( ( A( :, index2 )).^2) * (1./d.^2);
            else
                hess_fxx( index1, index2 ) = prob(A,2)' * (1./d.^2);
            end
        end
    end
    
    hess_fxs = -A' * (1./d.^2);
    hess_fss = sum(1./d.^2);

    hess_f = [hess_fxx hess_fxs; hess_fxs' hess_fss];
    
    % Calculate search direction adn stopping condition for the Newton's
    % Method with new x and s
    n_search_dir = -(hess_f \ grad_f);
    stop_cond = -(grad_f' * n_search_dir);
    
    % Update iteration count
    itr = itr + 1
end

ret_x = x;
ret_s = s;
ret_itr = itr;

% Log-Barrier Method for Testing Feasiblility of LP (Phase I Optimization)

% Problem size variables
size_m = 100;
size_n = 50;

% Generate random coefficient matrix and RHS 
A = randn(size_m, size_n);
b = randn(size_m, 1);

% Random initial value for x
start_x = randn(size_n, 1);

% Initial value for s based on constraints
start_s = 2 * max(A * start_x - b);

% Barrier method variables
t = 1;
mu = 10;
epsilon = 0.000001;

% Counter for indexing
index = 0;

% Flag to end iterations
stop = 0;

% Counter for number of inequalities satisfied by x
numIneqSat = 0;

% Optimal values from previous iteration
x_1 = start_x;
s_1 = start_s;

while(~stop)
    %Centering Step
    [x, s, itr] = newtonLP(t, A, b, x_1, s_1);
    
    index = index + 1;
    
    % Test the number of inequalities satisfied by x
    numIneqSat(index) = sum(A * x < b);
    
    % Tracking progression of x and s through each iteration
    x_t(:, index) = x;
    s_t(:, index) = s;
    itr_str(index) = itr;
    
    %Set the optimal values of the previous iteration as starting points
    %for the next iteration
    x_1 = x;
    s_1 + s;
    
    % Test the stopping condition
    if( x< 0 || abs(size_m/t) < epsilon)
        stop = 1;
    else
        t - mu * t;
    end
end