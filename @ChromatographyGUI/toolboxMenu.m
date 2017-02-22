function toolboxMenu(obj, varargin)

% ---------------------------------------
% File Menu
% ---------------------------------------
obj.menu.file.main = uimenu(...
    'parent',   obj.figure,...
    'label',    'File',...
    'tag',      'filemenu');

obj.menu.file.load = uimenu(...
    'parent',   obj.menu.file.main,...
    'label',    'Load',...
    'tag',      'loadmenu');

obj.menu.file.save = uimenu(...
    'parent',   obj.menu.file.main,...
    'label',    'Save',...
    'tag',      'savemenu',...
    'callback', @(src, event) saveCheckpoint(obj, src, event));

obj.menu.file.saveas = uimenu(...
    'parent',   obj.menu.file.main,...
    'label',    'Save As...',...
    'tag',      'saveasmenu');

obj.menu.file.exit = uimenu(...
    'parent',   obj.menu.file.main,...
    'label',    'Exit',...
    'tag',      'exitmenu',...
    'callback', 'closereq');

% ---------------------------------------
% File Menu --> Load
% ---------------------------------------
obj.menu.file.agilent.load = uimenu(...
    'parent',   obj.menu.file.load,...
    'label',    'Agilent (*.D)',...
    'tag',      'loadagilentmenu',...
    'callback', @(src, event) loadAgilentCallback(obj, src, event));

obj.menu.file.mat.load = uimenu(...
    'parent',   obj.menu.file.load,...
    'label',    'MAT (*.mat)',...
    'tag',      'loadmatmenu',...
    'callback', @(src, event) loadMatlabCallback(obj, src, event));

% ---------------------------------------
% File Menu --> Save As
% ---------------------------------------
obj.menu.file.mat.save = uimenu(...
    'parent',   obj.menu.file.saveas,...
    'label',    'MAT (*.mat)',...
    'tag',      'saveasmatmenu',...
    'callback', @(src, event) saveMatlabCallback(obj, src, event));

if ispc
    
    obj.menu.file.xls.save = uimenu(...
        'parent',   obj.menu.file.saveas,...
        'label',    'Excel (*.xls, *.xlsx)',...
        'tag',      'saveasxlsmenu',...
        'callback', @(src, event) saveExcelCallback(obj, src, event));
    
end

obj.menu.file.csv.save = uimenu(...
    'parent',   obj.menu.file.saveas,...
    'label',    'CSV (*.csv)',...
    'tag',      'saveasxlsmenu',...
    'callback', @(src, event) saveCSVCallback(obj, src, event));

obj.menu.file.img.save = uimenu(...
    'parent',   obj.menu.file.saveas,...
    'label',    'Image (*.jpg, *.png, *.tiff)',...
    'tag',      'saveasimagemenu',...
    'callback', @(src, event) saveImageCallback(obj, src, event));

% ---------------------------------------
% Edit Menu
% ---------------------------------------
obj.menu.edit.main = uimenu(...
    'parent',   obj.figure,...
    'label',    'Edit',...
    'tag',      'editmenu');

% ---------------------------------------
% Edit Menu --> Copy
% ---------------------------------------
obj.menu.edit.copy.main = uimenu(...
    'parent',   obj.menu.edit.main,...
    'label',    'Copy',...
    'tag',      'editcopymenu');

obj.menu.edit.copy.figure = uimenu(...
    'parent',   obj.menu.edit.copy.main,...
    'label',    'Figure',...
    'tag',      'copyfiguremenu',...
    'callback', @obj.copyFigure);

obj.menu.edit.copy.table = uimenu(...
    'parent',   obj.menu.edit.copy.main,...
    'label',    'Table',...
    'tag',      'copytablemenu',...
    'callback', @obj.copyTable);

% ---------------------------------------
% Edit Menu --> Table
% ---------------------------------------
obj.menu.edit.table.main = uimenu(...
    'parent',   obj.menu.edit.main,...
    'label',    'Table',...
    'tag',      'edittablemenu');

