function toolboxMenu(obj, varargin)

% ---------------------------------------
% Menu
% ---------------------------------------
obj.menu.file.main    = newMenu(obj.figure, 'File');
obj.menu.edit.main    = newMenu(obj.figure, 'Edit');
obj.menu.view.main    = newMenu(obj.figure, 'View');
obj.menu.options.main = newMenu(obj.figure, 'Options');
obj.menu.help.main    = newMenu(obj.figure, 'Help');

% ---------------------------------------
% File Menu
% ---------------------------------------
obj.menu.file.load   = newMenu(obj.menu.file.main, 'Load');
obj.menu.file.save   = newMenu(obj.menu.file.main, 'Save');
obj.menu.file.saveAs = newMenu(obj.menu.file.main, 'Save As...');
obj.menu.file.import = newMenu(obj.menu.file.main, 'Import');
obj.menu.file.export = newMenu(obj.menu.file.main, 'Export');
obj.menu.file.exit   = newMenu(obj.menu.file.main, 'Exit');

obj.menu.file.save.Callback = {@saveCheckpoint, obj};
obj.menu.file.exit.Callback = 'closereq';

obj.menu.file.import.Separator = 'on';
obj.menu.file.exit.Separator   = 'on';

% ---------------------------------------
% File Menu --> Load
% ---------------------------------------
obj.menu.loadRaw     = newMenu(obj.menu.file.load, 'Data');
obj.menu.loadData    = newMenu(obj.menu.file.load, 'Workspace');
obj.menu.loadAgilent = newMenu(obj.menu.loadRaw, 'Agilent (*.D)');
obj.menu.loadMat     = newMenu(obj.menu.loadData, 'MAT (*.MAT)');

obj.menu.loadAgilent.Callback = {@loadAgilentCallback, obj};
obj.menu.loadMat.Callback     = {@loadMatlabCallback, obj};

% ---------------------------------------
% File Menu --> Save As
% ---------------------------------------
obj.menu.saveFig   = newMenu(obj.menu.file.saveAs, 'Figure');
obj.menu.saveTable = newMenu(obj.menu.file.saveAs, 'Table');
obj.menu.saveData  = newMenu(obj.menu.file.saveAs, 'Workspace');
obj.menu.saveImg   = newMenu(obj.menu.saveFig, 'Image (*.JPG, *.PNG, *.TIFF)');
obj.menu.saveCsv   = newMenu(obj.menu.saveTable, 'CSV (*.CSV)');
obj.menu.saveMat   = newMenu(obj.menu.saveData, 'MAT (*.MAT)');

obj.menu.saveImg.Callback = {@saveImageCallback, obj};
obj.menu.saveCsv.Callback = {@saveCsvCallback, obj};
obj.menu.saveMat.Callback = {@saveMatlabCallback, obj};

if ispc
    obj.menu.saveXls = newMenu(obj.menu.saveTable, 'Excel (*.XLS, *.XLSX)');
    obj.menu.saveXls.Callback = {@saveXlsCallback, obj};
end

% ---------------------------------------
% File Menu --> Import/Export
% ---------------------------------------
obj.menu.file.importPeakList = newMenu(obj.menu.file.import, 'Peak List');
obj.menu.file.importSettings = newMenu(obj.menu.file.import, 'Settings');

obj.menu.file.exportPeakList = newMenu(obj.menu.file.export, 'Peak List');
obj.menu.file.exportSettings = newMenu(obj.menu.file.export, 'Settings');

obj.menu.file.importPeakList.Callback = {@importPeakList, obj};
obj.menu.file.importSettings.Callback = {@obj.toolboxSettings, 'load_custom'};
obj.menu.file.exportPeakList.Callback = {@exportPeakList, obj};
obj.menu.file.exportSettings.Callback = {@obj.toolboxSettings, 'save_custom'};

% ---------------------------------------
% Edit Menu
% ---------------------------------------
obj.menu.edit.copy   = newMenu(obj.menu.edit.main, 'Copy');
obj.menu.edit.delete = newMenu(obj.menu.edit.main, 'Delete');

