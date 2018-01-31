function toolboxPeakFit(obj, varargin)

if isempty(obj.data) || isempty(obj.view.row) || isempty(obj.view.col)
    return
elseif obj.view.row == 0 || obj.view.col == 0
    return
elseif length(obj.data) < obj.view.row
    return
elseif length(obj.peaks.name) < obj.view.col
    return
end

% ---------------------------------------
% Defaults
% ---------------------------------------
default.y              = [];
default.selectionType  = [];
default.peakOverride   = [];
default.peakWindow     = 3;
default.peakModel      = obj.settings.peakModel;
default.areaOf         = obj.settings.peakAreaOf;
default.row            = obj.view.row;
default.col            = obj.view.col;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'x');
addOptional(p, 'y', default.y);

addParameter(p, 'selectionType',  default.selectionType);
addParameter(p, 'peakOverride',   default.peakOverride);
addParameter(p, 'peakWindow',     default.peakWindow);
addParameter(p, 'peakModel',      default.peakModel);
addParameter(p, 'areaOf',         default.areaOf);
addParameter(p, 'row',            default.row);
addParameter(p, 'col',            default.col);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
input.x              = p.Results.x;
input.y              = p.Results.y;
input.selectionType  = p.Results.selectionType;
input.peakOverride   = p.Results.peakOverride;
input.peakWindow     = p.Results.peakWindow;
input.peakModel      = p.Results.peakModel;
input.areaOf         = p.Results.areaOf;
input.row            = p.Results.row;
input.col            = p.Results.col;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: x (peak retention time)
if ~isnumeric(input.x) || isinf(input.x) || isnan(input.x)
    return
end

% Parameter: y (currently unused)
if ~isempty(input.y) && ~isnumeric(input.y)
    input.y = [];
end

% Parameter: peakOverride (force peak fit at x)
if ~isfield(obj.settings, 'peakOverride')
    obj.settings.peakOverride = 0;
end

if isempty(input.peakOverride)
    input.peakOverride = obj.settings.peakOverride;
elseif ~isempty(input.peakOverride) && ~isnumeric(input.peakOverride)
    input.peakOverride = obj.settings.peakOverride;
end

% Parameter: selectionType ('manual', 'override', 'auto')
if ~isempty(input.selectionType)
    if ~ischar(input.selectionType)
        input.selectionType = [];
    elseif strcmpi(input.selectionType, 'manual') && input.peakOverride
        input.selectionType = 'override';
    end
end

% Parameter: peakWindow (use data between: x +/- peakWindow)
if ~isempty(input.peakWindow) && ~isnumeric(input.peakWindow)
    input.peakWindow = default.peakWindow;
elseif isinf(input.peakWindow) || isnan(input.peakWindow)
    input.peakWindow = default.peakWindow;
end

% Parameter: peakModel ('nn1', 'nn2', 'egh')
if isempty(input.peakModel) || ~ischar(input.peakModel)
    input.peakModel = default.peakModel;
elseif ~any(strcmpi(input.peakModel, obj.settings.peakModelOptions))
    input.peakModel = default.peakModel;
end
    
% Parameter: areaOf ('rawdata', 'fitdata')
if isempty(input.areaOf) || ~ischar(input.areaOf)
    input.areaOf = default.areaOf;
elseif ~any(strcmpi(input.areaOf, obj.settings.peakAreaOfOptions))
    input.areaOf = default.areaOf;
end

% Parameter: row (sample index)
if isempty(input.row) || ~isnumeric(input.row)
    input.row = default.row;
elseif isinf(input.row) || isnan(input.row)
    input.row = default.row;
elseif input.row < 1 || input.row > length(obj.data)
    return
else
    input.row = input.row(1);
end

% Parameter: col (peak index)
if isempty(input.col) || ~isnumeric(input.col)
    input.col = default.col;
elseif isinf(input.col) || isnan(input.col)
    input.col = default.col;
elseif input.col < 1 || input.col > length(obj.peaks.name)
    return
else
    input.col = input.col(1);
end

% ---------------------------------------
% Get XY values
% ---------------------------------------
[x,y] = getXY(obj, input.row, input.x, input.peakWindow);

if isempty(x) || isempty(y)
    return
end

% ---------------------------------------
% Peak fit
% ---------------------------------------
switch input.peakModel
    
    case {'nn', 'nn1', 'nn2'}
        getNN(obj, x, y, input)
        
    case {'egh'}
        getEGH(obj, x, y, input);
        
end

% ---------------------------------------
% Update GUI
% ---------------------------------------
obj.updatePeakText();
obj.userPeak(0);

end

% ------------------------------------------
% Get XY values
% ------------------------------------------
function [x,y] = getXY(obj, row, time, width)

% Check data
if isempty(obj.data(row).time) && isempty(obj.data(row).intensity)
    obj.loadAgilentData(row);
end

% Get xy values
if ~isempty(obj.data(row).time) && ~isempty(obj.data(row).intensity)
    x = obj.data(row).time(:,1);
    y = obj.data(row).intensity(:,1);
else
    x = [];
    y = [];
    return
end

% Get x-min
if time < obj.settings.xlim(1) - width
    xmin = time - width;
else
    xmin = obj.settings.xlim(1) - width;
end

% Get x-max
if time > obj.settings.xlim(2) + width
    xmax = time + width;
else
    xmax = obj.settings.xlim(2) + width;
end

% Check boundaries
if xmax - xmin < (width * 2)
    width = ((width*2) - (xmax-xmin)) / 2;
    xmin = xmin - width;
    xmax = xmax + width;
