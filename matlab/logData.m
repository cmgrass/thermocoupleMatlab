function [tuyTs] = logData(mySerialPort, samples)
%LOGDATA Summary of this function goes here
%   Detailed explanation goes here

    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);

    %% Send start
    fprintf(mySerialPort, '%s', num2str(1234)); % Start signal
    pause(1);
    echo = 0;
    while echo ~= 1234
       echo = fscanf(mySerialPort, '%u'); 
    end
    disp('Started');
    
    %% Log data
    % Initialize result matrix
    tuyTs = zeros(5,samples);   % (1: t, 2: u, 3: yA, 4: yB, 5: Ts)
    relayPwm = 0;
    
    tic    % start clock
    for k = 1:samples   % Loop through the serial buffer
        
        % Send Relay PWM command
        if (k == round(samples*0.01))
            fprintf(mySerialPort, '%s', num2str(60));
            relayPwm = 60;
        end
        
        % Send Relay PWM command
        if (k == round(samples*0.4))
            fprintf(mySerialPort, '%s', num2str(255));
            relayPwm = 255;
        end
               
        % Send Relay PWM command
        if (k == round(samples*.25))
            fprintf(mySerialPort, '%s', num2str(100));
            relayPwm = 100;
        end
        
        % Send Relay PWM command
        if (k == round(samples*0.75))
            fprintf(mySerialPort, '%s', num2str(0));
            relayPwm = 0;
        end
        
        % Read through one chunk of protocol
        % initialize
        serialInput = 0.0;
        
        % start
        while serialInput ~= 9998
            serialInput = fscanf(mySerialPort, '%u');
        end
        
        % data
        tuyTs(2,k) = relayPwm;
        tuyTs(3,k) = fscanf(mySerialPort, '%f');
        tuyTs(4,k) = fscanf(mySerialPort, '%f');
        disp(tuyTs(3,k));    % for debugging
        disp(tuyTs(4,k));    % for debugging
        
        % end
        while serialInput ~= 9999
            serialInput = fscanf(mySerialPort, '%u');
        end

        % log time information for sample set
        tuyTs(1,k) = toc;
        if k > 1
            tuyTs(5,k) = tuyTs(1,k)-tuyTs(1,(k-1)); % sampling time for averaging later on
        else
            tuyTs(5,k) = 0;
        end
    end
    
    disp('Sample Duration :');
    disp(toc);  % Display sample duration

    %% Send stop command
    fprintf(mySerialPort, '%s', num2str(4321)); % Stop signal
    disp('Stop stream');
    
    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);
    
    %% Plot Results
    figure;
    subplot(3,1,1);
    plot(tuyTs(1,:),tuyTs(2,:));
    title('Input `u` to System: Bacon? Vs. Time');
    xlabel('Time (seconds)');
    ylabel('Bacon Units? (0 to 100)');
    
    subplot(3,1,2);
    plot(tuyTs(1,:),tuyTs(3,:));
    title('Response `y` of System: Temperature `A` Vs. Time');
    xlabel('Time (seconds)');
    ylabel('System Temperature `A` (Farenheit)');    

    subplot(3,1,3);
    plot(tuyTs(1,:),tuyTs(4,:));
    title('Response `y` of System: Temperature `B` Vs. Time');
    xlabel('Time (seconds)');
    ylabel('System Temperature `B` (Farenheit)');
end

