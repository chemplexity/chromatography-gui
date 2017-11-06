function toolboxPeakFit(obj, varargin)

if isempty(obj.data) || isempty(obj.controls.peakList.Value)
    return
elseif obj.view.index == 0 || obj.controls.peakList.Value == 0
    return
else
    row = obj.view.index;
    col = obj.controls.peakList.Value;    
end

if length(obj.data) < row || length(obj.peaks.name) < col
    return
end

if isempty(varargin)
    userX = str2double(obj.controls.peakTimeEdit.String);
else
    userX = varargin{1};
end

if isnan(userX) || isinf(userX)
    return
else
    [x,y] = getXY(obj);
end

if isempty(x) || isempty(y) || userX > max(x) || userX < min(x)
    return
end

switch obj.settings.peakModel
    
    case {'nn', 'nn1', 'nn2'}
        getNN(obj, x, y, userX)
        
    case {'egh'}
        getEGH(obj, x, y, userX);
        
end

obj.updatePeakText();
obj.userPeak(0);

end

function [x,y] = getXY(obj)

row = obj.view.index;
pad = 3;

if isempty(obj.data(row).intensity)
    x = [];
    y = [];
else
    x = obj.data(row).time;
    y = obj.data(row).intensity(:,1);
end

if diff(obj.settings.xlim) < 6
    pad = (6 - diff(obj.settings.xlim)) / 2;
end

if isempty(x) || isempty(y)
    return
else
    y(x < obj.settings.xlim(1)-pad | x > obj.settings.xlim(2)+pad) = [];
    x(x < obj.settings.xlim(1)-pad | x > obj.settings.xlim(2)+pad) = [];
end

end

function getNN(obj, x, y, peakCenter)

row = obj.view.index;
col = obj.controls.peakList.Value;
pad = 1.5;

% Peak Center
if isfield(obj.settings, 'peakOverride')
    
    if ~obj.settings.peakOverride
        
        px = peakfindNN(x, y,...
            'xmin', peakCenter - pad,...
            'xmax', peakCenter + pad,...
            'sensitivity', 350);

        if ~isempty(px)

            [~, ii] = min(abs(peakCenter - px(:,1)));
            xc = px(ii,1);
    
            xtol = 0.02;
            xf = x(x >= xc-xtol & x <= xc+xtol);
            yf = y(x >= xc-xtol & x <= xc+xtol);
    
            if ~isempty(yf)
                [~,xi] = max(yf);
                peakCenter = xf(xi);
            else
                peakCenter = px(ii,1);
            end
    
        else
            peakCenter = findPeakCenter(x, y, peakCenter);
        end
       
    else
        obj.settings.peakOverride = 0;
    end
    
end

xi = find(x >= peakCenter, 1);

if ~isempty(xi)
    peakCenter = x(xi);    
end

% Crop XY
xpad = 3;
xf = x >= peakCenter - xpad & x <= peakCenter + xpad;
x = x(xf);
y = y(xf);

% Select Model
switch obj.settings.peakModel
    case {'nn1'}
        nnVersion = 'nn_v1';
    case {'nn2', 'nn'}
        nnVersion = 'nn_v2';
    otherwise
        nnVersion = 'latest';  
end

% Sampling Rate
xi = find(x >= peakCenter, 1);

if ~isempty(xi)
    
    if y(xi) > 175
        f = 100;
    elseif y(xi) > 125
        f = 200;
    elseif y(xi) > 50
        f = 300;
    elseif y(xi) > 25
        f = 400;
    else
        f = 500;
    end
    
else
    f = 500;
end
    
% Baseline
[b,x,y] = getBaselineFit(obj,x,y,0);

% Peak Fit
peak = [];

for i = f-50:50:f+50
    
    if i <= 0
        continue
    end
    
    p = peakfitNN(x, y, peakCenter,...
        'area', obj.settings.peakArea,...
        'model', nnVersion,...
        'baseline', b,...
        'frequency', i);

    if isempty(peak)
        peak = p;
    end
    
    if isempty(p.error) || isnan(p.error)
        continue
    end
    
    if p.error < peak.error
        peak = p;
    end

