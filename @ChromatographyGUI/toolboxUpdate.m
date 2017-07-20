function toolboxUpdate(obj, varargin)

% ---------------------------------------
% Git URL
% ---------------------------------------
url.win   = 'Visit ''git-scm.com/download/windows'' to install Git for PC...';
url.mac   = 'Visit ''git-scm.com/download/mac'' to install Git for OSX...';
url.linux = 'Visit ''git-scm.com/download/linux'' to install Git for Linux...';

% ---------------------------------------
% Waitbar
% ---------------------------------------
w = waitbar(0, 'Initiating toolbox update...');

% ---------------------------------------
% Path
% ---------------------------------------
returnPath = pwd;
sourcePath = fileparts(fileparts(mfilename('fullpath')));

if ~isdir([sourcePath, filesep, '@ChromatographyGUI'])
    updateWaitbar(w, 1, 'Unable to locate project directory...');
    closeWaitbar(w, returnPath);
    return
else
    cd(sourcePath);
end

% ---------------------------------------
% Check Online Version
% ---------------------------------------
updateWaitbar(w, 0.0, 'Checking online for available updates...');

[latestVersion, updateStatus] = checkUpdate();

updateWaitbar(w, 0.15, ['Latest online version: ', latestVersion]);
pause(3);

switch updateStatus
    
    case {'unknown'}
        updateWaitbar(w, 1, 'Unable to update toolbox at this time...');
        closeWaitbar(w, returnPath);
        return
        
    case {'n'}
        updateWaitbar(w, 1, 'Everything is up-to-date!');
        closeWaitbar(w, returnPath);
        return
        
    case {'y'}
        updateWaitbar(w, 0.15, 'New updates available!' );
        
    otherwise
        updateWaitbar(w, 1, 'Error retrieving latest online version...');
        closeWaitbar(w, returnPath);
        return
        
end

% ---------------------------------------
% Find 'git'
% ---------------------------------------
[status, ~] = system('git --version');

if ~status
    git = 'git';
elseif ispc
    git = pcGit(w, 0.2);
elseif isunix
    git = unixGit(w, 0.2);
else
    git = '';
end

git = checkGit(git, url, w, 0.3);

if isempty(git)
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Test 'git'
% ---------------------------------------
status = testGit(git, w);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Initialize 'git'
% ---------------------------------------
status = initializeGit(git, w, 0.4);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Check 'git' remote
% ---------------------------------------
status = remoteGit(git, obj.url, w, 0.5);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Fetch 'git' remote
% ---------------------------------------
status = fetchGit(git, w, 0.6);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Check 'git' branch
% ---------------------------------------
status = branchGit(git, w);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Check 'git' hash
% ---------------------------------------
status = hashGit(git);

switch status
    
    case 0 
        
    case -1
        updateWaitbar(w, 1, 'Everything is up-to-date!');
        closeWaitbar(w, returnPath);
        return
        
    otherwise
        updateWaitbar(w, 1, 'Unable to retreive updates at this time...');
        closeWaitbar(w, returnPath);
        return
        
end

% ---------------------------------------
% Pull 'git' remote
% ---------------------------------------
status = pullGit(git, w, 0.8);

if status
    closeWaitbar(w, returnPath);
    return
end

% ---------------------------------------
% Finish update
% ---------------------------------------
updateWaitbar(w, 1, 'Update complete!');

updateFinish(git, w, returnPath);

end

function updateWaitbar(h, x, msg)

if any(ishandle(h))
    waitbar(x, h, msg);
    pause(1);
end

end

function closeWaitbar(h, userpath)

cd(userpath);

if any(ishandle(h))
    close(h);
end

end

function updateFinish(git, w, returnPath)

if any(ishandle(w))
    close(w);
end

status = hashGit(git);

if status == -1
    msg = 'Please exit and restart ChromatographyGUI to complete update...';
    questdlg(msg, 'Update', 'OK', 'OK');
end

cd(returnPath);

end

% ---------------------------------------
% Find 'git' (PC)
% ---------------------------------------
function git = pcGit(w, n)

updateWaitbar(w, n, 'Searching system for ''git.exe''...');
    
[status, git] = system('where git');

