function uart_communication(dev)
%profile clear;
wlen = 1000;
window = zeros(wlen,1);




% hFig = uifigure;
% hFig.CloseRequestFcn = @(src,event)my_closereq(src);

function my_closereq(fig)
    selection = uiconfirm(fig,'Close the figure window?',...
        'Confirmation');
    
    switch selection
        case 'OK'
            delete(fig)
            stop(timerfind)
            delete(timerfind)
            clear dev
            return
        case 'Cancel'
            return
    end
end


tm = timer; % create an instance of timer
tm.Period = 1;
tm.ExecutionMode = 'fixedDelay';
tm.TimerFcn = @(h,~)showHW(window);
start(tm); % start the timer

% regTm = timer; % create an instance of timer
% regTm.Period = 0.2;
% regTm.ExecutionMode = 'fixedRate';
% regTm.TimerFcn = @(h,~)showHW(window);
% start(regTm); % start the timer

% Create UIFigure and hide until all components are created
UIFigure = uifigure('Visible', 'off');
UIFigure.AutoResizeChildren = 'off';
UIFigure.Position = [100 100 657 480];
UIFigure.Name = 'MATLAB App';
%UIFigure.SizeChangedFcn = createCallbackFcn(@updateAppLayout, true);

% Create GridLayout
GridLayout = uigridlayout(UIFigure);
GridLayout.ColumnWidth = {238, '1x'};
GridLayout.RowHeight = {'1x'};
GridLayout.ColumnSpacing = 0;
GridLayout.RowSpacing = 0;
GridLayout.Padding = [0 0 0 0];
GridLayout.Scrollable = 'on';

% Create LeftPanel
LeftPanel = uipanel(GridLayout);
LeftPanel.Layout.Row = 1;
LeftPanel.Layout.Column = 1;

% Create setTempSliderLabel
setTempSliderLabel = uilabel(LeftPanel);
setTempSliderLabel.HorizontalAlignment = 'right';
setTempSliderLabel.Position = [87 157 51 22];
setTempSliderLabel.Text = 'setTemp';

% Create setTempSlider
setTempSlider = uislider(LeftPanel);
%setTempSlider.ValueChangedFcn = createCallbackFcn(src, @setTempValue, true);
setTempSlider.Position = [8 145 210 3];
setTempSlider.Limits = [0 3.3];

% Create controlTypeSwitchLabel
controlTypeSwitchLabel = uilabel(LeftPanel);
controlTypeSwitchLabel.HorizontalAlignment = 'center';
controlTypeSwitchLabel.Position = [90 403 67 22];
controlTypeSwitchLabel.Text = 'controlType';

% Create controlTypeSwitch
controlTypeSwitch = uiswitch(LeftPanel, 'slider');
controlTypeSwitch.Items = {'PWM', 'TEMP'};
%controlTypeSwitch.ValueChangedFcn = createCallbackFcn(src, @ctrlType, true);
controlTypeSwitch.Position = [100 440 45 20];
controlTypeSwitch.Value = 'PWM';

% Create setPWMSliderLabel
setPWMSliderLabel = uilabel(LeftPanel);
setPWMSliderLabel.HorizontalAlignment = 'right';
setPWMSliderLabel.Position = [86 229 51 22];
setPWMSliderLabel.Text = 'setPWM';

% Create setPWMSlider
setPWMSlider = uislider(LeftPanel);
setPWMSlider.ValueChangedFcn = @ylineupdate;
setPWMSlider.Position = [7 217 210 3];
setPWMSlider.Limits = [0 3.3];

% Create RegulationtypeButtonGroup
RegulationtypeButtonGroup = uibuttongroup(LeftPanel);
RegulationtypeButtonGroup.Title = 'Regulation type';
RegulationtypeButtonGroup.Position = [55 273 123 106];

% Create BBButton
BBButton = uitogglebutton(RegulationtypeButtonGroup);
BBButton.Text = 'BB';
BBButton.Position = [11 52 100 23];
BBButton.Value = true;

% Create PIButton
PIButton = uitogglebutton(RegulationtypeButtonGroup);
PIButton.Text = 'PI';
PIButton.Position = [11 31 100 23];

% Create PIDButton
PIDButton = uitogglebutton(RegulationtypeButtonGroup);
PIDButton.Text = 'PID';
PIDButton.Position = [11 10 100 23];

% Create RightPanel
RightPanel = uipanel(GridLayout);
RightPanel.Layout.Row = 1;
RightPanel.Layout.Column = 2;

% Create UIAxes
UIAxes = uiaxes(RightPanel);
title(UIAxes, 'Temp')
xlabel(UIAxes, 'X')
ylabel(UIAxes, 'Y')
zlabel(UIAxes, 'Z')
UIAxes.XGrid = 'on';
UIAxes.XMinorGrid = 'on';
UIAxes.YGrid = 'on';
UIAxes.YMinorGrid = 'on';
UIAxes.Position = [6 178 408 296];
UIAxes.YLim = [0 3.3];

% Show the figure after all components are created
UIFigure.Visible = 'on';


% hAx = uiaxes('Parent', hFig, 'Position', [10 10 540 400],'YLim',[0 3.3]);
uiplot = plot(UIAxes,window);

while(1)
    %profile on;
    write(dev,101,"uint8");
    voltage = read(dev, 1, 'uint8')/255 *3.3;
%     if voltage > 3
%         write(dev,0,'uint8');
%     else
%         write(dev,100,'uint8');
%     end
    %voltage = randn(1,1);

    if(BBButton.Value)
            if voltage > setTempSlider.Value
                write(dev,0,'uint8');
            else
                write(dev,100,'uint8');
            end
        %voltage = randn(1,1);
    end

    window(end) = voltage;
    window = circshift(window,1);
    %uiplot.YData = window;
    %yline(UIAxes,setTempSlider.Value)
    %disp("data recvd")
    %profile off;
    %profile viewer;
end




function showHW(data)
    uiplot.YData = window;
    datetime('now','Format','ss.SSS')
    %drawnow();
end


 
end

