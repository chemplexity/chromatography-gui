function varargout = exponentialgaussian(varargin)
% ------------------------------------------------------------------------
% Method      : exponentialgaussian
% Description : Curve fitting analysis of chromatographic peaks
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   peaks = exponentialgaussian(x, y)
%   peaks = exponentialgaussian( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Optional)
% ------------------------------------------------------------------------
%   x -- time values (size = n x 1)
%       array
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   y -- intensity values
%       array | matrix (size = n x m)
%       
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'center' -- search window center
%       x at max(y) (default) | number
%
%   'width' -- search window width
%       1 (default) | number
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   peaks = exponentialgaussian(x, y)
%   peaks = exponentialgaussian(x, y, 'center', 22.10)
%   peaks = exponentialgaussian(x, y, 'center', 12.44, 'width', 0.24)
%
% ------------------------------------------------------------------------
% References
% ------------------------------------------------------------------------
%   K. Lan, et. al. Journal of Chromatography A, 915 (2001) 1-13

% ---------------------------------------
% Defaults
% ---------------------------------------
default.center = 0;
default.width  = 1;

default.cutoff.area = 1E-5;

varargout{1} = [];

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'y', @ismatrix);

addOptional(p, 'x', [], @isnumeric);

addParameter(p, 'center', default.center);
addParameter(p, 'width',  default.width);
    
parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
x      = p.Results.x;
y      = p.Results.y;
center = p.Results.center;
width  = p.Results.width;

if isempty(center)
    center = default.center;
end

if isempty(width)
    width = default.width;
end

% ---------------------------------------
% Validate
% ---------------------------------------

% Input: x
if ~isempty(x)
    y = p.Results.x;
    x = p.Results.y;
else
    x = (1:size(y,1))';
end

if isempty(x)
    x = 1:size(y,1);
end

if size(x,1) == 1 && size(x,2) > 1
    x = x';
end

% Input: y
type = class(y);

if ~strcmpi(type, 'double')
    x = double(x);
    y = double(y);
end

if size(y,1) == 1 && size(y,2) > 1
    y = y';
end

if size(x,1) ~= size(y,1)
    x = 1:size(y,1);
end

% Parameter: 'center'
if center == 0
    [~,index] = max(y);
    center = x(index,1);
elseif center > max(x)
    center = max(x) - width/2;
elseif center < min(x)
    center = min(x) + width/2;
elseif center + width/2 > max(x)
    width = (max(x) - center) * 2;
elseif center - width/2 < min(x)
    width = (center - min(x)) * 2;
end

% ---------------------------------------
% Variables
% ---------------------------------------
peaks = struct(...
    'time',   [],...
    'width',  [],...
    'height', [],...
    'area',   [],...
    'fit',    [],...
    'error',  []...
);

if size(y,1) <= 1 || ~nnz(y)
    return
end

pIndex = find(x>=center,1);

pSlope = '';
pDown = 0;
pUp = 0;

pLX = x(pIndex,1);
pRX = x(pIndex,1);
pLY = y(pIndex,1);
pRY = y(pIndex,1);
pLimit = 0.3;
pMax = 10;

for i = pIndex:length(x)
    
    if y(i,1) >= pRY
        pRX = x(i);
        pRY = y(i,1);
        pUp = pUp + 1;
        if pUp > 2
            pDown = 0;
        end
    elseif y(i,1) < pRY
        pDown = pDown + 1;
        if pDown > 2
            pUp = 0;
        end
    end
    
    if pUp == pMax
        pSlope = [pSlope, 'u'];
    end
    
    if pDown == pMax
        pSlope = [pSlope, 'd'];
    end
    
    if x(i) > center + pLimit
        break
    elseif strcmpi(pSlope, 'ud') || strcmpi(pSlope, 'dud')
        break
    end
    
end

pDown = 0;
pUp = 0;
pSlope = '';

for i = pIndex:-1:1
    
    if y(i,1) > pLY
        pLX = x(i);
        pLY = y(i,1);
        pUp = pUp + 1;
        if pUp > 2
            pDown = 0;
        end
    elseif y(i,1) < pLY
        pDown = pDown + 1;
        if pDown > 2
            pUp = 0;
        end
    end
    
    if pUp == pMax
        pSlope = [pSlope, 'u'];
    end
    
    if pDown == pMax
        pSlope = [pSlope, 'd'];
    end
    
    if x(i) < center - pLimit
        break
    elseif strcmpi(pSlope, 'ud') || strcmpi(pSlope, 'dud')
        break
    end
    
end

