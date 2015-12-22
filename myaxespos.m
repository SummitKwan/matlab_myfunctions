% posAxes = myaxespos(posCtrAxes, posCtrBox)
% to calculate the [left, down, width, height] format based on
% the [xcenter, ycenter, width,height] format in the whole figure, 
% or in a biger box [xcenter, ycenter, width,height]
% written by Shaobo Guan (Summit Kwan), Jun 11, 2013

function posAxes = myaxespos(posCtrAxes, posCtrBox)

if nargin == 0
    disp('the function myaxespos needs input arguments');
elseif nargin == 1
    posCtrBox = [0.5,0.5,1,1];
elseif nargin == 2
elseif nargin >  2
    disp('too many arguments for function mysubplot');
end

posAxesInbox = [0,0,1,1];
posAxes = posAxesInbox;

posAxesInbox([1,2]) = (posCtrAxes([1,2])-0.5).*posCtrBox([3,4]) + posCtrBox([1,2]);
posAxesInbox([3,4]) = posCtrAxes([3,4]).*posCtrBox([3,4]);

cen2edge = [
    1,    0, -0.5,    0
    0,    1,    0, -0.5
    0,    0,    1,    0
    0,    0,    0,    1
];
posAxes = transpose(cen2edge * posAxesInbox(:));




end