% ---------------------------------------
% Edit Menu --> Copy
% ---------------------------------------
obj.menu.edit.copyFigure = newMenu(obj.menu.edit.copy, 'Figure');
obj.menu.edit.copyTable  = newMenu(obj.menu.edit.copy, 'Table');

obj.menu.edit.copyFigure.Callback = @obj.copyFigure;
obj.menu.edit.copyTable.Callback  = @obj.copyTable;

% ---------------------------------------
% Edit Menu --> Delete
% ---------------------------------------
obj.menu.edit.deleteSample   = newMenu(obj.menu.edit.delete, 'Data');
obj.menu.edit.deleteSelected = newMenu(obj.menu.edit.deleteSample, 'Selected rows...');

obj.menu.edit.deleteSelected.Callback = {@tableDeleteRowMenu, obj};

% ---------------------------------------
% View Menu
% ---------------------------------------
obj.menu.view.data      = newMenu(obj.menu.view.main, 'Data');
obj.menu.view.peak      = newMenu(obj.menu.view.main, 'Peak');
obj.menu.view.zoom      = newMenu(obj.menu.view.main, 'Zoom');
obj.menu.view.plotLabel = newMenu(obj.menu.view.data, 'Show Label');
obj.menu.view.peakLabel = newMenu(obj.menu.view.peak, 'Show Label');
obj.menu.view.peakLine  = newMenu(obj.menu.view.peak, 'Show Line');

obj.menu.view.plotLabel.Tag      = 'showPlotLabel';
obj.menu.view.peakLabel.Tag      = 'showPeakLabel';
obj.menu.view.peakLine.Tag       = 'showPeakLine';

obj.menu.view.plotLabel.Checked  = 'on';
obj.menu.view.peakLabel.Checked  = 'on';
obj.menu.view.peakLine.Checked   = 'on';
obj.menu.view.zoom.Checked       = 'off';

obj.menu.view.plotLabel.Callback = {@plotViewMenuCallback, obj};
obj.menu.view.peakLabel.Callback = {@peakViewMenuCallback, obj};
obj.menu.view.peakLine.Callback  = {@peakViewMenuCallback, obj};
obj.menu.view.zoom.Callback      = {@zoomMenuCallback, obj};

obj.menu.view.zoom.Separator     = 'on';

% ---------------------------------------
% Options Menu
% ---------------------------------------
obj.menu.dataOptions  = newMenu(obj.menu.options.main, 'Data');
obj.menu.peakOptions  = newMenu(obj.menu.options.main, 'Peak');

% ---------------------------------------
% Options --> Data
% ---------------------------------------
obj.menu.labelData       = newMenu(obj.menu.dataOptions, 'Label');
obj.menu.labelFilePath   = newMenu(obj.menu.labelData, 'File Path');
obj.menu.labelFileName   = newMenu(obj.menu.labelData, 'File Name');
obj.menu.labelInstrument = newMenu(obj.menu.labelData, 'Instrument');
obj.menu.labelDatetime   = newMenu(obj.menu.labelData, 'Date/Time');
obj.menu.labelMethodName = newMenu(obj.menu.labelData, 'Method Name');
obj.menu.labelSampleName = newMenu(obj.menu.labelData, 'Sample Name');
obj.menu.labelOperator   = newMenu(obj.menu.labelData, 'Operator');
obj.menu.labelSeqIndex   = newMenu(obj.menu.labelData, 'Sequence Index');
obj.menu.labelVialNum    = newMenu(obj.menu.labelData, 'Vial #');
obj.menu.labelSelectAll  = newMenu(obj.menu.labelData, 'Select All');
obj.menu.labelSelectNone = newMenu(obj.menu.labelData, 'Select None');

