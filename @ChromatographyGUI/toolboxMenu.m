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
obj.menu.file.exit   = newMenu(obj.menu.file.main, 'Exit');

obj.menu.file.import.Separator = 'on';
obj.menu.file.exit.Separator   = 'on';

obj.menu.file.save.Callback = {@saveCheckpoint, obj};

obj.menu.file.exit.Callback = @obj.closeRequest;

% ---------------------------------------
% File Menu --> Load
% ---------------------------------------
obj.menu.loadAgilent   = newMenu(obj.menu.file.load, 'Agilent data (*.D)');
obj.menu.loadWorkspace = newMenu(obj.menu.file.load, 'Workspace data (*.MAT)');
obj.menu.loadPeaklist  = newMenu(obj.menu.file.load, 'Peak list (*.MAT)');

obj.menu.loadAgilent.Callback   = {@loadAgilentCallback, obj};
obj.menu.loadWorkspace.Callback = {@loadMatlabCallback, obj};
obj.menu.loadPeaklist.Callback  = {@obj.toolboxPeakList, 'load_custom'};

% ---------------------------------------
% File Menu --> Save As
% ---------------------------------------
obj.menu.saveWorkspace = newMenu(obj.menu.file.saveAs, 'Workspace data (*.MAT)');
obj.menu.savePeaklist  = newMenu(obj.menu.file.saveAs, 'Peak list (*.MAT)');
obj.menu.saveImg       = newMenu(obj.menu.file.saveAs, 'Figure (*.JPG, *.PNG, *.TIFF)');
obj.menu.saveTable     = newMenu(obj.menu.file.saveAs, 'Table (*.CSV)');

obj.menu.saveWorkspace.Callback = {@saveMatlabCallback, obj};
obj.menu.savePeaklist.Callback  = {@obj.toolboxPeakList, 'save_custom'};
obj.menu.saveImg.Callback       = {@saveImageCallback, obj};
obj.menu.saveTable.Callback     = {@saveCsvCallback, obj};

if ispc
    obj.menu.saveXls = newMenu(obj.menu.file.saveAs, 'Table (*.XLS, *.XLSX)');
    obj.menu.saveXls.Callback = {@saveXlsCallback, obj};
end

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
obj.menu.edit.tableDeleteSelected = newMenu(obj.menu.edit.delete, 'Selected table rows...');
obj.menu.edit.tableDeleteAll = newMenu(obj.menu.edit.delete, 'All table rows...');

obj.menu.edit.tableDeleteSelected.Callback = {@tableDeleteRowMenu, obj};
obj.menu.edit.tableDeleteAll.Callback = {@tableDeleteRowMenu, obj};

obj.menu.edit.tableDeleteSelected.Tag = 'selected';
obj.menu.edit.tableDeleteAll.Tag = 'all';

% ---------------------------------------
% View Menu
% ---------------------------------------
obj.menu.view.data         = newMenu(obj.menu.view.main, 'Sample');
obj.menu.view.peak         = newMenu(obj.menu.view.main, 'Peak');
obj.menu.view.zoom         = newMenu(obj.menu.view.main, 'Zoom');
obj.menu.view.plotLabel    = newMenu(obj.menu.view.data, 'Show Label');
obj.menu.view.peakLabel    = newMenu(obj.menu.view.peak, 'Show Label');
obj.menu.view.peakLine     = newMenu(obj.menu.view.peak, 'Show Line');
obj.menu.view.peakArea     = newMenu(obj.menu.view.peak, 'Show Area');
obj.menu.view.peakBaseline = newMenu(obj.menu.view.peak, 'Show Baseline');

obj.menu.view.plotLabel.Tag    = 'showPlotLabel';
obj.menu.view.peakLabel.Tag    = 'showPeakLabel';
obj.menu.view.peakLine.Tag     = 'showPeakLine';
obj.menu.view.peakArea.Tag     = 'showPeakArea';
obj.menu.view.peakBaseline.Tag = 'showPeakBaseline';

obj.menu.view.plotLabel.Checked    = 'on';
obj.menu.view.peakLabel.Checked    = 'on';
obj.menu.view.peakLine.Checked     = 'on';
obj.menu.view.peakArea.Checked     = 'on';
obj.menu.view.peakBaseline.Checked = 'on';

