function y = movingAverage(varargin)

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

p.addRequired('x', @ismatrix);
p.addOptional('n', 10, @isscalar);

p.parse(varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
x = p.Results.x;
n = p.Results.n;

% ---------------------------------------
% Validate
% ---------------------------------------
if size(x,1) == 1
    x = x(:);
end

n = round(abs(n));

if n < 1
    n = 1;
elseif n > size(x,1)
    n = size(x,1);
end

% ---------------------------------------
% Moving Average
% ---------------------------------------
y0 = cumsum(x) / n;
y0(n+1:end,:) = y0(n+1:end,:) - y0(1:end-n,:);
y0(1:n,:) = x(1:n,:);

x = flipud(x);

y1 = cumsum(x) / n;
y1(n+1:end,:) = y1(n+1:end,:) - y1(1:end-n,:);
y1(1:n,:) = x(1:n,:);

y1 = flipud(y1);

y = (y0 + y1) / 2;

end