obj.menu.labelFilePath.Tag        = 'file_path';
obj.menu.labelFileName.Tag        = 'file_name';
obj.menu.labelInstrument.Tag      = 'instrument';
obj.menu.labelDatetime.Tag        = 'datetime';
obj.menu.labelMethodName.Tag      = 'method_name';
obj.menu.labelSampleName.Tag      = 'sample_name';
obj.menu.labelOperator.Tag        = 'operator';
obj.menu.labelSeqIndex.Tag        = 'seqindex';
obj.menu.labelVialNum.Tag         = 'vial';
obj.menu.labelSelectAll.Tag       = 'selectAll';
obj.menu.labelSelectNone.Tag      = 'selectNone';

obj.menu.labelFilePath.Callback   = {@plotLabelCallback, obj};
obj.menu.labelFileName.Callback   = {@plotLabelCallback, obj};
obj.menu.labelInstrument.Callback = {@plotLabelCallback, obj};
obj.menu.labelDatetime.Callback   = {@plotLabelCallback, obj};
obj.menu.labelMethodName.Callback = {@plotLabelCallback, obj};
obj.menu.labelSampleName.Callback = {@plotLabelCallback, obj};
obj.menu.labelOperator.Callback   = {@plotLabelCallback, obj};
obj.menu.labelSeqIndex.Callback   = {@plotLabelCallback, obj};
obj.menu.labelVialNum.Callback    = {@plotLabelCallback, obj};
obj.menu.labelSelectAll.Callback  = {@plotLabelQuickSelectCallback, obj};
obj.menu.labelSelectNone.Callback = {@plotLabelQuickSelectCallback, obj};

obj.menu.labelSelectAll.Separator = 'on';

labelName = obj.settings.labels.legend;

for i = 1:length(obj.menu.labelData.Children)
    if any(ishandle(obj.menu.labelData.Children(i)))
        if any(strcmpi(obj.menu.labelData.Children(i).Tag, labelName))
            obj.menu.labelData.Children(i).Checked = 'on';
        else
            obj.menu.labelData.Children(i).Checked = 'off';
        end
    end
end

% ---------------------------------------
% Options --> Peak
% ---------------------------------------
obj.menu.peakOptionsModel        = newMenu(obj.menu.peakOptions, 'Model');
obj.menu.peakOptionsArea         = newMenu(obj.menu.peakOptions, 'Area');
obj.menu.peakNeuralNetwork       = newMenu(obj.menu.peakOptionsModel, 'Neural Network (NN)');
obj.menu.peakExponentialGaussian = newMenu(obj.menu.peakOptionsModel, 'Exponential Gaussian Hybrid (EGH)');
obj.menu.peakOptionsAreaActual   = newMenu(obj.menu.peakOptionsArea, 'Raw Data');
obj.menu.peakOptionsAreaFit      = newMenu(obj.menu.peakOptionsArea, 'Curve Fit');

obj.menu.peakNeuralNetwork.Tag            = 'peakNN';
obj.menu.peakExponentialGaussian.Tag      = 'peakEGH';
obj.menu.peakOptionsAreaActual.Tag        = 'rawData';
obj.menu.peakOptionsAreaFit.Tag           = 'fitData';

obj.menu.peakNeuralNetwork.Checked        = 'on';
obj.menu.peakExponentialGaussian.Checked  = 'off';
obj.menu.peakOptionsAreaActual.Checked    = 'on';
obj.menu.peakOptionsAreaFit.Checked       = 'off';

obj.menu.peakNeuralNetwork.Callback       = {@peakModelMenuCallback, obj};
obj.menu.peakExponentialGaussian.Callback = {@peakModelMenuCallback, obj};
obj.menu.peakOptionsAreaActual.Callback   = {@peakAreaMenuCallback, obj};
obj.menu.peakOptionsAreaFit.Callback      = {@peakAreaMenuCallback, obj};

% ---------------------------------------
% Help Menu
% ---------------------------------------
obj.menu.help.update = newMenu(obj.menu.help.main, 'Check for updates...');

obj.menu.help.update.Callback = @obj.toolboxUpdate;

% ---------------------------------------
% Developer Mode
% ---------------------------------------
sourcePath = dir(fileparts(fileparts(mfilename('fullpath'))));