end

% Update
if ~isempty(peak.fit) && peak.area ~= 0 && peak.width ~= 0
    obj.updatePeakData(row, col, peak);
    obj.updatePeakTable(row, col);
    obj.updatePeakLine(col);
    obj.plotPeakLabels(col);
    obj.updatePeakArea(col);
    obj.updatePeakBaseline(col);
else
    obj.clearPeakData(row, col);
    obj.clearPeakTable(row, col);
    obj.clearPeakLine(col);
    obj.clearPeakLabel(col);
    obj.clearPeakArea(col);
    obj.clearPeakBaseline(col);
end

end

function getEGH(obj, x, y, peakCenter)

row = obj.view.index;
col = obj.controls.peakList.Value;

% Crop XY
xpad = 3;
xf = x >= peakCenter - xpad & x <= peakCenter + xpad;
x = x(xf);
y = y(xf);

[baseline,x,y] = getBaselineFit(obj,x,y,0);

peak = peakfitEGH(...
    x, y-baseline,...
    'center', peakCenter,...
    'area', obj.settings.peakArea,...
    'override', obj.settings.peakOverride);

obj.settings.peakOverride = 0;

if ~isempty(peak) && ~isempty(peak.fit) && peak.area ~= 0 && peak.width ~= 0
    
    if length(x) == length(peak.fit)
        peak.fit = [x, peak.fit];
    end
    
    peak = yclip(peak, baseline);
    peak = xclip(peak);
    
    obj.updatePeakData(row, col, peak);
    obj.updatePeakTable(row, col);
    obj.updatePeakLine(col);
    obj.plotPeakLabels(col);
    obj.updatePeakArea(col);
    obj.updatePeakBaseline(col);
    
else
    obj.clearPeakData(row, col);
    obj.clearPeakTable(row, col);
    obj.clearPeakLine(col);
    obj.clearPeakLabel(col);
    obj.clearPeakArea(col);
    obj.clearPeakBaseline(col);
end

end

function peak = xclip(peak)

if size(peak.fit,2) ~= 2
    return
end

if ~isempty(peak.width) && ~isempty(peak.time) && peak.width > 0
    
    x = peak.fit(:,1);
    y = peak.fit(:,2);
    
    t = peak.time;
    w = peak.width * 2.5;
    
    if isfield(peak, 'xmin') && t-w < peak.xmin
        yf = y <= 0.02 * max(y) + min(y);
        y(x < t-w & yf) = [];
        x(x < t-w & yf) = [];
    end
        
    if isfield(peak, 'xmax') && t+w > peak.xmax
        yf = y <= 0.02 * max(y) + min(y);
        y(x > t+w & yf) = [];
        x(x > t+w & yf) = [];
    end
    
    if ~isempty(x) && ~isempty(y) && length(x) == length(y)
        peak.fit = [x,y];
    end
    
end

end

function peak = yclip(peak, b)

if size(peak.fit,2) ~= 2
    return
end

x = peak.fit(:,1);
y = peak.fit(:,2);

if length(x) == length(y) && any(y)
    
    y0 = y ~= 0;
    
    ii = find(y0 > 0, 1);
    
    if ~isempty(ii)
        if ii > 5
            y0(ii-5:ii-1) = 1;
        elseif ii > 1
            y0(ii-1) = 1;
        end
    end
    
    ii = find(flipud(y0) > 0, 1);
    
    if ~isempty(ii)
        ii = length(y0) - ii + 2;
        if ii+5 <= length(y0)
            y0(ii:ii+5) = 1;
        elseif ii <= length(y0)
            y0(ii) = 1;
        end
    end
    
    x = x(y0);
    y = y(y0);
    b = b(y0);
    
    y0 = y >= 1E-3;
    
    x = x(y0);
    y = y(y0);
    b = b(y0);
    
    if size(y,1) == size(b,1)
        
        y = y + b;
        
        if isfield(peak,'ymin') && isfield(peak,'ymax')
            if peak.ymin ~= 0 && peak.ymax ~= 0
                peak.ymin = min(y);
                peak.ymax = max(y);
                peak.height = peak.ymax - peak.ymin;
            end
        end
        
    end
    
    if ~isempty(x) && ~isempty(y) && length(x) == length(y)
        peak.fit = [x,y];
    end
    