pLCount = pIndex - find(x>=pLX,1);
pRCount = find(x>=pRX,1) - pIndex;

if pRCount == 0 && pLCount == 0
    center = x(pIndex);
elseif pRCount ~= 0 && (pRCount < pLCount || pLCount == 0)
    center = pRX;
elseif pLCount ~= 0 && (pLCount < pRCount || pRCount == 0)
    center = pLX;
end

width = 0.10;

% ---------------------------------------
% Peak detection
% ---------------------------------------
peak = peakdetection(x, y, 'center', center, 'width', width);

if ~isempty(peak)
    peak = addParameters(x, y, peak);
end

% ---------------------------------------
% Exponentially modified gaussian
% ---------------------------------------
EGH.y = @(x, c, h, w, e) h .* exp((-(x-c).^2) ./ ((2.*(w.^2)) + (e.*(x-c))));
EGH.w = @(a, b, alpha) sqrt((-1 ./ (2 .* log(alpha))) .* (a .* b));
EGH.e = @(a, b, alpha) (-1 ./ log(alpha)) .* (b - a);
EGH.a = @(h, w, e, e0) h .* (w .* sqrt(pi/8) + abs(e)) .* e0;
EGH.t = @(w, e) atan(abs(e) ./ w);

EGH.c = @(t) 4.000000 * t^0 + -6.293724 * t^1 + 9.2328340 * t^2 + ...
            -11.34291 * t^3 + 9.1239780 * t^4 + -4.173753 * t^5 + ...
            0.8277970 * t^6;

% ---------------------------------------
% Curve fitting
% ---------------------------------------
for i = 1:length(y(1,:))
    
    peaks.time(i)   = 0;
    peaks.width(i)  = 0;
    peaks.height(i) = 0;
    peaks.area(i)   = 0;
    peaks.fit(:,i)  = zeros(size(y,1), 1, type);
    peaks.error(i)  = 0;
    
    % Check y-values
    if ~nnz(y(:,i))
        continue
    end
    
    % Check peak values
    if isempty(peak) || any(peak.center(:,i) == 0)
        continue
    end
    
    % Get peak parameters
    c = peak.center(:,i);
    h = peak.height(:,i);
    w = EGH.w(peak.a(:,i), peak.b(:,i), peak.alpha(:,i));
    e = EGH.e(peak.a(:,i), peak.b(:,i), peak.alpha(:,i));
    
    % Determine limits of function
    lim(:,1) = (2 * w(1)^2) + (e(1) .* (x-c(1))) > 0;
    lim(:,2) = (2 * w(2)^2) + (e(2) .* (x-c(2))) > 0;
    lim(:,3) = (2 * w(3)^2) + (e(3) .* (x-c(3))) > 0;
    lim(:,4) = (2 * w(4)^2) + (e(4) .* (x-c(4))) > 0;
    lim(:,5) = (2 * w(1)^2) + (-e(1) .* (x-c(1))) > 0;
    lim(:,6) = (2 * w(2)^2) + (-e(2) .* (x-c(2))) > 0;
    lim(:,7) = (2 * w(3)^2) + (-e(3) .* (x-c(3))) > 0;
    lim(:,8) = (2 * w(4)^2) + (-e(4) .* (x-c(4))) > 0;
    
    % Calculate fit
    yfit = zeros(length(y(:,i)), 8);
    
    yfit(lim(:,1),1) = EGH.y(x(lim(:,1)), c(1), h(1), w(1), e(1));
    yfit(lim(:,2),2) = EGH.y(x(lim(:,2)), c(2), h(2), w(2), e(2));
    yfit(lim(:,3),3) = EGH.y(x(lim(:,3)), c(3), h(3), w(3), e(3));
    yfit(lim(:,4),4) = EGH.y(x(lim(:,4)), c(4), h(4), w(4), e(4));
    yfit(lim(:,5),5) = EGH.y(x(lim(:,5)), c(1), h(1), w(1), -e(1));
    yfit(lim(:,6),6) = EGH.y(x(lim(:,6)), c(2), h(2), w(2), -e(2));
    yfit(lim(:,7),7) = EGH.y(x(lim(:,7)), c(3), h(3), w(3), -e(3));
    yfit(lim(:,8),8) = EGH.y(x(lim(:,8)), c(4), h(4), w(4), -e(4));
    
    % Set values outside normal range to zero
    yfit(yfit(:,1) < h(1) * 10^-9 | yfit(:,1) > h(1) * 10, 1) = 0;
    yfit(yfit(:,2) < h(2) * 10^-9 | yfit(:,2) > h(2) * 10, 2) = 0;
    yfit(yfit(:,3) < h(3) * 10^-9 | yfit(:,3) > h(3) * 10, 3) = 0;
    yfit(yfit(:,4) < h(4) * 10^-9 | yfit(:,4) > h(4) * 10, 4) = 0;
    yfit(yfit(:,5) < h(1) * 10^-9 | yfit(:,5) > h(1) * 10, 5) = 0;
    yfit(yfit(:,6) < h(2) * 10^-9 | yfit(:,6) > h(2) * 10, 6) = 0;
    yfit(yfit(:,7) < h(3) * 10^-9 | yfit(:,7) > h(3) * 10, 7) = 0;
    yfit(yfit(:,8) < h(4) * 10^-9 | yfit(:,8) > h(4) * 10, 8) = 0;
    
    w(5:8) = w(1:4);
    
    for j = 1:size(yfit,2)
        w(j) = peakWidth(x, yfit(:,j));
        rmsd(j) = peakError(x, y(:,i), yfit(:,j), w(j));
    end
    
    [~, index] = min(rmsd);
    yIndex = index;
    
    if index > 4
        index = index - 4;
        e = -e(index);
    else
        e = e(index);
    end
    
    if isnan(rmsd(yIndex))
        continue
    end
    
    peaks.time(i)   = c(index);
    peaks.height(i) = h(index);
    peaks.width(i) = w(yIndex);
    peaks.error(i)  = rmsd(yIndex);
    peaks.fit(:,i) = yfit(:,yIndex);
    
    if size(x,1) == size(peaks.fit(:,i), 1)
        peaks.area(i) = peakArea(x, y, peaks.fit(:,i));
    else
        peaks.width(i) = w(yIndex);
        peaks.area(i) = EGH.a(h(index), w(yIndex), e, EGH.c(EGH.t(w(index), e)));
    end
    
    if peaks.area(i) < std(y) * default.cutoff.area
        peaks.time(i)   = 0;
        peaks.width(i)  = 0;
        peaks.height(i) = 0;
        peaks.area(i)   = 0;
        peaks.fit(:,i)  = zeros(size(y,1), 1, type);
        peaks.error(i)  = 0;
    end
    
