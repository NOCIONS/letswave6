function [ g_gamma, phi, K ] = sub_gabor_dict( x, gamma )

% sub-function used to calculate the gabor function

% pre-processing
if size(x,2)==1
    x = x.';
end
x = x - mean(x);
%
u = gamma(1);
omega = gamma(2);
s = gamma(3);
%
t = 1:length(x);
C = exp(-pi*((t-u)/s).^2).*cos(omega*(t-u));
S = exp(-pi*((t-u)/s).^2).*sin(omega*(t-u));

phi = atan(((x*S')/(S*S'))/((x*C')/(C*C')));
g_gamma = exp(-pi*((t-u)/s).^2).*cos(omega*(t-u)+phi);
K = 1/sqrt(sum(g_gamma.^2));
g_gamma = K*g_gamma;
