function y=prevexpn(x,base)
% previous exponent number of a specific base

y=base.^(floor(log(x)/log(base)));

end