obj.menu.edit.table.delete = uimenu(...
    'parent',   obj.menu.edit.table.main,...
    'label',    'Delete selected rows...',...
    'tag',      'deletetablerowmenu',...
    'callback', @(src, event) tableDeleteRowMenu(obj, src, event));

% ---------------------------------------
% View Menu
% ---------------------------------------
obj.menu.view.main = uimenu(...
    'parent',   obj.figure,...
    'label',    'View',...
    'tag',      'viewmenu');

obj.menu.view.zoom = uimenu(...
    'parent',   obj.menu.view.main,...
    'label',    'Zoom',...
    'tag',      'zoommenu',...
    'checked',  'off',...
    'callback', @(src, event) zoomMenuCallback(obj, src, event));

obj.menu.view.label = uimenu(...
    'parent',   obj.menu.view.main,...
    'label',    'Labels',...
    'tag',      'labelmenu',...
    'checked',  'on',...
    'callback', @(src, event) labelMenuCallback(obj, src, event));

%obj.menu.view.preferences = uimenu(...
%    'parent',   obj.menu.view.main,...
%    'label',    'Preferences',...
%    'tag',      'preferencemenu');

% ---------------------------------------
% Help Menu
% ---------------------------------------
obj.menu.help.main = uimenu(...
    'parent',   obj.figure,...
    'label',    'Help',...
    'tag',      'helpmenu');

obj.menu.help.update = uimenu(...
    'parent',   obj.menu.help.main,...
    'label',    'Check for updates...',...
    'tag',      'updatemenu',...
    'callback', @(src, event) updateToolboxCallback(obj, src, event));

end

% ---------------------------------------
% Load Agilent
% ---------------------------------------
function loadAgilentCallback(obj, varargin)

data = importagilent('verbose', 'off', 'depth', 3);

if ~isempty(data) && isstruct(data)
    
    for i = 1:length(data)
        
        if ~isempty(data(i).file_path) && ~isempty(data(i).file_name)
            
            obj.data = [obj.data; data(i)];
            
            if ~isempty(obj.peaks.name)
                
                nCol = length(obj.peaks.name);
                nRow = length(obj.data);
                
                obj.peaks.time{nRow, nCol}   = [];
                obj.peaks.width{nRow, nCol}  = [];
                obj.peaks.height{nRow, nCol} = [];
                obj.peaks.area{nRow, nCol}   = [];
                obj.peaks.error{nRow, nCol}  = [];
                obj.peaks.fit{nRow, nCol}    = [];
                
            end
            
            obj.appendTableData();
            
        end
    end
    
    if ~isempty(obj.data)
        obj.updateFigure();
    end
    
end

end

% ---------------------------------------
% Load MAT
% ---------------------------------------
function loadMatlabCallback(obj, varargin)

[fileName, filePath] = uigetfile('*.mat', 'Open');

if ischar(fileName) && ischar(filePath)
    data = load([filePath, fileName]);
    
    if isstruct(data) && isfield(data, 'data')
        data = data.data;
        
        if isstruct(data) && isfield(data, 'sample_name') && length(data) >= 1
            obj.data = data;
            obj.peaks = obj.data(1).peaks;
            
            if ~isempty(obj.peaks.name)
                nRow = length(obj.data);
                nCol = length(obj.peaks.name);
                obj.validatePeakData(nRow, nCol);
            end
            
            obj.checkpoint = [filePath, fileName];
            
            obj.clearTableData();
            obj.resetTableHeader();
            obj.resetTableData();
            
            listboxRefreshCallback(obj);
            
            obj.updatePeakEditText();
            obj.updateFigure();
            
        end
    end
end

end

% ---------------------------------------
% Save MAT
% ---------------------------------------
function saveCheckpoint(obj, varargin)

if ~isempty(obj.data)
    data = obj.data;
else
    return
end

fileName = [];

