%data_2 = readcsv('~/data.csv');

function fit_curve()
data_1 = csvread('CambridgeAnalytica.csv');
% Susceptible populations sizes at t = 0
% Data used for fitting 
num_tweets = data_1(:, 1);
times = linspace(0, length(num_tweets) - 1, length(num_tweets));
% Initial values of the parameters to be fitted 
param0 = [300000 100 100 100 20 0.5 0.5 20 20 20];
% param(1) - Susceptible population at t = 0
% param(2) - Exposed population at t = 0
% param(3) - Infected population at t = 0
% param(4) - Skeptic population at t = 0
% param(5) - beta
% param(6) - p
% param(7) - l
% param(8) - rho
% param(9) - e 
% param(10) - gamma
% Define lower and upper bound for the parameters
large = 10^7;
N =  param0(1) + param0(2) + param0(3) + param0(4);
A = [];
B = [];
LB = zeros(10);
UB = [N N N N large 1 1 large large large];
% Setting linear equalities
Aeq = [];
beq = [];
nonlcon = [];
% Declare options for fmincon
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',Inf,...
                       'PlotFcns',{@optimplotfval, @optimplotfunccount});
% Fit the parameters 
[param,E,exitflag] = fmincon(@(param) loss_function(param, times, num_tweets), param0, A, B, Aeq, beq,LB, UB, nonlcon, options);
% Display outputs
ic = param(1:4);
[~, population] = ode23(@(t, population) ...
    RHS(t,population, param(5),param(6),param(7),param(8)...
    , param(9), param(10)),times , ic);
I = population(:,3);
figure();
plot(times, I)
hold on;
scatter(times, num_tweets)
display(E)
display(param)
end

% Define loss function
function error = loss_function(param, times, num_tweets)
% Initial conditions for ode solver
ic = param(1:4);
% Solve ode, return population sizes with corresping times
[~, population] = ode23(@(t, population) ...
    RHS(t,population,param(5),param(6),param(7),param(8)...
    , param(9), param(10)),times , ic);
% Select only Infected population size
I = population(:,3);
% Compute error with respect to data
error = sum((I-num_tweets).^2);
end

% Define differential equation
function dxdt = RHS(t, population, beta, p, l, rho, e, gamma) 
S = population(1); 
I = population(3); 
E = population(2); 
Z = population(4);
N = S + I + E + Z;
dxdt = [-beta*S*(I/N) - gamma*S*(Z/N);
        beta*(1-p)*S*(I/N) - e*E - rho*E*(I/N) + gamma*(1-l)*S*(Z/N);
        beta*p*S*(I/N) + rho*E*(I/N) + e*E;
        gamma*l*S*(Z/N)
    ];
end