end

if ~strcmpi(type, 'double')
    peaks.fit = cast(peaks.fit, type);
end
    
varargout{1} = peaks;

end

function w = peakWidth(x,y)

f0 = 1000;
f1 = 1 / mean(diff(x));

if f1 < 1000
    
    xi = min(x) : 1/f0 : max(x);
    yi = interp1(x, y, xi, 'pchip');
    
    [ymax, i] = max(yi);
    
    ri = find(yi(i:end) <= ymax / 2, 1);
    li = find(fliplr(yi(1:i)) <= ymax / 2, 1);
    
    if ~isempty(ri) && ~isempty(li)
        w = xi(i+ri-1) - xi(i-li+1);
    else
        w = 0;
    end
    
else
    x = x(y >= max(y) / 2);
    w = max(x) - min(x);
end

end

function rmsd = peakError(x,y1,y2,w)

ymin = min(y2);
[ymax, xi] = max(y2);

if w ~= 0
    xCutoff = w*10;
    xFilter = x > x(xi)-xCutoff & x < x(xi)+xCutoff;
else
    xFilter = [];
end

yFilter = y2 >= ymin + 0.05 * (ymax-ymin);

if any(yFilter)
    if ~isempty(xFilter)
        y1 = y1(xFilter&yFilter);
        y2 = y2(xFilter&yFilter);
    else
        y1 = y1(yFilter);
        y2 = y2(yFilter);
    end
end

rmsd = sqrt(sum(abs(y2 - y1).^2) / numel(y2));
rmsd = rmsd / (ymax - ymin) * 100;

end

function area = peakArea(x0, y0, y1)

ymin = min(y1);
ymax = max(y1);

x0 = x0(y1 >= ymin + 0.001 * (ymax-ymin));
y0 = y0(y1 >= ymin + 0.001 * (ymax-ymin));

if length(y0) <= 1 || length(x0) ~= length(y0)
    area = 0;
    return
end

x0 = [x0(1)-(x0(2)-x0(1)); x0; x0(end)+x0(end)-x0(end-1)];
y0 = [0; y0; 0];

f0 = 5000;
f1 = 1/mean(diff(x0));

if f1 < f0
    xi = min(x0) : 1/f0 : max(x0);
    yi = interp1(x0, y0, xi, 'pchip');
else
    xi = x;
    yi = y;
end

