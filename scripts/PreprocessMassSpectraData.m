% ------------------------------------------------------------------------
% Method      : PreprocessMassSpectraData
% Description : Cleanup noise from mass spectra data file
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   PreprocessMassSpectraData(data)
%   PreprocessMassSpectraData(data, Name, Value)
%
% ------------------------------------------------------------------------
% Parameters
% ------------------------------------------------------------------------
%   'smoothness' (optional)
%       Description : smoothness parameter used for baseline calculation
%       Type        : number
%       Default     : 1E6
%       Range       : 1E3 to 1E9
%
%   'asymmetry' (optional)
%       Description : asymmetry parameter used for baseline calculation
%       Type        : number
%       Default     : 1E-4
%       Range       : 1E-3 to 1E-9
%
%   'xmin' (optional)
%       Description : filter chromatogram starting point
%       Type        : double
%
%   'xmax' (optional)
%       Description : filter chromatogram end point
%       Type        : double
%
%   'percentNonZeroData' (optional)
%       Description : percent of non zero data required for baseline
%       Type        : double

function data = PreprocessMassSpectraData(data, varargin)

[data, options] = parse(data, varargin);

% centroid mass spectra data
[data.mz, data.xic] = centroid(data.mz, data.xic);
data.isCentroided = true;

% get index of xmin within data.time
xminIndex = GetTimeIndex(data.time, options.xmin);

% get index of xmax within data.time
xmaxIndex = GetTimeIndex(data.time, options.xmax);

% overwrite time, tic, xic
data.time = data.time(xminIndex:xmaxIndex,1);
data.tic = data.tic(xminIndex:xmaxIndex,1);
data.xic = data.xic(xminIndex:xmaxIndex,:);

% baseline detection
data.baseline = zeros(size(data.xic));

for i = 1:length(data.xic(1,:))
    if sum(data.xic(:,i) > 0) >= length(data.xic(:,i)) * ...
            options.percentNonZeroData
        data.baseline(:,i) = baseline(data.xic(:,i), 'smoothness', ...
            options.smoothness, 'asymmetry', options.asymmetry);
    end
end

% baseline removal
% for all of the m/z values in xic data, every time under that column has
% the baseline value at that point subtracted
for i = 1:length(data.xic(1,:))
    data.xic(:,i) = data.xic(:,i) - data.baseline(:,i);
end

data.isBaselineSubtracted = true;

end

%% parses function input
function [data, options] = parse(data, varargin)

varargin = varargin{1};

% default arguments
options.smoothness = 1E6;
options.asymmetry = 1E-4;
options.xmin = min(data.time(:,1));
options.xmax = max(data.time(:,1));
options.percentNonZeroData = 0.5;

% validates data
if isempty(data)
    fprintf('\n[WARNING]: data is empty...\n')
    return
end

% checks user input
input = @(x) find(strcmpi(varargin, x),1);

% validates smoothness
if ~isempty(input('smoothness'))
    smoothness = varargin{input('smoothness') + 1};
    if smoothness > 1E3 && smoothness < 1E9
        options.smoothness = smoothness;
    end
end

% validates asymmetry
if ~isempty(input('asymmetry'))
    asymmetry = varargin{input('asymmetry') + 1};
    if asymmetry < 1E-3 && asymmetry > 1E-9
        options.asymmetry = asymmetry;
    end
end

% validates xmin
if ~isempty(input('xmin'))
    xmin = varargin{input('xmin') + 1};
    if isnumeric(xmin) && xmin > options.xmin
        options.xmin = xmin;
    end
end

% validates xmax
if ~isempty(input('xmax'))
    xmax = varargin{input('xmax') + 1};
    if isnumeric(xmax) && xmax < options.xmax
        options.xmax = xmax;
    end
end

% validate percentNonZeroData
if ~isempty(input('percentnonzerodata'))
    percentNonZeroData = double(varargin{input('percentnonzerodata') + 1});
    if isnumeric(percentNonZeroData) && percentNonZeroData > 0 && ...
            percentNonZeroData < 100
        options.percentNonZeroData = percentNonZeroData;
    end
end

end

%% finds index of nearest time value in the array
function index = GetTimeIndex(timeArray, timeValue)  

[~,index] = min(abs(timeArray - timeValue));

end