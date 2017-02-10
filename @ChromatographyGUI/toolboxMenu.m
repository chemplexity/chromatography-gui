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
    'checked',  'on',...
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

%obj.menu.help.about = uimenu(...
%    'parent',   obj.menu.help.main,...
%    'label',    'About',...
%    'tag',      'aboutmenu');

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
            tableAppendCallback(obj);
            
            if ~isempty(obj.peaks.name)
                
                cols = length(obj.peaks.name);
                rows = length(obj.data);
                
                obj.peaks.time{rows, cols}   = [];
                obj.peaks.width{rows, cols}  = [];
                obj.peaks.height{rows, cols} = [];
                obj.peaks.area{rows, cols}   = [];
                obj.peaks.error{rows, cols}  = [];
                obj.peaks.fit{rows, cols}    = [];
                
            end
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
                
                rows = length(obj.data);
                cols = length(obj.peaks.name);
                
                if size(obj.peaks.time,1) < rows
                    obj.peaks.time{rows,1}   = [];
                    obj.peaks.width{rows,1}  = [];
                    obj.peaks.height{rows,1} = [];
                    obj.peaks.area{rows,1}   = [];
                    obj.peaks.error{rows,1}  = [];
                    obj.peaks.fit{rows,1}    = [];
                end
                
                if size(obj.peaks.time,2) < cols
                    obj.peaks.time{1,cols}   = [];
                    obj.peaks.width{1,cols}  = [];
                    obj.peaks.height{1,cols} = [];
                    obj.peaks.area{1,cols}   = [];
                    obj.peaks.error{1,cols}  = [];
                    obj.peaks.fit{1,cols}    = [];
                end
                
            end
            
            obj.table.main.Data = [];
            
            tableHeaderRefreshCallback(obj);
            tableDataRefreshCallback(obj);
            listboxRefreshCallback(obj);
            
            obj.checkpoint = [filePath, fileName];
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

if ~isempty(obj.peaks.name)
    data(1).peaks = obj.peaks;
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

if ischar(fileName) && ~isempty(data)
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

if ~isempty(obj.peaks.name)
    data(1).peaks = obj.peaks;
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

[~, ~, fileExtension] = fileparts(fileName);

if ischar(fileName) && ischar(filePath)
    
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
        
        if any(axesPlot)
            p1 = get(axesHandles(axesPlot), 'position');
            p2 = get(axesHandles(axesPlot), 'outerposition');
        else
            p1 = get(gca, 'position');
            p2 = get(gca, 'outerposition');
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

tableHeader = get(obj.table.main, 'columnname');
tableData   = get(obj.table.main, 'data');

tableHeader(1) = [];
tableData(:,1) = [];

if length(tableData(1,:)) ~= length(tableHeader)
    tableData{end, length(tableHeader)} = [];
end

excelData = [];

try
    excelData = tableHeader';
    excelData(2:length(tableData(:,1))+1, 1:length(tableData(1,:))) = tableData;
catch
end

if isempty(excelData)
    return
end

filterExtensions = '*.xls;*.xlsx';
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

tableHeader = get(obj.table.main, 'columnname');
tableData   = get(obj.table.main, 'data');

if length(tableData(1,:)) ~= length(tableHeader)
    tableData{end, length(tableHeader)} = ' ';
end

tableHeader(1) = [];
tableData(:,1) = [];

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
    tableFmt = [repmat('%s, ', 1, length(tableHeader)-1), '%s\n'];
    
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
% Refresh Table Header
% ---------------------------------------
function tableHeaderRefreshCallback(obj, varargin)

tableHeader = obj.table.main.ColumnName(1:14);

if ~isempty(obj.peaks.name)
    
    for i = 1:length(obj.peaks.name)
        tableHeader(end+1) = {['Time (', obj.peaks.name{i}, ')']};
    end
    
    for i = 1:length(obj.peaks.name)
        tableHeader(end+1) = {['Area (', obj.peaks.name{i}, ')']};
    end
    
    for i = 1:length(obj.peaks.name)
        tableHeader(end+1) = {['Height (', obj.peaks.name{i}, ')']};
    end
    
    for i = 1:length(obj.peaks.name)
        tableHeader(end+1) = {['Width (', obj.peaks.name{i}, ')']};
    end
    