obj.menu.view.plotLabel.Callback    = {@plotViewMenuCallback, obj};
obj.menu.view.peakLabel.Callback    = {@peakViewMenuCallback, obj};
obj.menu.view.peakLine.Callback     = {@peakViewMenuCallback, obj};
obj.menu.view.peakArea.Callback     = {@peakViewMenuCallback, obj};
obj.menu.view.peakBaseline.Callback = {@peakViewMenuCallback, obj};
obj.menu.view.zoom.Callback         = {@zoomMenuCallback, obj};

obj.menu.view.zoom.Separator = 'on';

% ---------------------------------------
% Options Menu
% ---------------------------------------
obj.menu.dataOptions = newMenu(obj.menu.options.main, 'Sample');
obj.menu.peakOptions = newMenu(obj.menu.options.main, 'Peak');

% ---------------------------------------
% Options --> Data
% ---------------------------------------
obj.menu.labelData = newMenu(obj.menu.dataOptions, 'Label');

obj.menu.labelData.Tag = 'data';

% ---------------------------------------
% Options --> Data --> Label
% ---------------------------------------
obj.menu.labelRowNum     = newMenu(obj.menu.labelData, 'ID');
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

obj.menu.labelRowNum.Tag     = 'row_num';
obj.menu.labelFilePath.Tag   = 'file_path';
obj.menu.labelFileName.Tag   = 'file_name';
obj.menu.labelInstrument.Tag = 'instrument';
obj.menu.labelDatetime.Tag   = 'datetime';
obj.menu.labelMethodName.Tag = 'method_name';
obj.menu.labelSampleName.Tag = 'sample_name';
obj.menu.labelOperator.Tag   = 'operator';
obj.menu.labelSeqIndex.Tag   = 'seqindex';
obj.menu.labelVialNum.Tag    = 'vial';
obj.menu.labelSelectAll.Tag  = 'selectAll';
obj.menu.labelSelectNone.Tag = 'selectNone';

obj.menu.labelRowNum.Callback     = {@plotLabelCallback, obj};
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

labelName = obj.settings.labels.data;

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
obj.menu.peakOptionsLabel      = newMenu(obj.menu.peakOptions, 'Label');
obj.menu.peakOptionsModel      = newMenu(obj.menu.peakOptions, 'Model');
obj.menu.peakOptionsArea       = newMenu(obj.menu.peakOptions, 'Area');
%obj.menu.peakOptionsAutoDetect = newMenu(obj.menu.peakOptions, 'Auto-Detect');

obj.menu.peakOptionsLabel.Tag = 'peak';

obj.menu.peakOptionsModel.Separator = 'on';
%obj.menu.peakOptionsAutoDetect.Separator = 'on';

%obj.menu.peakOptionsAutoDetect.Callback = {@peakAutodetectCallback, obj};

% ---------------------------------------
% Options --> Peak --> Label
% ---------------------------------------
obj.menu.labelPeakName   = newMenu(obj.menu.peakOptionsLabel, 'Name');
obj.menu.labelPeakTime   = newMenu(obj.menu.peakOptionsLabel, 'Time');
obj.menu.labelPeakWidth  = newMenu(obj.menu.peakOptionsLabel, 'Width');
obj.menu.labelPeakHeight = newMenu(obj.menu.peakOptionsLabel, 'Height');
obj.menu.labelPeakArea   = newMenu(obj.menu.peakOptionsLabel, 'Area');
obj.menu.labelPeakAll    = newMenu(obj.menu.peakOptionsLabel, 'Select All');
obj.menu.labelPeakNone   = newMenu(obj.menu.peakOptionsLabel, 'Select None');

obj.menu.labelPeakName.Tag   = 'peakName';
obj.menu.labelPeakTime.Tag   = 'peakTime';
obj.menu.labelPeakWidth.Tag  = 'peakWidth';
obj.menu.labelPeakHeight.Tag = 'peakHeight';
obj.menu.labelPeakArea.Tag   = 'peakArea';
obj.menu.labelPeakAll.Tag    = 'selectAll';
obj.menu.labelPeakNone.Tag   = 'selectNone';

