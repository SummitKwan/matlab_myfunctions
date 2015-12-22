function [h,m,n,mm,nn,r] = mysubplot(m,n,mm,nn,r)
% m : total num of rows
% n : total num of columns
% mm: the current row
% nn: the current column
% r : ratio of the panal

if nargin <= 1
    disp('not enough input parameters for function mysubplot');
elseif nargin==2 || nargin==3 || nargin==4
    r=0.8;
    if nargin==2 || nargin==3
        if nargin == 2
            mm= n;
            n = ceil(sqrt(m));
            m = ceil(m/n);
        end

        % if more than 2
        i=mm;
        mm=ceil(i/n);
        nn=mod(i,n);
        if nn==0
            nn=n;
        end
    end
end

if length(r)==1
    r(2)=r;
end

h=axes('Position', ...
    [1/n*(nn-1+(1-r(1))/2),1/m*(m-mm+(1-r(2))/2), 1/n*r(1), 1/m*r(2)]);

end