end

obj.table.main.ColumnName = tableHeader;

end

% ---------------------------------------
% Refresh Table Data
% ---------------------------------------
function tableDataRefreshCallback(obj, varargin)

if isempty(obj.data)
    return
end

x = length(obj.peaks.name);

for i = 1:length(obj.data)
    
    obj.table.main.Data{i,1}  = i;
    obj.table.main.Data{i,2}  = obj.data(i).file_path;
    obj.table.main.Data{i,3}  = obj.data(i).file_name;
    obj.table.main.Data{i,4}  = obj.data(i).datetime;
    obj.table.main.Data{i,5}  = obj.data(i).instrument;
    obj.table.main.Data{i,6}  = obj.data(i).instmodel;
    obj.table.main.Data{i,7}  = obj.data(i).method_name;
    obj.table.main.Data{i,8}  = obj.data(i).operator;
    obj.table.main.Data{i,9}  = obj.data(i).sample_name;
    obj.table.main.Data{i,10} = obj.data(i).sample_info;
    obj.table.main.Data{i,11} = obj.data(i).seqindex;
    obj.table.main.Data{i,12} = obj.data(i).vial;
    obj.table.main.Data{i,13} = obj.data(i).replicate;
    
    if ~isempty(obj.peaks.name)
        for j = 1:x
            obj.table.main.Data{i, 14+j + x*0} = obj.peaks.time{i,j};
            obj.table.main.Data{i, 14+j + x*1} = obj.peaks.area{i,j};
            obj.table.main.Data{i, 14+j + x*2} = obj.peaks.height{i,j};
            obj.table.main.Data{i, 14+j + x*3} = obj.peaks.width{i,j};
        end
    end
    
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
% Append Table
% ---------------------------------------
function tableAppendCallback(obj, varargin)

if isempty(obj.data)
    return
end

for i = length(obj.table.main.Data)+1:length(obj.data)
    
    obj.table.main.Data{i,1}  = i;
    obj.table.main.Data{i,2}  = obj.data(i).file_path;
    obj.table.main.Data{i,3}  = obj.data(i).file_name;
    obj.table.main.Data{i,4}  = obj.data(i).datetime;
    obj.table.main.Data{i,5}  = obj.data(i).instrument;
    obj.table.main.Data{i,6}  = obj.data(i).instmodel;
    obj.table.main.Data{i,7}  = obj.data(i).method_name;
    obj.table.main.Data{i,8}  = obj.data(i).operator;
    obj.table.main.Data{i,9}  = obj.data(i).sample_name;
    obj.table.main.Data{i,10} = obj.data(i).sample_info;
    obj.table.main.Data{i,11} = obj.data(i).seqindex;
    obj.table.main.Data{i,12} = obj.data(i).vial;
    obj.table.main.Data{i,13} = obj.data(i).replicate;
    
end

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
                set(obj.axes.zoom, 'enable', 'off');
                set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
                
            case 'off'
                set(src, 'checked', 'on');
                set(obj.axes.zoom, 'enable', 'on');
                set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
                
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
option.branch  = 'master';
option.force   = true;
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

[~,~] = system(['"', option.git, '" pull']);

if gitTest
    
    if option.force
        gitCmd = '" checkout -f master';
    else
        gitCmd = '" checkout master';
    end
    
    [~,~] = system(['"', option.git, gitCmd]);
    
end

if ishandle(h)
    waitbar(0.9, h, msg);
end

% ---------------------------------------
% Checkout branch
% ---------------------------------------
if ~isempty(option.branch)
    
    if option.force
        gitCmd = ['" checkout -f ', option.branch];
    else
        gitCmd = ['" checkout ', option.branch];
    end
    
    [~,~] = system(['"', option.git, gitCmd]);
    
end

if ishandle(h)
    waitbar(0.9, h, msg);
end

% ---------------------------------------
% Status
% ---------------------------------------
fprintf(' STATUS  %s \n', 'Update complete!');
fprintf('\n');
fprintf([obj.name, ' (v', obj.version, '.', obj.date, ')\n']);

fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' %s', 'EXIT');
fprintf(['\n', repmat('-',1,50), '\n\n']);

if ishandle(h)
    waitbar(1.0, h, msg);
    close(h)
end

end