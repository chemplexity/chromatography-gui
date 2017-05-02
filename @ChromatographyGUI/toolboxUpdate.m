function toolboxUpdate(obj, varargin)

% ---------------------------------------
% Git URL
% ---------------------------------------
url.win   = 'Visit ''git-scm.com/download/windows'' to install Git for PC...';
url.mac   = 'Visit ''git-scm.com/download/mac'' to install Git for OSX...';
url.linux = 'Visit ''git-scm.com/download/linux'' to install Git for Linux...';

toolboxVersion = obj.version;

% ---------------------------------------
% Waitbar
% ---------------------------------------
w = waitbar(0, 'Updating toolbox...');
updateWaitbar(w, 0.0, 'Checking online for updates...');
updateWaitbar(w, 0.1, ['Current toolbox version: ', toolboxVersion]);

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
        updateWaitbar(w, 0.7, 'New updates available...');
        
    case -1
        updateWaitbar(w, 1, 'Already up-to-date!');
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

function updateCleanup()

% Toolbox Path
toolboxPath = fileparts(fileparts(mfilename('fullpath')));

% Version < v0.0.5 
examplePath   = [toolboxPath, filesep, 'examples'];
integratePath = [toolboxPath, filesep, 'src', filesep, 'integration'];
integrateFile = {'findpeaks.p', 'exponentialgaussian.m', 'peakdetection.m'};

% chromatography-gui/examples
if isdir(examplePath)
    if length(dir(examplePath)) <= 3
        rmdir(examplePath, 's');
    end
end

% chromatography-gui/src/integration
for i = 1:length(integrateFile)
    if exist([integratePath, filesep, integrateFile{i}], 'file')
        delete([integratePath, filesep, integrateFile{i}]);
    end
end

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
    updateCleanup();
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

if ~status && isClean
    status = addBranch(git, 'develop');
end

if ~status && isClean
    status = addBranch(git, 'master');
end

if ~isempty(branch) && ischar(branch)
    status = checkoutBranch(git, branch);
end

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
elseif isBranch
    [status, ~] = system([git, ' checkout ', str]);
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
    [status, ~] = system([git, ' commit -m "new commit"']);
end

if status
    updateWaitbar(w, 1, 'Unable to commit changes to current branch...');
end

end

function status = checkoutBranch(git, str)

[status, branchList] = system([git, ' branch']);
isBranch = ~isempty(regexp(branchList, str, 'once'));
isActive = ~isempty(regexp(branchList, ['[*] ', str], 'once'));

if ~status && isBranch && ~isActive
    [status, ~] = system([git, ' checkout ', branch]);
end

end

function str = getBranch(git)

[status, branchList] = system([git, ' branch']);
str = regexp(branchList, '[*] \w+', 'match');

if ~status && ~isempty(str) && iscell(str)
    
    str = strsplit(deblank(strtrim(str{1})));
    
    if iscell(str) && length(str) >= 2
        str = str{2};
    end
    
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
