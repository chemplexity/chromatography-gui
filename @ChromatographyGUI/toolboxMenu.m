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
%obj.menu.help.main = uimenu(...
%    'parent',   obj.figure,...
%    'label',    'Help',...
%    'tag',      'helpmenu');

%obj.menu.help.update = uimenu(...
%    'parent',   obj.menu.help.main,...
%    'label',    'Check for updates...',...
%    'tag',      'updatemenu');

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
    
    if ~isempty(obj.data)
        obj.updateFigure();
    end
    
end

end

% ---------------------------------------
% Load MAT
% ---------------------------------------
function loadMatlabCallback(obj, varargin)

[filename, filepath] = uigetfile('*.mat', 'Open');

if ischar(filename) && ischar(filepath)
    data = load([filepath, filename]);
    
    if isstruct(data) && isfield(data, 'data')
        data = data.data;
        
        if isstruct(data) && isfield(data, 'sample_name') && length(data) >= 1
            obj.data = data;
            obj.checkpoint = [filepath, filename];
            
            tableClearCallback(obj);
            tableRefreshCallback(obj);
            
            if ~isfield(obj.data, 'baseline') 
                for i = 1:length(data)
                    obj.data(i).baseline = [];
                end
            end
            
            rows = length(obj.data);
            cols = length(obj.peaks.name);
                
            obj.peaks.time{rows, cols}   = [];
            obj.peaks.width{rows, cols}  = [];
            obj.peaks.height{rows, cols} = [];
            obj.peaks.area{rows, cols}   = [];
            obj.peaks.error{rows, cols}  = [];
            obj.peaks.fit{rows, cols}    = [];
            
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

filename = [];

if ~isempty(obj.checkpoint)
    
    [status, fileinfo] = fileattrib(obj.checkpoint);
    
    if status
        [filepath, filename] = fileparts(fileinfo.Name);
        filepath = [filepath, filesep];
        filename = [filename, '.mat'];
    end
    
end

if isempty(filename)
    
    defaultname = [num2str(yyyymmdd(datetime)), '_chromatography_data'];
    
    [filename, filepath] = uiputfile('*.mat', 'Save As...', defaultname);
    
    if ischar(filename) && ischar(filepath)
        obj.checkpoint = [filepath, filename];
    end 
    
end

if ischar(filename) && ~isempty(data)
    currentpath = pwd;
    cd(filepath);
    save(filename, 'data', '-mat');
    cd(currentpath);
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
    [~, defaultname] = fileparts(obj.checkpoint);
else
    defaultname = [num2str(yyyymmdd(datetime)), '_chromatography_data'];
end

[filename, filepath] = uiputfile('*.mat', 'Save As...', defaultname);

if ischar(filename) && ischar(filepath) && ~isempty(data)
    currentpath = pwd;
    cd(filepath);
    save(filename, 'data', '-mat');
    obj.checkpoint = [filepath, filename];
    cd(currentpath);
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

[fileName, filePath] = uiputfile({filterExtensions, filterDescription});

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
filterDefaultName = [num2str(yyyymmdd(datetime)), '_chromatography_data'];

[filename, filepath] = uiputfile(...
    {filterExtensions, filterDescription},...
    'Save As...',...
    filterDefaultName);

if ischar(filename) && ischar(filepath)
    currentpath = pwd;
    cd(filepath);
    xlswrite(filename, excelData)
    cd(currentpath);
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

filterExtensions = '*.csv';
filterDescription = 'CSV file (*.csv)';
filterDefaultName = [num2str(yyyymmdd(datetime)), '_chromatography_data'];

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
% Refresh Table
% ---------------------------------------
function tableRefreshCallback(obj, varargin)

if isempty(obj.data)
    return
end

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
    
end

obj.updatePlot();

end

% ---------------------------------------
% Clear Table
% ---------------------------------------
function tableClearCallback(obj, varargin)

obj.table.main.Data = [];

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
end

rowSelection = '';

for i = 1:length(obj.table.selection(:,1))
    
    row = obj.table.selection(i,1);
    
    if i == 1
        rowSelection = num2str(row);
    elseif i > 1
        if obj.table.selection(i,1) - obj.table.selection(i-1,1) == 1
            if ~strcmpi(rowSelection(end), ':')
                if i == length(obj.table.selection(:,1))
                    rowSelection = [rowSelection, ':', num2str(row)];
                elseif i < length(obj.table.selection(:,1))
                    if obj.table.selection(i+1,1) - obj.table.selection(i,1) ~= 1
                        rowSelection = [rowSelection, ':', num2str(row)];
                    elseif obj.table.selection(i+1,1) - obj.table.selection(i,1) == 1
                        rowSelection = [rowSelection, ':'];
                    end
                end
            elseif strcmpi(rowSelection(end), ':')
                if i == length(obj.table.selection(:,1))
                    rowSelection = [rowSelection, num2str(row)];
                elseif i < length(obj.table.selection(:,1))
                    if obj.table.selection(i+1,1) - obj.table.selection(i,1) ~= 1
                        rowSelection = [rowSelection, num2str(row)];
                    end
                end
            end
            
        elseif obj.table.selection(i,1) - obj.table.selection(i-1,1) ~= 1
            rowSelection = [rowSelection, ', ', num2str(row)];
        end
    end    
end

msgPrompt = ['Delete selected rows (', rowSelection, ')?'];

msg = questdlg(...
    msgPrompt,...
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