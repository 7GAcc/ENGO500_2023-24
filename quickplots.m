function quickplots(filename)
plotsetting=2;
if nargin<1
    [filen,filepath]=uigetfile("Processed Data/*.mat");
    filen=string(filepath)+string(filen);
    data=load(filen);
else
    data=load(filename);
end

figure
if plotsetting==0
    subplot(2,1,1)
    % title(filename)
    hold on
    grid on
    plot(data.gyro_data(:,2),data.gyro_data(:,3)*180/pi,'r')
    plot(data.gyro_data(:,2),data.gyro_data(:,4)*180/pi,'b')
    plot(data.gyro_data(:,2),data.gyro_data(:,5)*180/pi,'k')
    legend('Gyro X (Roll)','Gyro Y (Pitch)','Gyro Z (Yaw)')
    xlabel('Time Elapsed [s]')
    ylabel('Rotation [deg/s]')
    subplot(2,1,2)
    hold on
    grid on
    plot(data.grav_data(:,2),data.grav_data(:,3),'r')
    plot(data.grav_data(:,2),data.grav_data(:,4),'b')
    plot(data.grav_data(:,2),data.grav_data(:,5),'k')
    legend('Grav X','Grav Y','Grav Z')
    xlabel('Time Elapsed [s]')
    ylabel('Grav Force [m/s^2]')
elseif plotsetting==1
    subplot(3,1,1)
    % title(filename)
    hold on
    grid on
    plot(data.gyro_data(:,2),data.gyro_data(:,3)*180/pi,'r')
    plot(data.gyro_data(:,2),data.gyro_data(:,4)*180/pi,'b')
    plot(data.gyro_data(:,2),data.gyro_data(:,5)*180/pi,'k')
    legend('Gyro X (Roll)','Gyro Y (Pitch)','Gyro Z (Yaw)')
    xlabel('Time Elapsed [s]')
    ylabel('Rotation [deg/s]')
    subplot(3,1,2)
    hold on
    grid on
    plot(data.grav_data(:,2),data.grav_data(:,3),'r')
    plot(data.grav_data(:,2),data.grav_data(:,4),'b')
    plot(data.grav_data(:,2),data.grav_data(:,5),'k')
    legend('Grav X','Grav Y','Grav Z')
    xlabel('Time Elapsed [s]')
    ylabel('Grav Force [m/s^2]')    
    subplot(3,1,3)
    hold on
    grid on
    plot(data.bar_data(:,2),data.bar_data(:,3),'b')
    legend("Barometer Data (Rel Altitude)")
    xlabel('Time Elapsed [s]')
    ylabel('Relative Altitude [m]')
elseif plotsetting==2
    subplot(2,2,1)
    % title(filename)
    hold on
    grid on
    plot(data.gyro_data(:,2),data.gyro_data(:,3)*180/pi,'r')
    plot(data.gyro_data(:,2),data.gyro_data(:,4)*180/pi,'b')
    plot(data.gyro_data(:,2),data.gyro_data(:,5)*180/pi,'k')
    legend('Gyro X (Roll)','Gyro Y (Pitch)','Gyro Z (Yaw)')
    xlabel('Time Elapsed [s]')
    ylabel('Rotation [deg/s]')
    subplot(2,2,2)
    hold on
    grid on
    plot(data.grav_data(:,2),data.grav_data(:,3),'r')
    plot(data.grav_data(:,2),data.grav_data(:,4),'b')
    plot(data.grav_data(:,2),data.grav_data(:,5),'k')
    legend('Grav X','Grav Y','Grav Z')
    xlabel('Time Elapsed [s]')
    ylabel('Grav Force [m/s^2]')    
    subplot(2,2,3)
    hold on
    grid on
    plot(data.bar_data(:,2),data.bar_data(:,3),'b')
    legend("Barometer Data (Rel Altitude)")
    xlabel('Time Elapsed [s]')
    ylabel('Relative Altitude [m]')
    subplot(2,2,4)
    hold on
    grid on
    plot(data.accel_data(:,2),data.accel_data(:,3),'r')
    plot(data.accel_data(:,2),data.accel_data(:,4),'b')
    plot(data.accel_data(:,2),data.accel_data(:,5),'k')
    legend('Accel X','Accel Y','Accel Z')
    ylabel('Acceleration [m/s^2]')
    xlabel('Time Elapsed [s]')
end


end