obj.menu.labelPeakName.Callback   = {@plotLabelCallback, obj};
obj.menu.labelPeakTime.Callback   = {@plotLabelCallback, obj};
obj.menu.labelPeakWidth.Callback  = {@plotLabelCallback, obj};
obj.menu.labelPeakHeight.Callback = {@plotLabelCallback, obj};
obj.menu.labelPeakArea.Callback   = {@plotLabelCallback, obj};
obj.menu.labelPeakAll.Callback    = {@plotLabelQuickSelectCallback, obj};
obj.menu.labelPeakNone.Callback   = {@plotLabelQuickSelectCallback, obj};

obj.menu.labelPeakAll.Separator = 'on';

labelName = obj.settings.labels.peak;

for i = 1:length(obj.menu.peakOptionsLabel.Children)
    if any(ishandle(obj.menu.peakOptionsLabel.Children(i)))
        if any(strcmpi(obj.menu.peakOptionsLabel.Children(i).Tag, labelName))
            obj.menu.peakOptionsLabel.Children(i).Checked = 'on';
        else
            obj.menu.peakOptionsLabel.Children(i).Checked = 'off';
        end
    end
end

% ---------------------------------------
% Options --> Peak --> Model
% ---------------------------------------
obj.menu.peakNN1 = newMenu(obj.menu.peakOptionsModel, 'Neural Network (NN) v1.0');
obj.menu.peakNN2 = newMenu(obj.menu.peakOptionsModel, 'Neural Network (NN) v2.0');
obj.menu.peakEGH = newMenu(obj.menu.peakOptionsModel, 'Exponential Gaussian Hybrid (EGH)');

obj.menu.peakNN1.Tag = 'nn1';
obj.menu.peakNN2.Tag = 'nn2';
obj.menu.peakEGH.Tag = 'egh';

obj.menu.peakNN1.Checked = 'off';
obj.menu.peakNN2.Checked = 'on';
obj.menu.peakEGH.Checked = 'off';

obj.menu.peakNN1.Callback = {@peakModelMenuCallback, obj};
obj.menu.peakNN2.Callback = {@peakModelMenuCallback, obj};
obj.menu.peakEGH.Callback = {@peakModelMenuCallback, obj};

% ---------------------------------------
% Options --> Peak --> Area
% ---------------------------------------
obj.menu.peakOptionsAreaActual = newMenu(obj.menu.peakOptionsArea, 'Raw Data');
obj.menu.peakOptionsAreaFit    = newMenu(obj.menu.peakOptionsArea, 'Curve Fit');

obj.menu.peakOptionsAreaActual.Tag = 'rawdata';
obj.menu.peakOptionsAreaFit.Tag    = 'fitdata';

obj.menu.peakOptionsAreaActual.Checked = 'on';
obj.menu.peakOptionsAreaFit.Checked    = 'off';

obj.menu.peakOptionsAreaActual.Callback = {@peakAreaMenuCallback, obj};
obj.menu.peakOptionsAreaFit.Callback    = {@peakAreaMenuCallback, obj};

% ---------------------------------------
% Help Menu
% ---------------------------------------
obj.menu.help.website = newMenu(obj.menu.help.main, 'Project Website');
obj.menu.help.update  = newMenu(obj.menu.help.main, 'Check for updates...');

obj.menu.help.website.Callback = @obj.toolboxWebsite;
obj.menu.help.update.Callback  = @obj.toolboxUpdate;

end

% ---------------------------------------
% Load Agilent
% ---------------------------------------
function loadAgilentCallback(~, ~, obj)

% importAgilent 
isVerbose = 'off';
searchDepth = 3;

try
    data = importAgilent('verbose', isVerbose, 'depth', searchDepth); 
catch
    disp('Error importing data...'); 
end

