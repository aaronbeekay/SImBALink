function [sse, r2] = test_model_performance(cell_name)
%% test model performance 

% Name of the directory containing truth data to test against
%truth_dir = 'RedCell_3';
truth_dir = cell_name;

% Name of the truth file to test against
truth_file = 'PikesPeak_discharge';

truth = fullfile('..', 'Data', 'Truth', truth_dir, truth_file);

% Get timeseries voltage and current data for comparison
load( truth );
Idc = timeseries( Current, Time );
V	= timeseries( Voltage, Time );

load_system(fullfile( '..', 'Battery_pack'));
mws = get_param(bdroot, 'modelworkspace');

mws.reload();		% reload workspace from source file
mws.assignin('Idc',Idc);

% Simulate
set_param('Battery_pack', 'StopTime', 'max(Idc.Time)');
set_param('Battery_pack', 'StartTime', 'min(Idc.Time)');
set_param('Battery_pack', 'MaxStep', '0.1');
out = sim('Battery_pack', 'LoadExternalInput', 'on', 'ExternalInput', 'Idc');
outTime = out.get('tout');
outValues = out.get('yout');

simulated.Voltage = timeseries (outValues(:,2), outTime);

%% metrics

sse = V - resample(simulated.Voltage, V.time);		% resample simulation timeseries to truth indices
sse = sum((sse.Data).^2);

avg = mean(simulated.Voltage.Data);

sst = sum( (simulated.Voltage.Data - avg).^2 );
r2 = 1 - sse/sst;

%% plot
figure

hold on;
plot(simulated.Voltage);
plot(V, 'r');
title(['Terminal voltage: model and truth vs. time, ' cell_name]);
xlabel('Time (sec)');
ylabel('Terminal voltage (V)');
legend('Model', 'Truth');

annotation('textbox', [0.7,0.2,0.1,0.1], 'String', {['SSE: ' num2str(sse)], ['R^2: ' num2str(r2) ]});

hold off;

saveas(gcf, ['Figures/ModelAgreement_' cell_name '.eps'], 'epsc');
saveas(gcf, ['Figures/ModelAgreement_' cell_name '.png']);

