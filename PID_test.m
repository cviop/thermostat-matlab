function PID_test


serialportlist;
%clear dev
clear;clc; close all force;close all;


regulator = serialport("COM4",115200);

wlen = 1400;
temperatureWindow = zeros(wlen,1);


%% PID constants
% constants for PID
Kp = 5;
Ki = 5;
Kd = 0.5;
IntegratorMin = 0;
IntegratorMax = 80;
SetPoint = 50; %%temperature setpoint

%on/off for PID
pON = 1;
iON = 1;
dON = 1;

T = 0.005;
tau = 0.1;

% Global Variables for PID
outP = 0;
outI = 0;
outD = 0;
errPrev = 0;
temperaturePrev = 0;

% Vectors for PID values plot
outPWindow = zeros(wlen,1);
outIWindow = zeros(wlen,1);
outDWindow = zeros(wlen,1);
outPIDWindow = zeros(wlen,1);
SetPointWindow = ones(wlen,1)*SetPoint;

%% UI window

hFig = uifigure('Visible', 'on');
hFig.AutoResizeChildren = 'off';
hFig.Position = [100 100 1000 750];

%% Grid layout init
GridLayout = uigridlayout(hFig);
GridLayout.ColumnWidth = {238, '1x'};
GridLayout.RowHeight = {'1x'};
GridLayout.ColumnSpacing = 0;
GridLayout.RowSpacing = 0;
GridLayout.Padding = [0 0 0 0];
GridLayout.Scrollable = 'on';

%% Panels
RightPanel = uipanel(GridLayout);
RightPanel.Layout.Row = 1;
RightPanel.Layout.Column = 2;

LeftPanel = uipanel(GridLayout);
LeftPanel.Layout.Row = 1;
LeftPanel.Layout.Column = 1;

%% Sliders

setTLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 510 210 22], Text="Temperature");
setTSlider = uislider(LeftPanel);
setTSlider.Value = SetPoint;
setTSlider.ValueChangedFcn = @(t,~)setpointChange;
setTSlider.Position = [12 500 210 3];
setTSlider.Limits = [20 100];

setPLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 410 210 22], Text="Kp");
setPSlider = uislider(LeftPanel);
setPSlider.ValueChangedFcn = @(t,~)KpChange;
setPSlider.Value = Kp;
setPSlider.Position = [12 400 210 3];
setPSlider.Limits = [0 10];

setILabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 310 210 22], Text="Ki");
setISlider = uislider(LeftPanel);
setISlider.ValueChangedFcn = @(t,~)KiChange;
setISlider.Value = Ki;
setISlider.Position = [12 300 210 3];
setISlider.Limits = [0 10];

setDLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 210 210 22], Text="Kd");
setDSlider = uislider(LeftPanel);
setDSlider.ValueChangedFcn = @(t,~)KdChange;
setDSlider.Value = Kd;
setDSlider.Position = [12 200 210 3];
setDSlider.Limits = [0 1];

%% Buttons
resetIButton = uibutton(LeftPanel);
resetIButton.Position = [12 100 90 30];
resetIButton.Text = "Rst. integrator";
resetIButton.ButtonPushedFcn = @(t,~)resetIfunction;

exitButton = uibutton(LeftPanel);
exitButton.Position = [12 12 60 30];
exitButton.Text = 'Exit';
exitButton.ButtonPushedFcn = @(t,~)exitFunction;

%% Switches
pSwitch = uiswitch(LeftPanel);
pSwitch.Position = [30 413 30 22];
pSwitch.Value = 'On';
pSwitch.ValueChangedFcn = @pActiveChange;

iSwitch = uiswitch(LeftPanel);
iSwitch.Position = [30 313 30 22];
iSwitch.Value = 'On';
iSwitch.ValueChangedFcn = @iActiveChange;

dSwitch = uiswitch(LeftPanel);
dSwitch.Position = [30 213 30 22];
dSwitch.Value = 'On';
dSwitch.ValueChangedFcn = @dActiveChange;

%% Text field
uilabel(LeftPanel, HorizontalAlignment='center', Position=[94 130 100 30], Text="Integrator max");
IntegratorMaxTextField = uieditfield(LeftPanel);
IntegratorMaxTextField.Position = [114 100 60 30];
IntegratorMaxTextField.Value = num2str(IntegratorMax);
IntegratorMaxTextField.ValueChangedFcn = @(t,~)IntegratorMaxChange;

%% Graphs
%temperature
temperatureAx = uiaxes('Parent', RightPanel,'Position', [10 400 740 300], 'YLim',[0 120]);
title(temperatureAx, 'Measured and set temperature')
xlabel(temperatureAx, 'Samples in history')
ylabel(temperatureAx, 'Temperature (C)')
temperatureAx.XGrid = 'on';
temperatureAx.XMinorGrid = 'on';
temperatureAx.YGrid = 'on';
temperatureAx.YMinorGrid = 'on';

