%% f_VideoTrack_PI_MAIN.m   cmgrass 20170315
close all; clear all; clc;

delete(instrfind);
SerialCommPort = serial('COM8');
SerialCommPort.BaudRate = 9600;
fopen(SerialCommPort);
fprintf(SerialCommPort,num2str(90));
pause(1);

Camera = imaq.VideoDevice('winvideo', 1);
Frame = step(Camera);
pause(1);
Frame = step(Camera);
[d1,d2,d3] = size(Frame);
Show = imshow(Frame); hold on;
plot([1 d2],[d1 d1]/2,'y');
plot([d2 d2]/2,[1 d1],'y');
Title = title('Double click to select color');
[xClick,yClick] = getpts;
PlotXY = plot(xClick,yClick,'oy'); pause(1);
DesColor(1:3) = Frame(round(yClick),round(xClick),:);
DeltaColor = 0.10;

%%
xTgt = xClick; yTgt = yClick; beta = 0.4; alfa = 1 - beta;
N = 300; dt = 1/30; F = 1; eInteg = 0;
tic
for k = 0:N
    Frame = step(Camera);
    set(Show,'cdata',Frame);
    Mask = abs(Frame(:,:,1)-DesColor(1)) < DeltaColor & ...
        abs(Frame(:,:,2)-DesColor(2)) < DeltaColor & ...
        abs(Frame(:,:,3)-DesColor(3)) < DeltaColor;
    [Row, Col] = find(Mask);
    if ~isempty(Row),
        xTgt = alfa*xTgt + beta*mean(Col);
        yTgt = alfa*yTgt + beta*mean(Row);
    end

    %% P Controller
    % Kp = 0.4;
    % AngDeg = round(Kp*(xTgt-80) + 90);
    
    %% PI Control
    Kp = 0.1; Z = 4; Ki = Z*Kp;
    e = xTgt-80;
    eInteg = eInteg + e*dt;
    eInteg = min([100 max([-100 eInteg])]);
    AngDeg = round(Kp*e - Ki*eInteg + 90);
    
    %% Send Control to ServoMotor
    % AngDeg = 10*sign(sin(2*pi*F*l*dt)) + 90;
    fprintf(SerialCommPort,num2str(AngDeg));
    set(PlotXY,'xdata',xTgt,'ydata',yTgt);
    drawnow;
end
FramePerSec = N/toc;
set(Title,'string',['FramePerSec ',num2str(FramePerSec)]);

%% Clean Up
fprintf(SerialCommPort,num2str(90)); fclose(SerialCommPort);
release(Camera); clear vidDevice;