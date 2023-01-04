function PID_test


serialportlist;
%clear dev
clear;clc; close all force;close all;


regulator = serialport("COM4",115200);

wlen = 500;
temperatureWindow = zeros(wlen,1);


%% PID constants
% constants for PID
Kp = 2;
Ki = 0.01;
Kd = 0.001;
SetPoint = 50; %%temperature setpoint

% Global Variables for PID
outP = 0;
outI = 0;
outD = 0;
errPrev = 0;

% Vectors for PID values plot
outPWindow = zeros(wlen,1);
outIWindow = zeros(wlen,1);
outDWindow = zeros(wlen,1);
outPIDWindow = zeros(wlen,1);
SetPointWindow = ones(wlen,1)*SetPoint;

%% UI window

hFig = uifigure('Visible', 'on');
hFig.AutoResizeChildren = 'off';
hFig.Position = [100 100 700 570];

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

setTLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 410 210 22], Text="Temperature");
setTSlider = uislider(LeftPanel);
setTSlider.Value = SetPoint;
setTSlider.ValueChangedFcn = @(t,~)setpointChange;
setTSlider.Position = [12 400 210 3];
setTSlider.Limits = [20 100];

setPLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 310 210 22], Text="Kp");
setPSlider = uislider(LeftPanel);
setPSlider.ValueChangedFcn = @(t,~)KpChange;
setPSlider.Value = 2;
setPSlider.Position = [12 300 210 3];
setPSlider.Limits = [0 3];

setILabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 210 210 22], Text="Ki");
setISlider = uislider(LeftPanel);
setISlider.ValueChangedFcn = @(t,~)KiChange;
setISlider.Value = 0.005;
setISlider.Position = [12 200 210 3];
setISlider.Limits = [0.0001 0.01];

setDLabel = uilabel(LeftPanel, HorizontalAlignment='center', Position=[12 110 210 22], Text="Kd");
setDSlider = uislider(LeftPanel);
setDSlider.ValueChangedFcn = @(t,~)KdChange;
setDSlider.Value = 0.005;
setDSlider.Position = [12 100 210 3];
setDSlider.Limits = [0.0001 0.01];

%% Graf
hAx = uiaxes('Parent', RightPanel,'Position', [10 100 440 400], 'YLim',[-100 120]);
uiplot = plot(hAx,temperatureWindow);
hold(hAx, "on");
pPlot = plot(hAx, outPWindow);
iPlot = plot(hAx, outIWindow);
dPlot = plot(hAx, outDWindow);
pidPlot = plot(hAx, outPIDWindow,'LineWidth',1);
SetPointPlot = plot(hAx, SetPointWindow);
legend(hAx,'Temperature','P','I','D','PIDout');

hFig.Visible = 'on';

disp("gui done")


%% Timers
pidTm = timer; % create an instance of timer
pidTm.Period = 0.005;
pidTm.ExecutionMode = 'fixedSpacing';
%pidTm.BusyMode = 'drop';
pidTm.TimerFcn = @(h,~)pidLoop(regulator);


dispTm = timer; % create an instance of timer
dispTm.Period = 1;
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
    

    outI = outI + Ki*(err+errPrev);
    outI(outI<0) = 0;
    outI(outI>100) = 100;
    
    outPID = outP + outI + outD;
    outPID(outPID<0) = 0;
    write(device,outPID,'uint8');

    temperatureWindow(end) = temperature;
    outPWindow(end) = outP;
    outIWindow(end) = outI;
    outDWindow(end) = outD;
    outPIDWindow(end) = outPID;
    SetPointWindow(end) = SetPoint;

    temperatureWindow = circshift(temperatureWindow, 1);
    outPWindow = circshift(outPWindow, 1);
    outIWindow = circshift(outIWindow, 1);
    outDWindow = circshift(outDWindow, 1);
    outPIDWindow = circshift(outPIDWindow, 1);
    SetPointWindow = circshift(SetPointWindow, 1);

    errPrev = err;
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
    tr.Value = SetPoint;
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



end