uiplot = plot(temperatureAx,temperatureWindow);
hold(temperatureAx, "on");
SetPointPlot = plot(temperatureAx, SetPointWindow);
legend(temperatureAx,'Actual temperature','Temperature setpoint');


%PID, power
hAx = uiaxes('Parent', RightPanel,'Position', [10 80 740 300], 'YLim',[-150 150]);
title(hAx, 'Temp')
xlabel(hAx, 'Samples in history')
ylabel(hAx, 'PID values, percentage of max power')
zlabel(hAx, 'Z')
hAx.XGrid = 'on';
hAx.XMinorGrid = 'on';
hAx.YGrid = 'on';
hAx.YMinorGrid = 'on';

hold(hAx, "on");
pPlot = plot(hAx, outPWindow);
iPlot = plot(hAx, outIWindow);
dPlot = plot(hAx, outDWindow);
pidPlot = plot(hAx, outPIDWindow,'LineWidth',1);
legend(hAx,'P','I','D','PIDout');

hFig.Visible = 'on';

disp("gui done")
%return

%% Timers
pidTm = timer; % create an instance of timer
pidTm.Period = 0.005;
pidTm.ExecutionMode = 'fixedSpacing';
%pidTm.BusyMode = 'drop';
pidTm.TimerFcn = @(h,~)pidLoop(regulator);


dispTm = timer; % create an instance of timer
dispTm.Period = .5;
dispTm.ExecutionMode = 'fixedRate';
dispTm.BusyMode = 'drop';
dispTm.TimerFcn = @(t,~)updateGUI;

start(pidTm); % start the timer
start(dispTm);

%% PID Loop
function pidLoop(device)
    write(device,101,"uint8");
    
    temperature = read(device, 1, 'uint8')/255 *100 + 20;
   
    err = SetPoint-temperature;

    outP = err*Kp;
    
    % Integral 
    outI = outI + Ki*T*(err+errPrev);
    % Clamping
    outI(outI<IntegratorMin) = 0;
    outI(outI>IntegratorMax) = IntegratorMax;
    
    % Derivative
    outD = (2*Kd*(temperature - temperaturePrev) + outD*(2*tau-T))/(2*tau+T);

    % PID out
    outPID = pON*outP + iON*outI - dON*outD;
    outPID(outPID<0) = 0;
    outPID(outPID>100) = 100;
    write(device,outPID,'uint8');

    % Save actual values to display buffer
    temperatureWindow(end) = temperature;
    outPWindow(end) = outP;
    outIWindow(end) = outI;
    outDWindow(end) = -outD;
    outPIDWindow(end) = outPID;
    SetPointWindow(end) = SetPoint;
    
    % Circular shift
    temperatureWindow = circshift(temperatureWindow, 1);
    outPWindow = circshift(outPWindow, 1);
    outIWindow = circshift(outIWindow, 1);
    outDWindow = circshift(outDWindow, 1);
    outPIDWindow = circshift(outPIDWindow, 1);
    SetPointWindow = circshift(SetPointWindow, 1);

    errPrev = err;
    temperaturePrev = temperature;
end

%% GUI uprade function
function updateGUI(~)
    uiplot.YData = temperatureWindow;
    pPlot.YData = outPWindow;
    iPlot.YData = outIWindow;
    dPlot.YData = outDWindow;
    pidPlot.YData = outPIDWindow;
    SetPointPlot.YData = SetPointWindow;

end

%% Parameters change
function setpointChange(~)
    SetPoint = setTSlider.Value;
    %tr.Value = SetPoint;
end

function KpChange(~)
    Kp = setPSlider.Value;
end

function KiChange(~)
    Ki = setISlider.Value;
end

function KdChange(~)
    Kd = setDSlider.Value;
end

function IntegratorMaxChange(~)
    IntegratorMax = str2double(IntegratorMaxTextField.Value);
end

function resetIfunction(~)
    outI = 0;
end

function pActiveChange(src,event)
    switch src.Value
        case 'On'
            pON = 1;
            pPlot.LineStyle="-";
            pPlot.LineWidth=.1;
        case 'Off'
            pON = 0;
            pPlot.LineStyle=":";
            pPlot.LineWidth=.1;
    end
end

function iActiveChange(src,event)
    switch src.Value
        case 'On'
            iON = 1;
            iPlot.LineStyle="-";
            iPlot.LineWidth=.1;
        case 'Off'
            iON = 0;
            iPlot.LineStyle=":";
            iPlot.LineWidth=.1;
    end
end

function dActiveChange(src,event)
    switch src.Value
        case 'On'
            dON = 1;
            dPlot.LineStyle="-";
        case 'Off'
            dON = 0;
            dPlot.LineStyle=":";
    end
end


function exitFunction(~)
    write(regulator, 0, "uint8");
    stop(timerfind);
    write(regulator, 0, "uint8");
    delete(timerfind);
    pause(0.5);
    write(regulator, 0, "uint8");
    close all force;
    write(regulator, 0, "uint8");
    return
end




end