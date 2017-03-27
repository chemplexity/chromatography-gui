function fileName = exportMAT(varargin)
% ------------------------------------------------------------------------
% Method      : exportMAT
% Description : Save MATLAB data files (.MAT)
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   data = exportMAT(data)
%   data = exportMAT( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'file' -- name of file
%       empty (default) | char | cell array of strings
%
%   'name' -- variable name
%       'data' | char

% ---------------------------------------
% Defaults
% ---------------------------------------
default.file    = [];
default.varname = 'data';
default.name    = [datestr(date, 'yyyymmdd'), '_data'];
default.filter  = {{'*.mat', 'MAT (*.mat)'}, 'Save As...', default.name};

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'data');

addParameter(p, 'file', default.file);
addParameter(p, 'name', default.varname);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
data = p.Results.data;

option.file = p.Results.file;
option.name = p.Results.name;

fileName = [];

% ---------------------------------------
% Validate
% ---------------------------------------
if isempty(data)
    return
end

if ~isempty(option.file)
    if iscell(option.file) && ischar(option.file{1})
        option.file = option.file{1};
    elseif iscell(option.file) && ~ischar(option.file{1})
        option.file = [];
    elseif ~ischar(option.file)
        option.file = [];
    end
end

if ~isempty(option.file)
    
    [filePath, fileName, fileExt] = fileparts(option.file);
    
    if ~isempty(filePath) && ~isdir(filePath)
        option.file = [];
    elseif isempty(filePath)
        filePath = pwd;
    end
    
    if ~isempty(fileExt) && strcmpi(fileExt, '.mat')
        fileExt = '.mat';
    elseif isempty(fileExt)
        fileExt = '.mat';
    end
    
    if isempty(fileName)
        option.file = [];
    end
    
    if ~isempty(option.file)
        option.file = [filePath, filesep, fileName, fileExt];
    end
    
end

if ~isempty(option.name) && ~ischar(option.name)
    option.name = default.varname;
elseif isempty(option.name)
    option.name = default.varname;
end

feval(@()assignin('caller', option.name, data));

% ---------------------------------------
% Save file
% ---------------------------------------
if isempty(option.file)
    [fileName, filePath] = uiputfile(default.filter{:});
    fileName = [filePath, filesep, fileName];
else
    [filePath, fileName, fileExt] = fileparts(option.file);
    fileName = [filePath, filesep, fileName, fileExt];
end

if ischar(fileName) && ischar(filePath)
    save(fileName, option.name, '-mat');
else
    fileName = [];
end