dx = diff(xi);
dy = 0.5 * (yi(1:end-1) + yi(2:end));

if length(dx) == length(dy)
    area = sum(dx.*dy);
else
    area = 0;
end

% Scale to Agilent Peak Area
%if area ~= 0
%    area = (area - 0.001107524) / 0.016599114;
%end

end

function peak = addParameters(x, y, peak)

t = mean(peak.center);

if 1 / mean(diff(x)) < 200
    xi = min(x) : 1/200 : max(x);
    y = interp1(x, y, xi, 'pchip');
end

xx = x(x <= t+1 & x >= t-1);
yy = y(x <= t+1 & x >= t-1);

counterMax = 20;

if ~isempty(xx)
    
    ymin = min(yy);
    yy = yy - ymin;
    
    idx = find(xx >= t, 1);
    
    hx = [xx(idx), xx(idx)];
    hy = [yy(idx), yy(idx)];
    
    counter = 0;
    noiseCounter = 0;
    
    for i = idx:length(yy)
        if yy(i) < hy(2) && yy(i) >= yy(idx) / 2
            hx(2) = xx(i);
            hy(2) = yy(i);
            counter = 0;
            noiseCounter = 0;
        elseif yy(i) > hy(2)
            noiseCounter = noiseCounter + 1;
            if counter + 1 > counterMax
                break
            elseif noiseCounter > 3
                counter = counter + 1;
            end
        elseif yy(i) < yy(idx) / 2
            break
        end
    end
    
    counter = 0;
    noiseCounter = 0;
    
    for i = idx:-1:1
        if yy(i) < hy(1) && yy(i) >= yy(idx) / 2
            hx(1) = xx(i);
            hy(1) = yy(i);
            counter = 0;
            noiseCounter = 0;
        elseif yy(i) > hy(1)
            noiseCounter = noiseCounter + 1;
            if counter + 1 > counterMax
                break
            elseif noiseCounter > 3
                counter = counter + 1;
            end
        elseif yy(i) < yy(idx) / 2
            break
        end
    end
    
    yy = yy + ymin;
    hy = hy + ymin;
    
    if hx(2) > hx(1)
        peak.width = [peak.width; hx(2) - hx(1)];
    else
        hx = [xx(idx)-0.15, xx(idx)+0.15];
        peak.width = [peak.width; 0.15];
    end
    
    peak.center = [peak.center; xx(idx)];
    peak.height = [peak.height; yy(idx)];
    peak.alpha = [peak.alpha; (mean(hy) - ymin) / (yy(idx) - ymin)];
    peak.a = [peak.a; xx(idx) - hx(1)];
    peak.b = [peak.b; hx(2) - xx(idx)];
    
    yy = yy - ymin;
    
    hx = [xx(idx), xx(idx)];
    hy = [yy(idx), yy(idx)];
    
    counter = 0;
    noiseCounter = 0;
    
    for i = idx:length(yy)
        if yy(i) < hy(2) && yy(i) >= yy(idx) / 4
            hx(2) = xx(i);
            hy(2) = yy(i);
            counter = 0;
            noiseCounter = 0;
        elseif yy(i) > hy(2)
            noiseCounter = noiseCounter + 1;
            if counter + 1 > counterMax
                break
            elseif noiseCounter > 3
                counter = counter + 1;
            end
        elseif yy(i) < yy(idx) / 4
            break
        end
    end
    
    counter = 0;
    noiseCounter = 0;
    
    for i = idx:-1:1
        if yy(i) < hy(1) && yy(i) >= yy(idx) / 4
            hx(1) = xx(i);
            hy(1) = yy(i);
            counter = 0;
            noiseCounter = 0;
        elseif yy(i) > hy(1)
            noiseCounter = noiseCounter + 1;
            if counter + 1 > counterMax
                break
            elseif noiseCounter > 3
                counter = counter + 1;
            end
        elseif yy(i) < yy(idx) / 4
            break
        end
    end
    
    yy = yy + ymin;
    hy = hy + ymin;
    
    if hx(2) > hx(1)
        peak.width = [peak.width; hx(2) - hx(1)];
    else
        hx = [xx(idx)-0.15, xx(idx)+0.15];
        peak.width = [peak.width; 0.15];
    end
    
    peak.center = [peak.center; xx(idx)];
    peak.height = [peak.height; yy(idx)];
    peak.alpha = [peak.alpha; (mean(hy) - ymin) / (yy(idx) - ymin)];
    peak.a = [peak.a; xx(idx) - hx(1)];
    peak.b = [peak.b; hx(2) - xx(idx)];
    
end

end