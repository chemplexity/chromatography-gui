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
%   'file' -- name of .MAT file
%       empty (default) | char | cell array of strings
%
%   'path' -- path to save file
%       empty (default) | char | cell array of strings
%
%   'varname' -- variable name
%       'data' (default) | char
%
%   'version' -- .MAT file version
%       '-v7.3' (default), '-v7', '-v6', '-v4'
%
%   'waitbar' -- use waitbar to show progress
%       false (default) | true

% ---------------------------------------
% Defaults
% ---------------------------------------
default.file    = [];
default.path    = [];
default.varname = 'data';
default.version = '-v7.3';
default.waitbar = false;
default.suggest = [datestr(date, 'yyyymmdd'), '_data'];

matVersion = {'-v7.3', '-v7', '-v6', '-v4'};

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'data');

addParameter(p, 'file', default.file);
addParameter(p, 'path', default.path);
addParameter(p, 'varname', default.varname);
addParameter(p, 'version', default.version);
addParameter(p, 'waitbar', default.waitbar);
addParameter(p, 'suggest', default.suggest);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
data = p.Results.data;

option.file    = p.Results.file;
option.path    = p.Results.path;
option.varname = p.Results.varname;
option.version = p.Results.version;
option.waitbar = p.Results.waitbar;
option.suggest = p.Results.suggest;

default.filter  = {{'*.mat', 'MAT (*.mat)'}, 'Save As...', option.suggest};

fileName = [];
userPath = pwd;

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

if ~isempty(option.path) && ischar(option.path)
    try
        cd(option.path)
    catch
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

if ~isempty(option.varname) && ~ischar(option.varname)
    option.varname = default.varname;
elseif isempty(option.varname)
    option.varname = default.varname;
end

feval(@()assignin('caller', option.varname, data));

if ~ischar(option.version)
    option.version = default.version;
elseif ~any(strcmpi(option.version, matVersion))
    option.version = default.version;
else
    option.version = lower(option.version);
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
    h = waitbar(0, 'Saving file...');
else
    h = [];
end
   
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

if option.waitbar && ishandle(h)
    waitbar(0.7, h, 'Saving file...');
end

if ischar(fileName) && ischar(filePath)
    save(fileName, option.varname, option.version);%'-mat');
else
    fileName = [];
end

if option.waitbar && ishandle(h)
    waitbar(0.9, h, 'Saving complete!');
end

cd(userPath);

if ishandle(h)
    close(h);
end

end