if any(strcmpi('.git', {sourcePath.name}))
    [gitStatus, ~] = system('git --version');
    
    if ~gitStatus
        [gitStatus, gitBranch] = system('git rev-parse --abbrev-ref HEAD');
        
        if ~gitStatus
            gitBranch = deblank(strtrim(gitBranch));
            
            if strcmpi(gitBranch, 'develop')
                developerMode = 'on';
            else
                developerMode = 'off';
            end
            
            obj.menu.help.update = newMenu(obj.menu.help.main, 'Developer Mode');
            
            obj.menu.help.update.Checked   = developerMode;
            obj.menu.help.update.Callback  = @developerModeCallback;
            obj.menu.help.update.Separator = 'on';
            
        end
    end
end

end

% ---------------------------------------
% Import Peak List
% ---------------------------------------
function importPeakList(~, ~, obj)

data = importMAT();

if isempty(data)
    return
elseif ~isstruct(data) || ~isfield(data, 'user_peaks')
    return
else
    data = data.user_peaks;
end

if ~isfield(data, 'name') || ~strcmpi(data.name, 'peaklist')
    return
elseif ~isfield(data, 'data') || isempty(data.data)
    return
elseif ~iscell(data.data)
    return
else
    data = data.data;
end

for i = 1:length(data)
    
    if ~ischar(data{i})
        continue
    end
    
    if ~any(strcmpi(data{i}, obj.peaks.name))
        obj.peakAddColumn(data{i})
    end
    
end

end

% ---------------------------------------
% Export Peak List
% ---------------------------------------
function exportPeakList(~, ~, obj)

if isempty(obj.peaks.name)
    return
end

user_peaks.version = obj.version;
user_peaks.name    = 'peaklist';
user_peaks.data    = obj.peaks.name;

exportMAT(user_peaks, 'name', 'user_peaks');

end

% ---------------------------------------
% Load Agilent
% ---------------------------------------
function loadAgilentCallback(~, ~, obj)

data = importAgilent('verbose', 'off', 'depth', 3);

if ~isempty(data) && isstruct(data)
    
    for i = 1:length(data)
        
        if ~isempty(data(i).file_path) && ~isempty(data(i).file_name)
            obj.data = [obj.data; data(i)];
            obj.appendTableData();
        end
        
    end
    
    obj.validatePeakData(length(obj.data), length(obj.peaks.name));
    obj.updateFigure();
    
end

end

% ---------------------------------------
% Load MAT
% ---------------------------------------
function loadMatlabCallback(~, ~, obj)

data = importMAT();

if ~isempty(data) && isstruct(data) && isfield(data, 'data')
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
        
        obj.updatePeakText();
        obj.updateFigure();
        
    end
end

end

% ---------------------------------------
% Save MAT
% ---------------------------------------
function saveCheckpoint(~, ~, obj)

if ~isempty(obj.data)
    obj.data(1).peaks = obj.peaks;
else
    return
end

if ~isempty(obj.checkpoint) && fileattrib(obj.checkpoint)
    fileName = obj.checkpoint;
else
    fileName = [];
end

fileName = exportMAT(obj.data, 'file', fileName, 'name', 'data');

if ischar(fileName)
    obj.checkpoint = fileName;
end

end

% ---------------------------------------
% Save MAT
% ---------------------------------------
function saveMatlabCallback(~, ~, obj)

if ~isempty(obj.data)
    obj.data(1).peaks = obj.peaks;
else
    return
end

fileName = exportMAT(obj.data, 'name', 'data');

if ischar(fileName)
    obj.checkpoint = fileName;
end

end

% ---------------------------------------
% Save Image
% ---------------------------------------
function saveImageCallback(~, ~, obj)

if isempty(obj.data) || obj.view.index == 0
    return
end

row = obj.view.index;

filterExtensions  = '*.jpg;*.jpeg;*.png;*.tif;*.tiff';
filterDescription = 'Image file (*.jpg, *.png, *.tif)';
filterDefaultName = '';

