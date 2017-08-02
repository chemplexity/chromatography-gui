function toolboxTable(obj, varargin)

% ---------------------------------------
% Table Properties
% ---------------------------------------
backgroundColor = [1.00, 1.00, 1.00; 0.94, 0.94, 0.94];
foregroundColor = [0.00, 0.00, 0.00];

% ---------------------------------------
% Table Columns (metadata)
% ---------------------------------------
columnParameters = {...
    'Filepath',   125,   false,   'char';...
    'Filename',   150,   false,   'char';...
    'Datetime',   150,   false,   'char';...
    'Instrument', 100,   false,   'char';...
    'Detector',   100,   false,   'char';...
    'Method',     125,   false,   'char';...
    'Operator',   75,    false,   'char';...
    'SampleName', 100,   false,   'char';
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
            {['Area (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Height (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
    end
    
    for i = 1:length(obj.peaks.name)
        columnParameters(end+1, 1:4) = ...
            {['Time (', obj.peaks.name{i}, ')'], 110, false, 'numeric'};
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
    'rowname',               {'numbered'},...
    'rowstriping',           'off',...
    'units',                 'normalized',...
    'position',              [0,0,1,1],...
    'columnname',            columnParameters(:,1),...
    'columnwidth',           columnParameters(:,2)',...
    'columneditable',        [columnParameters{:,3}],...
    'columnformat',          columnParameters(:,4)',...
    'backgroundcolor',       backgroundColor,....
    'foregroundcolor',       foregroundColor,...
    'fontname',              obj.settings.table.fontname,...
    'fontsize',              obj.settings.table.fontsize,...
    'rearrangeablecolumns',  'off',....
    'selectionhighlight',    'off',...
    'celleditcallback',      {@tableEditCallback, obj},...
    'cellselectioncallback', {@tableSelectCallback, obj},...
    'keypressfcn',           {@tableKeyDownCallback, obj});

end

% ---------------------------------------
% Table Edit Callback
% ---------------------------------------
function tableEditCallback(src, evt, obj)

if isempty(src.Data)
    return
end

switch evt.Indices(2)

    case 9
        obj.data(evt.Indices(1)).sample_info = evt.NewData;
        src.Data(evt.Indices(1), evt.Indices(2)) = {evt.NewData};
        
    case 13
        
        x = src.Data{evt.Indices(1), evt.Indices(2)};
        
        if isempty(x) || ~isnumeric(x) || isnan(x)
            obj.data(evt.Indices(1)).injvol = [];
            src.Data{evt.Indices(1), evt.Indices(2)} = [];
            return
            
        elseif ~isinf(x) && isreal(x) && ~isnan(x)
            obj.data(evt.Indices(1)).injvol = x;

        else
            obj.data(evt.Indices(1)).injvol = evt.PreviousData;
            src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
            return
        end
        
end

end

% ---------------------------------------
% Table Selection Callback
% ---------------------------------------
function tableSelectCallback(~, evt, obj)

obj.table.selection = evt.Indices;

end

% ---------------------------------------
% Table Key Press Callback
% ---------------------------------------
function tableKeyDownCallback(~, evt, obj)

if isempty(obj.table.selection) || isempty(obj.data)
    return
end

if strcmpi(evt.EventName, 'KeyPress')
    
    switch evt.Key
        
        case 'return'
            
            if ~any(obj.table.selection(1,2) == [9,13])
                obj.selectSample(obj.table.selection(1,1)-obj.view.index);
            end
            
        case 'delete'
            
            if isempty(obj.table.selection) || isempty(obj.data)
                return
            end
            
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
            
            if any(any(obj.table.selection(:,2) == 13))
                
                for i = 1:length(obj.table.selection(:,2))
                    
                    if obj.table.selection(i,2) == 9
                        row = obj.table.selection(i,1);
                        obj.data(row).sample_info = [];
                        obj.table.main.Data{row,9} = []; 
                    elseif obj.table.selection(i,2) == 13
                        row = obj.table.selection(i,1);
                        obj.data(row).injvol = [];
                        obj.table.main.Data{row,13} = []; 
                    end
                    
                end
                
            end
            
    end
    
end

end

% ---------------------------------------
% Table Delete Row
% ---------------------------------------
function message = tableDeleteMessage(obj)

obj.table.selection = unique(obj.table.selection(:,1));

row = '';
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

end