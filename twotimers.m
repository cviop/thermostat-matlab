
tm1 = timer; % create an instance of timer
tm1.Period = 0.01;
tm1.ExecutionMode = 'fixedDelay';
tm1.TimerFcn = @(t,~)timfun1;


tm2 = timer; % create an instance of timer
tm2.Period = 3;
tm2.ExecutionMode = 'fixedRate';
tm2.BusyMode = 'drop';
tm2.TimerFcn = @(t,~)timfun2;

start(tm1); % start the timer
start(tm2); % start the timer


function timfun1(~)
disp("t1")
disp(datetime('now','Format','mm:ss:SSS'))
disp("----")
end

function timfun2(~)
disp("t2")
disp(datetime('now','Format','mm:ss:SSS'))
disp("----")
pause(2)
end



