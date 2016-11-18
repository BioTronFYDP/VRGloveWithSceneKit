clear all;
close all;
clc;


countmyos = 1;
mm = MyoMex(countmyos);

%
uno = arduino()

m1 = mm.myoData(1);
pause(0.1);

% data properties sampled on the IMU time base
m1.timeIMU
m1.quat
m1.rot
m1.gyro
m1.gyro_fixed
m1.accel
m1.accel_fixed
m1.pose
m1.pose_rest
m1.pose_fist
m1.pose_wave_in
m1.pose_wave_out
m1.pose_fingers_spread
m1.pose_double_tap
m1.arm
m1.arm_right
m1.arm_left
m1.arm_unknown
m1.xDir
m1.xDir_wrist
m1.xDir_elbow
m1.xDir_unknown

% data properties sampled on the EMG time base
m1.timeEMG
m1.emg

%% Using Logged Data
% As |MyoData| receives data from |MyoMex|, it's automatically accumulated
% in so-called |<data>_log| properties, i.e. |quat_log|, |accel_log|, etc.
% We refer to this as the streaming mode of a |MyoData| object. This status
% is indicated by the |isStreaming| property.

m1.isStreaming

%%
% We can inspect the accumulation of the logs for example,

fprintf('%10s%10s\n','time','samples')
for ii = 1:5
  fprintf('% 8.2f%10d\n',...
    m1.timeIMU,size(m1.quat_log,1));
  pause(0.2);
end
fprintf('\n\n');

%%
% Although we can't stop the data from being passed to in |MyoData|, we can
% toggle streaming mode by using the methods |stopStreaming()| and
% |startStreaming()|.

m1.stopStreaming();
fprintf('Number of samples:               \t%d\n',length(m1.timeIMU_log));
pause(1);
fprintf('Number of samples after pause(1):\t%d\n',length(m1.timeIMU_log));

%%
% Now we can plot some data taking care to use the correct time vectors.
norder = 4;
Fs = 200;
[b,a] = butter(norder/2, [2]/(Fs/2));
numruns = zeros(32,1)
means = zeros(8,1);
lastbm = 0;

while(1)
    m1.clearLogs();
    m1.startStreaming();
    pause(0.6); % 8 points
    m1.stopStreaming();
    
    loglen = length( m1.emg_log);
    
    bimag = 0;
    trimag = 0;
    for j = 1:8
        means(j) = mean( filtfilt( b, a, abs( m1.emg_log(1:end, j))));
    end
    bicepmag = mean( means(3:5));
    tricepmag = (means(1) + means(2) + means(6) + means(7) + means(8)) / 5;
    
    if 0
        if bicepmag > 0.5 && lastbm < 0.5
            writeDigitalPin( uno, 'D13', 1);
        elseif bicepmag < 0.5 && lastbm > 0.5
            writeDigitalPin( uno, 'D13', 0);
        end
        lastbm = bicepmag;
    end
    
    if bicepmag > 0.1 && bicepmag < 0.25
        writeDigitalPin( uno, 'D10', 1);
        writeDigitalPin( uno, 'D11', 0);
        writeDigitalPin( uno, 'D12', 0);
        writeDigitalPin( uno, 'D13', 0);
    end
    if bicepmag > 0.25 && bicepmag < 0.4
        writeDigitalPin( uno, 'D10', 1);
        writeDigitalPin( uno, 'D11', 1);
        writeDigitalPin( uno, 'D12', 0);
        writeDigitalPin( uno, 'D13', 0);
    end
    if bicepmag > 0.4 && bicepmag < 0.6
        writeDigitalPin( uno, 'D10', 1);
        writeDigitalPin( uno, 'D11', 1);
        writeDigitalPin( uno, 'D12', 1);
        writeDigitalPin( uno, 'D13', 0);
    end
    if bicepmag > 0.6
        writeDigitalPin( uno, 'D10', 1);
        writeDigitalPin( uno, 'D11', 1);
        writeDigitalPin( uno, 'D12', 1);
        writeDigitalPin( uno, 'D13', 1);
    end
    
end

%%
figure(1);
subplot(5,1,1); plot(m1.timeIMU_log,m1.gyro_log);  title('gyro');
subplot(5,1,2); plot(m1.timeIMU_log,m1.accel_log); title('accel');
subplot(5,1,3); plot(m1.timeEMG_log,m1.emg_log);   title('emg');
ax1 = subplot(5,1,4); plot(m1.timeEMG_log,filtfilt( b, a, abs( m1.emg_log(1:end, 4))));   title('emg - bicep');
ylim([0 1]);
ax2 = subplot(5,1,5); plot(m1.timeEMG_log,filtfilt( b, a, abs( m1.emg_log(1:end, 8))));   title('emg - tricep');
ylim([0 1]);
linkaxes([ax1,ax2], 'xy');
%%
for i = 1:10
      writeDigitalPin( uno, 'D13', 0);
      pause(0.5);
      writeDigitalPin( uno, 'D13', 1);
      pause(0.5);
end 

%%
m1.stopStreaming();
m1.clearLogs();

testdata = zeros(50, 1);
for i = 1:10
        m1.startStreaming();
        pause(0.05);
        m1.stopStreaming();
        testdata(i,1) = length( m1.emg_log);
        
    %set_param('realtimedataview/input',
end
m1.stopStreaming();



%%
Fs = 200;
norder = 2;
rawdata = m1.emg_log;
onedata = m1.emg_log(1)
[b,a] = butter(norder, [2]/(Fs/2));
y = filter(b,a, rawdata);
onedata = [m1.timeEMG_log; m1.emg_log(1)];

%%
% If you'd like to clear the |<data>_log| properties to start a new logging
% trial, then you may use the |clearLogs()| method,

% collect about T seconds of data
T = 5; % seconds
m1.clearLogs()
m1.startStreaming();
pause(T);
m1.stopStreaming();
fprintf('Logged data for %d seconds,\n\t',T);
fprintf('IMU samples: %10d\tApprox. IMU sample rate: %5.2f\n\t',...
  length(m1.timeIMU_log),length(m1.timeIMU_log)/T);
fprintf('EMG samples: %10d\tApprox. EMG sample rate: %5.2f\n\t',...
  length(m1.timeEMG_log),length(m1.timeEMG_log)/T);

%%
% Finally, when you're done with |MyoMex|, don't forget to clean up!

mm.delete;
clear mm