if ~isempty(obj.checkpoint)
    
    [status, fileInfo] = fileattrib(obj.checkpoint);
    
    if status
        [filePath, fileName] = fileparts(fileInfo.Name);
        filePath = [filePath, filesep];
        fileName = [fileName, '.mat'];
    end
    
end

if isempty(fileName)
    
    filterExtensions = '*.mat';
    filterDescription = 'MAT-files (*.mat)';
    filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];
    
    [fileName, filePath] = uiputfile(...
        {filterExtensions, filterDescription},...
        'Save As...',...
        filterDefaultName);
    
    if ischar(fileName) && ischar(filePath)
        obj.checkpoint = [filePath, fileName];
    end
    
end

if ischar(fileName) && ischar(filePath) && ~isempty(data)
    
    if ~isempty(obj.peaks.name)
        data(1).peaks = obj.peaks;
    end

    currentPath = pwd;
    cd(filePath);
    save(fileName, 'data', '-mat');
    cd(currentPath);
    
end

end

% ---------------------------------------
% Save MAT
% ---------------------------------------
function saveMatlabCallback(obj, varargin)

if ~isempty(obj.data)
    data = obj.data;
else
    return
end

if ~isempty(obj.checkpoint)
    [~, filterDefaultName] = fileparts(obj.checkpoint);
else
    filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];
end

filterExtensions = '*.mat';
filterDescription = 'MAT-files (*.mat)';

[fileName, filePath] = uiputfile(...
    {filterExtensions, filterDescription},...
    'Save As...',...
    filterDefaultName);

if ischar(fileName) && ischar(filePath) && ~isempty(data)
    
    if ~isempty(obj.peaks.name)
        data(1).peaks = obj.peaks;
    end

    currentPath = pwd;
    cd(filePath);
    save(fileName, 'data', '-mat');
    obj.checkpoint = [filePath, fileName];
    cd(currentPath);
    
end

end

% ---------------------------------------
% Save Image
% ---------------------------------------
function saveImageCallback(obj, varargin)

if isempty(obj.data)
    return
end

filterExtensions = '*.jpg;*.jpeg;*.png;*.tif;*.tiff';
filterDescription = 'Image file (*.jpg, *.png, *.tif)';
filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];

[fileName, filePath] = uiputfile(...
    {filterExtensions, filterDescription},...
    'Save As...',...
    filterDefaultName);

if ischar(fileName) && ischar(filePath)

    [~, ~, fileExtension] = fileparts(fileName);

    switch fileExtension
        case {'.png'}
            fileType = '-dpng';
        case {'.jpg', '.jpeg'}
            fileType = '-djpeg';
        case {'.tif', '.tiff'}
            fileType = '-dtiff';
        otherwise
            fileType = [];
    end
    
    if ~isempty(fileType)
        
        exportFigure = figure;
        exportPanel = copy(obj.panel.axes);
        
        set(exportFigure,...
            'color',    'white',...
            'units',    'pixels',...
            'position', [0, 0, 1200, 600]);
        
        set(exportPanel,....
            'parent',   exportFigure,...
            'position', [0, 0, 1, 1],....
            'backgroundcolor', 'white');
        
        axesHandles = get(exportPanel, 'children');
        axesTags = get(axesHandles, 'tag');
        axesPlot = strcmpi(axesTags, 'axesplot');
        
        p1 = [];
        p2 = [];
        
        if any(axesPlot)

            uiProperties = properties(axesHandles(axesPlot));

            if any(strcmp(uiProperties, 'OuterPosition'))
                p1 = get(axesHandles(axesPlot), 'position');
                p2 = get(axesHandles(axesPlot), 'outerposition');
            end
            
        else
            
            uiProperties = properties(axesHandles(axesPlot));
            
            if any(strcmp(uiProperties, 'OuterPosition'))
                p1 = get(gca, 'position');
                p2 = get(gca, 'outerposition');
            end
            
        end
        
        if isempty(p1) || isempty(p2)
            p1 = get(gca, 'position');
            p2 = p1;
        end
        
        axesPosition(1) = p1(1) - p2(1);
        axesPosition(2) = p1(2) - p2(2);
        axesPosition(3) = p1(3) - (p2(3)-1);
        axesPosition(4) = p1(4) - (p2(4)-1);
        
        for i = 1:length(axesHandles)
            if strcmpi(get(axesHandles(i), 'type'), 'axes')
                set(axesHandles(i), 'position', axesPosition);
            end
        end
        
        msg = ['Saving image... (', fileName, ')'];
        h = waitbar(0, msg);
        
        waitbar(0.25, h, msg);
        
        currentPath = pwd;
        cd(filePath);
        
        waitbar(0.75, h, msg);
        print(exportFigure, fileName, fileType, '-r150')
        waitbar(1.0, h, msg);
        
        cd(currentPath);
        
        if ishandle(h)
            close(h);
        end
        
        if ishandle(exportFigure)
            delete(exportFigure);
        end
    end
