load Environment_Val.mat
close all

%must have data:
%   P = preassure in Pa
%   alt = Altitude in m
%   rho = Air Density 

sub = get_param('Environment','ModelWorkspace');
sub.reload;

assignin(sub,'alty',alt');
assignin(sub,'altx',[1:1:length(alt)]);

t = [1:1:length(alt)];
Timespan = max(t);
UT = [t',t'];
opt = simset('ReturnWorkspaceOutputs', 'off');
[T,X,Y] = sim('Environment',Timespan,opt, UT);
sub.reload;

figure
hold all
plot(alt,rho)
plot(Y(:,6),Y(:,4))
legend('data','model')
title('Validate Density')
xlabel('Altitude')
ylabel('Density')