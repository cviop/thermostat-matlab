tm = timer; % create an instance of timer
tm.Period = 1;
tm.ExecutionMode = 'fixedDelay';
tm.TimerFcn = @(h,~)showHW();
start(tm); % start the timer

function showHW()
    datetime('now','Format','ss.SSS')
end