end

end

% ---------------------------------------
% Save Excel
% ---------------------------------------
function saveExcelCallback(obj, varargin)

if isempty(obj.data)
    return
end

if size(obj.table.main.Data,2) ~= length(obj.table.main.ColumnName)
    obj.table.main.Data{end, length(obj.table.main.ColumnName)} = [];
end

try
    excelData = [obj.table.main.ColumnName'; obj.table.main.Data];
catch
    excelData = obj.table.main.Data;
end

if isempty(excelData)
    return
end

if length(excelData(1,:)) >= 14
    for i = 1:length(excelData(:,1))
        for j = 14:length(excelData(1,:))
            if ~isempty(excelData{i,j}) && isnumeric(excelData{i,j})
                excelData{i,j} = round(excelData{i,j},4);
            end
        end 
    end
end

filterExtensions  = '*.xls;*.xlsx';
filterDescription = 'Excel spreadsheet (*.xls, *.xlsx)';
filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];

[fileName, filePath] = uiputfile(...
    {filterExtensions, filterDescription},...
    'Save As...',...
    filterDefaultName);

if ischar(fileName) && ischar(filePath)
    currentPath = pwd;
    cd(filePath);
    xlswrite(fileName, excelData)
    cd(currentPath);
end

end

% ---------------------------------------
% Save CSV
% ---------------------------------------
function saveCSVCallback(obj, varargin)

if isempty(obj.data) || isempty(obj.table.main.Data)
    return
end

tableHeader = obj.table.main.ColumnName;
tableData   = obj.table.main.Data;

if length(tableData(1,:)) ~= length(tableHeader)
    tableData{end, length(tableHeader)} = ' ';
end

filterExtensions  = '*.csv';
filterDescription = 'CSV file (*.csv)';
filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];

[fileName, filePath] = uiputfile(...
    {filterExtensions, filterDescription},...
    'Save As...',...
    filterDefaultName);

