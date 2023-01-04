classdef test_gui_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        RegulationtypeButtonGroup  matlab.ui.container.ButtonGroup
        PIDButton                  matlab.ui.control.ToggleButton
        PIButton                   matlab.ui.control.ToggleButton
        BBButton                   matlab.ui.control.ToggleButton
        setPWMSlider               matlab.ui.control.Slider
        setPWMSliderLabel          matlab.ui.control.Label
        controlTypeSwitch          matlab.ui.control.Switch
        controlTypeSwitchLabel     matlab.ui.control.Label
        setTempSlider              matlab.ui.control.Slider
        setTempSliderLabel         matlab.ui.control.Label
        RightPanel                 matlab.ui.container.Panel
        UIAxes                     matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: setPWMSlider
        function setPwmValue(app, event)
            value = app.setPWMSlider.Value;
            
        end

        % Value changed function: setTempSlider
        function setTempValue(app, event)
            value = app.setTempSlider.Value;
            
        end

        % Value changed function: controlTypeSwitch
        function ctrlType(app, event)
            value = app.controlTypeSwitch.Value;
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {238, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 657 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {238, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create setTempSliderLabel
            app.setTempSliderLabel = uilabel(app.LeftPanel);
            app.setTempSliderLabel.HorizontalAlignment = 'right';
            app.setTempSliderLabel.Position = [87 157 51 22];
            app.setTempSliderLabel.Text = 'setTemp';

            % Create setTempSlider
            app.setTempSlider = uislider(app.LeftPanel);
            app.setTempSlider.ValueChangedFcn = createCallbackFcn(app, @setTempValue, true);
            app.setTempSlider.Position = [8 145 210 3];

            % Create controlTypeSwitchLabel
            app.controlTypeSwitchLabel = uilabel(app.LeftPanel);
            app.controlTypeSwitchLabel.HorizontalAlignment = 'center';
            app.controlTypeSwitchLabel.Position = [90 403 67 22];
            app.controlTypeSwitchLabel.Text = 'controlType';

            % Create controlTypeSwitch
            app.controlTypeSwitch = uiswitch(app.LeftPanel, 'slider');
            app.controlTypeSwitch.Items = {'PWM', 'TEMP'};
            app.controlTypeSwitch.ValueChangedFcn = createCallbackFcn(app, @ctrlType, true);
            app.controlTypeSwitch.Position = [100 440 45 20];
            app.controlTypeSwitch.Value = 'PWM';

            % Create setPWMSliderLabel
            app.setPWMSliderLabel = uilabel(app.LeftPanel);
            app.setPWMSliderLabel.HorizontalAlignment = 'right';
            app.setPWMSliderLabel.Position = [86 229 51 22];
            app.setPWMSliderLabel.Text = 'setPWM';

            % Create setPWMSlider
            app.setPWMSlider = uislider(app.LeftPanel);
            app.setPWMSlider.ValueChangedFcn = createCallbackFcn(app, @setPwmValue, true);
            app.setPWMSlider.Position = [7 217 210 3];

            % Create RegulationtypeButtonGroup
            app.RegulationtypeButtonGroup = uibuttongroup(app.LeftPanel);
            app.RegulationtypeButtonGroup.Title = 'Regulation type';
            app.RegulationtypeButtonGroup.Position = [55 273 123 106];

            % Create BBButton
            app.BBButton = uitogglebutton(app.RegulationtypeButtonGroup);
            app.BBButton.Text = 'BB';
            app.BBButton.Position = [11 52 100 23];
            app.BBButton.Value = true;

            % Create PIButton
            app.PIButton = uitogglebutton(app.RegulationtypeButtonGroup);
            app.PIButton.Text = 'PI';
            app.PIButton.Position = [11 31 100 23];

            % Create PIDButton
            app.PIDButton = uitogglebutton(app.RegulationtypeButtonGroup);
            app.PIDButton.Text = 'PID';
            app.PIDButton.Position = [11 10 100 23];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Temp')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.YMinorGrid = 'on';
            app.UIAxes.Position = [6 178 408 296];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end



    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = test_gui_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
    
end

