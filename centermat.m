function AA = centermat(A,mm,nn)
% cut the maxtrix and get its cneter part, so that it becomes m*n

[m,n,~] = size(A);
AA = A( floor((m-mm)/2)+1:floor((m-mm)/2)+mm,...
    floor((n-nn)/2)+1:floor((n-nn)/2)+nn ,:,:);

end