

serialportlist;
%clear dev
%clear;clc; close all force;close all;


%dev = serialport("COM4",115200);



uart_communication(dev);



% serialportlist;
% clear;clc; close all force;
% dev = serialport("COM4",115200);
% 
% wlen = 500;
% window = zeros(wlen,1);
% 
% hFig = uifigure;
% hAx = uiaxes('Parent', hFig, 'Position', [10 10 540 400],'YLim',[0 3.3]);
% uiplot = plot(hAx,window);
% 
% while(1)
%     tic
%     write(dev,101,"uint8");
%     toc
%     voltage = read(dev, 1, 'uint8')/255 *3.3;
%     if voltage > 3
%         write(dev,0,'uint8');
%     else
%         write(dev,100,'uint8');
%     end
% 
%     %voltage = randn(1,1);
%     toc
%     window(end) = voltage;
%     toc
%     window = circshift(window,1);
%     toc
%     uiplot.YData = window;
%     toc
%     drawnow();
%     toc
% end


