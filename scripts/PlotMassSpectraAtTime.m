% ------------------------------------------------------------------------
% Method      : PlotMassSpectraAtTime
% Description : Plot a mass spectra at retention time
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   PlotMassSpectraAtTime(data, timeValue)
%
% ------------------------------------------------------------------------
% Parameters
% ------------------------------------------------------------------------
%   'export' (optional)
%       Description : export figure to image file
%       Type        : string
%       Options     : 'on' (default), 'off'

function PlotMassSpectraAtTime(varargin)

% parses input
[data, timeValue, options] = parse(varargin);

% looks up the index of time
index = GetTimeIndex(data.time, timeValue);

% makes sure index is within data.xic
if index > size(data.xic,1)
    fprintf('\n[WARNING]: index is out of range...\n')
    return
end

% plot mass spectra at index
if strcmpi(options.export, 'off')
    MassSpectra(data.mz, data.xic(index, :))
% takes into account export options   
else
    % fills in sample name to read 'Sample' if name is not in the data
    if isempty(data.sample.name)
        sampleName = 'Sample';
    else
        sampleName = string(data.sample.name);
    end

    % creates a new subfolder in the current directory (if export is on)
    oldFolder = pwd;
    folderName = string(oldFolder) + filesep + data.sample.name;

    if ~isfolder(folderName)
        mkdir(folderName)
    end

    % moves to new folder
    cd(folderName)

    % rounds timeValue to 2 decimals
    rTimeValue = round(timeValue,2);

    % generates file name based on sample name and time value
    fileName = sampleName + '_' + string(rTimeValue) + '.png';
    MassSpectra(data.mz, data.xic(index, :), 'export', ...
    {fileName, '-dpng', '-r300'});

    % moves back to old folder
    cd(oldFolder)

    close();
end

end

%% finds index of nearest time value in the array
function index = GetTimeIndex(timeArray, timeValue)  

[~,index] = min(abs(timeArray - timeValue));

end

%% parses function input 
function [data, timeValue, options] = parse(varargin)

options.export = 'on';

varargin = varargin{1};
nargin = length(varargin);

if (nargin < 2)
    fprintf('\n[WARNING]: not enough arguments...\n')
   return
end

data = varargin{1};
timeValue = varargin{2};

% if data is empty, or if data.time, data.mz, or data.xic doesn't exist,
% prints warning statement  
if isempty(data) || isempty(data.time) || isempty(data.mz) ...
        || isempty(data.xic)
   fprintf('\n[WARNING]: data is empty...\n')
   return
end

% checks that time value input is valid  
if ~isnumeric(timeValue)
   fprintf('\n[WARNING]: time value invalid...\n')
   return
end
    
% checks if timeValue is within the range of data.time, prints warning
% statement otherwise
if timeValue < data.time(1) || timeValue > data.time(size(data.time,1))
    fprintf('\n[WARNING]: time is out of range...\n')
    return
end

% check for export option
input = @(x) find(strcmpi(x, varargin));

if ~isempty(input('export'))
    exportOption = varargin{input('export') + 1};
    if strcmpi(exportOption, 'on') || strcmpi(exportOption, 'off')
        options.export = exportOption;
    end
end

end