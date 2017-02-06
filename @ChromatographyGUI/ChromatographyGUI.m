classdef ChromatographyGUI < handle
    
    properties (Constant = true)
        name        = 'Chromatography Toolbox';
        url         = 'https://github.com/chemplexity/chromatography-gui';
        version     = '0.0.1';
        date        = '20170206';
        platform    = ChromatographyGUI.getPlatform();
        environment = ChromatographyGUI.getEnvironment();
    end
    
    properties
        
        checkpoint
        
        data
        peaks
        
        figure
        menu
        panel
        table
        axes
        controls
        view
        
    end
    
    methods
        
        function obj = ChromatographyGUI(varargin)
            
            % ---------------------------------------
            % Path
            % ---------------------------------------
            sourceFile = fileparts(mfilename('fullpath'));
            [sourcePath, sourceFile] = fileparts(sourceFile);
            
            if ~strcmpi(sourceFile, '@ChromatographyGUI')
                sourcePath = [sourcePath, filesep, sourceFile];
            end
            
            addpath(sourcePath);
            addpath(genpath([sourcePath, filesep, 'src']));
            
            % ---------------------------------------
            % Defaults
            % ---------------------------------------
            obj.axes.xmode = 'auto';
            obj.axes.ymode = 'auto';
            obj.axes.xlim  = [0, 1];
            obj.axes.ylim  = [0, 1];
            
            obj.view.index = 0;
            obj.view.id    = 'N/A';
            obj.view.name  = 'N/A';
            
            obj.view.plot       = [];
            obj.view.baseline   = [];
            obj.view.peak       = [];
            obj.view.label      = [];
            obj.view.showLabel  = 1;
            obj.view.selection  = 0;
            
            obj.table.selection = [];
            
            obj.peaks.name = {...
                'C35'; 'C36';...
                'C37:3 Me'; 'C37:2 Me';...
                'C38:3 Et'; 'C38:2 Et';...
                'C38:3 Me'; 'C38:2 Me';...
                'C39:3 Et'; 'C39:2 Et'};
            
            obj.peaks.time   = {};
            obj.peaks.width  = {};
            obj.peaks.height = {};
            obj.peaks.area   = {};
            obj.peaks.error  = {};
            obj.peaks.fit    = {};
            
            % ---------------------------------------
            % GUI
            % ---------------------------------------
            obj.initializeGUI();
            
        end
        
        function updateFigure(obj, varargin)
            
            % ---------------------------------------
            % Select
            % ---------------------------------------
            if obj.view.index == 0 && ~isempty(obj.data)
                obj.view.index = 1;
                obj.view.id    = '1';
                obj.view.name  = obj.data(1).sample_name;
                
            elseif isempty(obj.data)
                obj.view.index = 0;
                obj.view.id    = 'N/A';
                obj.view.name  = 'N/A';
            end
            
            set(obj.controls.editID,   'string', obj.view.id);
            set(obj.controls.editName, 'string', obj.view.name);
            
            % ---------------------------------------
            % Table
            % ---------------------------------------
            if any(cellfun(@isempty, obj.table.main.Data(:,2))) || length(obj.table.main.Data(:,1)) ~= length(obj.data)
                
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
                
            end
            
            % ---------------------------------------
            % Plot
            % ---------------------------------------
            obj.updatePlot();
            
        end
        
        function updatePlot(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            end
            
            zoom reset
            
            n = obj.view.index;
            x = [];
            y = [];
            
            if n ~= 0 && n <= length(obj.data)
                x = obj.data(n).time;
                y = obj.data(n).intensity(:,1);
            end
            
            if ~isempty(x)
                if isempty(obj.axes.xlim) || strcmpi(obj.axes.xmode, 'auto')
                    obj.xlimUpdate();
                end
            end
            
            if ~isempty(y)
                if isempty(obj.axes.ylim) || strcmpi(obj.axes.ymode, 'auto')
                    obj.ylimUpdate();
                end
            end
            
            cla(obj.axes.main);
            
            obj.view.plot = plot(x, y,...
                'parent',    obj.axes.main,...
                'color',     [0.1, 0.1, 0.1],...
                'linewidth', 1.25,...
                'visible',   'on',...
                'tag',       'main');
            
            set(obj.axes.main, 'xlim', obj.axes.xlim);
            set(obj.axes.main, 'ylim', obj.axes.ylim);
            
            if get(obj.controls.showBaseline, 'value') == 1
                if isempty(obj.data(n).baseline)
                    obj.getBaseline()
                end
                obj.plotBaseline();
            end
            
            if get(obj.controls.showPeak, 'value') == 1
                obj.plotPeaks();
            end
            
            axesChildren = get(obj.axes.main,'children');
            
            for i = 1:length(axesChildren)
                if strcmpi(get(axesChildren(i), 'type'), 'line')
                    set(axesChildren(i), 'hittest', 'off');
                end
            end
            
        end
        
        function xlimUpdate(obj, varargin)
            
            if obj.view.index ~= 0
                x = obj.data(obj.view.index).time;
            else
                x = [];
            end
            
            if isempty(x)
                x = [0, 1];
            end
            
            switch obj.axes.xmode
                
                case 'auto'
                    xmargin = (max(x) - min(x)) * 0.02;
                    obj.axes.xlim = [min(x) - xmargin, max(x) + xmargin];
                    
                case 'manual'
                    xmin = get(obj.controls.xMin, 'string');
                    xmax = get(obj.controls.xMax, 'string');
                    obj.axes.xlim = [str2double(xmin), str2double(xmax)];
            end
            
            obj.updateAxesLimitEditText();
            
        end
        
        function ylimUpdate(obj, varargin)
            
            if obj.view.index ~= 0
                x = obj.data(obj.view.index).time;
                y = obj.data(obj.view.index).intensity(:,1);
            else
                x = [];
                y = [];
            end
            
            if isempty(y)
                x = [0, 1];
                y = [0, 1];
            end
            
            switch obj.axes.ymode
                
                case 'auto'
                    y = y(x >= obj.axes.xlim(1) & x <= obj.axes.xlim(2));
                    
                    if any(y)
                        ymargin = (max(y) - min(y)) * 0.02;
                        obj.axes.ylim = [min(y) - ymargin, max(y) + ymargin];
                    end
                    
                case 'manual'
                    ymin = get(obj.controls.yMin, 'string');
                    ymax = get(obj.controls.yMax, 'string');
                    obj.axes.ylim = [str2double(ymin), str2double(ymax)];
            end
            
            obj.updateAxesLimitEditText();
            
        end
        
        function plotBaseline(obj)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            end
            
            row = obj.view.index;
            
            if isempty(obj.data(row).baseline)
                obj.getBaseline();
            end
            
            if ~isempty(obj.data(row).baseline)
                axesChildren = get(obj.axes.main,'children');
                
                if ~isempty(axesChildren)
                    axesTag = get(axesChildren, 'tag');
                    
                    if ~isempty(axesTag)
                        axesDel = strcmpi(axesTag, 'baseline');
                        
                        if any(axesDel)
                            axesDel = axesChildren(axesDel);
                            delete(axesDel);
                        end
                    end
                end
            end
            
            x = obj.data(row).baseline(:,1);
            y = obj.data(row).baseline(:,2);
            
            obj.view.baseline = plot(x, y,...
                'parent',    obj.axes.main,...
                'color',     [0.95, 0.22, 0.17],...
                'linewidth', 1.5,...
                'visible',   'off',...
                'tag',       'baseline');
            
            if get(obj.controls.showBaseline, 'value')
                set(obj.view.baseline, 'visible', 'on');
            end
            
        end
        
        function plotPeaks(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            end
            
            row = obj.view.index;
            
            axesChildren = get(obj.axes.main,'children');
            
            if ~isempty(axesChildren)
                axesTag = get(axesChildren, 'tag');
                
                if ~isempty(axesTag)
                    axesDel = strcmpi(axesTag, 'peak');
                    textDel = strcmpi(axesTag, 'label');
                    
                    if any(axesDel)
                        axesDel = axesChildren(axesDel);
                        delete(axesDel);
                    end
                    
                    if any(textDel)
                        textDel = axesChildren(textDel);
                        delete(textDel);
                    end
                end
            end
            
            if get(obj.controls.showPeak, 'value')
                
                if any(~cellfun(@isempty, obj.peaks.fit(row,:)))
                    
                    axesLine = get(obj.axes.main, 'children');
                    axesMain = [];
                    
                    if ~isempty(axesLine)
                        axesTag = get(axesLine, 'tag');
                        
                        if ~isempty(axesTag)
                            axesMain = strcmpi(axesTag, 'main');
                            
                            if any(axesMain)
                                axesIndex = find(axesMain == 1, 1);
                                axesMain = axesLine(axesIndex);
                            end
                        end
                    end
                    
                    for i = 1:length(obj.peaks.fit(row,:))
                        
                        if isempty(obj.peaks.fit{row,i})
                            continue
                        end
                        
                        if length(obj.peaks.fit{row,i}(1,:)) == 2
                            
                            x = obj.peaks.fit{row,i}(:,1);
                            y = obj.peaks.fit{row,i}(:,2);
                            
                            obj.view.peak{i} = plot(x, y,...
                                'parent',    obj.axes.main,...
                                'color',     [0.00, 0.30, 0.53],...
                                'linewidth', 1.5,...
                                'visible',   'on',...
                                'hittest',   'off',...
                                'tag',       'peak');
                            
                            if obj.view.showLabel
                                
                                [~, idx] = max(y);
                                
                                textStr = ['\rm ', obj.peaks.name{i}];
                                textX = x(idx);
                                textY = y(idx);
                                
                                obj.view.label{i} = text(textX, textY, textStr,...
                                    'parent',   obj.axes.main,...
                                    'clipping', 'on',...
                                    'hittest',  'off',...
                                    'tag',      'label',...
                                    'fontsize', 11,...
                                    'fontname', 'arial',...
                                    'margin',   3,...
                                    'units',    'data',...
                                    'pickableparts',       'none',...
                                    'horizontalalignment', 'center',...
                                    'verticalalignment',   'bottom',...
                                    'selectionhighlight',  'off');
                                
                                textPos = get(obj.view.label{i}, 'extent');
                                
                                if ~isempty(axesMain)
                                    axesX = get(axesMain, 'xdata');
                                    axesY = get(axesMain, 'ydata');
                                    
                                    axesFilter = axesX >= textPos(1) & axesX <= textPos(1) + textPos(3);
                                    
                                    axesX = axesX(axesFilter);
                                    axesY = axesY(axesFilter);
                                    
                                    if ~isempty(axesX)
                                        plotOverlap = axesY >= textPos(2) & axesY <= textPos(2) + textPos(4);
                                    else
                                        plotOverlap = [];
                                    end
                                    
                                    if ~isempty(plotOverlap) && any(plotOverlap) && sum(plotOverlap) > 2
                                        
                                        axesX = axesX(plotOverlap);
                                        axesX(abs(axesX - textX) < 0.05) = [];
                                        
                                        if ~isempty(axesX)
                                            xMax = max(axesX);
                                            xMin = min(axesX);
                                            
                                            if xMax > textPos(1) && xMax < textX
                                                set(obj.view.label{i}, 'units', 'characters');
                                                textChar = get(obj.view.label{i}, 'extent');
                                                set(obj.view.label{i}, 'units', 'data');
                                                xMargin = ((textChar(3)-1) * textPos(3)) / textChar(3);
                                                xMargin = textPos(3) - xMargin;
                                                xPos = get(obj.view.label{i}, 'position');
                                                xDiff = xMax - textPos(1);
                                                xPos(1) = xPos(1) + xDiff + xMargin/4;
                                                set(obj.view.label{i}, 'position', xPos);
                                            elseif xMin < textPos(1) + textPos(3) && xMin > textX
                                                set(obj.view.label{i}, 'units', 'characters');
                                                textChar = get(obj.view.label{i}, 'extent');
                                                set(obj.view.label{i}, 'units', 'data');
                                                xMargin = ((textChar(3)+1) * textPos(3)) / textChar(3);
                                                xMargin = xMargin - textPos(3);
                                                xPos = get(obj.view.label{i}, 'position');
                                                xDiff = textPos(1) + textPos(3) - xMin;
                                                xPos(1) = xPos(1) - xDiff - xMargin/4;
                                                set(obj.view.label{i}, 'position', xPos);
                                            end
                                        end
                                    end
                                end
                                
                                textPos = get(obj.view.label{i}, 'extent');
                                
                                if textX <= obj.axes.xlim(2)
                                    if textPos(1) + textPos(3) >= obj.axes.xlim(2)
                                        set(obj.view.label{i}, 'units', 'characters');
                                        textChar = get(obj.view.label{i}, 'extent');
                                        set(obj.view.label{i}, 'units', 'data');
                                        
                                        xMargin = ((textChar(3)+1) * textPos(3)) / textChar(3);
                                        xMax = textPos(1) + textPos(3) + xMargin;
                                        
                                        obj.axes.xlim(2) = xMax;
                                        set(obj.controls.xMax, 'string', sprintf('%.3f', obj.axes.xlim(2)));
                                        set(obj.axes.main, 'xlim', obj.axes.xlim);
                                    end
                                end
                                
                                if textX >= obj.axes.xlim(1)
                                    if textPos(1) <= obj.axes.xlim(1)
                                        set(obj.view.label{i}, 'units', 'characters');
                                        textChar = get(obj.view.label{i}, 'extent');
                                        set(obj.view.label{i}, 'units', 'data');
                                        
                                        xMargin = ((textChar(3)+1) * textPos(3)) / textChar(3);
                                        xMin = textPos(1) - xMargin;
                                        
                                        obj.axes.xlim(1) = xMin;
                                        set(obj.controls.xMin, 'string', sprintf('%.3f', obj.axes.xlim(1)));
                                        set(obj.axes.main, 'xlim', obj.axes.xlim);
                                    end
                                end
                                
                                if textPos(2) + textPos(4) >= obj.axes.ylim(2)
                                    if textX > obj.axes.xlim(1) && textX < obj.axes.xlim(2)
                                        set(obj.view.label{i}, 'units', 'characters');
                                        textChar = get(obj.view.label{i}, 'extent');
                                        set(obj.view.label{i}, 'units', 'data');
                                        
                                        yMargin = ((textChar(4)+0.5) * textPos(4)) / textChar(4);
                                        yMax = textPos(2) + textPos(4) + yMargin;
                                        
                                        obj.axes.ylim(2) = yMax;
                                        set(obj.controls.yMax, 'string', sprintf('%.3f', obj.axes.ylim(2)));
                                        set(obj.axes.main, 'ylim', obj.axes.ylim);
                                    end
                                end
                                
                            end
                        end
                    end
                end
            end
        end
        
        function getBaseline(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            end
            
            xmin = obj.axes.xlim(1);
            xmax = obj.axes.xlim(2);
            
            x = obj.data(obj.view.index).time;
            y = obj.data(obj.view.index).intensity;
            
            if isempty(y)
                return
            end
            
            if ~isempty(x)
                y(x < xmin | x > xmax) = [];
                x(x < xmin | x > xmax) = [];
            end
            
            a = get(obj.controls.asymSlider, 'value');
            s = get(obj.controls.smoothSlider, 'value');
            
            a = 10 ^ a;
            s = 10 ^ s;
            
            b = baseline(y, 'asymmetry', a, 'smoothness', s);
            
            if ~isempty(b) && length(x(:,1)) == length(b(:,1))
                obj.data(obj.view.index).baseline = [x, b];
            end
            
        end
        
        function tableDeleteRow(obj, varargin)
            
            if ~isempty(obj.table.selection)
                
                row = obj.table.selection(:, 1);
                
                obj.data(row) = [];
                obj.peakDeleteRow(row);
                
                obj.table.main.Data(row, :) = [];
                
                for i = 1:length(obj.table.main.Data(:,1))
                    obj.table.main.Data{i,1} = i;
                end
                
                if isempty(obj.data)
                    obj.view.index = 0;
                    obj.view.id    = 'N/A';
                    obj.view.name  = 'N/A';
                elseif obj.view.index > length(obj.data)
                    obj.view.index = length(obj.data);
                    obj.view.id    = num2str(length(obj.data));
                    obj.view.name  = obj.data(end).sample_name;
                else
                    obj.view.id   = num2str(obj.view.index);
                    obj.view.name = obj.data(obj.view.index).sample_name;
                end
                
                set(obj.controls.editID, 'string', obj.view.id);
                set(obj.controls.editName, 'string', obj.view.name);
                
                obj.updatePlot();
                
            end
            
        end
        
        function peakDeleteRow(obj, row)
            
            if length(obj.peaks.time(:,1)) >= row
                obj.peaks.time(row, :)   = [];
                obj.peaks.width(row, :)  = [];
                obj.peaks.height(row, :) = [];
                obj.peaks.area(row, :)   = [];
                obj.peaks.error(row, :)  = [];
                obj.peaks.fit(row, :)    = [];
            end
            
        end
        
        function peakDeleteColumn(obj, m)
            
            if m == 0
                return
            end
            
            offset = length(obj.peaks.name);
            
            tableData = obj.table.main.Data;
            tableHeader = obj.table.main.ColumnName;
            
            obj.peaks.name(m) = [];
            
            if ~isempty(obj.peaks.time) && length(obj.peaks.time(1,:)) >= m
                obj.peaks.time(:,m)   = [];
                obj.peaks.width(:,m)  = [];
                obj.peaks.height(:,m) = [];
                obj.peaks.area(:,m)   = [];
                obj.peaks.error(:,m)  = [];
                obj.peaks.fit(:,m)    = [];
            end
            
            if isempty(tableData) || length(tableData(1,:)) < length(tableHeader)
                if ~isempty(obj.data)
                    tableData{end, length(tableHeader)} = [];
                end
            end
            
            if length(tableHeader) >= m
                tableHeader(m+14 + offset*0 - 0) = [];
                tableHeader(m+14 + offset*1 - 1) = [];
                tableHeader(m+14 + offset*2 - 2) = [];
                tableHeader(m+14 + offset*3 - 3) = [];
            end
            
            if ~isempty(tableData) && length(tableData(1,:)) >= m
                tableData(:, m+14 + offset*0 - 0) = [];
                tableData(:, m+14 + offset*1 - 1) = [];
                tableData(:, m+14 + offset*2 - 2) = [];
                tableData(:, m+14 + offset*3 - 3) = [];
            end
            
            obj.table.main.Data = tableData;
            obj.table.main.ColumnName = tableHeader;
            
            if isempty(obj.controls.peakList.String) && ~isempty(obj.peaks.name)
                if isempty(obj.controls.peakList.Value) || obj.controls.peakList.Value == 0
                    obj.controls.peakList.Value = 1;
                end
            end
            
            set(obj.controls.peakList, 'string', obj.peaks.name);
            
            if obj.controls.peakList.Value > length(obj.peaks.name)
                obj.controls.peakList.Value = length(obj.peaks.name);
            end
            
            if ~isempty(obj.data)
                obj.plotPeaks();
            end
            
        end
        
        function peakEditColumn(obj, m, str)
            
            if m == 0
                return
            end
            
            offset = length(obj.peaks.name);
            
            tableHeader = obj.table.main.ColumnName;
            
            if length(obj.peaks.name) >= m
                obj.peaks.name(m,1) = str;
            end
            
            if length(tableHeader) >= m
                tableHeader{m+14 + offset*0} = ['Time (', obj.peaks.name{m}, ')'];
                tableHeader{m+14 + offset*1} = ['Area (', obj.peaks.name{m}, ')'];
                tableHeader{m+14 + offset*2} = ['Height (', obj.peaks.name{m}, ')'];
                tableHeader{m+14 + offset*3} = ['Width (', obj.peaks.name{m}, ')'];
            end
            
            set(obj.controls.peakList, 'string', obj.peaks.name);
            obj.table.main.ColumnName = tableHeader;
            
            obj.plotPeaks();
            
        end
        
        function peakAddColumn(obj, str)
            
            offset = length(obj.peaks.name);
            
            tableHeader = obj.table.main.ColumnName;
            tableData = obj.table.main.Data;
            
            if isempty(tableData) || length(tableData(1,:)) < length(tableHeader)
                if ~isempty(obj.data)
                    tableData{end, length(tableHeader)} = [];
                end
            end
            
            if isempty(obj.peaks.name)
                obj.peaks.name(1,1) = str;
            else
                obj.peaks.name(end+1,1) = str;    
            end
            
            if ~isempty(obj.peaks.time) && ~isempty(obj.data)
                obj.peaks.time{end,end+1}   = [];
                obj.peaks.width{end,end+1}  = [];
                obj.peaks.height{end,end+1} = [];
                obj.peaks.area{end,end+1}   = [];
                obj.peaks.error{end,end+1}  = [];
                obj.peaks.fit{end,end+1}    = [];
            end
            
            headerInfo = tableHeader(1:14);
            
            if offset > 0
                headerTime   = tableHeader(15+offset*0:15+offset*1-1);
                headerArea   = tableHeader(15+offset*1:15+offset*2-1);
                headerHeight = tableHeader(15+offset*2:15+offset*3-1);
                headerWidth  = tableHeader(15+offset*3:15+offset*4-1);
            else
                headerTime   = {};
                headerArea   = {};
                headerHeight = {};
                headerWidth  = {};
            end
            
            headerTime{end+1,1}   = ['Time (',   obj.peaks.name{end}, ')'];
            headerArea{end+1,1}   = ['Area (',   obj.peaks.name{end}, ')'];
            headerHeight{end+1,1} = ['Height (', obj.peaks.name{end}, ')'];
            headerWidth{end+1,1}  = ['Width (',  obj.peaks.name{end}, ')'];
            
            tableHeader = [headerInfo; headerTime; headerArea; headerHeight; headerWidth];
            
            if ~isempty(tableData)
                
                if length(tableData(1,:)) < 15+offset*4-1
                    tableData{end,15+offset*4-1} = [];
                end
                
                tableInfo   = tableData(:,1:14);
                tableTime   = tableData(:,15+offset*0:15+offset*1-1);
                tableArea   = tableData(:,15+offset*1:15+offset*2-1);
                tableHeight = tableData(:,15+offset*2:15+offset*3-1);
                tableWidth  = tableData(:,15+offset*3:15+offset*4-1);
                
                tableTime{end, end+1}   = [];
                tableArea{end, end+1}   = [];
                tableHeight{end, end+1} = [];
                tableWidth{end, end+1}  = [];
                
                tableData = [tableInfo, tableTime, tableArea, tableHeight, tableWidth];
                
            end
            
            if isempty(obj.controls.peakList.Value) || obj.controls.peakList.Value == 0
                if ~isempty(obj.peaks.name)
                    obj.controls.peakList.Value = 1;
                end
            end
            
            set(obj.controls.peakList, 'string', obj.peaks.name);
            
            obj.table.main.ColumnName = tableHeader;
            obj.table.main.Data = tableData;
            
        end
        
        function updateAxesLimitMode(obj, varargin)
            
            if get(obj.controls.xManual, 'value')
                obj.axes.xmode = 'manual';
            else
                obj.axes.xmode = 'auto';
            end
            
            if get(obj.controls.yManual, 'value')
                obj.axes.ymode = 'manual';
            else
                obj.axes.ymode = 'auto';
            end
            
        end
        
        function updateAxesLimitToggle(obj, varargin)
            
            switch obj.axes.xmode
                case 'manual'
                    set(obj.controls.xManual, 'value', 1);
                    set(obj.controls.xAuto, 'value', 0);
                case 'auto'
                    set(obj.controls.xManual, 'value', 0);
                    set(obj.controls.xAuto, 'value', 1);
            end
            
            switch obj.axes.ymode
                case 'manual'
                    set(obj.controls.yManual, 'value', 1);
                    set(obj.controls.yAuto, 'value', 0);
                case 'auto'
                    set(obj.controls.yManual, 'value', 0);
                    set(obj.controls.yAuto, 'value', 1);
            end
            
        end
        
        function updateAxesLimitEditText(obj, varargin)
            
            getStr = @(x) sprintf('%.3f', x);
            
            set(obj.controls.xMin, 'string', getStr(obj.axes.xlim(1)));
            set(obj.controls.xMax, 'string', getStr(obj.axes.xlim(2)));
            set(obj.controls.yMin, 'string', getStr(obj.axes.ylim(1)));
            set(obj.controls.yMax, 'string', getStr(obj.axes.ylim(2)));
            
        end
        
        function updatePeakEditText(obj, varargin)
            
            getStr = @(x) sprintf('%.3f', x);
            
            col = get(obj.controls.peakList, 'value');
            row = obj.view.index;
            
            if ~isempty(obj.data) && size(obj.peaks.time, 1) < length(obj.data)
                if ~isempty(obj.peaks.name)
                    obj.peaks.time{length(obj.data), length(obj.peaks.name)} = [];
                end
            end
            
            if ~isempty(obj.peaks.name) && size(obj.peaks.time, 2) < length(obj.peaks.name)
                if ~isempty(obj.data)
                    obj.peaks.time{length(obj.data), length(obj.peaks.name)} = [];
                end
            end
            
            if isempty(col) || col == 0
                id     = '';
                time   = '';
                width  = '';
                height = '';
                area   = '';
            elseif col ~= 0 && (row == 0 || isempty(obj.data))
                id     = obj.peaks.name{col};
                time   = '';
                width  = '';
                height = '';
                area   = '';
            else
                id     = obj.peaks.name{col};
                time   = getStr(obj.peaks.time{row,col});
                width  = getStr(obj.peaks.width{row,col});
                height = getStr(obj.peaks.height{row,col});
                area   = getStr(obj.peaks.area{row,col}); 
            end
            
            set(obj.controls.peakIDEdit,     'string', id);
            set(obj.controls.peakTimeEdit,   'string', time);
            set(obj.controls.peakWidthEdit,  'string', width);
            set(obj.controls.peakHeightEdit, 'string', height);
            set(obj.controls.peakAreaEdit,   'string', area);
            
        end
        
        function figureMotionCallback(obj, src, ~)
            
            xObj = get(src, 'currentobject');
            
            if isempty(xObj)
                return
            end
            
            xTag = get(xObj, 'tag');
            
            if isempty(xTag)
                return
            end
            
            switch xTag
                
                case {'peaktimeedit', 'peaklist', 'selectpeak'}
                    
                    if strcmpi(get(obj.axes.zoom, 'enable'), 'on')
                        set(obj.axes.zoom, 'enable', 'off');
                        set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
                    end
                    
                    if isempty(get(obj.axes.main, 'buttondownfcn'))
                        set(obj.axes.main, 'buttondownfcn', @(src, evt) peakTimeSelectCallback(obj, src, evt));
                    end
                    
                otherwise
                    
                    if strcmpi(get(obj.axes.zoom, 'enable'), 'off') && obj.view.selection == 0
                        if strcmpi(get(obj.menu.view.zoom, 'checked'), 'on')
                            set(obj.axes.zoom, 'enable', 'on');
                            set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
                        end
                    end
                    
                    if ~isempty(get(obj.axes.main, 'buttondownfcn')) && obj.view.selection == 0
                        set(obj.axes.main, 'buttondownfcn', '');
                    end
                    
            end
            
        end
        
        function peakTimeSelectCallback(obj, ~, evt)
            
            getStr = @(x) sprintf('%.3f', x);
            
            switch evt.EventName
                
                case 'Hit'
                    
                    if isempty(obj.data) || isempty(obj.controls.peakList.Value) || obj.view.index == 0
                        set(obj.controls.peakTimeEdit, 'string', '');
                    else
                        str = getStr(evt.IntersectionPoint(1));
                        set(obj.controls.peakTimeEdit, 'string', str);
                        obj.getPeakFit();
                    end
                    
                    axesChildren = get(obj.axes.main,'children');
                    
                    for i = 1:length(axesChildren)
                        if strcmpi(get(axesChildren(i), 'type'), 'line')
                            set(axesChildren(i), 'hittest', 'off');
                        end
                        if strcmpi(get(axesChildren(i), 'type'), 'text')
                            set(axesChildren(i), 'hittest', 'off');
                        end
                    end
                    
                    if strcmpi(get(obj.axes.zoom, 'enable'), 'off')
                        if strcmpi(get(obj.menu.view.zoom, 'checked'), 'on')
                            set(obj.axes.zoom, 'enable', 'on');
                            set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
                        end
                    end
                    
            end
            
        end
        
        function getPeakFit(obj, varargin)
            
            row = obj.view.index;
            col = get(obj.controls.peakList, 'value');
            
            if isempty(col) || isempty(obj.data) || row == 0 || col == 0 
                return
            end
            
            time  = str2double(get(obj.controls.peakTimeEdit, 'string'));
            width = diff(obj.axes.xlim) * 0.02;
            
            if isempty(time) || isnan(time) || isinf(time)
                time = [];
            end
            
            x = obj.data(row).time;
            y = obj.data(row).intensity(:,1);
            
            if isempty(x) || isempty(y)
                return
            else
                y(x < obj.axes.xlim(1) | x > obj.axes.xlim(2)) = [];
                x(x < obj.axes.xlim(1) | x > obj.axes.xlim(2)) = [];
            end
            
            if time > max(x) || time < min(x)
                return
            end
            
            if isempty(obj.data(row).baseline) || length(obj.data(row).baseline(:,1)) ~= length(y(:,1))
                obj.getBaseline();
            end
            
            b = obj.data(row).baseline;
            
            if length(b(:,1)) == length(y(:,1))
                y = y - b(:,2);
            end
            
            peak = exponentialgaussian(x, y,...
                'center', time,...
                'width', width);
            
            if ~isempty(peak)
                
                if length(peak.fit) == length(x)
                    
                    x = x(peak.fit ~= 0);
                    y = peak.fit(peak.fit ~= 0);
                    
                    if length(peak.fit) == length(b(:,1))
                        b = b(peak.fit ~= 0, 2);
                        y = y + b;
                    end
                    
                    filter = x > peak.time+peak.width*5 | x < peak.time-peak.width*5;
                    
                    if any(filter)
                        x(filter) = [];
                        y(filter) = [];
                    end
                    
                    if length(x) == length(y)
                        peak.fit = [x,y];
                    end
                    
                end
                
                obj.peaks.time{row,col}   = peak.time;
                obj.peaks.width{row,col}  = peak.width;
                obj.peaks.height{row,col} = peak.height;
                obj.peaks.area{row,col}   = peak.area;
                obj.peaks.error{row,col}  = peak.error;
                obj.peaks.fit{row,col}    = peak.fit;
                
                obj.updatePeakEditText();
                
                offset = length(obj.peaks.name);
                
                obj.table.main.Data{row, col+14 + offset*0} = peak.time;
                obj.table.main.Data{row, col+14 + offset*1} = peak.area;
                obj.table.main.Data{row, col+14 + offset*2} = peak.height;
                obj.table.main.Data{row, col+14 + offset*3} = peak.width;
                
                if get(obj.controls.showPeak, 'value')
                    obj.plotPeaks();
                end
                
            end
            
            obj.view.selection = 0;
            
        end
        
        function zoomCallback(obj, varargin)
            
            if obj.view.index ~= 0
                obj.axes.xmode = 'manual';
                obj.axes.ymode = 'manual';
                obj.axes.xlim = varargin{1,2}.Axes.XLim;
                obj.axes.ylim = varargin{1,2}.Axes.YLim;
                obj.updateAxesLimitToggle();
                obj.updateAxesLimitEditText();
                obj.xlimUpdate();
                obj.ylimUpdate();
            else
                set(obj.axes.main, 'xlim', obj.axes.xlim);
                set(obj.axes.main, 'ylim', obj.axes.ylim);
            end
            
        end
        
    end
    
    
    methods (Access = private)
        
        function initializeGUI(obj, varargin)
            
            obj.toolboxFigure();
            obj.toolboxMenu();
            obj.toolboxPanel();
            obj.toolboxTable();
            obj.toolboxAxes();
            obj.toolboxButton();
            
            obj.axes.zoom = zoom(obj.figure);
            
            set(obj.axes.zoom,...
                'enable', 'on',...
                'actionpostcallback', @(src, evt) zoomCallback(obj, src, evt));
            
            set(obj.figure,...
                'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
            
        end
        
    end
    
    methods (Static = true)
        
        function x = getPlatform()
            if ismac()
                x = 'mac';
            elseif isunix()
                x = 'linux';
            elseif ispc()
                x = 'windows';
            else
                x = 'unknown';
            end
        end
        
        function x = getEnvironment()
            if ~isempty(ver('MATLAB'))
                x = ver('MATLAB');
                x = ['matlab (',  x.Version, ')'];
            elseif ~isempty(ver('OCTAVE'))
                x = 'octave';
            else
                x = 'unknown';
            end
        end
        
    end
end