if ~isempty(data) && isstruct(data)
    
    % Check file path
    data(cellfun(@isempty, {data.file_path})) = [];
    data(cellfun(@isempty, {data.file_name})) = [];
    data(cellfun(@isempty, {data.time}))      = [];
    data(cellfun(@isempty, {data.intensity})) = [];
    
    if isempty(data)
        return
    end
    
    % Check sequence index
    idx = find(cellfun(@isempty, {data.seqindex}));
    
    for i = 1:length(idx)
        data(idx(i)).seqindex = 99;
    end
    
    % Sort by file name
    if all(cellfun(@length, {data.channel}) == 1)
        
        [~, idx] = sort({data.channel});
    
        if length(idx) == length(data)
            data = data(idx);
        end
        
    end
    
    % Sort by sequence index
    [~, idx] = sort([data.seqindex], 'ascend');
    
    if length(idx) == length(data)
        data = data(idx);
    end
    
    % Sort by file path
    if length(unique({data.file_path})) > 1
    
        [~, idx] = sort({data.file_path});
    
        if length(idx) == length(data)
            data = data(idx);
        end
        
    end
    
    % Update GUI
    for i = 1:length(data)
        obj.data = [obj.data; data(i)];
        obj.appendTableData();
    end
    
    obj.validatePeakData(length(obj.data), length(obj.peaks.name));
    obj.updateFigure();
    
end

end

% ---------------------------------------
% Load MAT
% ---------------------------------------
function loadMatlabCallback(~, ~, obj)

[data, file] = importMAT('waitbar', true);

if ~isempty(data) && isstruct(data)
    
    if isstruct(data) && length(fields(data)) == 1
        x = fields(data);
        data = data.(x{1});
    end
        
    if isstruct(data) && isfield(data, 'sample_name') && length(data) >= 1
        
        if ~isfield(data, 'time') && ~isfield(data, 'intensity')
            return
        end
        
        if ~isfield(data, 'visited')
            for i = 1:length(data)
                data(i).visited = 0;
            end
        end
        
        if ~isfield(data, 'baseline')
            data(1).baseline = [];
        end
        
        if ~isfield(data, 'peaks')
            data(1).peaks = [];
            data(1).peaks.name = obj.peaks.name;
        end
        
        obj.data = data;
        obj.peaks = obj.data(1).peaks;
        
        if ~isempty(obj.peaks.name)
            nRow = length(obj.data);
            nCol = length(obj.peaks.name);
            obj.validatePeakData(nRow, nCol);
        end
        
        obj.checkpoint = file;
        
        obj.clearTableData();
        obj.resetTableHeader();
        obj.resetTableData();
        
        listboxRefreshCallback(obj);
        
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
    file = obj.checkpoint;
else
    file = [];
end

file = exportMAT(obj.data,...
    'file',    file,...
    'varname', 'data',...
    'waitbar', true);

if ischar(file)
    obj.checkpoint = file;
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

file = exportMAT(obj.data,...
    'varname', 'data',...
    'waitbar', true);

if ischar(file)
    obj.checkpoint = file;
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
        
        if ~isempty(axesHandles(axesPlot))
            
            axesPlot = axesHandles(axesPlot);
            axesChildren = axesPlot.Children;
            axesTag = get(axesChildren(isprop(axesChildren, 'tag')), 'tag');
            axesLabel = axesChildren(strcmp(axesTag, 'plotlabel'));
            
            if ~isempty(axesLabel)
                
                axesLabel = axesLabel(1);
                
                m = 0.01;
                
                a = axesLabel.Extent;
                xlimit = axesPlot.XLim;
                ylimit = axesPlot.YLim;
                
                b = axesLabel.Position(1);
                b = b - (a(1)+a(3) - (xlimit(2) - diff(xlimit)*m));
                axesLabel.Position(1) = b;
                
                b = axesLabel.Position(2);
                b = b - (a(2)+a(4) - (ylimit(2) - diff(ylimit)*m));
                axesLabel.Position(2) = b;
                
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

obj.removeTableHighlightText();

