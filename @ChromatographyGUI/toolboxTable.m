function toolboxTable(obj, varargin)

% ---------------------------------------
% Table Columns
% ---------------------------------------
columnParameters = {...
    'Filepath',   125,   false,   'char';...
    'Filename',   150,   false,   'char';...
    'Datetime',   150,   false,   'char';...
    'Instrument', 75,    false,   'char';...
    'Sequence',   100,   false,   'char';...
    'Method',     125,   false,   'char';...
    'Operator',   75,    false,   'char';...
    'SampleName', 150,   false,   'char';
    'SampleInfo', 75,    true,    'char';...
    'SeqLine',    75,    false,   'numeric';...
    'VialNum',    75,    false,   'numeric';...
    'InjNum',     75,    false,   'numeric';...
    'InjVol',     75,    true,    'char'};

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
    'backgroundcolor',       obj.settings.table.backgroundColor,....
    'foregroundcolor',       obj.settings.table.foregroundColor,...
    'fontname',              obj.settings.table.fontname,...
    'fontsize',              obj.settings.table.fontsize,...
    'rearrangeablecolumns',  'off',....
    'selectionhighlight',    'off',...
    'celleditcallback',      {@tableEditCallback, obj},...
    'cellselectioncallback', {@tableSelectCallback, obj},...
    'keypressfcn',           {@tableKeyDownCallback, obj});

% ---------------------------------------
% Java Table
% ---------------------------------------
try
    obj.java.scrollpane = findjobj(obj.table.main);
    obj.java.viewport = obj.java.scrollpane.getViewport;
    obj.java.table = obj.java.viewport.getView;
    set(obj.java.table, 'mouseclickedcallback', @obj.tableButtonDownCallback);
catch
    obj.java.scrollpane = [];
    obj.java.viewport = [];
    obj.java.table = [];
end

if ~isempty(obj.java.table) && ismethod(obj.java.table, 'setValueAt')
    obj.settings.other.useJavaTable = 1;
end

% Disable setting
obj.settings.other.useJavaTable = 0;

% ---------------------------------------
% Update Table
% ---------------------------------------
obj.updateTableHeader();
obj.updateTableProperties();
obj.updateTablePeakData();

end

% ---------------------------------------
% Table Edit Callback
% ---------------------------------------
function tableEditCallback(src, evt, obj)

if isempty(src.Data) || size(evt.Indices,2) < 2
    return
end

switch evt.Indices(2)
    
    case 9
        
        obj.data(evt.Indices(1)).sample_info = evt.NewData;
        src.Data{evt.Indices(1), evt.Indices(2)} = evt.NewData;
        
        if evt.Indices(1) == obj.view.row
            obj.addCellHighlightText(obj.view.row, 9)
        end
        
        javaChangeSelection(obj, evt.Indices(1)-1, evt.Indices(2)-1);
        
    case 13
        
        str = src.Data{evt.Indices(1), evt.Indices(2)};
        
        if ~isempty(str) && isnumeric(str)
            str = sprintf('%.2f', str);
        end
        
        if ~isempty(str) && ischar(str)
            val = str2double(str);
        else
            val = [];
        end
        
        if isempty(val) || ~isnumeric(val) || isnan(val)
            
            if isempty(evt.PreviousData)
                obj.data(evt.Indices(1)).injvol = [];
                src.Data{evt.Indices(1), evt.Indices(2)} = ' ';
            else
                src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
            end
            
        elseif ~isinf(val) && isreal(val) && ~isnan(val)
            obj.data(evt.Indices(1)).injvol = val;
            src.Data{evt.Indices(1), evt.Indices(2)} = sprintf('%.2f', val);
            
        else
            obj.data(evt.Indices(1)).injvol = evt.PreviousData;
            src.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
        end
        
        if evt.Indices(1) == obj.view.row
            obj.addCellHighlightText(obj.view.row, 13)
        end
        
        javaChangeSelection(obj, evt.Indices(1)-1, evt.Indices(2)-1);
        
end

end

% ---------------------------------------
% Table Selection Callback
% ---------------------------------------
function tableSelectCallback(src, evt, obj)

obj.table.selection = evt.Indices;

if size(evt.Indices,1) == 1 && evt.Indices(1,1) == obj.view.row
    
    row = evt.Indices(1,1);
    col = evt.Indices(1,2);
    
    if evt.Indices(1,2) == 9
        src.Data{row,col} = obj.data(row).sample_info;
    elseif evt.Indices(1,2) == 13
        src.Data{row,col} = obj.data(row).injvol;
    end
    
    javaChangeSelection(obj, row-1, col-1);
    
end

end

% ---------------------------------------
% Table Key Press Callback
% ---------------------------------------
function tableKeyDownCallback(~, evt, obj)

if isempty(obj.data)
    return
elseif isempty(obj.table.selection) || size(obj.table.selection,2) < 2
    return
elseif ~strcmp(evt.EventName, 'KeyPress')
    return
end

switch evt.Key
    
    case 'return'
        
        if ~any(obj.table.selection(1,2) == [9,13])
            
            idx = obj.view.row;
            row = obj.table.selection(1,1);
            col = obj.table.selection(1,2);
            
            if idx == row
                return
            elseif row >= 1 && row <= length(obj.data)
                obj.selectSample(row-idx);
            end
            
            javaChangeSelection(obj, row-1, col-1);
            
        end
        
    case 'delete'
        
        row = obj.table.selection(1,1);
        col = obj.table.selection(1,2);
        
        str = tableDeleteMessage(obj);
        msg = questdlg(str, 'Delete', 'Yes', 'No', 'Yes');
        
        switch msg
            case 'Yes'
                obj.tableDeleteRow();
            case 'No'
                obj.table.selection = [row,col];
        end
        
        javaChangeSelection(obj, row-1, col-1);
        
    case 'backspace'
        
        if any(any(obj.table.selection(:,2) == [9,13]))
            
            for i = 1:length(obj.table.selection(:,2))
                
                if i > length(obj.table.selection)
                    break
                end
                
                row = obj.table.selection(i,1);
                col = obj.table.selection(i,2);
                
                if strcmpi(obj.table.main.Data{row,col}, ' ')
                    continue
                elseif col == 9
                    obj.data(row).sample_info = [];
                    obj.table.main.Data{row,col} = ' ';
                elseif col == 13
                    obj.data(row).injvol = [];
                    obj.table.main.Data{row,13} = ' ';
                end
                
                javaChangeSelection(obj, row-1, col-1);
                
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

% ---------------------------------------
% Java Table Selection
% ---------------------------------------
function javaChangeSelection(obj, row, col)

if isempty(obj.java.table) || isempty(obj.data)
    return
elseif ~ismethod(obj.java.table, 'changeSelection')
    return
elseif row < 0 || row > size(obj.data,1) - 1
    return
elseif col < 0 || col > size(obj.table.main.Data,2) - 1
    return
end

drawnow(); pause(0.001);

obj.java.table.changeSelection(row, col, 0, 0);

end
