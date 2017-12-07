function checksum = getFileChecksum(varargin)
% ------------------------------------------------------------------------
% Method      : getFileChecksum
% Description : Returns the file checksum
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   checksum = getChecksum()
%   checksum = getChecksum(file)
%   checksum = getChecksum( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Optional)
% ------------------------------------------------------------------------
%   file -- absolute or relative path of one of more files
%       empty (default) | char | cell array of strings
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'hash' -- message digest algorithm
%       'MD5' (default), 'MD2', 'SHA-1', 'SHA-256', 'SHA-384', 'SHA-512'
%
%   'verbose' -- show progress in command window
%       true (default) | false
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   checksum = getChecksum()
%   checksum = getChecksum('FID1A.CH')
%   checksum = getChecksum('FID2B.CH', 'hash', 'SHA-1')
%   checksum = getChecksum({'FID1A.CH', 'FID2B.CH'}, 'hash', 'SHA-512')

% ---------------------------------------
% Defaults
% ---------------------------------------
default.file = [];
default.hash = 'MD5';
default.verbose = true;

% ---------------------------------------
% Variables
% ---------------------------------------
checksum = {};
hashlist = {...
    'MD-2', 'MD2',...
    'MD-5', 'MD5',...
    'SHA-1', 'SHA1',...
    'SHA-256', 'SHA256',...
    'SHA-384', 'SHA384',...
    'SHA-512', 'SHA512'};

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'file', default.file, @(x) isempty(x) || ischar(x) || iscell(x));
addParameter(p, 'hash', default.hash);
addParameter(p, 'verbose', default.verbose);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
file = p.Results.file;
hash = p.Results.hash;
verbose = p.Results.verbose;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: 'file'
if ~isempty(file)
    if ~ischar(file) && ~iscell(file)
        file = [];
    elseif iscell(file)
        file = file(:);
    end
end

% Parameter: 'hash'
if isempty(hash) || ~ischar(hash)
    hash = default.hash;
elseif ~any(strcmpi(hash, hashlist))
    hash = default.hash;
else
    hash = upper(hash);
end

switch hash
    case 'MD-2'
        hash = 'MD2';
    case 'MD-5'
        hash = 'MD5';
    case 'SHA1'
        hash = 'SHA-1';
    case 'SHA256'
        hash = 'SHA-256';
    case 'SHA384'
        hash = 'SHA-384';
    case 'SHA512'
        hash = 'SHA-512';
end

% Parameter: 'verbose'
if ischar(verbose)
    
    switch verbose
        case {'true', 'on', 'yes', 'y', '1'}
            verbose = true;
        case {'false', 'off', 'no', 'n', '0'}
            verbose = false;
        otherwise
            verbose = default.verbose;
    end
    
elseif isnumeric(verbose)
    
    if verbose == 1
        verbose = true;
    elseif verbose == 0
        verbose = false;
    else
        verbose = default.verbose;
    end
    
elseif ~islogical(verbose)
    verbose = default.verbose;
end

% Status 
status(verbose, 'begin');

% ---------------------------------------
% Check Java
% ---------------------------------------
if ~usejava('jvm')
    status(verbose, 'java_error');
    status(verbose, 'exit');
    return
end

% ---------------------------------------
% Check files
% ---------------------------------------
if isempty(file)

    [filename, filepath] = uigetfile({'*.*',  'All Files (*.*)'});
    
    if isequal(filename, 0) || isequal(filepath, 0)
        status(verbose, 'selection_cancel');
        status(verbose, 'exit');
        return
    else
        file = {[filepath, filesep, filename]};
    end
    
end

% Convert to cell array of strings
if ischar(file)
    file = {file};
elseif iscell(file)
    file = file(:);
    file(~cellfun(@ischar, file)) = [];
end

if isempty(file)
    status(verbose, 'selection_error');
    status(verbose, 'exit');
    return
end

% Get full file path
for i = 1:length(file)
    
    [fileStatus, fileAttributes] = fileattrib(file{i});

    if ~fileStatus || fileAttributes.directory
        file{i} = [];
    elseif fileAttributes.UserRead
        file{i} = fileAttributes.Name;
    else
        file{i} = [];
    end

end

file(cellfun(@isempty, file)) = [];

if isempty(file)
    status(verbose, 'selection_error');
    status(verbose, 'exit');
    return
end

% ---------------------------------------
% Load Java instance
% ---------------------------------------
try
    fileHash = java.security.MessageDigest.getInstance(hash);
    status(verbose, 'checksum_type', hash);
    status(verbose, 'file_count', length(file));
catch
    status(verbose, 'java_error');
    status(verbose, 'exit');
    return
end

% ---------------------------------------
% Get checksum
% ---------------------------------------
for i = 1:length(file)
    
    status(verbose, 'loading_file', i, length(file))
    
    tic;
    
    f = fopen(file{i});
    digest = dec2hex(typecast(fileHash.digest(fread(f, inf, '*uint8')), 'uint8'));
    fclose(f);

    checksum{i,1} = (reshape(digest',1,[]));
    runtime = toc;
    
    status(verbose, 'file_checksum', checksum{i,1});
    status(verbose, 'loading_stats', runtime);
    
end

status(verbose, 'exit');

end

% ---------------------------------------
% Status
% ---------------------------------------
function status(varargin)

if ~varargin{1}
    return
end

switch varargin{2}

    case 'begin'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' CHECKSUM');
        fprintf(['\n', repmat('-',1,50), '\n\n']);
        
    case 'exit'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' EXIT');
        fprintf(['\n', repmat('-',1,50), '\n']);

    case 'checksum_type'
        fprintf([' STATUS  ', varargin{3}, ' checksum... \n']);
        
    case 'file_count'
        fprintf([' STATUS  Processing ', num2str(varargin{3}), ' files...', '\n\n']);

    case 'file_checksum'
        fprintf(' %s', varargin{3});
        
    case 'java_error'
        fprintf([' STATUS  Required Java function not available...', '\n']);
        
    case 'loading_file'
        m = num2str(varargin{3});
        n = num2str(varargin{4});
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        
    case 'loading_stats'
        fprintf([' (', num2str(varargin{3}), ' sec)\n']);
        
    case 'selection_cancel'
        fprintf([' STATUS  No files selected...', '\n']);

    case 'selection_error'
        fprintf([' STATUS  No files found...', '\n']);
        
end

end
