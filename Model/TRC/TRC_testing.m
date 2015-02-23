%load CoastDownTimeSeries

lat = ts{17};
long = ts{18};
temp = ts{2};
datastart = 1300;

close all
figure
scatter(lat.Data(datastart:end),long.Data(datastart:end));

figure
plot(temp);


%start at B
%loop is 1.463 km corner radius 233n
%then straight 548.6 m. slop -1%
%loop 1.205 km radius 192 m
% staight 548.6 slope 1%
% 1% is 1 : 95.49 gradient
% alt 0 at B so
% B after loop is alt 0
% 1/(95.49)*548.6 m = 5.74
% A alt = -5.74

d = [0,1463,2011.6,3216.6,3765.2];
altx = d;
alty = [0,0,-5.74,-5.74,0];
rcx = d;
rcy = [233,233,100000,192,10000];

dist = [0:6000];
t = [1:1:length(dist)];
Timespan = max(t);
UT = [t',dist'];
opt = simset('ReturnWorkspaceOutputs', 'off');
[T,X,Y] = sim('Environment_TRC',Timespan,opt, UT);

figure
hold all
plot(Y(:,5),Y(:,4))
title('Validate Air Density')
xlabel('Altitude')
ylabel('Density')

figure()
[hAx,hLine1,hLine2] = plotyy(Y(:,5),Y(:,6),Y(:,5),Y(:,1));
title('Validate Road Grad')
xlabel('Distance')
ylabel(hAx(1),'Altitude [m]')
ylabel(hAx(2),'Road Rad [rad]')

figure
hold all
plot(Y(:,5),Y(:,7))
title('Corner Radius')
xlabel('Distance')
ylabel('Corner Radius')

%% rider

close all
starttime = ts{1}.Data(datastart);
endtime = 832;
thr = ts{26};
rpm = ts{34};
eff_tyre = 0.01843; %(m/s)/RPM

figure
plot(thr);

thr_sample = getsampleusingtime(thr,starttime,endtime) ;
rpm_sample = getsampleusingtime(rpm,starttime,endtime);

dist = cumtrapz(rpm_sample.Time,rpm_sample.Data*eff_tyre*-1);

figure
plot(thr_sample);

thrx = thr_sample.Time - starttime;
thry = thr_sample.Data;

t = [1:1:endtime];
Timespan = max(t);
UT = [t',t'];
opt = simset('ReturnWorkspaceOutputs', 'off');
[T,X,Y] = sim('Rider_TRC',Timespan,opt, UT);

figure
plot(T,Y(:,1));