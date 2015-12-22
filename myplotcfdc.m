function [h_line, h_shade] = myplotcfdc(x, y, varargin)
% 
% "my plot confidence"
% aim:         plot curve and the shaded confidence inverval
% requires:    myplotarea (my plot area)
% based on:    none
% improvement: 
% 
% example:
%   myplotcfdc(x, y, e)
%   myplotcfdc(x, y, eu, yr)
%   myplotcfdc(x, y, yu, yr, 'boundary')
%   [h_line, h_shade]= myplotcfdc(x, y, e, 'Color', [1,0,0]);
%       set(h_shade,'FaceAlpha',0.2,'LineStyle','--');
%
% input:
%   x :  N*1 array
%   y :  N*1 array
%   e :  N*1 or 1*1, symetric error
%   el:  N*1, (>=0) lower error (= y  - yl)
%   eu:  N*1, (>=0) upper error (= yu - y )
%   yl:  N*1 array, lower boundary
%   yu:  N*1 array, upper boundary
%   optional parameters:
%       'boundary'  : input is yl, yu
%       'error'     : input is el, eu (default)
%       'Color', [r,g,b]:  between 0~1
% output:
%   h_line :  handle of line  object
%   h_shade:  handle of patch object
%              
% ---------- Shaobo Guan, 2015-0303, MON ----------
% Sheinberg lab, Brown University, USA, Shaobo_Guan@brown.edu
%


h_line = [];
h_shade= [];
tf_boundary = false;

% parse inputs variables
num_varin = length(varargin);
if isempty(num_varin)
    disp('too few parameters for myplotcfdc');
    return
elseif num_varin==1
    e = varargin{1};    % if only one input, get e
elseif ~isnumeric(varargin{2})
    e = varargin{1};    % if only one numeric input get e
else
    el = varargin{1};   % if two numeric inputs, get el and eu
    eu = varargin{2};
end
for i=1:num_varin
    
end

end