end

% Crop xy values
y(x < xmin | x > xmax) = [];
x(x < xmin | x > xmax) = [];

end

% ------------------------------------------
% Crop XY values
% ------------------------------------------
function [x,y] = cropXY(x, y, input)

ii = x >= input.x - input.peakWindow & x <= input.x + input.peakWindow;
x = x(ii);
y = y(ii);

end

% ------------------------------------------
% Update peak data
% ------------------------------------------
function peak = updatePeaks(obj, peak, input)

if ~isempty(peak) && ~isempty(input)
    
    peak.input_x      = input.x;
    peak.input_y      = input.y;
    peak.input_mode   = input.selectionType;
    peak.date_created = datestr(datetime, 'yyyy-mm-dd HH:MM:SS.FFF');
    
    if ~isempty(peak.fit) && peak.area ~= 0 && peak.width ~= 0
        obj.updatePeakData(input.row, input.col, peak);
        obj.updatePeakTable(input.row, input.col);
        obj.updatePeakLine(input.col);
        obj.plotPeakLabels(input.col);
        obj.updatePeakArea(input.col);
        obj.updatePeakBaseline(input.col);
        obj.updatePeakListText(input.col);
        updatePeakStatusBar(obj, input, 1)
    else
        obj.clearPeakData(input.row, input.col);
        obj.clearPeakTable(input.row, input.col);
        obj.clearPeakLine(input.col);
        obj.clearPeakLabel(input.col);
        obj.clearPeakArea(input.col);
        obj.clearPeakBaseline(input.col);
        updatePeakStatusBar(obj, input, 0)
    end
    
end

end

% ------------------------------------------
% Update status bar
% ------------------------------------------
function updatePeakStatusBar(obj, input, status)

if ~strcmpi(input.selectionType, 'auto')
    
    statusText = ['Selecting ', obj.peaks.name{obj.view.col}, ' peak... '];
    
    if status
        statusText = [statusText, 'COMPLETE'];
    else
        statusText = [statusText, 'ERROR'];
    end
    
    obj.setStatusBarText(statusText);
    
end

end

% ------------------------------------------
% Neural network peak fit
% ------------------------------------------
function getNN(obj, x, y, input)

if ~input.peakOverride
    
    % Find peaks
    peaklist = peakfindNN(x, y,...
        'xmin', input.x - (input.peakWindow / 2),...
        'xmax', input.x + (input.peakWindow / 2),...
        'sensitivity', 250);
    
    % Filter peaks
    if ~isempty(peaklist)
        
        % Find nearest peak
        [~, ii] = min(abs(input.x - peaklist(:,1)));
        
        center = peaklist(ii,1);
        window = 0.02;
        
        % Get peak xy values
        px = x(x >= center - window & x <= center + window);
        py = y(x >= center - window & x <= center + window);
        
        % Update peak center
        if isempty(py)
            input.x = peaklist(ii,1);
        else
            [~,ii] = max(py);
            input.x = px(ii);
        end
        
    else
        input.x = findPeakCenter(x, y, input.x);
    end
    
end

% Update peak center
ii = find(x >= input.x, 1);

if ~isempty(ii)
    input.x = x(ii);
end

% Get sampling rate
if ~isempty(ii)
    
    if y(ii) >= 200
        sampleRate = 100;
    elseif y(ii) <= 15
        sampleRate = 500;
    else
        sampleRate = 150.85 * log(1/y(ii)) + 898.32;
    end
    
else
    sampleRate = 500;
end

sampleRate = sampleRate-50:50:sampleRate+50;

% Update xy values
[x,y] = cropXY(x,y,input);
[peakBaseline,x,y] = getBaselineFit(obj,x,y,0);

% Get peak fit
for i = 1:length(sampleRate)
    
    if sampleRate(i) <= 0
        continue
    end
    
    peak(i) = peakfitNN(x, y, input.x,...
        'area',      input.areaOf,...
        'model',     input.peakModel,...
        'frequency', sampleRate(i),...
        'baseline',  peakBaseline);
    
end

% Update peak info
[~,ii] = min([peak.error]);
peak = peak(ii);

updatePeaks(obj, peak, input);

end

% ------------------------------------------
% Exponential Gaussian hybrid peak
% ------------------------------------------
function getEGH(obj, x, y, input)

% Update xy values
[x,y] = cropXY(x,y,input);
[peakBaseline,x,y] = getBaselineFit(obj,x,y,0);

% Get peak fit
peak = peakfitEGH(x, y-peakBaseline,...
    'center',   input.x,...
    'area',     input.areaOf,...
    'override', input.peakOverride);

% Update peak fit
if length(x) == length(peak.fit)
    peak.fit = [x, peak.fit];
end
    
peak = yclip(peak, peakBaseline);
peak = xclip(peak);

% Update peak info
updatePeaks(obj, peak, input);

end

% ------------------------------------------
% Clip peak x-values
% ------------------------------------------
function peak = xclip(peak)

if isempty(peak) && isempty(peak.fit) || size(peak.fit,2) ~= 2
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

% ------------------------------------------
% Clip peak y-values
% ------------------------------------------
function peak = yclip(peak, b)

if isempty(peak) && isempty(peak.fit) || size(peak.fit,2) ~= 2
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

% ------------------------------------------
% Get peak baseline
% ------------------------------------------
function [b,x,y] = getBaselineFit(obj,x,y,varargin)

row = obj.view.row;
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

% ------------------------------------------
% Get peak center
% ------------------------------------------
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