if ~isempty(obj.data(row).datetime) && length(obj.data(row).datetime) >= 10
    filterDefaultName = [obj.data(row).datetime(1:10), ' - '];
end

if ~isempty(obj.data(row).sample_name)
    sampleName = obj.data(row).sample_name;
    sampleName = regexprep(sampleName, '[/\*:?!%^#@"<>|.]', '_');
    sampleName = deblank(strtrim(sampleName));
    filterDefaultName = [filterDefaultName, sampleName];
end

if isempty(filterDefaultName)
    filterDefaultName = [datestr(date, 'yyyymmdd'),'-chromatography-data'];
end

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
            'bordertype', 'none',...
            'backgroundcolor', 'white');
        
        axesHandles = exportPanel.Children;
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
            close(exportFigure);
        end
    end
end

end

% ---------------------------------------
% Save Excel
% ---------------------------------------
function saveXlsCallback(~, ~, obj)

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
                excelData{i,j} = excelData{i,j};
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
function saveCsvCallback(~, ~, obj)

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
                
            elseif isnumeric(tableData{i,j}) && j >= 14
                tableData{i,j} = num2str(tableData{i,j});
                
            elseif isnumeric(tableData{i,j})
                tableData{i,j} = num2str(tableData{i,j});
                
            elseif ischar(tableData{i,j})
                tableData{i,j} = regexprep(tableData{i,j}, '([,]|\t)', ' ');
                tableData{i,j} = deblank(strtrim(tableData{i,j}));
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

obj.controls.peakList.String = obj.peaks.name;

end

% ---------------------------------------
% Delete Table Row
% ---------------------------------------
function tableDeleteRowMenu(~, ~, obj)

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
function zoomMenuCallback(src, evt, obj)

if strcmpi(evt.EventName, 'Action')
    
    switch src.Checked
        
        case 'on'
            src.Checked = 'off';
            obj.userZoom(0);
            
        case 'off'
            src.Checked = 'on';
            obj.userZoom(1);
            obj.userPeak(0);
            
    end
    
end

end

% ---------------------------------------
% Enable/Disable Peak Labels, Lines
% ---------------------------------------
function peakViewMenuCallback(src, evt, obj)

if strcmpi(evt.EventName, 'Action')
    
    switch src.Checked
        case 'on'
            src.Checked = 'off';
        case 'off'
            src.Checked = 'on';
    end
    
    switch src.Tag
        
        case 'showPeakLabel'
            
            if strcmpi(src.Checked, 'on')
                obj.view.showPeakLabel = 1;
                obj.plotPeakLabels();
            else
                obj.view.showPeakLabel = 0;
                obj.clearAllPeakLabel();
            end
            
        case 'showPeakLine'
            
            if strcmpi(src.Checked, 'on')
                obj.view.showPeakLine = 1;
                obj.updatePeakLine();
            else
                obj.view.showPeakLine = 0;
                obj.clearAllPeakLine();
            end
    end
    
end

end

% ---------------------------------------
% Enable/Disable Data Labels
% ---------------------------------------
function plotViewMenuCallback(src, evt, obj)

if strcmpi(evt.EventName, 'Action')
    
    switch src.Checked
        case 'on'
            src.Checked = 'off';
        case 'off'
            src.Checked = 'on';
    end
    
    switch src.Tag
        
        case 'showPlotLabel'
            
            if strcmpi(src.Checked, 'on')
                obj.view.showPlotLabel = 1;
                obj.updatePlotLabel();
            else
                obj.view.showPlotLabel = 0;
                obj.clearAxesChildren('plotlabel');
            end
            
    end
    
end

end

% ---------------------------------------
% Select Fields for Plot Label
% ---------------------------------------
function plotLabelCallback(src, ~, obj)

switch src.Checked
    
    case 'on'
        src.Checked = 'off';
        
    case 'off'
        src.Checked = 'on';
        
    otherwise
        src.Checked = 'off';
        
end

updatePlotLabel(src, obj);

end

function plotLabelQuickSelectCallback(src, ~, obj)