end

end

function [b,x,y] = getBaselineFit(obj,x,y,varargin)

row = obj.view.index;
b = [];

xmin = min(x);
xmax = max(x);

if isempty(obj.data(row).baseline)
    obj.getBaseline();
end

if ~isempty(obj.data(row).baseline) && size(obj.data(row).baseline,2) == 2
    
    b = obj.data(row).baseline;
    b = b(b(:,1) >= xmin & b(:,1) <= xmax, :);
    
    if isempty(b)
        b = obj.getBaseline(varargin{:});
        b = b(b(:,1) >= xmin & b(:,1) <= xmax, :);
    end
    
    if ~isempty(b)
        bmin = min(b(:,1));
        bmax = max(b(:,1));
    else
        return
    end
    
    if bmin > xmin && bmax >= xmax
    
        if size(b,1) ~= size(y,1)            
            n = numel(x) - size(b,1);
            
            if abs(x(n+1) - b(1,1)) <= 0.01
                b = [x(1:n), repmat(b(1,2),n,1); b];
            end
        end

    elseif bmin <= xmin && bmax < xmax
       
        if size(b,1) ~= size(y,1)    
            n = numel(x) - size(b,1);
            
            if abs(x(end-n) - b(end,1)) <= 0.01
                b = [b; x(end-n+1:end), repmat(b(end,2),n,1)];
            end
        end
        
    elseif bmin > xmin && bmax < xmax
        
        xf = x >= bmin & x <= bmax;
        
        if nnz(xf) == size(b,1)
            x = x(xf);
            y = y(xf);
        end
        
    end
    
    if size(b,1) ~= size(y,1)
        b = obj.getBaseline(varargin{:});
        b = b(b(:,1) >= xmin & b(:,1) <= xmax, :);
    end
        
elseif isempty(obj.data(row).baseline)
    b = obj.getBaseline();
    b = b(b(:,1) >= xmin & b(:,1) <= xmax, :);
end

if ~isempty(b) && size(b,1) == size(y,1) && size(b,2) == 2
    b = b(:,2);
else
    b = zeros(size(y,1),1) + min(y);
end

end

function peakCenter = findPeakCenter(x, y, peakCenter)

pIndex = find(x >= peakCenter, 1);

pSlope = '';
pLimit = 0.3;
pStop  = 5;

y = movingAverage(y,10);

pLX = x(pIndex,1);
pRX = x(pIndex,1);
pLY = y(pIndex,1);
pRY = y(pIndex,1);

pDown = 0;
pUp   = 0;

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
    
    if pUp == pStop
        pSlope = [pSlope, 'u'];
    end
    
    if pDown == pStop
        pSlope = [pSlope, 'd'];
    end
    
    if x(i) > peakCenter + pLimit
        break
    elseif strcmpi(pSlope, 'ud') || strcmpi(pSlope, 'dud')
        break
    end
    
end

pSlope = '';
pDown  = 0;
pUp    = 0;

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
    
    if pUp == pStop
        pSlope = [pSlope, 'u'];
    end
    
    if pDown == pStop
        pSlope = [pSlope, 'd'];
    end
    
    if x(i) < peakCenter - pLimit
        break
    elseif strcmpi(pSlope, 'ud') || strcmpi(pSlope, 'dud')
        break
    end
    
end

pLCount = pIndex - find(x >= pLX, 1);
pRCount = find(x >= pRX, 1) - pIndex;

if pRCount == 0 && pLCount == 0
    peakCenter = x(pIndex);
    
elseif pRCount ~= 0 && (pRCount < pLCount || pLCount == 0)
    peakCenter = pRX;
    
elseif pLCount ~= 0 && (pLCount < pRCount || pRCount == 0)
    peakCenter = pLX;
end

end