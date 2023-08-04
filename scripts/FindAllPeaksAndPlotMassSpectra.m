% ------------------------------------------------------------------------
% Method      : FindAllPeaksAndPlotMassSpectra
% Description : Find all peaks and plot mass spectra for each peaks
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   FindAllPeaksAndPlotMassSpectra(data)
%   FindAllPeaksAndPlotMassSpectra(data, Name, Value)
%
% ------------------------------------------------------------------------
% Parameters
% ------------------------------------------------------------------------
%   data (required)
%       Description : mass spectrometry data
%       Type        : structure
%
%   xmin (optional)
%       Description : filter chromatogram starting point
%       Type        : double
%
%   xmax (optional)
%       Description : filter chromatogram end point
%       Type        : double

function FindAllPeaksAndPlotMassSpectra(varargin)

% Parse and validate input
[data, options] = parse(varargin);

% Detect chromatographic peaks
% peakfindNN is in chromatography-gui/src/integration
peaks = peakfindNN(data.time, data.tic, 'xmin', options.xmin, 'xmax', ...
    options.xmax, 'sensitivity', 200);

% checks if peaks are present, if not warning message return
if isempty(peaks)
    fprintf('\n[WARNING]: no peaks detected...\n')
    return
end

% loop through peaks array and PlotMassSpectraAtTime for each peak
for i = 1:length(peaks)
    PlotMassSpectraAtTime(data, peaks(i, 1))
end

end

%% parses inputs
function [data, options] = parse(varargin)

varargin = varargin{1};
data = varargin{1};
data = PreprocessMassSpectraData(data);

options.xmin = min(data.time(:,1));
options.xmax = max(data.time(:,1));

% validates data
if isempty(data)
    fprintf('\n[WARNING]: data is empty...\n')
    return
end

% checks user input
input = @(x) find(strcmpi(varargin, x),1);

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

end