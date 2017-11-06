function toolboxUpdate(obj, varargin)

% ---------------------------------------
% Waitbar
% ---------------------------------------
w = waitbar(0, 'Checking online for new updates...');

% ---------------------------------------
% Check Online Version
% ---------------------------------------
[latestVersion, updateStatus] = checkUpdate();

switch updateStatus
    
    case {'unknown'}
        updateWaitbar(w, 1, 'Unable to check for updates at this time...');
        closeWaitbar(w);
        return
        
    case {'n'}
        updateWaitbar(w, 1, 'Everything is up-to-date!');
        updateWaitbar(w, 0.15, ['Latest online version: ', latestVersion]);
        pause(3);
        closeWaitbar(w);
        return
        
    case {'y'}
        updateWaitbar(w, 0.15, 'New updates are available!' );
        
    otherwise
        updateWaitbar(w, 1, 'Error retrieving latest online version...');
        closeWaitbar(w);
        return
        
end

closeWaitbar(w);

end

function updateWaitbar(h, x, msg)

if any(ishandle(h))
    waitbar(x, h, msg);
    pause(1);
end

end

function closeWaitbar(h)

if any(ishandle(h))
    close(h);
end

end

% ---------------------------------------
% Get latest online version
% ---------------------------------------
function [latestVersion, updateStatus] = checkUpdate()

installedVersion = ChromatographyGUI.version;
latestVersion    = 'unknown';
updateStatus     = 'unknown';

% Github URL
urlHome = 'https://raw.githubusercontent.com/chemplexity/chromatography-gui/';
urlFile = '/%40ChromatographyGUI/ChromatographyGUI.m';

if ~isempty(regexp(installedVersion, 'dev', 'once'))
    urlBranch = 'develop';
else
    urlBranch = 'master';
end

% Read ChromatographyGUI.m
[txt, s] = urlread([urlHome, urlBranch, urlFile], 'timeout', 7);

if s ~= 1
    updateStatus = 'error';
    return
else
    [txt, ~] = regexpi(txt, '(\d+[.]\d+[.]\d+[.]\d+[-]*\w*)', 'tokens', 'once');
end

% Parse version number
if iscell(txt) && ~isempty(txt)
    latestVersion = txt{1};
else
    return
end

if strcmpi(installedVersion, latestVersion)
    updateStatus = 'n';
    return
    
end
    
installed = parseVersion(installedVersion);
latest = parseVersion(latestVersion);

if compareVersion(installed, latest, 'date')
    updateStatus = 'y'; 
elseif compareVersion(installed, latest, 'a')
    updateStatus = 'y';
elseif compareVersion(installed, latest, 'b')
    updateStatus = 'y';
elseif compareVersion(installed, latest, 'c')
    updateStatus = 'y';
else
    updateStatus = 'n';
end

end

% ---------------------------------------
% Parse version number
% ---------------------------------------
function v = parseVersion(x)

v.a = regexpi(x, '^v*(\d+)(?:[.])', 'tokens', 'once');
v.b = regexpi(x, '[.](\d+)(?:[.])', 'tokens', 'once');
v.c = regexpi(x, '[.]\d+[.](\d{1,2})', 'tokens', 'once');
v.date = regexpi(x, '[.](\d{8})', 'tokens', 'once');

if ~isempty(v.a) && ischar(v.a{1})
    v.a = str2double(v.a{1});
end

if ~isempty(v.b) && ischar(v.b{1})
    v.b = str2double(v.b{1});
end

if ~isempty(v.c) && ischar(v.c{1})
    v.c = str2double(v.c{1});
end

if ~isempty(v.date) && ischar(v.date{1}) && length(v.date{1}) == 8
    v.date = datenum(v.date{1}, 'yyyymmdd');
end

end

% ---------------------------------------
% Compare version number
% ---------------------------------------
function x = compareVersion(a,b,str)

x = 0;

if ~isstruct(a) || ~isstruct(b)
    return
end

if ~isfield(a, str) || ~isfield(b, str)
    return
elseif isempty(a.(str)) || isempty(b.(str))
    return
elseif ~isnumeric(a.(str)) || ~isnumeric(b.(str)) 
    return
elseif a.(str) < b.(str)
    x = 1;
end

end