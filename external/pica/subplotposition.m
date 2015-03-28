function [left, bottom, width, height] = subplotposition(x,numx,y,numy,spacex,spacey)

% [left, bottom, width, height] = subplotposition(x,numx,y,numy,spacex,spacey)
% 
% Calls subplot passing a calculated position
% numx is the number of columns, x is the column to use counted
% from the left
%
% numy is the number of rows, y is the row to use counted from the
% bottom
%
% spacex and spacey are optional and specify the spacing between plots 
% the default is 0.05

if nargin < 5,
  spacex = 0.05;
end;

if nargin < 6,
  spacey = spacex;
end;

height = (1-spacey)/numy - spacey;
bottom = (y-1)*(height+spacey) + spacey;

width = (1-spacex)/numx - spacex;
left = (x-1)*(width+spacex) + spacex;

subplot('position', [left, bottom, width, height]);