if status
    
    git = '';
    
    windowsGit = {...
        '"C:\Program Files\Git\*git.exe"',...
        '"C:\Program Files (x86)\Git\*git.exe"',...
        '"C:\Users\*git.exe"'};
    
    for i = 1:length(windowsGit)
        
        updateWaitbar(w, n+0.05, 'Searching: ''', windowsGit{i}, '''');
        
        [status, git] = system(['dir ', windowsGit{i}, ' /S']);
        
        if ~status
            break
        end
        
    end
    
    if ischar(git)
        git = regexp(git,'(?i)(?!of)\S[:]\\(\\|\w)*', 'match');
    end
    
    if iscell(git)
        git = [git{1}, filesep, 'git.exe'];
    end
    
end

git = deblank(strtrim(git));

if ischar(git)
    [~, ~] = system(['icacls "', git, '\" /grant Users:(OI)(CI)F']);
end

end

% ---------------------------------------
% Find 'git' (UNIX)
% ---------------------------------------
function git = unixGit(w, n)

updateWaitbar(w, n, 'Searching system for ''git''...');
    
[status, git] = system('which git');

if status
    git = '';
else
    git = deblank(strtrim(git));
end

end

% ---------------------------------------
% Check 'git' executable
% ---------------------------------------
function git = checkGit(git, url, w, n)

if isempty(git)
    
    if ispc
        updateWaitbar(w, 1, 'Unable to locate ''git.exe''...');
        updateWaitbar(w, 1, url.winURL);
    elseif ismac
        updateWaitbar(w, 1, 'Unable to locate ''git'' executable...');
        updateWaitbar(w, 1, url.macURL);
    elseif isempty(git) && ~ismac
        updateWaitbar(w, 1, 'Unable to locate ''git'' executable...');
        updateWaitbar(w, 1, url.linuxURL);
    end
        
else
    git = ['"', git, '"'];
    updateWaitbar(w, n, ['Using ', git, ' to begin update...' ]);
end

end

% ---------------------------------------
% Test 'git'
% ---------------------------------------
function status = testGit(git, w)

[status, ~] = system([git, ' --version']);

if status
    updateWaitbar(w, 1, 'Error executing ''git --version''...');
end

status = configGit(git);

if status
    updateWaitbar(w, 1, 'Error executing ''git config''...');
end

end

% ---------------------------------------
% Check 'git config'
% ---------------------------------------
function status = configGit(git)

[status, str] = system([git, ' config --list']);

if ~status
    
    % Setup user.name
    if isempty(regexpi(str, 'user[.]name[=](\w+)', 'tokens', 'once'))
        [status, ~] = system([git, ' config user.name ChromatographyGUI']);
    end
    
    % Setup user.email
    if isempty(regexpi(str, 'user[.]name[=](\w+)', 'tokens', 'once'))
        [status, ~] = system([git, ' config user.email abc@xyz.com']);
    end
    
end

end

% ---------------------------------------
% Initialize 'git'
% ---------------------------------------
function status = initializeGit(git, w, n)

[status, ~] = system([git, ' status']);

if status
    
    updateWaitbar(w, n, 'Initializing new ''git'' repository...');

    [status, ~] = system([git, ' init']);
    
    if ~status
        updateWaitbar(w, n+0.05, 'Initialization complete!');
    end
    
else
    waitbar(n, w);
end

end

% ---------------------------------------
% Add 'git' remote
% ---------------------------------------
function status = remoteGit(git, url, w, n)

[status, remote] = system([git, ' remote']);

if status || isempty(remote)
    
    updateWaitbar(w, n, 'Linking repository to online remote...');
    
    [status, remote] = system([git, ' remote add origin ', url, '.git']);
    
    isRemote = regexp(remote, 'remote origin already exists', 'once');
    
    if ~isempty(isRemote)
        status = 0;
    elseif status
        updateWaitbar(w, 1, 'Unable to add online repository...');
    end
   
else
    waitbar(n, w);
end

end

% ---------------------------------------
% Fetch 'git' remote
% ---------------------------------------
function status = fetchGit(git, w, n)

updateWaitbar(w, n, 'Fetching latest updates...');

[status, ~] = system([git, ' fetch origin']);

if status
    updateWaitbar(w, 1, 'Unable to get updates at this time...');
end

end

% ---------------------------------------
% Check 'git' branch
% ---------------------------------------
function [status, branch] = branchGit(git, w)

[status, msg] = system([git, ' branch --list']);

if ~status && isempty(msg)
    
    if ~isempty(contains(ChromatographyGUI.version, 'dev'))
        status = addBranch(git, 'develop');
    else
        status = addBranch(git, 'master');
    end
    
    if status
        updateWaitbar(w, 1, 'Error executing ''git branch''');
    end
    
end

[status, msg] = system([git, ' status']);

isStaged = isempty(regexpi(msg, 'initial commit', 'once'));

if isStaged
    isStaged = isempty(regexpi(msg, 'untracked files', 'once')); 
end

if isStaged
    isStaged = isempty(regexpi(msg, 'changes not staged', 'once'));
end

if ~status && ~isStaged
    status = addFiles(git, w);
end

if ~status
    [status, msg] = system([git, ' status']);
end

isClean = isempty(regexpi(msg, 'changes to be committed', 'once'));

if ~status && ~isClean
    status = addCommit(git, w);
end

if ~status
    branch = getBranch(git);
else
    branch = '';
end

if ~status
    [status, msg] = system([git, ' status']);
end

isClean = ~isempty(regexpi(msg, 'working tree clean', 'once'));

if ~isClean
    status = 1;
end

%if ~status && isClean
%    if ~isempty(contains(ChromatographyGUI.version, 'dev'))
%        status = addBranch(git, 'develop');
%    end
%end

%if ~status && isClean
%    status = addBranch(git, 'master');
%end

