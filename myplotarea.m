function h_shade = myplotarea(x,yl,yu, varargin)
% 
% my plot area
% aim:         plot filled area between yl and yu
% requires:    none
% based on:    none
% improvement: 
% 
% input:
%   x :  N*1 array
%   yl:  N*1 array, lower boundary
%   yu:  N*1 array, upper boundary
%   C:   color, [r,g,b] between 0~1
% output:
%   h_shade: the handle of patch object, can be used to edit the appreance
%              
% example:
%   myplotshade(x,yl,yu);
%   or:
%   h = myplotshade(x,yl,yu); set(h, 'FaceAlpha',0.8,'EdgeType','--');
% 
% ---------- Shaobo Guan, 2015-0303, MON ----------
% Sheinberg lab, Brown University, USA, Shaobo_Guan@brown.edu
%

% defalt color
C = [0,0.4470,0.7410];
% default alpha value of shade
ShadeAlpha = 0.4;

% get color from input
if ~isempty(varargin)
    C = varargin{1};
end

x  = x(:);
yl = yl(:);
yu = yu(:);

% plot area using fill
h_shade = fill( x([1:1:end,end:-1:1]), [yl(1:1:end); yu(end:-1:1)], C);
set(h_shade, 'FaceAlpha',ShadeAlpha, 'LineStyle','none','EdgeColor',C);

end