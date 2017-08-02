function [data, fileName] = importMAT(varargin)
% ------------------------------------------------------------------------
% Method      : importMAT
% Description : Load MATLAB data files (.MAT)
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   data = importMAT(data)
%   data = importMAT( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'file' -- name of file
%       empty (default) | char | cell array of strings
%
%   'waitbar' -- use waitbar to show progress
%       false (default) | true

% ---------------------------------------
% Defaults
% ---------------------------------------
data = [];

default.file    = [];
default.path    = [];
default.waitbar = false;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addParameter(p, 'file',    default.file);
addParameter(p, 'path',    default.path);
addParameter(p, 'waitbar', default.waitbar);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
fileName = p.Results.file;
filePath = p.Results.path;

option.waitbar = p.Results.waitbar;

userPath = pwd;

% ---------------------------------------
% Validate
% ---------------------------------------
if ~isempty(filePath) && ischar(filePath)
    try
        cd(filePath)
    catch
    end
end

if isnumeric(option.waitbar)
    if option.waitbar == 1
        option.waitbar = true;
    elseif option.waitbar ~= 1
        option.waitbar = default.waitbar;
    end
elseif ~islogical(option.waitbar)
    option.waitbar = default.waitbar;
end

% ---------------------------------------
% Waitbar
% ---------------------------------------
if option.waitbar
    h = waitbar(0, 'Loading file...');
else
    h = [];
end

% ---------------------------------------
% Get file
% ---------------------------------------
if ischar(fileName)
    
    [isFile, fileInfo] = fileattrib(fileName);
    
    if isFile && isstruct(fileInfo) && isfield(fileInfo, 'Name')
        fileName = fileInfo.Name;
    else
        fileName = [];
    end
    
else
    
    [fileName, filePath] = uigetfile('*.mat', 'Open');
    
    if ischar(fileName) && ischar(filePath)
        fileName = [filePath, fileName];
    else
        fileName = [];
    end
    
end

% ---------------------------------------
% Load file
% ---------------------------------------
if option.waitbar && ishandle(h)
    if ~isempty(fileName)
        waitbar(0.7, h, 'Loading file...');
    else
        waitbar(1.0, h, 'Unable to load file...');
    end
end

if ~isempty(fileName)
    data = load(fileName);
end

cd(userPath);

if option.waitbar && ishandle(h) && ~isempty(data)
    waitbar(1.0, h, 'Loading complete!');
end

if ishandle(h)
    close(h)
end

end