%if ~isempty(branch) && ischar(branch)
%    status = checkoutBranch(git, branch);
%end

end

% ---------------------------------------
% Check 'git' hash
% ---------------------------------------
function status = hashGit(git)

[status, branch] = system([git, ' rev-parse --abbrev-ref HEAD']);

if ischar(branch) && ~status
    branch = deblank(strtrim(branch));
end

if ~status
    [status, userHash] = system([git, ' rev-parse --short ', branch]);
else
    userHash = '';
end

if ~status
    [status, remoteHash] = system([git, ' rev-parse --short origin/', branch]);
else
    remoteHash = '';
end

if ~status && ~isempty([userHash, remoteHash]) && strcmp(userHash, remoteHash)
    status = -1;
end

if status ~= -1
    
    x = getUpstream(git);
    
    if ~isempty(x) && x >= 0
        status = -1;
    end
    
end

end

% ---------------------------------------
% Pull 'git'
% ---------------------------------------
function status = pullGit(git, w, n)

updateWaitbar(w, n, 'Applying latest updates...');

[status, branch] = system([git, ' rev-parse --abbrev-ref HEAD']);

if ischar(branch) && ~status
    branch = deblank(strtrim(branch));
end

if ~status && any(strcmpi(branch, {'HEAD', 'master', 'develop'}))
    
    [status, ~] = system([git, ' pull --rebase origin ' branch]);
    
    waitbar(n+0.1, w);
    
    if status
        system([git, ' checkout --ours .'])
        system([git, ' add .']);
        [status, ~] = system([git, ' rebase --continue']);
    end
    
end

if status 
    updateWaitbar(w, 1, 'Error applying updates...');
end
   
% 'git reset --hard origin/master'
 
end

function status = addBranch(git, str)

[status, branchList] = system([git, ' branch']);
isBranch = ~isempty(regexp(branchList, str, 'once'));

if ~status && ~isBranch
    [status, ~] = system([git, ' checkout -b ', str]);
%elseif isBranch
%    [status, ~] = system([git, ' checkout ', str]);
end

end

function status = addFiles(git, w)

[status, msg] = system([git, ' status']);
isUntracked = ~isempty(regexpi(msg, 'untracked files', 'once'));

if ~status && isUntracked
    [status, ~] = system([git, ' add .']);
end

isDeleted = ~isempty(regexpi(msg, 'deleted', 'once'));

if ~status && isDeleted
    [status, ~] = system([git, ' add -u .']);
end

if status
    updateWaitbar(w, 1, 'Unable to add untracked files to current branch...');
end

end

function status = addCommit(git, w)

[status, msg] = system([git, ' status']);
isUncommitted = ~isempty(regexpi(msg, 'changes to be committed', 'once'));

if ~status && isUncommitted
    msg = ['GUI initialized update - ', ChromatographyGUI.version];
    [status, ~] = system([git, ' commit -m "', msg, '"']);
end

%if ~status && isUncommitted
%    [status, ~] = system([git, ' commit -m "new commit"']);
%end

if status
    updateWaitbar(w, 1, 'Unable to commit changes to current branch...');
end

end

%function status = checkoutBranch(git, str)

%[status, branchList] = system([git, ' branch']);
%isBranch = ~isempty(regexp(branchList, str, 'once'));
%isActive = ~isempty(regexp(branchList, ['[*] ', str], 'once'));

%if ~status && isBranch && ~isActive
%    [status, ~] = system([git, ' checkout ', branch]);
%end

%end

function str = getBranch(git)

[status, branchList] = system([git, ' branch']);
str = regexp(branchList, '[*] (\w+)', 'tokens', 'once');

if ~status && ~isempty(str) && iscell(str)
    str = str{1};
else
    str = '';
end

if iscell(str)
    str = '';
end

end

function x = getUpstream(git)

str = getBranch(git);

if ~char(str)
    x = [];
    return
end

[status, x] = system([git, ' rev-list --left-right --count origin/', str, '...',  str]);

if ~status && ischar(x)
    x = strsplit(deblank(strtrim(x)));
    x = cellfun(@str2double, x);
    x(isnan(x)) = [];
end
   
if ~isempty(x) && isnumeric(x)
    x = diff(x);
else
    x = [];
end

end

function [latestVersion, updateStatus] = checkUpdate()

installedVersion = ChromatographyGUI.version;
latestVersion    = 'unknown';
updateStatus     = 'unknown';

% Github URL
urlHome = 'https://raw.githubusercontent.com/chemplexity/chromatography-gui/';
urlFile = '/%40ChromatographyGUI/ChromatographyGUI.m';

if ~isempty(contains(installedVersion, 'dev'))
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
    [txt, ~] = regexpi(txt, '(\d+[.]\d+[.]\d+[.]\d+[.a-zA-Z]*)', 'tokens', 'once');
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
elseif compareVersion(installed, latest, 'b')
    updateStatus = 'y';
else
    updateStatus = 'n';
end

end

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