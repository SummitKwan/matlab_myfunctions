function [h_axes,m,n,mm,nn,r] = mysubplot(varargin)
% 
% aim:         replace original subplot
% requires:    data under TDT orgnization format
% based on:    none
% improvement: 
% 
% input:
% m : total num of rows
% n : total num of columns
% mm: the current row
% nn: the current column
% r : ratio of the panal
%              
% example:
%   mysubplot(12,3);
%       12 axes in total, plot in the third one
%   mysubplot(4,3,3);
%       4*3 axes in total, plot in the third one
%   mysubplot(4,3,1,3);
%       4*3 axes in total, plot in the first row, third column
%   mysubplot(12,3, 'r', 0.6);
%       12 axes in total, plot in the third one, axes size ratio=0.6;
%   mysubplot(12,3, 'r', [0.8,0.6]);
%       12 axes in total, plot in the third one, axes size ratio=[0.8,0.6];
% 
% 
% ---------- Shaobo Guan, 2014-0914, SUN ----------
% Sheinberg lab, Brown University, USA, Shaobo_Guan@brown.edu
% 


% --------------------
% default parameters
m  =   1;
n  =   1;
mm =   1;
nn =   1;
r  = 0.8;


% --------------------
% parse inputs

% find first consecutive numeric inputs (before the string input)
tf_nmrc = cellfun(@isnumeric, varargin); % true/false of numeric inputs
indx_non_numr = find(tf_nmrc==false);    % index of non-numeric inputs
if isempty(indx_non_numr)
    num_mn = length(tf_nmrc);            % number of inputs for m,n,mm,nn
    tf_prmt = false;                     % true/false of containing parameter input
else
    indx_prmt = indx_non_numr(1);        % start index of parameter input
    num_mn = indx_prmt - 1;              % number of inputs for m,n,mm,nn
    tf_prmt = true;                      % true/false of containing parameter input
end


% parse m, n, mm, nn
if num_mn > 4
    disp('too many mumerical input parameters for function mysubplot');
elseif num_mn == 4
    m  = varargin{1};
    n  = varargin{2};
    mm = varargin{3};
    nn = varargin{4};
elseif num_mn == 3
    m  = varargin{1};
    n  = varargin{2};
    mm = ceil(varargin{3} ./n);
    nn = varargin{3} - n.*(mm-1);
elseif num_mn == 2
    n = ceil(sqrt(varargin{1}));
    m = ceil(varargin{1}./n);
    mm = ceil(varargin{2} ./n);
    nn = varargin{2} - n.*(mm-1);
elseif num_mn < 2
    disp('non enough mumerical input parameters for function mysubplot');
end

% parse other pamameters
if tf_prmt
    for i = indx_prmt:2:length(varargin)
        eval([varargin{i} '=varargin{i+1};']);
    end
end
if length(r)==1
    r(2)=r;
end

% plot axes
h_axes = axes('Position', ...
    [1/n*(nn-1+(1-r(1))/2),1/m*(m-mm+(1-r(2))/2), 1/n*r(1), 1/m*r(2)]);


end