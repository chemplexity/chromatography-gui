function [data, file] = importMAT(varargin)
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

% ---------------------------------------
% Defaults
% ---------------------------------------
file = [];
data = [];

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addParameter(p, 'file', file);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
file = p.Results.file;

% ---------------------------------------
% Validate
% ---------------------------------------
if ischar(file)
    
    [isFile, fileInfo] = fileattrib(file);
    
    if ~isFile
        file = fileInfo.Name;
    else
        file = [];
    end

else
    
    [fileName, filePath] = uigetfile('*.mat', 'Open');
    
    if ischar(fileName) && ischar(filePath)
        file = [filePath, fileName];
    else
        file = [];
    end
        
end

% ---------------------------------------
% Load
% ---------------------------------------
if ~isempty(file)
    data = load(file);
end

end
