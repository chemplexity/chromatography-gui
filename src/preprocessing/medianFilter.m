function y = medianFilter(varargin)
% ------------------------------------------------------------------------
% Method      : medianFilter
% Description : Filters narrow spikes in signal  
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   y = medianfilter(y)
%   y = medianfilter( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   y -- intensity values
%       array | matrix
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'points' -- size of filter window
%       10 (default) | number (>2)
%
%   'threshold' -- filter values greater than median x threshold
%       2 (default) | number (>0)
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   y = medianfilter(y)
%   y = medianfilter(y, 'points', 5)

% ---------------------------------------
% Defaults
% ---------------------------------------
default.points    = 10;
default.threshold = 2;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

p.addRequired('y', @ismatrix);

p.addParameter('points',    default.points, @isscalar);
p.addParameter('threshold', default.points, @isscalar);

p.parse(varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
y = p.Results.y;
n = p.Results.points;
m = p.Results.threshold;

% ---------------------------------------
% Validate
% ---------------------------------------
if size(y,1) == 1
    y = y(:);
end
    
n = round(abs(n));

if n < 3
    n = 3;
elseif n > size(y,1)
    n = size(y,1);
end

m = abs(m);

% ---------------------------------------
% Filter
% ---------------------------------------
yi(:,1) = 1:ceil(size(y,1)/n);
yi(:,2) = (yi(:,1)-1) .* n + 1;
yi(:,3) = yi(:,1) .* n;

if size(y,1) - yi(end,2) <= 3
    yi(end,:) = [];
else
    yi(end,3) = size(y,1);
end

for i = 1:size(yi,1)
    
    ii = yi(i,2):yi(i,3);
    yy = y(ii);
    
    ym = median(yy);

    yy(abs(yy) >= ym * m) = ym;
    y(ii) = yy;
    
end

end