try
    excelData = [obj.table.main.ColumnName'; obj.table.main.Data];
catch
    excelData = obj.table.main.Data;
end

obj.addTableHighlightText();

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

obj.removeTableHighlightText();

tableHeader = obj.table.main.ColumnName;
tableData   = obj.table.main.Data;

if length(tableData(1,:)) ~= length(tableHeader)
    tableData{end, length(tableHeader)} = ' ';
end

obj.addTableHighlightText();

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
function tableDeleteRowMenu(src, ~, obj)

if isempty(obj.data) || isempty(obj.table.main.Data)% || isempty(obj.table.selection)
    return
else
    row = '';
end

switch src.Tag
    
    case 'all'
        obj.table.selection = (1:size(obj.table.main.Data,1))';
        
    case 'selected'
        
        if isempty(obj.table.selection)
            return
        else
            obj.table.selection = unique(obj.table.selection(:,1));
        end
        
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
    message = 'Delete selected samples?';
else
    message = ['Delete selected samples (', row, ')?'];
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
                obj.settings.showPeakLabel = 1;
                obj.plotPeakLabels();
            else
                obj.settings.showPeakLabel = 0;
                obj.clearAllPeakLabel();
            end
            
        case 'showPeakLine'
            
            if strcmpi(src.Checked, 'on')
                obj.settings.showPeakLine = 1;
                obj.updatePeakLine();
            else
                obj.settings.showPeakLine = 0;
                obj.clearAllPeakLine();
            end
            
        case 'showPeakArea'
            
            if strcmpi(src.Checked, 'on')
                obj.settings.showPeakArea = 1;
                obj.updatePeakArea();
            else
                obj.settings.showPeakArea = 0;
                obj.clearAllPeakArea();
            end
            
        case 'showPeakBaseline'
            
            if strcmpi(src.Checked, 'on')
                obj.settings.showPeakBaseline = 1;
                obj.updatePeakBaseline();
            else
                obj.settings.showPeakBaseline = 0;
                obj.clearAllPeakBaseline();
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
                obj.settings.showPlotLabel = 1;
                obj.updatePlotLabel();
            else
                obj.settings.showPlotLabel = 0;
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
            
            case 'row_num'
                plotLabel{1} = src.Parent.Children(i).Tag;
            case 'file_path'
                plotLabel{2} = src.Parent.Children(i).Tag;
            case 'file_name'
                plotLabel{3} = src.Parent.Children(i).Tag;
            case 'instrument'
                plotLabel{4} = src.Parent.Children(i).Tag;
            case 'datetime'
                plotLabel{5} = src.Parent.Children(i).Tag;
            case 'method_name'
                plotLabel{6} = src.Parent.Children(i).Tag;
            case 'sample_name'
                plotLabel{7} = src.Parent.Children(i).Tag;
            case 'operator'
                plotLabel{8} = src.Parent.Children(i).Tag;
            case 'seqindex'
                plotLabel{9} = src.Parent.Children(i).Tag;
            case 'vial'
                plotLabel{10} = src.Parent.Children(i).Tag;
                
            case 'peakName'
                plotLabel{1} = src.Parent.Children(i).Tag;
            case 'peakTime'
                plotLabel{2} = src.Parent.Children(i).Tag;
            case 'peakWidth'
                plotLabel{3} = src.Parent.Children(i).Tag;
            case 'peakHeight'
                plotLabel{4} = src.Parent.Children(i).Tag;
            case 'peakArea'
                plotLabel{5} = src.Parent.Children(i).Tag;
                
        end
        
    end
    
end

plotLabel(cellfun(@isempty, plotLabel)) = [];

switch src.Parent.Tag
    
    case 'data'
        
        obj.settings.labels.data = plotLabel;

        if obj.settings.showPlotLabel
            obj.updatePlotLabel();
        end

    case 'peak'
        
        obj.settings.labels.peak = plotLabel;

        if obj.settings.showPeakLabel
            obj.plotPeakLabels();
        end
        
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

obj.settings.peakModel = src.Tag;

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
% Set Peak Auto-Detection
% ---------------------------------------
%function peakAutodetectCallback(src, ~, obj)

%switch src.Checked
%    case 'on'
%        obj.settings.peakAutoDetect = 1;
%    case 'off'
%        obj.settings.peakAutoDetect = 0;
%end
%
%end

% ---------------------------------------
% Menu
% ---------------------------------------
function menu = newMenu(parent, label)

menu = uimenu('parent', parent, 'label', label);

end