switch src.Tag
    
    case 'selectAll'
        labelState = 'on';
        
    case 'selectNone'
        labelState = 'off';
        
    otherwise
        labelState = 'off';
        
end

for i = 1:length(src.Parent.Children)
    
    if ~any(strcmpi(src.Parent.Children(i).Tag, {'selectAll', 'selectNone'}))
        src.Parent.Children(i).Checked = labelState;
    end
    
end

updatePlotLabel(src, obj);

end

function updatePlotLabel(src, obj)

plotLabel = {};

for i = 1:length(src.Parent.Children)
    
    if strcmpi(src.Parent.Children(i).Checked, 'on')
        
        switch src.Parent.Children(i).Tag
            case 'file_path'
                plotLabel{1} = src.Parent.Children(i).Tag;
            case 'file_name'
                plotLabel{2} = src.Parent.Children(i).Tag;
            case 'instrument'
                plotLabel{3} = src.Parent.Children(i).Tag;
            case 'datetime'
                plotLabel{4} = src.Parent.Children(i).Tag;
            case 'method_name'
                plotLabel{5} = src.Parent.Children(i).Tag;
            case 'sample_name'
                plotLabel{6} = src.Parent.Children(i).Tag;
            case 'operator'
                plotLabel{7} = src.Parent.Children(i).Tag;
            case 'seqindex'
                plotLabel{8} = src.Parent.Children(i).Tag;
            case 'vial'
                plotLabel{9} = src.Parent.Children(i).Tag;
        end
        
    end
    
end

plotLabel(cellfun(@isempty, plotLabel)) = [];
obj.settings.labels.legend = plotLabel;

if obj.view.showPlotLabel
    obj.updatePlotLabel();
end

end

% ---------------------------------------
% Set Peak Model
% ---------------------------------------
function peakModelMenuCallback(src, ~, obj)

for i = 1:length(src.Parent.Children)
    src.Parent.Children(i).Checked = 'off';
end

src.Checked = 'on';

switch src.Tag
    case 'peakNN'
        obj.settings.peakModel = 'nn';
    case 'peakEGH'
        obj.settings.peakModel = 'egh';
end

end

% ---------------------------------------
% Set Peak Area Target
% ---------------------------------------
function peakAreaMenuCallback(src, ~, obj)

for i = 1:length(src.Parent.Children)
    src.Parent.Children(i).Checked = 'off';
end

src.Checked = 'on';

obj.settings.peakArea = src.Tag;

end

% ---------------------------------------
% Enable/Disable Developer Mode
% ---------------------------------------
function developerModeCallback(src, ~)

[gitStatus, ~] = system('git --version');

if gitStatus
    return
end

if strcmpi(src.Checked, 'on')
    src.Checked = 'off';
else
    src.Checked = 'on';
end

currentPath = pwd;
sourcePath = fileparts(fileparts(mfilename('fullpath')));
cd(sourcePath);

[gitStatus, gitBranch] = system('git rev-parse --abbrev-ref HEAD');

if gitStatus
    return
else
    gitBranch = deblank(strtrim(gitBranch));
end

if strcmpi(src.Checked, 'on') && ~strcmpi(gitBranch, 'develop')
    
    [gitStatus,~] = system('git checkout develop');
    
    if gitStatus
        msg = 'Error switching to developer mode...';
    else
        msg = 'Please restart ChromatographyGUI to enter developer mode...';
    end
    
elseif strcmpi(src.Checked, 'off') && ~strcmpi(gitBranch, 'master')
    
    [gitStatus,~] = system('git checkout master');
    
    if gitStatus
        msg = 'Error switching from developer mode...';
    else
        msg = 'Please restart ChromatographyGUI to exit developer mode...';
    end
    
else
    msg = '';
end

if ~isempty(msg)
    questdlg(msg, 'Developer Mode', 'OK', 'OK');
end

cd(currentPath);

end

% ---------------------------------------
% Menu
% ---------------------------------------
function menu = newMenu(parent, label)

menu = uimenu('parent', parent, 'label', label);

end