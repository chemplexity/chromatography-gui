function toolboxTable(obj, varargin)

% ---------------------------------------
% Table Properties
% ---------------------------------------
backgroundColor = [1.00, 1.00, 1.00; 0.94, 0.94, 0.94];
foregroundColor = [0.00, 0.00, 0.00];
fontSize        = 10;

% ---------------------------------------
% Table Columns (metadata)
% ---------------------------------------
columnParameters = {...
    'ID',         35,    false,   'numeric';...
    'Filepath',   125,   false,   'char';...
    'Filename',   150,   false,   'char';...
    'Datetime',   150,   false,   'char';...
    'Instrument', 100,   true,    'char';...
    'Detector',   100,   true,    'char';...
    'Method',     125,   false,   'char';...
    'Operator',   75,    true,    'char';...
    'SampleName', 100,   true,    'char';
    'SampleInfo', 100,   true,    'char';...
    'SeqLine',    75,    false,   'numeric';...
    'VialNum',    75,    false,   'numeric';...
    'InjNum',     75,    false,   'numeric';...
    'InjVol',     75,    true,    'numeric'};

% ---------------------------------------
% Table Columns (peak data)
% ---------------------------------------
if ~isempty(obj.peaks.name)
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Time (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Area (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Height (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Width (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end

end

% ---------------------------------------
% Table
% ---------------------------------------
obj.table.main = uitable(...
    'parent',                obj.panel.table,...
    'tag',                   'datatable',...
    'rowname',               [],...
    'rowstriping',           'off',...
    'units',                 'normalized',...
    'position',              [0,0,1,1],...
    'columnname',            columnParameters(:,1),...
    'columnwidth',           columnParameters(:,2)',...
    'columneditable',        [columnParameters{:,3}],...
    'columnformat',          columnParameters(:,4)',...
    'backgroundcolor',       backgroundColor,....
    'foregroundcolor',       foregroundColor,...
    'fontname',              obj.font,...
    'fontSize',              fontSize,...
    'rearrangeablecolumns',  'off',....
    'selectionhighlight',    'off',...
    'celleditcallback',      @(src, event) tableEditCallback(obj, src, event),...
    'cellselectioncallback', @(src, event) tableSelectCallback(obj, src, event),...
    'keypressfcn',           @(src, event) tableKeyDownCallback(obj, src, event));

end

% ---------------------------------------
% Table Edit Callback
% ---------------------------------------
function tableEditCallback(obj, src, evt)

if isempty(src.Data)
    return
end

switch evt.Indices(2)
    
    case 5
        obj.data(evt.Indices(1)).instrument = evt.NewData;
    case 6
        obj.data(evt.Indices(1)).instmodel = evt.NewData;
    case 8
        obj.data(evt.Indices(1)).operator = evt.NewData;
    case 9
        obj.data(evt.Indices(1)).sample_name = evt.NewData;
    case 10
        obj.data(evt.Indices(1)).sample_info = evt.NewData;
    case 14
        obj.data(evt.Indices(1)).injvol = evt.NewData;
end

src.Data(evt.Indices(1), evt.Indices(2)) = evt.NewData;

end

% ---------------------------------------
% Table Selection Callback
% ---------------------------------------
function tableSelectCallback(obj, ~, evt)

obj.table.selection = evt.Indices;

end

% ---------------------------------------
% Table Key Press Callback
% ---------------------------------------
function tableKeyDownCallback(obj, ~, evt)

if strcmpi(evt.EventName, 'KeyPress')
    
    switch evt.Key
        
        case 'return'
            
            if isempty(obj.table.selection) || isempty(obj.data)
                return
            end
            
            obj.table.selection = obj.table.selection(1,:);
            
            row = obj.table.selection(1,1);
            
            if row <= length(obj.data) && row > 0
                obj.view.index = row;
                obj.view.id    = num2str(row);
                obj.view.name  = obj.data(row).sample_name;
            else
                return
            end
            
            set(obj.controls.editID,   'string', obj.view.id);
            set(obj.controls.editName, 'string', obj.view.name);
            
            obj.updatePlot();
            
        case 'delete'
            
            msgPrompt = tableDeleteMessage(obj);
            
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
            
        case 'backspace'
            
            if isempty(obj.table.selection) || isempty(obj.data)
                return
            end
            
            if obj.table.selection(1,2) == 1
                
                msgPrompt = tableDeleteMessage(obj);
                
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
    end
end

end

% ---------------------------------------
% Table Delete Row
% ---------------------------------------
function message = tableDeleteMessage(obj)

row = '';

for i = 1:length(obj.table.selection(:,1))
    
    row = obj.table.selection(i,1);
    
    if i == 1
        row = num2str(row);
    elseif i > 1
        if obj.table.selection(i,1) - obj.table.selection(i-1,1) == 1
            if ~strcmpi(row(end), ':')
                if i == length(obj.table.selection(:,1))
                    row = [row, ':', num2str(row)];
                elseif i < length(obj.table.selection(:,1))
                    if obj.table.selection(i+1,1) - obj.table.selection(i,1) ~= 1
                        row = [row, ':', num2str(row)];
                    elseif obj.table.selection(i+1,1) - obj.table.selection(i,1) == 1
                        row = [row, ':'];
                    end
                end
            elseif strcmpi(row(end), ':')
                if i == length(obj.table.selection(:,1))
                    row = [row, num2str(row)];
                elseif i < length(obj.table.selection(:,1))
                    if obj.table.selection(i+1,1) - obj.table.selection(i,1) ~= 1
                        row = [row, num2str(row)];
                    end
                end
            end
            
        elseif obj.table.selection(i,1) - obj.table.selection(i-1,1) ~= 1
            row = [row, ', ', num2str(row)];
        end
    end
end

if isempty(row)
    message = 'Delete selected rows?';
else
    message = ['Delete selected rows (', row, ')?'];
end

end