if ischar(fileName) && ischar(filePath)
    
    currentPath = pwd;
    cd(filePath);
    
    for i = 1:length(tableData(:,1))
        for j = 1:length(tableData(1,:))
            if isempty(tableData{i,j})
                tableData{i,j} = ' ';
            elseif isnumeric(tableData{i,j})
                tableData{i,j} = num2str(tableData{i,j});
            end
        end
    end
    
    tableHeader{1,1} = ['''', tableHeader{1,1}];
    tableFmt = [repmat('%s, ', 1, length(tableHeader)), '\n'];
    
    f = fopen(fileName, 'w');
    
    fprintf(f, tableFmt, tableHeader{:});
    
    for i = 1:length(tableData(:,1))
        fprintf(f, tableFmt, tableData{i,:});
    end
    
    fclose(f);
    cd(currentPath);
    
end

end

% ---------------------------------------
% Refresh Listbox
% ---------------------------------------
function listboxRefreshCallback(obj, varargin)

x = obj.controls.peakList.Value;

if isempty(x) || x == 0 || x > length(obj.peaks.name)
    obj.controls.peakList.Value = 1;
end

set(obj.controls.peakList, 'string', obj.peaks.name);

end

% ---------------------------------------
% Delete Table Row
% ---------------------------------------
function tableDeleteRowMenu(obj, varargin)

if isempty(obj.data) || isempty(obj.table.main.Data) || isempty(obj.table.selection)
    return
else
    row = '';
end

obj.table.selection = unique(obj.table.selection(:,1));
nRows = length(obj.table.selection(:,1));

for i = 1:nRows
    
    n = obj.table.selection(i,1);
    
    if i == 1
        row = num2str(n);
        
    elseif i > 1
        
        if n - obj.table.selection(i-1,1) == 1
            
            if ~strcmpi(row(end), ':')
                
                if i == nRows
                    row = [row, ':', num2str(n)];
                else
                    if obj.table.selection(i+1,1) - n ~= 1
                        row = [row, ':', num2str(n)];
                    elseif obj.table.selection(i+1,1) - n == 1
                        row = [row, ':'];
                    end
                end
                
            elseif strcmpi(row(end), ':')
                
                if i == nRows
                    row = [row, num2str(n)];
                elseif obj.table.selection(i+1,1) - n ~= 1
                    row = [row, num2str(n)];
                end
            end
            
        elseif n - obj.table.selection(i-1,1) ~= 1
            row = [row, ', ', num2str(n)];
        end
    end
end

if isempty(row)
    message = 'Delete selected rows?';
else
    message = ['Delete selected rows (', row, ')?'];
end

msg = questdlg(...
    message,...
    'Delete',...
    'Yes', 'No', 'Yes');

switch msg
    case 'Yes'
        obj.tableDeleteRow();
    case 'No'
        return
end

end

% ---------------------------------------
% Enable/Disable Zoom
% ---------------------------------------
function zoomMenuCallback(obj, src, evt)

switch evt.EventName
    
    case 'Action'
        
        switch get(src, 'checked')
            case 'on'
                set(src, 'checked', 'off');
                obj.userZoom(0);
            case 'off'
                set(src, 'checked', 'on');
                obj.userZoom(1);                
        end
end

end

% ---------------------------------------
% Enable/Disable Peak Labels
% ---------------------------------------
function labelMenuCallback(obj, src, evt)

switch evt.EventName
    
    case 'Action'
        
        switch get(src, 'checked')
            case 'on'
                set(src, 'checked', 'off');
                obj.view.showLabel = 0;
                obj.plotPeaks();
            case 'off'
                set(src, 'checked', 'on');
                obj.view.showLabel = 1;
                obj.plotPeaks();
        end
end

end

function updateToolboxCallback(obj, ~, ~)

% ---------------------------------------
% Options
% ---------------------------------------
link.windows = 'https://git-scm.com/download/windows';
link.mac     = 'https://git-scm.com/download/mac';
link.linux   = 'https://git-scm.com/download/linux';

option.git     = [];
option.verbose = true;

msg = 'Updating toolbox...';
h = waitbar(0, msg);

% ---------------------------------------
% Path
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' %s', 'UPDATE');
fprintf(['\n', repmat('-',1,50), '\n\n']);

fprintf([obj.name, ' (v', obj.version, '.', obj.date, ')\n\n']);

fprintf(' STATUS  %s \n', 'Checking online for updates...');

sourceFile = fileparts(mfilename('fullpath'));
[sourcePath, sourceFile] = fileparts(sourceFile);

if ~strcmpi(sourceFile, '@ChromatographyGUI')
    sourcePath = [sourcePath, filesep, sourceFile];
end

cd(sourcePath);

if ishandle(h)
    waitbar(0.2, h, msg);
end

% ---------------------------------------
% Locate git
% ---------------------------------------
if ispc
    
    [gitStatus, gitPath] = system('where git');
    
    if gitStatus
        
        fprintf(' STATUS  %s \n', 'Searching system for ''git.exe''...');
        
        [gitStatus, gitPath] = system('dir C:\Users\*git.exe /s');
        
        if gitStatus
            
            msg = ['Visit ', link.windows, ' to and install Git for Windows...'];
            
            fprintf(' STATUS  %s \n', 'Unable to find ''git.exe''...');
            fprintf(' STATUS  %s \n', msg);
            
            fprintf(['\n', repmat('-',1,50), '\n']);
            fprintf(' %s', 'EXIT');
            fprintf(['\n', repmat('-',1,50), '\n\n']);
            
            if ishandle(h)
                waitbar(1, h, msg);
                close(h);
            end
            
            return
            
        end
        
        gitPath = regexp(gitPath,'(?i)(?!of)\S[:]\\(\\|\w)*', 'match');
        gitPath = [gitPath{1}, filesep, 'git.exe'];
        
    end
    
    option.git = deblank(strtrim(gitPath));
    
elseif isunix
    
    [gitStatus, gitPath] = system('which git');
    
    if gitStatus
        
        if ismac
            msg = ['Visit ', link.mac, ' to and install Git for OSX...'];
        else
            msg = ['Visit ', link.linux, ' to and install Git for Linux...'];
        end
        
        fprintf(' STATUS  %s \n', 'Unable to find ''git'' executable...');
        fprintf(' STATUS  %s \n', msg);
        
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' %s', 'EXIT');
        fprintf(['\n', repmat('-',1,50), '\n\n']);
        
        if ishandle(h)
            waitbar(1, h, msg);
            close(h);
        end
        
        return
        
    end
    
    option.git = deblank(strtrim(gitPath));
    
end

fprintf(' STATUS  %s \n', ['Using ', option.git, '...']);

if ishandle(h)
    waitbar(0.4, h, msg);
end

% ---------------------------------------
% Check permissions
% ---------------------------------------
if ispc
    [~, ~] = system(['icacls "', option.git, '\" /grant Users:(OI)(CI)F']);
end

% ---------------------------------------
% Check system git
% ---------------------------------------
[gitTest, ~] = system(['"', option.git, '" --version']);

if gitTest
    
    fprintf(2, ' ERROR  ');
    fprintf('%s \n', 'Error executing ''git --version''...');
    
    fprintf(['\n', repmat('-',1,50), '\n']);
    fprintf(' %s', 'EXIT');
    fprintf(['\n', repmat('-',1,50), '\n\n']);
    
    if ishandle(h)
        waitbar(1, h, msg);
        close(h);
    end
    
    return
    
end

if ishandle(h)
    waitbar(0.6, h, msg);
end

% ---------------------------------------
% Check git repository
% ---------------------------------------
[gitTest, ~] = system(['"', option.git, '" status']);

if gitTest
    
    fprintf(' STATUS  %s \n', 'Initializing git repository...');
    
    [~,~] = system(['"', option.git, '" init']);
    [~,~] = system(['"', option.git, '" remote add origin ', obj.url, '.git']);
    
end

if ishandle(h)
    waitbar(0.8, h, msg);
end

% ---------------------------------------
% Fetch latest updates
% ---------------------------------------
fprintf(' STATUS  %s \n', ['Fetching latest updates from ', obj.url]);

%[~,~] = system(['"', option.git, '" stash']);
[~,~] = system(['"', option.git, '" checkout master']);
[~,~] = system(['"', option.git, '" pull origin master']);
%[~,~] = system(['"', option.git, '" stash pop']);

if ishandle(h)
    waitbar(0.9, h, msg);
end

% ---------------------------------------
% Status
% ---------------------------------------
fprintf(' STATUS  %s \n', 'Update complete!');
fprintf('\n');

fprintf([...
    ChromatographyGUI.name, ' (v',...
    ChromatographyGUI.version, '.',...
    ChromatographyGUI.date, ')\n']);

fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' %s', 'EXIT');
fprintf(['\n', repmat('-',1,50), '\n\n']);

if ishandle(h)
    waitbar(1.0, h, msg);
    close(h)
end

end