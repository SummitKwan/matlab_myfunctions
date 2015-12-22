function [f, y] = myfft(t,x, varargin)
% fft returning freqency directly
% 
% example use:
%   t=0:0.001:1;
%   [f,y] = myfft(t,sin(2.*pi.*30.*t),'2sided','f_range',[-100,100]);
%   plot(f,abs(y));
% 
% input:
%   t: time grid if N*1 , or sampling interval dt if 1*1
%   x: values in time domain, N*1 or N*M, M = number of realizaions/trials
%   optional parameters:
%       '2sided' or'1sided',          : two sided or one sided
%       'f_range', [f_start, f_end]   : set the freq range
% output:
%   f: freq grid
%   y: fourier transform of x
% 
% ---------- Shaobo Guan, 2015-0302, SUN ----------
% Sheinberg lab, Brown University, USA, Shaobo_Guan@brown.edu

tf_2sided = false;
f_range =[];

% ========== get optional parameters ==========
i = 1;
while i <= length(varargin)
    if strcmp(varargin{i},'2sided')
        tf_2sided = true;
    elseif strcmp(varargin{i},'1sided')
        tf_2sided = false;
    elseif isstr(varargin{i})
        if ismember(varargin{i},{'f_range'})
        eval([varargin{i} '=varargin{i+1};']);
        i=i+1;
        end
    end
    i=i+1;
end

% ---------- get basic info of input signal ----------

if size(x,1) == 1
    x = x';          % if a row vector, make it a column
end
n  = size(x,1);      % number of samples in time domain
if length(t)==1
    t = (0:n-1)'.*t; % generate time grid t of input is dt
end
dt = t(2)-t(1);      % sample interval
fs = 1./dt;          % sample frequency
T  = t(end)-t(1)+dt; % total time

nf = pow2(nextpow2(n)); % number of frequencies


% fft
y = fft(x,nf);
f = [0:nf-1].*(fs./nf);


% ---------- if two sided ----------
if tf_2sided
    y = fftshift(y);          % Rearrange y values
    f = (-nf/2:nf/2-1)*(fs/nf);  % 0-centered frequency range
end

% ---------- cut the freq range of intrest ----------
if ~isempty(f_range)
    y = y ( f>=f_range(1) & f<= f_range(end), :);
    f = f ( f>=f_range(1) & f<= f_range(end));
end



end