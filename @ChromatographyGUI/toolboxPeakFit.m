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
    userTime = str2double(obj.controls.peakTimeEdit.String);
else
    userTime = varargin{1};
end

if isnan(userTime) || isinf(userTime)
    return
else
    [x,y] = getXY(obj);
end

if isempty(x) || isempty(y) || userTime > max(x) || userTime < min(x)
    return
end

switch obj.preferences.peakModel
    
    case 'nn'
        getNN(obj, x, y, userTime)
        
    case 'egh'
        getEGH(obj, x, y, userTime);
        
end

obj.updatePeakText();
obj.userPeak(0);

end

function [x,y] = getXY(obj)

row = obj.view.index;

x = obj.data(row).time;
y = obj.data(row).intensity(:,1);

if isempty(x) || isempty(y)
    return
else
    y(x < obj.axes.xlim(1) | x > obj.axes.xlim(2)) = [];
    x(x < obj.axes.xlim(1) | x > obj.axes.xlim(2)) = [];
end

end

function getNN(obj, x, y, peakCenter)

row = obj.view.index;
col = obj.controls.peakList.Value;

px = findpeaks(x, y,...
    'xmin', peakCenter - 0.5,...
    'xmax', peakCenter + 0.5,...
    'sensitivity', 200);

if ~isempty(px)
    [~, ii] = min(abs(peakCenter - px(:,1)));
    peakCenter = px(ii,1);
else
    peakCenter = findPeakCenter(x, y, peakCenter);
end

peak = peakfitNN(...
    x, y, peakCenter,...
    'area', obj.preferences.peakArea);

if ~isempty(peak.fit) && peak.area ~= 0 && peak.width ~= 0
    
    obj.updatePeakData(row, col, peak);
    obj.updatePeakTable(row, col);
    obj.updatePeakLine(col);
    obj.plotPeakLabels(col);
    
else
    
    obj.clearPeakData(row, col);
    obj.clearPeakTable(row, col);
    obj.clearPeakLine(col);
    obj.clearPeakLabel(col);
    
end

end

function getEGH(obj, x, y, peakCenter)

row = obj.view.index;
col = obj.controls.peakList.Value;

baseline = getBaselineEGH(obj, row, y);

peak = peakfitEGH(...
    x, y-baseline,...
    'center', peakCenter,...
    'area', obj.preferences.peakArea);

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
    
else
    obj.clearPeakData(row, col);
    obj.clearPeakTable(row, col);
    obj.clearPeakLine(col);
    obj.clearPeakLabel(col);
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
    
    y(x > t+w | x < t-w) = [];
    x(x > t+w | x < t-w) = [];
    
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
    
    y0 = y >= 1E-5;
    
    x = x(y0);
    y = y(y0);
    b = b(y0);
    
    if size(y,1) == size(b,1)
        y = y + b;
    end
    
    if ~isempty(x) && ~isempty(y) && length(x) == length(y)
        peak.fit = [x,y];
    end
    
end

end

function b = getBaselineEGH(obj, row, y)

if isempty(obj.data(row).baseline) || size(obj.data(row).baseline,1) ~= size(y,1)
    obj.getBaseline();
end

b = obj.data(row).baseline;

if ~isempty(b) && size(b,1) == size(y,1) && size(b,2) == 2
    b = b(:,2);
else 
    b = 0;
end

end

function peakCenter = findPeakCenter(x,y,peakCenter)

pIndex = find(x >= peakCenter, 1);

pSlope = '';
pLimit = 0.3;
pStop  = 10;

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