classdef ChromatographyGUI < handle
    
    properties (Constant = true)
        
        name        = 'Chromatography Toolbox';
        url         = 'https://github.com/chemplexity/chromatography-gui';
        version     = '0.0.8.20171005-dev';
        
        platform    = ChromatographyGUI.getPlatform();
        environment = ChromatographyGUI.getEnvironment();
        screensize  = ChromatographyGUI.getScreenSize();
        
    end
    
    properties
        
        data
        peaks
        
        figure
        menu
        panel
        table
        axes
        controls
        view
        
        settings
        
    end
    
    properties (Hidden = true)
        
        checkpoint
        font = ChromatographyGUI.getFont();
        
        % /path/to/chromatography-gui
        toolbox_path = fileparts(fileparts(mfilename('fullpath')));
        
        % /path/to/chromatography-gui/@ChromatographyGUI
        toolbox_file = fileparts(mfilename('fullpath'));
        
        % Toolbox Paths
        toolbox_config = 'config';
        toolbox_data   = 'data';
        toolbox_src    = 'src';
        
        % Toolbox Defaults
        default_settings = 'default_settings.mat';
        default_peaklist = 'default_peaklist.mat';
        
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
            addpath(genpath([sourcePath, filesep, obj.toolbox_src]));
            addpath(genpath([sourcePath, filesep, obj.toolbox_config]));
            
            % ---------------------------------------
            % Settings
            % ---------------------------------------
            obj.toolboxSettings([], [], 'initialize');
            obj.toolboxPeakList([], [], 'load_default');
            
            obj.view.index = 0;
            obj.view.id    = 'N/A';
            obj.view.name  = 'N/A';
            
            obj.view.plotLine     = [];
            obj.view.plotLabel    = [];
            obj.view.plotBaseline = [];
            obj.view.peakLine     = [];
            obj.view.peakLabel    = [];
            obj.view.peakArea     = [];
            obj.view.peakBaseline = [];
            
            obj.view.selectPeak = 0;
            obj.table.selection = [];
            
            obj.peaks.time   = {};
            obj.peaks.width  = {};
            obj.peaks.height = {};
            obj.peaks.area   = {};
            obj.peaks.areaOf = {};
            obj.peaks.error  = {};
            obj.peaks.fit    = {};
            obj.peaks.model  = {};
            obj.peaks.xlim   = {};
            obj.peaks.ylim   = {};
            
            obj.initializeGUI();
            obj.toolboxSettings([], [], 'load_default');
            
        end
        
        % ---------------------------------------
        % Update figure after loading data
        % ---------------------------------------
        function updateFigure(obj, varargin)
            
            obj.removeTableHighlightText();
            
            if obj.view.index == 0 && ~isempty(obj.data)
                obj.view.index = 1;
                obj.view.id    = '1';
                obj.view.name  = obj.data(1).sample_name;
            elseif isempty(obj.data)
                obj.view.index = 0;
                obj.view.id    = 'N/A';
                obj.view.name  = 'N/A';
            end
            
            obj.updateSampleText();
            obj.updateAllPeakListText();
            obj.updatePeakText();
            obj.updatePlot();
            obj.addTableHighlightText();
            
        end
        
        % ---------------------------------------
        % Plot - update all
        % ---------------------------------------
        function updatePlot(obj, varargin)
            
            cla(obj.axes.main);
            
            if isempty(obj.data) || obj.view.index == 0
                return
            else
                row = obj.view.index;
            end
            
            if isempty(obj.data(row).time) && isempty(obj.data(row).intensity)
                obj.loadAgilentData();
            end
            
            if ~isempty(obj.data(row).intensity)
                
                x = obj.data(row).time;
                y = obj.data(row).intensity(:,1);
                
                if size(x,1) ~= size(y,1)
                    return
                end
                
                if any(ishandle(obj.view.plotLine))
                    set(obj.view.plotLine, 'xdata', x, 'ydata', y);
                else
                    obj.view.plotLine = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.plot.color,...
                        'linewidth', obj.settings.plot.linewidth,...
                        'visible',   'on',...
                        'hittest',   'off',...
                        'tag',       'main');
                end
                
                zoom reset
                
                obj.updateAxesLimits();
                
                if obj.settings.showPlotBaseline
                    obj.plotBaseline();
                end
                
                if obj.settings.showPeaks
                    obj.plotPeaks();
                end
                
            end
            
            obj.updateAxesLabel();
            obj.updatePlotLabel();
            
        end
        
        % ---------------------------------------
        % Load signal data
        % ---------------------------------------
        function loadAgilentData(obj, varargin)
            
            i = obj.view.index;
            f = [obj.data(i).file_path, filesep, obj.data(i).file_name];
            
            if ~exist(f, 'file')
                return
            end
                
            x = importAgilent(...
                'file', f,...
                'content', 'data',...
                'verbose', 'off');
                
            if isempty(x)
                return
            end
            
            obj.data(i).time = x.time;
            obj.data(i).intensity = x.intensity;
            obj.data(i).sampling_rate = x.sampling_rate;
               
        end
        
        % ---------------------------------------
        % Update x-axes limits
        % ---------------------------------------
        function updateAxesXLim(obj, varargin)
            
            switch obj.settings.xmode
                
                case 'auto'
                    
                    row = obj.view.index;
                    
                    if row ~= 0 && ~isempty(obj.data(row).time)
                        
                        xmin = min(obj.data(row).time);
                        xmax = max(obj.data(row).time);
                        xpad = (xmax - xmin) * obj.settings.xpad;
                        
                        if xmin >= 0 && xmin - xpad < 0
                            xmin = 0;
                        else
                            xmin = xmin - xpad;
                        end
                        
                        xmax = xmax + xpad;
                        
                        obj.settings.xlim = [xmin, xmax];
                        
                    end
                    
                    obj.axes.main.XLim = obj.settings.xlim;
                    
                case 'manual'
                    
                    if obj.view.index ~= 0
                        
                        xmin = str2double(obj.controls.xMin.String);
                        xmax = str2double(obj.controls.xMax.String);
                        
                        if xmin ~= round(obj.settings.xlim(2), 3)
                            obj.settings.xlim(1) = xmin;
                            obj.axes.main.XLim = obj.settings.xlim;
                        end
                        
                        if xmax ~= round(obj.settings.xlim(2), 3)
                            obj.settings.xlim(2) = xmax;
                            obj.axes.main.XLim = obj.settings.xlim;
                        end
                        
                    else
                        obj.axes.main.XLim = obj.settings.xlim;
                    end
                    
            end
            
            obj.updateAxesLimitEditText();
            
        end
        
        % ---------------------------------------
        % Update y-axes limits
        % ---------------------------------------
        function updateAxesYLim(obj, varargin)
            
            row = obj.view.index;
            
            if row ~= 0 && ~isempty(obj.data(row).time)
                x = obj.data(row).time;
                y = obj.data(row).intensity(:,1);
            else
                x = [];
                y = [];
            end
            
            switch obj.settings.ymode
                
                case 'auto'
                    
                    if ~isempty(y) && ~isempty(x)
                        
                        y = y(x >= obj.settings.xlim(1) & x <= obj.settings.xlim(2));
                        
                        if any(y)
                            ymin = min(y);
                            ymax = max(y);
                            ypad = (ymax - ymin) * obj.settings.ypad;
                            obj.settings.ylim = [ymin-ypad, ymax+ypad];
                        end
                        
                    else
                        obj.settings.ylim = [0,1];
                    end
                    
                case 'manual'
                    
                    ymin = str2double(obj.controls.yMin.String);
                    ymax = str2double(obj.controls.yMax.String);
                    
                    obj.settings.ylim = [ymin, ymax];
                    
            end
            
            obj.axes.main.YLim = obj.settings.ylim;
            obj.updateAxesLimitEditText();
            obj.updatePlotLabelPosition();
            
        end
        
        
        % ---------------------------------------
        % Update mode for axes limits
        % ---------------------------------------
        function updateAxesLimitMode(obj, varargin)
            
            if obj.controls.xUser.Value
                obj.settings.xmode = 'manual';
            else
                obj.settings.xmode = 'auto';
            end
            
            if obj.controls.yUser.Value
                obj.settings.ymode = 'manual';
            else
                obj.settings.ymode = 'auto';
            end
            
        end
        
        % ---------------------------------------
        % Update toggle buttons for axes limits
        % ---------------------------------------
        function updateAxesLimitToggle(obj, varargin)
            
            switch obj.settings.xmode
                case 'manual'
                    obj.controls.xUser.Value = 1;
                    obj.controls.xAuto.Value = 0;
                case 'auto'
                    obj.controls.xUser.Value = 0;
                    obj.controls.xAuto.Value = 1;
            end
            
            switch obj.settings.ymode
                case 'manual'
                    obj.controls.yUser.Value = 1;
                    obj.controls.yAuto.Value = 0;
                case 'auto'
                    obj.controls.yUser.Value = 0;
                    obj.controls.yAuto.Value = 1;
            end
            
        end
        
        % ---------------------------------------
        % Update text for axes limits
        % ---------------------------------------
        function updateAxesLimitEditText(obj, varargin)
            
            str = @(x) sprintf('%.3f', x);
            
            obj.controls.xMin.String = str(obj.settings.xlim(1) + 0);
            obj.controls.xMax.String = str(obj.settings.xlim(2) + 0);
            obj.controls.yMin.String = str(obj.settings.ylim(1) + 0);
            obj.controls.yMax.String = str(obj.settings.ylim(2) + 0);
            
        end
        
        % ---------------------------------------
        % Plot - basline
        % ---------------------------------------
        function plotBaseline(obj)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPlotBaseline
                return
            else
                row = obj.view.index;
            end
            
            if isempty(obj.data(row).baseline)
                obj.getBaseline();
            end
            
            if ~isempty(obj.data(row).baseline)
                
                x = obj.data(row).baseline(:,1);
                y = obj.data(row).baseline(:,2);
                
                if any(ishandle(obj.view.plotBaseline))
                    set(obj.view.plotBaseline, 'xdata', x, 'ydata', y);
                else
                    obj.view.plotBaseline = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth,...
                        'visible',   'on',...
                        'hittest',   'off',...
                        'tag',       'baseline');
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Plot - peak fit data
        % ---------------------------------------
        function plotPeaks(obj, varargin)
            
            obj.clearAxesChildren('peak');
            obj.clearAxesChildren('peaklabel');
            obj.clearAxesChildren('peakarea');
            obj.clearAxesChildren('peakbaseline');
            
            obj.updateAxesLimits();
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPeaks || isempty(obj.peaks.fit)
                return
            else
                row = obj.view.index;
            end
            
            if any(~cellfun(@isempty, obj.peaks.fit(row,:)))
                
                for i = 1:length(obj.peaks.fit(row,:))
                    
                    if isempty(obj.peaks.fit{row,i})
                        continue
                    elseif length(obj.peaks.fit{row,i}(1,:)) ~= 2
                        continue
                    end
                    
                    x = obj.peaks.fit{row,i}(:,1);
                    y = obj.peaks.fit{row,i}(:,2);
                    
                    if obj.settings.showPeakLine
                        
                        obj.view.peakLine{i} = plot(x, y,...
                            'parent',    obj.axes.main,...
                            'color',     obj.settings.peaks.color,...
                            'linewidth', obj.settings.peaks.linewidth,...
                            'visible',   'on',...
                            'hittest',   'off',...
                            'tag',       'peak');
                        
                    end
                    
                end
                
                obj.plotPeakLabels();
                obj.updatePeakArea();
                obj.updatePeakBaseline();
                
            end
            
        end
        
        % ---------------------------------------
        % Plot - peak labels
        % ---------------------------------------
        function plotPeakLabels(obj, varargin)
            
            if ~obj.settings.showPeaks || ~obj.settings.showPeakLabel
                return
            elseif isempty(obj.data) || obj.view.index == 0
                return
            elseif isempty(obj.peaks.fit)
                return
            else
                row = obj.view.index;
            end
            
            if ~isempty(varargin)
                col = varargin{1};
            else
                col = 1:length(obj.peaks.fit(row,:));
            end
            
            if any(~cellfun(@isempty, obj.peaks.fit(row,:)))
                
                for i = 1:length(col)
                    
                    if isempty(obj.peaks.fit{row,col(i)})
                        continue
                    elseif length(obj.peaks.fit{row,col(i)}(1,:)) ~= 2
                        continue
                    end
                    
                    obj.clearPeakLabel(col(i));
                    
                    if isempty(obj.settings.labels.peak)
                        continue
                    else
                        labelFields = obj.settings.labels.peak;
                    end
                    
                    str = '';
                    strPrecision = obj.settings.labels.precision;
                    
                    for j = 1:length(labelFields)
                        
                        switch labelFields{j}
                            case 'peakName'
                                n = obj.peaks.name{col(i)};
                            case 'peakTime'
                                n = obj.peaks.time{row,col(i)};
                                n = sprintf(strPrecision, n);
                            case 'peakWidth'
                                n = obj.peaks.width{row,col(i)};
                                n = ['Width: ', sprintf(strPrecision, n)];
                            case 'peakHeight'
                                n = obj.peaks.height{row,col(i)};
                                n = ['Height: ', sprintf(strPrecision, n)];
                            case 'peakArea'
                                n = obj.peaks.area{row,col(i)};
                                n = ['Area: ', sprintf(strPrecision, n)];
                        end
                        
                        n(n=='_') = ' ';
                        
                        if j == 1 || isempty(str)
                            str = n;
                        else
                            str = [str, char(10), n];
                        end
                        
                    end
                    
                    if ~isempty(str)
                        str = deblank(strtrim(str(str ~= '\')));
                        str = ['\rm ', str];
                    end
                    
                    % Text Position
                    x = obj.peaks.fit{row,col(i)}(:,1);
                    y = obj.peaks.fit{row,col(i)}(:,2);
                    
                    [~, yi] = max(y);
                    
                    textX = x(yi);
                    textY = y(yi);
                    
                    dataX = obj.data(row).time(:,1);
                    xi = find(obj.data(row).time(:,1) >= textX, 1);
                    xf = dataX >= dataX(xi)-0.05 & dataX <= dataX(xi)+0.05;
                    dataY = max(obj.data(row).intensity(xf,1));
                    
                    textY = max([textY, dataY]);
                    
                    % Plot Text
                    obj.view.peakLabel{col(i)} = text(textX, textY, str,...
                        'parent',   obj.axes.main,...
                        'clipping', 'on',...
                        'hittest',  'off',...
                        'tag',      'peaklabel',...
                        'fontsize', obj.settings.labels.fontsize,...
                        'fontname', obj.settings.labels.fontname,...
                        'margin',   obj.settings.labels.margin,...
                        'units',    'data',...
                        'pickableparts',       'none',...
                        'horizontalalignment', 'center',...
                        'verticalalignment',   'bottom',...
                        'selectionhighlight',  'off');
                    
                    if isprop(obj.view.peakLabel{col(i)}, 'extent')
                        
                        textPos = obj.view.peakLabel{col(i)}.Extent;
                        
                        tL = textPos(1);
                        tR = textPos(1) + textPos(3);
                        tB = textPos(2);
                        tT = textPos(2) + textPos(4);
                        tW = textPos(3);
                        
                        axesMain = obj.getAxes();
                        
                        if ~isempty(axesMain)
                            
                            x = get(axesMain, 'xdata');
                            y = get(axesMain, 'ydata');
                            
                            y = y(x >= tL & x <= tR);
                            x = x(x >= tL & x <= tR);
                            
                            if ~isempty(x)
                                yOverlap = y >= tB & y <= tT;
                            else
                                yOverlap = [];
                            end
                            
                            % Text / Data
                            if ~isempty(yOverlap) && any(yOverlap) && sum(yOverlap)>2
                                
                                x = x(yOverlap);
                                x(abs(x - textX) < 0.05) = [];
                                
                                if ~isempty(x)
                                    
                                    xmax = max(x);
                                    xmin = min(x);
                                    
                                    if xmax > tL && xmax < textX
                                        
                                        obj.view.peakLabel{col(i)}.Units = 'characters';
                                        t = get(obj.view.peakLabel{col(i)}, 'extent');
                                        
                                        xmargin = (tW - ((t(3)-1) * tW) / t(3)) / 4;
                                        
                                        obj.view.peakLabel{col(i)}.Units = 'data';
                                        t = obj.view.peakLabel{col(i)}.Position;
                                        
                                        t(1) = t(1) + xmax - tL + xmargin;
                                        obj.view.peakLabel{col(i)}.Position = t;
                                        
                                    elseif xmin < tR && xmin > textX
                                        
                                        obj.view.peakLabel{col(i)}.Units = 'characters';
                                        t = obj.view.peakLabel{col(i)}.Extent;
                                        
                                        xmargin = (((t(3)+1) * tW) / t(3) - tW) / 4;
                                        
                                        obj.view.peakLabel{col(i)}.Units = 'data';
                                        t = obj.view.peakLabel{col(i)}.Position;
                                        
                                        t(1) = t(1) - xmargin;
                                        obj.view.peakLabel{col(i)}.Position = t;
                                        
                                    end
                                    
                                end
                            end
                        end
                        
                        % Text / Axes Limits
                        textPos = obj.view.peakLabel{col(i)}.Extent;
                        
                        tL = textPos(1);
                        tR = textPos(1) + textPos(3);
                        tT = textPos(2) + textPos(4);
                        
                        if textX <= obj.settings.xlim(2) && tR >= obj.settings.xlim(2)
                            
                            obj.view.peakLabel{col(i)}.Units = 'characters';
                            tc = obj.view.peakLabel{col(i)}.Extent;
                            
                            obj.view.peakLabel{col(i)}.Units = 'data';
                            td = obj.view.peakLabel{col(i)}.Extent;
                            
                            xmargin = td(3) - (td(3) / tc(3)) * (tc(3) - 0.5);
                            obj.settings.xlim(2) = td(1) + td(3) + xmargin;
                            
                            obj.controls.xMax.String = sprintf('%.3f', obj.settings.xlim(2));
                            obj.axes.main.XLim = obj.settings.xlim;
                            
                            obj.updatePlotLabelPosition();
                            
                        end
                        
                        if textX >= obj.settings.xlim(1) && tL <= obj.settings.xlim(1)
                            
                            obj.view.peakLabel{col(i)}.Units = 'characters';
                            tc = obj.view.peakLabel{col(i)}.Extent;
                            
                            obj.view.peakLabel{col(i)}.Units = 'data';
                            td = obj.view.peakLabel{col(i)}.Extent;
                            
                            xmargin = td(3) - (td(3) / tc(3)) * (tc(3) - 0.5);
                            obj.settings.xlim(1) = td(1) - xmargin;
                            
                            obj.controls.xMin.String = sprintf('%.3f', obj.settings.xlim(1));
                            obj.axes.main.XLim = obj.settings.xlim;
                            
                        end
                        
                        if (tT >= obj.settings.ylim(2) && strcmpi(obj.settings.ymode, 'auto')) || ...
                                (tT >= obj.settings.ylim(2) && textPos(2) < obj.settings.ylim(2) && strcmpi(obj.settings.ymode, 'manual'))
                            
                            if textX > obj.settings.xlim(1) && textX < obj.settings.xlim(2)
                                
                                obj.view.peakLabel{col(i)}.Units = 'characters';
                                tc = obj.view.peakLabel{col(i)}.Extent;
                                
                                obj.view.peakLabel{col(i)}.Units = 'data';
                                td = obj.view.peakLabel{col(i)}.Extent;
                                
                                ymargin = td(4) - (td(4) / tc(4)) * (tc(4) - 0.5);
                                obj.settings.ylim(2) = td(2) + td(4) + ymargin;
                                
                                obj.controls.yMax.String = sprintf('%.3f', obj.settings.ylim(2));
                                obj.axes.main.YLim = obj.settings.ylim;
                                
                                obj.updatePlotLabelPosition();
                                
                            end
                        end
                    end
                end
            end
            
        end
        
        % ---------------------------------------
        % Axes handle
        % ---------------------------------------
        function axesMain = getAxes(obj, varargin)
            
            axesLine = obj.axes.main.Children;
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
            
        end
        
        % ---------------------------------------
        % Baseline
        % ---------------------------------------
        function b = getBaseline(obj, varargin)
            
            row = obj.view.index;
            b = [];
            
            if isempty(obj.data) || row == 0
                return
            elseif isempty(obj.data(row).intensity)
                return
            end
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                
                if varargin{1} == 0
                    setBaseline = 0;
                else
                    setBaseline = 1;
                end
                
            else
                setBaseline = 1;
            end
            
            x = obj.data(row).time;
            y = obj.data(row).intensity;
            
            if ~isempty(x)
                y(x < obj.settings.xlim(1) | x > obj.settings.xlim(2)) = [];
                x(x < obj.settings.xlim(1) | x > obj.settings.xlim(2)) = [];
            end
            
            a = 10 ^ obj.controls.asymSlider.Value;
            s = 10 ^ obj.controls.smoothSlider.Value;
            
            y = movingAverage(y);
            b = baseline(y, 'asymmetry', a, 'smoothness', s);
            
            if length(x) == length(b)
                
                b = [x, b];
                
                if setBaseline
                    obj.data(row).baseline = b;
                end
            
            end
            
        end
        
        % ---------------------------------------
        % Table - delete row
        % ---------------------------------------
        function tableDeleteRow(obj, varargin)
            
            if ~isempty(obj.table.selection)
                
                row = obj.table.selection(:,1);
                
                obj.removeTableHighlightText();
                
                obj.data(row) = [];
                obj.peakDeleteRow(row);
                obj.table.main.Data(row, :) = [];
                
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
                
                obj.updateSampleText();
                obj.updateAllPeakListText();
                obj.updatePeakText();
                obj.updatePlot();
                obj.addTableHighlightText();
                
                obj.validatePeakData(length(obj.data), length(obj.peaks.name));
                
            end
            
        end
        
        % ---------------------------------------
        % Table - add peak columns
        % ---------------------------------------
        function peakAddColumn(obj, str)
            
            offset = length(obj.peaks.name);
            
            tableHeader = obj.table.main.ColumnName;
            tableData = obj.table.main.Data;
            
            if isempty(tableData) || length(tableData(1,:)) < length(tableHeader)
                if ~isempty(obj.data)
                    tableData{end, length(tableHeader)} = [];
                end
            end
            
            if ischar(str) && ~iscell(str)
                str = {str};
            end
            
            if isempty(obj.peaks.name)
                obj.peaks.name(1,1) = str;
            else
                obj.peaks.name(end+1,1) = str;
            end
            
            % Expand peak data
            peakFields = fields(obj.peaks);
            
            if ~isempty(obj.data)
                
                for i = 1:length(peakFields)
                    if ~isempty(obj.peaks.(peakFields{i}))
                        obj.peaks.(peakFields{i}){end, end+1} = [];
                    end     
                end
                
            end
 
            headerInfo = tableHeader(1:13);
            
            if offset > 0
                headerArea   = tableHeader(14+offset*0:14+offset*1-1);
                headerHeight = tableHeader(14+offset*1:14+offset*2-1);
                headerTime   = tableHeader(14+offset*2:14+offset*3-1);
                headerWidth  = tableHeader(14+offset*3:14+offset*4-1);
            else
                headerArea   = {};
                headerHeight = {};
                headerTime   = {};
                headerWidth  = {};
            end
            
            headerArea{end+1,1}   = ['Area (',   obj.peaks.name{end}, ')'];
            headerHeight{end+1,1} = ['Height (', obj.peaks.name{end}, ')'];
            headerTime{end+1,1}   = ['Time (',   obj.peaks.name{end}, ')'];
            headerWidth{end+1,1}  = ['Width (',  obj.peaks.name{end}, ')'];
            
            tableHeader = [...
                headerInfo;...
                headerArea;...
                headerHeight;...
                headerTime;...
                headerWidth];
            
            if ~isempty(tableData)
                
                if length(tableData(1,:)) < 14 + offset*4 - 1
                    tableData{end,14 + offset*4 - 1} = [];
                end
                
                tableInfo   = tableData(:,1:13);
                tableArea   = tableData(:,14+offset*0:14+offset*1-1);
                tableHeight = tableData(:,14+offset*1:14+offset*2-1);
                tableTime   = tableData(:,14+offset*2:14+offset*3-1);
                tableWidth  = tableData(:,14+offset*3:14+offset*4-1);
                
                tableArea{end,end+1}   = [];
                tableHeight{end,end+1} = [];
                tableTime{end,end+1}   = [];
                tableWidth{end,end+1}  = [];
                
                tableData = [...
                    tableInfo,...
                    tableArea,...
                    tableHeight,...
                    tableTime,...
                    tableWidth];
                
            end
            
            if isempty(obj.controls.peakList.Value) || obj.controls.peakList.Value == 0
                if ~isempty(obj.peaks.name)
                    obj.controls.peakList.Value = 1;
                end
            end
            
            obj.controls.peakList.String{end+1} = obj.peaks.name{end};
            
            obj.table.main.ColumnName = tableHeader;
            obj.table.main.Data = tableData;
            
            % Set 'ColumnEditable', 'ColumnWidth', 'ColumnFormat'
            n = length(obj.table.main.ColumnName);
            obj.table.main.ColumnEditable(n) = false;
            
            m = length(obj.table.main.ColumnWidth);
            w = 110;
            
            for i = 1:n-m
                obj.table.main.ColumnWidth{end+1} = w;
                obj.table.main.ColumnFormat{end+1} = 'numeric';
            end
            
            obj.validatePeakData(length(obj.data), length(obj.peaks.name));
            
            if length(obj.peaks.name) == 1
                obj.updatePeakText()
            end
            
            obj.removeTableHighlightText();
            obj.addTableHighlightText();
            
        end
        
        % ---------------------------------------
        % Table - update column header
        % ---------------------------------------
        function updateTableHeader(obj, varargin)
            
            str = obj.settings.table.labelNames;
            
            m = obj.settings.table.minColumns;
            n = obj.peaks.name;
            
            x = obj.table.main.ColumnName(1:m);
            
            if length(n) < 1
                return
            end
            
            for i = 1:length(str)
               
                if ~isfield(obj.settings.table, ['show', str{i}])
                    continue
                elseif ~obj.settings.table.(['show', str{i}])
                    continue
                end
                    
                a = [str{i}, ' ('];
                x = [x; cellfun(@(x) [a,x,')'], n, 'uniformoutput', 0)];
                
            end
            
            obj.table.main.ColumnName = x;
            
        end
        
        % ---------------------------------------
        % Table - update column properties
        % ---------------------------------------
        function updateTableProperties(obj, varargin)
            
            str = obj.settings.table.labelNames;
            
            m = obj.settings.table.minColumns;
            n = length(obj.peaks.name);
            
            if n < 1
                return
            end
            
            w = obj.settings.table.columnWidth;
            x = obj.table.main.ColumnFormat(1:m);
            y = obj.table.main.ColumnWidth(1:m);
            z = obj.table.main.ColumnEditable(1:m);
            
            for i = 1:length(str)
               
                if ~isfield(obj.settings.table, ['show', str{i}])
                    continue
                elseif ~obj.settings.table.(['show', str{i}])
                    continue
                end
                
                if strcmpi(str{i}, 'model')
                    a = 'char';
                else
                    a = 'numeric';
                end
                
                x = [x, repmat({a}, 1, n)];
                y = [y, repmat({w}, 1, n)];
                z = [z, false(1,n)];
                
            end
            
            obj.table.main.ColumnFormat = x;
            obj.table.main.ColumnWidth = y;
            obj.table.main.ColumnEditable = z;
            
        end
        
        % ---------------------------------------
        % Table - update data
        % ---------------------------------------
        function updateTableData(obj, varargin)
            
            if isempty(obj.table.main.Data)
                return
            end
            
            str = obj.settings.table.labelNames;
            
            x = obj.table.main.Data(:,1:obj.settings.table.minColumns);
            
            for i = 1:length(str)
                
                if ~isfield(obj.settings.table, ['show', str{i}])
                    continue
                end
                
                if obj.settings.table.(['show', str{i}])
                    x = [x, obj.peaks.(lower(str{i}))];
                end
                
            end
            
            obj.table.main.Data = x;
            
        end
        
        % ---------------------------------------
        % Table - edit peak column names
        % ---------------------------------------
        function peakEditColumn(obj, col, str)
            
            if col == 0
                return
            end
            
            offset = length(obj.peaks.name);
            
            if offset >= col
                obj.peaks.name(col,1) = str;
                obj.controls.peakIDEdit.String = str;
            end
            
            if length(obj.table.main.ColumnName) >= col
                obj.table.main.ColumnName{col+13 + offset*0} = ['Area (', obj.peaks.name{col}, ')'];
                obj.table.main.ColumnName{col+13 + offset*1} = ['Height (', obj.peaks.name{col}, ')'];
                obj.table.main.ColumnName{col+13 + offset*2} = ['Time (', obj.peaks.name{col}, ')'];
                obj.table.main.ColumnName{col+13 + offset*3} = ['Width (', obj.peaks.name{col}, ')'];
            end
            
            obj.updatePeakListText();
            obj.plotPeakLabels(col);
            
        end
        
        % ---------------------------------------
        % Table - delete peak columns
        % ---------------------------------------
        function peakDeleteColumn(obj, col)
            
            if col == 0
                return
            else
                nCol = length(obj.peaks.name);
            end
            
            obj.peaks.name(col) = [];
            
            if ~isempty(obj.peaks.time) && length(obj.peaks.time(1,:)) >= col
                obj.peaks.time(:,col)   = [];
                obj.peaks.width(:,col)  = [];
                obj.peaks.height(:,col) = [];
                obj.peaks.area(:,col)   = [];
                obj.peaks.error(:,col)  = [];
                obj.peaks.fit(:,col)    = [];
                obj.peaks.areaOf(:,col) = [];
                obj.peaks.model(:,col)  = [];
                obj.peaks.xlim(:,col)   = [];
                obj.peaks.ylim(:,col)   = [];
            end
            
            if isempty(obj.table.main.Data) || length(obj.table.main.Data(1,:)) < length(obj.table.main.ColumnName)
                if ~isempty(obj.data)
                    obj.table.main.Data{end, length(obj.table.main.ColumnName)} = [];
                end
            end
            
            if length(obj.table.main.ColumnName) >= col
                obj.table.main.ColumnName(col+13 + nCol*0 - 0) = [];
                obj.table.main.ColumnName(col+13 + nCol*1 - 1) = [];
                obj.table.main.ColumnName(col+13 + nCol*2 - 2) = [];
                obj.table.main.ColumnName(col+13 + nCol*3 - 3) = [];
                
                obj.table.main.ColumnEditable(col+13 + nCol*0 - 0) = [];
                obj.table.main.ColumnEditable(col+13 + nCol*1 - 1) = [];
                obj.table.main.ColumnEditable(col+13 + nCol*2 - 2) = [];
                obj.table.main.ColumnEditable(col+13 + nCol*3 - 3) = [];
                
                obj.table.main.ColumnWidth(col+13 + nCol*0 - 0) = [];
                obj.table.main.ColumnWidth(col+13 + nCol*1 - 1) = [];
                obj.table.main.ColumnWidth(col+13 + nCol*2 - 2) = [];
                obj.table.main.ColumnWidth(col+13 + nCol*3 - 3) = [];
                
                obj.table.main.ColumnFormat(col+13 + nCol*0 - 0) = [];
                obj.table.main.ColumnFormat(col+13 + nCol*1 - 1) = [];
                obj.table.main.ColumnFormat(col+13 + nCol*2 - 2) = [];
                obj.table.main.ColumnFormat(col+13 + nCol*3 - 3) = [];
            end
            
            if ~isempty(obj.table.main.Data) && length(obj.table.main.Data(1,:)) >= col
                obj.table.main.Data(:, col+13 + nCol*0 - 0) = [];
                obj.table.main.Data(:, col+13 + nCol*1 - 1) = [];
                obj.table.main.Data(:, col+13 + nCol*2 - 2) = [];
                obj.table.main.Data(:, col+13 + nCol*3 - 3) = [];
            end
            
            if isempty(obj.table.main.Data) && size(obj.table.main.Data,2) > length(obj.table.main.ColumnName)
                obj.table.main.Data(:, length(obj.table.main.ColumnName)+1:end) = [];
            end
            
            if isempty(obj.controls.peakList.String) && ~isempty(obj.peaks.name)
                if isempty(obj.controls.peakList.Value) || obj.controls.peakList.Value == 0
                    obj.controls.peakList.Value = 1;
                end
            end
            
            if obj.controls.peakList.Value > length(obj.peaks.name)
                obj.controls.peakList.Value = length(obj.peaks.name);
            end
            
            if length(obj.controls.peakList.String) >= col
                obj.controls.peakList.String(col) = [];
            end
            
            obj.clearPeakLine(col);
            obj.clearPeakArea(col);
            obj.clearPeakBaseline(col);
            
            if length(obj.view.peakLine) >= col && any(ishandle(obj.view.peakLine{col}))
                delete(obj.view.peakLine{col});
                obj.view.peakLine(col) = [];
            end
            
            if length(obj.view.peakLabel) >= col && any(ishandle(obj.view.peakLabel{col}))
                delete(obj.view.peakLabel{col});
                obj.view.peakLabel(col) = [];
            end
            
            if length(obj.view.peakArea) >= col && any(ishandle(obj.view.peakArea{col}))
                delete(obj.view.peakArea{col});
                obj.view.peakArea(col) = [];
            end
            
            if length(obj.view.peakBaseline) >= col && any(ishandle(obj.view.peakBaseline{col}))
                delete(obj.view.peakBaseline{col});
                obj.view.peakBaseline(col) = [];
            end
            
        end
        
        % ---------------------------------------
        % Peak data - delete column
        % ---------------------------------------
        function peakDeleteCol(obj, col)
            
            x = fields(obj.peaks);
            x(strcmp(x,'name')) = [];
            
            for i = 1:length(x)
                obj.peaks.(x{i})(:,col) = [];
            end
            
            obj.peaks.name(col) = [];
            
        end
        
        % ---------------------------------------
        % Peak data - delete row
        % ---------------------------------------
        function peakDeleteRow(obj, row)
            
            x = fields(obj.peaks);
            x(strcmp(x,'name')) = [];
            
            for i = 1:length(x)
                obj.peaks.(x{i})(row,:) = [];
            end
            
        end
        
        % ---------------------------------------
        % Figure - copy to clipboard
        % ---------------------------------------
        function copyFigure(obj, varargin)
            
            exportFigure = figure(...
                'visible', 'off',...
                'menubar', 'none',...
                'toolbar', 'none');
            
            exportPanel = copy(obj.panel.axes);
            exportPanel.Units = 'pixels';
            
            exportWidth  = exportPanel.Position(3) - exportPanel.Position(1);
            exportHeight = exportPanel.Position(4) - exportPanel.Position(2);
            
            if exportWidth <= 0
                exportWidth = 1;
            end
            
            if exportHeight <= 0
                exportHeight = 1;
            end
            
            exportPanel.Units = 'normalized';
            
            set(exportFigure,...
                'color',    'white',...
                'units',    'pixels',...
                'position', [0, 0, exportWidth, exportHeight]);
            
            set(exportPanel,....
                'parent', exportFigure,...
                'position', [0, 0, 1, 1],....
                'bordertype', 'none',...
                'backgroundcolor', 'white');
            
            axesHandles = exportPanel.Children;
            
            if isempty(axesHandles)
                
                if any(ishandle(exportFigure))
                    close(exportFigure);
                end
                
                return
                
            end
            
            axesTags = get(axesHandles, 'tag');
            axesPlot = strcmpi(axesTags, 'axesplot');
            
            if any(axesPlot)
                if isprop(axesHandles(axesPlot), 'outerposition')
                    p1 = axesHandles(axesPlot).Position;
                    p2 = axesHandles(axesPlot).OuterPosition;
                else
                    p1 = axesHandles(axesPlot).Position;
                    p2 = p1;
                end
            else
                if isprop(gca, 'outerposition')
                    p1 = get(gca, 'position');
                    p2 = get(gca, 'outerposition');
                else
                    p1 = get(gca, 'position');
                    p2 = p1;
                end
            end
            
            axesPosition(1) = p1(1) - p2(1);
            axesPosition(2) = p1(2) - p2(2);
            axesPosition(3) = p1(3) - (p2(3)-1);
            axesPosition(4) = p1(4) - (p2(4)-1);
            
            if axesPosition(3) <= 0
                axesPosition(3) = 1;
            end
            
            if axesPosition(4) <= 0
                axesPosition(4) = 1;
            end
            
            for i = 1:length(axesHandles)
                if strcmpi(get(axesHandles(i), 'type'), 'axes')
                    axesHandles(i).Position = axesPosition;
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
            
            print(exportFigure, '-clipboard', '-dbitmap');
            
            if any(ishandle(exportFigure))
                
                close(exportFigure);
                
                try
                    delete(exportFigure);
                catch
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Table - copy to clipboard
        % ---------------------------------------
        function copyTable(obj, varargin)
            
            str = '';
            fmtStr = '%s%s\t';
            fmtNum = '%s%f\t';
            
            obj.removeTableHighlightText();
            
            tableHeader = obj.table.main.ColumnName;
            tableData = obj.table.main.Data;
            
            obj.addTableHighlightText();
            
            nRow = size(tableData, 1);
            nCol = length(tableHeader);
            
            if size(tableData, 2) ~= nCol && nRow ~= 0
                tableData = obj.validateData(tableData, nRow, nCol);
            end
            
            for i = 1:nCol
                str = sprintf(fmtStr, str, tableHeader{i});
            end
            
            str = sprintf('%s\n', str);
            
            if nRow > 0
                
                for i = 1:nRow
                    
                    for j = 1:nCol
                        if j < 10
                            str = sprintf(fmtStr, str, tableData{i,j});
                        else
                            str = sprintf(fmtNum, str, tableData{i,j});
                        end
                    end
                    
                    if i < nRow
                        str = sprintf('%s\n', str);
                    elseif i == nRow
                        str = sprintf('%s', str);
                    end
                    
                end
                
            end
            
            clipboard('copy', str);
            
        end
        
        % ---------------------------------------
        % Callback - mouse movement
        % ---------------------------------------
        function figureMotionCallback(obj, src, ~)
            
            if isprop(src, 'CurrentObject')
                
                if isprop(src.CurrentObject, 'Tag')
                    
                    switch src.CurrentObject.Tag
                        
                        case 'peaklist'
                            obj.userPeak(1);
                            
                        case 'selectpeak'
                            
                            if isprop(src.CurrentObject, 'Value')
                                if src.CurrentObject.Value
                                    obj.userPeak(1);
                                end
                            else
                                obj.userPeak(0);
                            end
                            
                        otherwise
                            obj.userPeak(0);
                    end
                    
                else
                    obj.userPeak(0);
                end
                
            else
                obj.userPeak(0);
            end
            
        end
        
        % ---------------------------------------
        % Callback - peak selection
        % ---------------------------------------
        function peakTimeSelectCallback(obj, ~, evt)
            
            switch evt.EventName
                
                case 'Hit'
                    
                    x = evt.IntersectionPoint(1);
                    
                    if obj.view.index == 0 || isempty(obj.peaks.name)
                        obj.clearPeak();
                    elseif x > obj.settings.xlim(1) && x < obj.settings.xlim(2)
                        obj.toolboxPeakFit(x);
                        obj.updatePeakListText();
                    end
                    
                    obj.userPeak(0);
                    
                otherwise
                    obj.userPeak(0);
                    
            end
            
        end
        
        % ---------------------------------------
        % Callback - zoom event
        % ---------------------------------------
        function zoomCallback(obj, varargin)
            
            if obj.view.index ~= 0
                obj.settings.xmode = 'manual';
                obj.settings.ymode = 'manual';
                obj.settings.xlim = varargin{1,2}.Axes.XLim;
                obj.settings.ylim = varargin{1,2}.Axes.YLim;
                obj.updateAxesLimitToggle();
                obj.updateAxesLimitEditText();
                obj.updateAxesLimits();
                obj.updatePlotLabelPosition();
            else
                obj.axes.main.XLim = obj.settings.xlim;
                obj.axes.main.YLim = obj.settings.ylim;
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
            set(obj.axes.zoom, 'actionpostcallback', @obj.zoomCallback);
            obj.userZoom([], 0);
            
            obj.figure.Visible = 'on';
            
            obj.toolboxAlign();
            obj.toolboxResize();
            
        end
        
        
        function selectTab(obj, varargin)
            
            if isprop(obj.figure, 'CurrentObject')
                currentObject = obj.figure.CurrentObject;
            else
                currentObject = [];
            end
            
            if isprop(obj.panel.controlGroup, 'SelectedTab')
                
                tabGroup = obj.panel.controlGroup;
                tabChildren = tabGroup.Children;
                tabSelected = tabGroup.SelectedTab.Tag;
                
                tabIndex = find(~strcmpi({tabChildren.Tag},tabSelected),1);
                
                if isempty(tabIndex)
                    return
                end
                
                obj.panel.controlGroup.SelectedTab = tabChildren(tabIndex);
                
                if ~isempty(currentObject)
                    obj.figure.CurrentObject = currentObject;
                end
                
            end
            
        end
        
        function selectSample(obj, varargin)
            
            currentIndex = obj.view.index;
            
            if ~isempty(currentIndex) && currentIndex ~= 0
                
                obj.removeTableHighlightText();
                
                if length(varargin) == 1
                    n = varargin{1};
                elseif length(varargin) == 3
                    n = varargin{3};
                end
                
                newIndex = currentIndex + n;
                maxIndex = length(obj.data);
                
                if maxIndex == 1
                    return
                elseif newIndex <= maxIndex && newIndex >= 1
                    obj.view.index = newIndex;
                    obj.view.id    = num2str(newIndex);
                    obj.view.name  = obj.data(newIndex).sample_name;
                elseif newIndex > maxIndex
                    obj.view.index = 1;
                    obj.view.id    = '1';
                    obj.view.name  = obj.data(1).sample_name;
                elseif newIndex < 1
                    obj.view.index = maxIndex;
                    obj.view.id    = num2str(maxIndex);
                    obj.view.name  = obj.data(maxIndex).sample_name;
                end
                
                obj.figure.CurrentObject = obj.axes.main;
                
                obj.updateSampleText();
                obj.updateAllPeakListText();
                obj.updatePeakText();
                obj.updatePlot();
                obj.addTableHighlightText();
                obj.userPeak(0);
                
            end
            
        end
        
        function selectPeak(obj, varargin)
            
            currentIndex = obj.controls.peakList.Value;
            
            if ~isempty(currentIndex) && currentIndex ~= 0
                
                newIndex = currentIndex + varargin{1};
                maxIndex = length(obj.peaks.name);
                
                if maxIndex == 1
                    return
                elseif newIndex <= maxIndex && newIndex >= 1
                    obj.controls.peakList.Value = newIndex;
                elseif newIndex > maxIndex
                    obj.controls.peakList.Value = 1;
                elseif newIndex < 1
                    obj.controls.peakList.Value = maxIndex;
                end
                
                obj.figure.CurrentObject = obj.controls.peakList;
                obj.updatePeakText();
                obj.userPeak(1);
                
            end
            
        end
        
        function addTableHighlightText(obj, varargin)
            
            format = obj.table.main.ColumnFormat;
            width  = cell2mat(obj.table.main.ColumnWidth);
            
            row = obj.view.index;
            col = length(format);
            
            if row < 1 || isempty(obj.table.main.Data)
                return
            end
            
            if col > size(obj.table.main.Data,2)
                obj.table.main.Data{end,col} = [];
            end
            
            x = obj.table.main.Data(row,:);
            
            str = ['<html><body ',...
                'bgcolor="', obj.settings.table.backgroundColor, '" ',...
                'text="',    obj.settings.table.textColor, '" ',...
                'width="'];
            
            for i = 1:length(x)
                
                if ~strcmpi(format{i}, 'numeric')
                    x{i} = [str, num2str(1000), '">', x{i}, '&nbsp</html>'];
                elseif i > 13
                    x{i} = [str, num2str(width(i)), '" align="right">',...
                        sprintf('%.4f', x{i}), '&nbsp</html>'];
                else
                    x{i} = [str, num2str(width(i)), '" align="right">',...
                        num2str(x{i}), '&nbsp</html>'];
                end
                
            end
            
            obj.table.main.Data(row,:) = x;
            
        end
        
        function addCellHighlightText(obj, row, col)
            
            format = obj.table.main.ColumnFormat{col};
            width  = obj.table.main.ColumnWidth{col};
            
            if row < 1 || isempty(obj.table.main.Data)
                return
            end
            
            if row > size(obj.table.main.Data,1)
                obj.table.main.Data{row,1} = [];
            end
            
            if col > size(obj.table.main.Data,2)
                obj.table.main.Data{end,col} = [];
            end
            
            x = obj.table.main.Data{row,col};
            
            str = ['<html><body ',...
                'bgcolor="', obj.settings.table.backgroundColor, '" ',...
                'text="',    obj.settings.table.textColor, '" ',...
                'width="',   num2str(width), '"'];
            
            if ~strcmpi(format, 'numeric')
                x = [str, '>', x, '&nbsp</html>'];
            elseif col > 13 && ~isempty(x)
                x = [str, ' align="right">', num2str(x,'%.4f'), '&nbsp</html>'];
            else
                x = [str, ' align="right">', num2str(x), '&nbsp</html>'];
            end
            
            obj.table.main.Data{row,col} = x;
            
        end
        
        function removeTableHighlightText(obj, varargin)
            
            format = obj.table.main.ColumnFormat;
            
            row = obj.view.index;
            col = length(format);
            
            if row < 1 || isempty(obj.table.main.Data)
                return
            end
            
            if col > size(obj.table.main.Data,2)
                obj.table.main.Data{end,col} = [];
            end
            
            x = obj.table.main.Data(row,:);
            
            for i = 1:length(x)
                
                if isempty(x{i}) || isnumeric(x{i})
                    continue
                elseif ischar(x{i}) && ~any(strfind(x{i}, 'html'))
                    continue
                end
                
                str = regexpi(x{i}, '["][>](.+)[<][/]h', 'tokens', 'once');
                
                if ~isempty(str)
                    str = str{1};
                    str = strrep(str, '&nbsp', '');
                elseif isempty(str) && any(strfind(x{i}, 'html'))
                    str = [];
                else
                    str = x{i};
                end
                
                if ~isempty(str) && strcmpi(format{i}, 'numeric')
                    str = str2double(str);
                    if isnan(str)
                        str = [];
                    end
                end
                
                x{i} = str;
                
            end
            
            obj.table.main.Data(row,:) = x;
            
        end
        
        function updateSampleText(obj, varargin)
            
            obj.controls.editID.String   = obj.view.id;
            obj.controls.editName.String = obj.view.name;
            
        end
        
        function updatePeakListText(obj, varargin)
            
            if isempty(obj.controls.peakList.String)
                return
            elseif ~obj.controls.peakList.Value
                return
            elseif size(obj.peaks.time, 1) < obj.view.index
                return
            end
            
            row = obj.view.index;
            col = obj.controls.peakList.Value;
            str = obj.peaks.name{col};
            
            if size(obj.peaks.time, 2) >= col
                if row ~= 0 && ~isempty(obj.peaks.time{row,col})
                    str = ['<html>', '&#10004 ', str];
                end
            end
            
            if ~strcmp(str, obj.controls.peakList.String{col})
                obj.controls.peakList.String{col} = str;
            end
            
        end
        
        function updateAllPeakListText(obj, varargin)
            
            if isempty(obj.controls.peakList.String)
                return
            elseif ~obj.controls.peakList.Value
                return
            elseif size(obj.peaks.time, 1) < length(obj.data)
                return
            elseif size(obj.peaks.time, 2) < length(obj.controls.peakList.String)
                return
            end
            
            for i = 1:length(obj.controls.peakList.String)
                
                if obj.view.index == 0
                    str = obj.peaks.name{i};
                elseif ~isempty(obj.peaks.time{obj.view.index,i})
                    str = ['<html>', '&#10004 ', obj.peaks.name{i}];
                else
                    str = obj.peaks.name{i};
                end
                
                if ~strcmp(str, obj.controls.peakList.String{i})
                    obj.controls.peakList.String{i} = str;
                end
                
            end
            
        end
        
        function updatePeakText(obj, varargin)
            
            str = @(x) sprintf('%.3f', x);
            
            row = obj.view.index;
            col = obj.controls.peakList.Value;
            
            if ~isempty(col) && col ~= 0 && length(obj.peaks.name) >= col
                obj.controls.peakIDEdit.String = obj.peaks.name{col};
            else
                obj.controls.peakIDEdit.String = '';
            end
            
            if length(obj.peaks.name) < col
                return
            elseif ~isempty(obj.data) && ~isempty(col) && col ~= 0 && row ~= 0
                obj.controls.peakAreaEdit.String   = str(obj.peaks.area{row,col});
                obj.controls.peakHeightEdit.String = str(obj.peaks.height{row,col});
                obj.controls.peakTimeEdit.String   = str(obj.peaks.time{row,col});
                obj.controls.peakWidthEdit.String  = str(obj.peaks.width{row,col});
            else
                obj.controls.peakAreaEdit.String   = '';
                obj.controls.peakHeightEdit.String = '';
                obj.controls.peakTimeEdit.String   = '';
                obj.controls.peakWidthEdit.String  = '';
            end
            
        end
        
        function updatePlotLabel(obj, varargin)
            
            if any(ishandle(obj.view.plotLabel))
                delete(obj.view.plotLabel);
            end
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPlotLabel
                return
            else
                row = obj.view.index;
            end
            
            if isempty(obj.settings.labels.data)
                return
            else
                labelFields = obj.settings.labels.data;
            end
            
            str = '';
            
            for i = 1:length(labelFields)
                
                if isfield(obj.data, labelFields{i})
                    
                    n = obj.data(row).(labelFields{i});
                    
                    if isempty(n)
                        continue
                    elseif isnumeric(n)
                        n = num2str(n);
                    end
                    
                    switch labelFields{i}
                        case 'datetime'
                            n(n=='-') = '/';
                            n(n=='T') = ' ';
                        case 'operator'
                            n = ['Operator: ', n];
                        case 'seqindex'
                            n = ['SeqIndex: ', n];
                        case 'vial'
                            n = ['Vial: ', n];
                    end
                    
                    n(n=='_') = ' ';
                    
                    if i == 1 || isempty(str)
                        str = n;
                    else
                        str = [str, char(10), n];
                    end
                    
                elseif strcmp('row_num', labelFields{i})
                    str = [str, '#', num2str(row)];
                end
                
            end
            
            if ~isempty(str)
                
                str = regexprep(str, '[\\]', '/');
                str = deblank(strtrim(str));
                str = ['\rm ', str];
                
                x = obj.axes.main.XLim(2);
                y = obj.axes.main.YLim(2);
                
                obj.view.plotLabel = text(x, y, str,...
                    'parent',   obj.axes.main,...
                    'clipping', 'on',...
                    'hittest',  'off',...
                    'tag',      'plotlabel',...
                    'fontsize', obj.settings.labels.fontsize,...
                    'fontname', obj.settings.labels.fontname,...
                    'margin',   obj.settings.labels.margin,...
                    'units',    'data',...
                    'pickableparts',       'none',...
                    'horizontalalignment', 'right',...
                    'verticalalignment',   'bottom',...
                    'selectionhighlight',  'off');
                
                obj.updatePlotLabelPosition();
                
            end
            
        end
        
        function updatePlotLabelPosition(obj, varargin)
            
            if any(ishandle(obj.view.plotLabel))
                
                a = obj.view.plotLabel.Extent;
                xlimit = obj.axes.main.XLim;
                ylimit = obj.axes.main.YLim;
                
                b = obj.view.plotLabel.Position(1);
                b = b - (a(1)+a(3) - (xlimit(2) - diff(xlimit)*0.01));
                obj.view.plotLabel.Position(1) = b;
                
                b = obj.view.plotLabel.Position(2);
                b = b - (a(2)+a(4) - (ylimit(2) - diff(ylimit)*0.01));
                obj.view.plotLabel.Position(2) = b;
                
            end
            
        end
        
        function updateAxesLabel(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            else
                row = obj.view.index;
            end
            
            if isfield(obj.data, 'intensity_units')
                str = obj.data(row).intensity_units;
            end
            
            if isprop(obj.axes.main, 'YLabel')
                
                if ~isempty(str)
                    str = ['Intensity (', str, ')'];
                else
                    str = 'Intensity';
                end
                
                obj.axes.main.YLabel.String = str;
                
                if isprop(obj.axes.main.YLabel, 'Extent')
                    
                    unitsA = obj.axes.main.Parent.Units;
                    unitsB = obj.axes.main.Units;
                    unitsC = obj.axes.main.YLabel.Units;
                    
                    obj.axes.main.Parent.Units = 'pixels';
                    obj.axes.main.Units        = 'pixels';
                    obj.axes.secondary.Units   = 'pixels';
                    obj.axes.main.YLabel.Units = 'pixels';
                    
                    panelWidth = obj.axes.main.Parent.Position(3);
                    axesWidth  = obj.axes.main.Position(3);
                    axesLeft   = obj.axes.main.Position(1);
                    axesMargin = panelWidth - (axesLeft + axesWidth);
                    
                    target = axesLeft - axesMargin / 3;
                    offset = abs(obj.axes.main.YLabel.Extent(1)) - target;
                    
                    obj.axes.secondary.Position(1) = axesLeft + offset;
                    obj.axes.secondary.Position(3) = axesWidth - offset;
                    obj.axes.main.Position(1)      = axesLeft + offset;
                    obj.axes.main.Position(3)      = axesWidth - offset;
                    
                    obj.axes.main.Parent.Units = unitsA;
                    obj.axes.main.Units        = unitsB;
                    obj.axes.secondary.Units   = unitsB;
                    obj.axes.main.YLabel.Units = unitsC;
                    
                end
                
            end
            
        end
        
        function updatePeakLine(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakLine
                return
            else
                row = obj.view.index;
            end
            
            if ~isempty(varargin)
                col = varargin{1};
            elseif ~isempty(obj.peaks.fit)
                col = 1:length(obj.peaks.fit(row,:));
            else
                return
            end
            
            for i = 1:length(col)
                
                if size(obj.peaks.fit,1) >= row && size(obj.peaks.fit,2) >= col(i)
                    
                    if isempty(obj.peaks.fit{row,col(i)})
                        continue
                    elseif size(obj.peaks.fit{row,col(i)},2) ~= 2
                        continue
                    else
                        x = obj.peaks.fit{row,col(i)}(:,1);
                        y = obj.peaks.fit{row,col(i)}(:,2);
                    end
                    
                    if length(obj.view.peakLine) >= col(i) && any(ishandle(obj.view.peakLine{col(i)}))
                        set(obj.view.peakLine{col(i)}, 'xdata', x, 'ydata', y);
                    else
                        obj.view.peakLine{col(i)} = plot(x, y,...
                            'parent',    obj.axes.main,...
                            'color',     obj.settings.peaks.color,...
                            'linewidth', obj.settings.peaks.linewidth,...
                            'visible',   'on',...
                            'hittest',   'off',...
                            'tag',       'peak');
                    end
                end
            end
            
        end
        
        function updatePeakArea(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakArea
                return
            else
                row = obj.view.index;
            end
            
            if ~isempty(varargin)
                col = varargin{1};
            elseif ~isempty(obj.peaks.fit)
                col = 1:length(obj.peaks.fit(row,:));
            else
                return
            end
            
            for i = 1:length(col)
                
                if size(obj.peaks.fit,1) >= row && size(obj.peaks.fit,2) >= col(i)
                    
                    if isempty(obj.peaks.fit{row,col(i)})
                        continue
                    elseif size(obj.peaks.fit{row,col(i)},2) ~= 2
                        continue
                    elseif isempty(obj.peaks.areaOf{row,col(i)})
                        continue
                    end
                    
                    switch obj.peaks.areaOf{row,col(i)}
                        
                        case 'rawdata'
                            x = obj.data(row).time;
                            y = obj.data(row).intensity(:,1);
                            
                        case 'fitdata'
                            x = obj.peaks.fit{row,col(i)}(:,1);
                            y = obj.peaks.fit{row,col(i)}(:,2);
                            
                    end
                    
                    if ~isfield(obj.peaks, 'xlim')
                        continue
                    elseif isempty(obj.peaks.xlim{row,col(i)})
                        continue
                    else
                        xmin = obj.peaks.xlim{row,col(i)}(1);
                        xmax = obj.peaks.xlim{row,col(i)}(2);
                    end
                    
                    if ~isfield(obj.peaks, 'ylim')
                        continue
                    elseif isempty(obj.peaks.ylim{row,col(i)})
                        continue
                    else
                        ymin = obj.peaks.ylim{row,col(i)}(1);
                    end
                    
                    xf = x >= xmin & x <= xmax;
                    xArea = x(xf);
                    yArea = y(xf);
                    
                    if isempty(xArea) || isempty(yArea)
                        continue
                    end
                    
                    xArea = [xArea(:); flipud([xmin; xmax])];
                    yArea = [yArea(:); flipud([ymin; ymin])];
                    
                    if length(obj.view.peakArea) >= col(i) && any(ishandle(obj.view.peakArea{col(i)}))
                        set(obj.view.peakArea{col(i)}, 'xdata', xArea, 'ydata', yArea);
                    else
                        obj.view.peakArea{col(i)} = fill(xArea, yArea,...
                            obj.settings.peakFill.color,...
                            'parent',    obj.axes.main,...
                            'facecolor', obj.settings.peakFill.color,...
                            'facealpha', obj.settings.peakFill.alpha,...
                            'edgecolor', 'none',...
                            'linestyle', 'none',...
                            'visible',   'on',...
                            'hittest',   'off',...
                            'tag',       'peakarea');
                    end
                    
                end
            end
            
        end
        
        function updatePeakBaseline(obj, varargin)
            
            if isempty(obj.data) || obj.view.index == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakBaseline
                return
            else
                row = obj.view.index;
            end
            
            if ~isempty(varargin)
                col = varargin{1};
            elseif ~isempty(obj.peaks.fit)
                col = 1:length(obj.peaks.fit(row,:));
            else
                return
            end
            
            for i = 1:length(col)
                
                if size(obj.peaks.fit,1) >= row && size(obj.peaks.fit,2) >= col(i)
                    
                    if isempty(obj.peaks.fit{row,col(i)})
                        continue
                    elseif size(obj.peaks.fit{row,col(i)},2) ~= 2
                        continue
                    end
                    
                    if ~isfield(obj.peaks, 'xlim')
                        continue
                    elseif isempty(obj.peaks.xlim{row,col(i)})
                        continue
                    else
                        xmin = obj.peaks.xlim{row,col(i)}(1);
                        xmax = obj.peaks.xlim{row,col(i)}(2);
                    end
                    
                    if ~isfield(obj.peaks, 'ylim')
                        continue
                    elseif isempty(obj.peaks.ylim{row,col(i)})
                        continue
                    else
                        ymin = obj.peaks.ylim{row,col(i)}(1);
                    end
                    
                    x = [xmin; xmax];
                    y = [ymin; ymin];
                    
                    if isempty(x) || isempty(y)
                        continue
                    end
                    
                    if length(obj.view.peakBaseline) >= col(i) && any(ishandle(obj.view.peakBaseline{col(i)}))
                        set(obj.view.peakBaseline{col(i)}, 'xdata', x, 'ydata', y);
                    else
                        obj.view.peakBaseline{col(i)} = plot(x, y, '-',...
                            'parent',     obj.axes.main,...
                            'color',      obj.settings.peakBaseline.color,...
                            'markersize', obj.settings.peakBaseline.markersize,...,...
                            'linewidth',  obj.settings.peakBaseline.linewidth,...
                            'visible',    'on',...
                            'hittest',    'off',...
                            'tag',        'peakbaseline');
                    end
                    
                end
            end
            
        end
        
        function updatePlotBaseline(obj, varargin)
            
            if ~obj.settings.showPlotBaseline || isempty(obj.data)
                return
            elseif obj.view.index == 0
                return
            else
                row = obj.view.index;
            end
            
            if isempty(obj.data(row).baseline)
                obj.getBaseline();
            end
            
            if ~isempty(obj.data(row).baseline) && size(obj.data(row).baseline, 2) == 2
                
                x = obj.data(row).baseline(:,1);
                y = obj.data(row).baseline(:,2);
                
                if any(ishandle(obj.view.plotBaseline))
                    set(obj.view.plotBaseline, 'xdata', x, 'ydata', y);
                else
                    obj.view.plotBaseline = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth,...
                        'visible',   'on',...
                        'tag',       'baseline');
                end
            end
            
        end
        
        function appendTableData(obj, varargin)
            
            if ~isempty(obj.data)
                
                row = size(obj.table.main.Data,1) + 1;
                
                obj.table.main.Data{row,1}  = obj.data(end).file_path;
                obj.table.main.Data{row,2}  = obj.data(end).file_name;
                obj.table.main.Data{row,3}  = obj.data(end).datetime;
                obj.table.main.Data{row,4}  = obj.data(end).instrument;
                obj.table.main.Data{row,5}  = obj.data(end).instmodel;
                obj.table.main.Data{row,6}  = obj.data(end).method_name;
                obj.table.main.Data{row,7}  = obj.data(end).operator;
                obj.table.main.Data{row,8}  = obj.data(end).sample_name;
                obj.table.main.Data{row,9}  = obj.data(end).sample_info;
                obj.table.main.Data{row,10} = obj.data(end).seqindex;
                obj.table.main.Data{row,11} = obj.data(end).vial;
                obj.table.main.Data{row,12} = obj.data(end).replicate;
                
            end
            
        end
        
        function clearTableData(obj, varargin)
            
            obj.table.main.Data = [];
            
        end
        
        function clearPeak(obj, varargin)
            
            row = obj.view.index;
            col = obj.controls.peakList.Value;
            
            if isempty(col) || row == 0
                return
            end
            
            if row ~= 0 && col ~= 0
                obj.clearPeakText(col);
                obj.clearPeakLine(col);
                obj.clearPeakLabel(col);
                obj.clearPeakArea(col);
                obj.clearPeakBaseline(col);
                obj.clearPeakData(row,col);
                obj.clearPeakTable(row,col);
                obj.updatePeakListText();
            end
            
        end
        
        function clearPeakText(obj, col)
            
            if col ~= 0
                obj.controls.peakIDEdit.String = obj.peaks.name{col};
            else
                obj.controls.peakIDEdit.String = '';
            end
            
            obj.controls.peakTimeEdit.String   = '';
            obj.controls.peakWidthEdit.String  = '';
            obj.controls.peakHeightEdit.String = '';
            obj.controls.peakAreaEdit.String   = '';
            
        end
        
        function clearPeakData(obj, row, col)
            
            obj.peaks.time{row,col}   = [];
            obj.peaks.width{row,col}  = [];
            obj.peaks.height{row,col} = [];
            obj.peaks.area{row,col}   = [];
            obj.peaks.error{row,col}  = [];
            obj.peaks.fit{row,col}    = [];
            obj.peaks.areaOf{row,col} = [];
            obj.peaks.model{row,col}  = [];
            obj.peaks.xlim{row,col}   = [];
            obj.peaks.ylim{row,col}   = [];
            
        end
        
        function updatePeakData(obj, row, col, peak)
            
            obj.peaks.time{row,col}   = peak.time;
            obj.peaks.width{row,col}  = peak.width;
            obj.peaks.height{row,col} = peak.height;
            obj.peaks.area{row,col}   = peak.area;
            obj.peaks.error{row,col}  = peak.error;
            obj.peaks.fit{row,col}    = peak.fit;
            obj.peaks.areaOf{row,col} = obj.settings.peakArea;
            
            if isfield(peak, 'model')
                obj.peaks.model{row,col} = peak.model;
            else
                obj.peaks.model{row,col} = [];
            end
            
            if isfield(peak, 'xmin') && isfield(peak, 'xmax')
                obj.peaks.xlim{row,col} = [peak.xmin, peak.xmax];
            else
                obj.peaks.xlim{row,col} = [];
            end
            
            if isfield(peak, 'ymin') && isfield(peak, 'ymax')
                obj.peaks.ylim{row,col} = [peak.ymin, peak.ymax];
            else
                obj.peaks.ylim{row,col} = [];
            end
            
        end
        
        function clearPeakTable(obj, row, col)
            
            n = length(obj.peaks.name);
            
            obj.table.main.Data{row, col+13 + n*0} = [];
            obj.table.main.Data{row, col+13 + n*1} = [];
            obj.table.main.Data{row, col+13 + n*2} = [];
            obj.table.main.Data{row, col+13 + n*3} = [];
            
            if row == obj.view.index
                obj.addCellHighlightText(row, col+13 + n*0);
                obj.addCellHighlightText(row, col+13 + n*1);
                obj.addCellHighlightText(row, col+13 + n*2);
                obj.addCellHighlightText(row, col+13 + n*3);
            end
            
        end
        
        function updatePeakTable(obj, row, col)
            
            n = length(obj.peaks.name);
            
            obj.table.main.Data{row, col+13 + n*0} = obj.peaks.area{row,col};
            obj.table.main.Data{row, col+13 + n*1} = obj.peaks.height{row,col};
            obj.table.main.Data{row, col+13 + n*2} = obj.peaks.time{row,col};
            obj.table.main.Data{row, col+13 + n*3} = obj.peaks.width{row,col};
            
            if row == obj.view.index
                obj.addCellHighlightText(row, col+13 + n*0);
                obj.addCellHighlightText(row, col+13 + n*1);
                obj.addCellHighlightText(row, col+13 + n*2);
                obj.addCellHighlightText(row, col+13 + n*3);
            end
            
        end
        
        function clearPeakLine(obj, col)
            
            if length(obj.view.peakLine) >= col && any(ishandle(obj.view.peakLine{col}))
                set(obj.view.peakLine{col}, 'xdata', [], 'ydata', []);
            end
            
        end
        
        function clearPeakArea(obj, col)
            
            if length(obj.view.peakArea) >= col && any(ishandle(obj.view.peakArea{col}))
                set(obj.view.peakArea{col}, 'xdata', [], 'ydata', []);
            end
            
        end
        
        function clearPeakBaseline(obj, col)
            
            if length(obj.view.peakBaseline) >= col && any(ishandle(obj.view.peakBaseline{col}))
                set(obj.view.peakBaseline{col}, 'xdata', [], 'ydata', []);
            end
            
        end
        
        function clearPeakLabel(obj, col)
            
            if length(obj.view.peakLabel) >= col && any(ishandle(obj.view.peakLabel{col}))
                
                if isprop(obj.view.peakLabel{col}, 'extent')
                    
                    xlimit = obj.axes.main.XLim;
                    ylimit = obj.axes.main.YLim;
                    
                    y = obj.view.peakLabel{col}.Extent;
                    y = y(2) + y(4);
                    
                    if y >= ylimit(2) - diff(ylimit) * 0.05
                        
                        isReset = 1;
                        
                        for i = 1:length(obj.view.peakLabel)
                            
                            if any(ishandle(obj.view.peakLabel{i})) && i ~= col
                                
                                xy = obj.view.peakLabel{i}.Extent;
                                
                                if xy(1) < xlimit(1) || xy(1) > xlimit(2)
                                    continue
                                end
                                
                                if xy(2)+xy(4) >= ylimit(2) - diff(ylimit)*0.05
                                    isReset = 0;
                                end
                            end
                        end
                        
                        if isReset
                            obj.updateAxesYLim();
                            obj.updatePlotLabelPosition();
                        end
                    end
                end
                
                delete(obj.view.peakLabel{col});
                
            end
            
        end
        
        function clearAllPlot(obj)
            
            obj.clearLine('plotLine');
            obj.clearLine('plotBaseline');
            obj.clearLine('peakLine');
            obj.clearLine('peakArea');
            obj.clearLine('peakBaseLine');
            
            obj.clearLabel('peakLabel');
            
        end
        
        function clearLine(obj, str)
            
            if isfield(obj.view, str)
                
                for i = 1:length(obj.view.(str))
                    
                    if iscell(obj.view.(str))
                        x = obj.view.(str){i};
                    else
                        x = obj.view.(str)(i);
                    end
                    
                    if any(ishandle(x))
                        set(x, 'xdata', [], 'ydata', []);
                    end
                    
                end
                
            end
            
        end
        
        function clearLabel(obj, str)
            
            if isfield(obj.view, str)
                
                for i = 1:length(obj.view.(str))
                    
                    if iscell(obj.view.(str))
                        x = obj.view.(str){i};
                    else
                        x = obj.view.(str)(i);
                    end
                    
                    if any(ishandle(x))
                        delete(x);
                    end
                    
                end
                
            end
            
        end
        
        function clearAxesChildren(obj, tag)
            
            axesChildren = obj.axes.main.Children;
            
            if ~isempty(axesChildren)
                axesTag = get(axesChildren, 'tag');
                delete(axesChildren(strcmpi(axesTag, tag)));
            end
            
        end
        
        function updateAxesLimits(obj)
            
            obj.updateAxesXLim();
            obj.updateAxesYLim();
            
        end
        
        function resetTableHeader(obj, varargin)
            
            if length(obj.table.main.ColumnName) >= 13
                obj.table.main.ColumnName = obj.table.main.ColumnName(1:13);
            end
            
            if ~isempty(obj.peaks.name)
                
                nCol = length(obj.peaks.name);
                
                for i = 1:length(obj.peaks.name)
                    obj.table.main.ColumnName(i+13 + nCol*0) = {['Area (', obj.peaks.name{i}, ')']};
                    obj.table.main.ColumnName(i+13 + nCol*1) = {['Height (', obj.peaks.name{i}, ')']};
                    obj.table.main.ColumnName(i+13 + nCol*2) = {['Time (', obj.peaks.name{i}, ')']};
                    obj.table.main.ColumnName(i+13 + nCol*3) = {['Width (', obj.peaks.name{i}, ')']};
                end
            end
            
        end
        
        function resetTableData(obj, varargin)
            
            if isempty(obj.data)
                return
            else
                nRow = length(obj.data);
            end
            
            if ~isempty(obj.peaks.name)
                nCol = length(obj.peaks.name);
            else
                nCol = 0;
            end
            
            if nCol ~= 0
                obj.validatePeakData(nRow, nCol);
            end
            
            for i = 1:nRow
                
                obj.table.main.Data{i,1}  = obj.data(i).file_path;
                obj.table.main.Data{i,2}  = obj.data(i).file_name;
                obj.table.main.Data{i,3}  = obj.data(i).datetime;
                obj.table.main.Data{i,4}  = obj.data(i).instrument;
                obj.table.main.Data{i,5}  = obj.data(i).instmodel;
                obj.table.main.Data{i,6}  = obj.data(i).method_name;
                obj.table.main.Data{i,7}  = obj.data(i).operator;
                obj.table.main.Data{i,8}  = obj.data(i).sample_name;
                obj.table.main.Data{i,9}  = obj.data(i).sample_info;
                obj.table.main.Data{i,10} = obj.data(i).seqindex;
                obj.table.main.Data{i,11} = obj.data(i).vial;
                obj.table.main.Data{i,12} = obj.data(i).replicate;
                
                if nCol ~= 0
                    for j = 1:nCol
                        obj.table.main.Data{i, j+13 + nCol*0} = obj.peaks.area{i,j};
                        obj.table.main.Data{i, j+13 + nCol*1} = obj.peaks.height{i,j};
                        obj.table.main.Data{i, j+13 + nCol*2} = obj.peaks.time{i,j};
                        obj.table.main.Data{i, j+13 + nCol*3} = obj.peaks.width{i,j};
                    end
                end
            end
            
        end
        
        function userZoom(obj, state, varargin)
            
            if ~isempty(varargin)
                state = varargin{1};
            elseif obj.settings.selectZoom == state
                return
            end
            
            switch state
                
                case 0
                    
                    obj.settings.selectZoom = 0;
                    obj.axes.zoom.Enable = 'off';
                    
                    set(obj.figure, 'pointer', 'arrow');
                    set(obj.figure, 'windowkeypressfcn', @obj.keyboardCallback);
                    set(obj.figure, 'windowbuttonmotionfcn', @obj.figureMotionCallback);
                    
                case 1
                    
                    obj.settings.selectZoom = 1;
                    obj.axes.zoom.Enable = 'on';
                    
                    set(obj.figure, 'windowbuttonmotionfcn', @obj.figureMotionCallback);
                    
            end
            
        end
        
        function userPeak(obj, state, varargin)
            
            if ~isempty(varargin)
                state = varargin{1};
            elseif obj.view.selectPeak == state
                return
            end
            
            switch state
                
                case 0
                    
                    obj.view.selectPeak = 0;
                    obj.controls.selectPeak.Value = 0;
                    
                    if strcmpi(obj.menu.view.zoom.Checked, 'on')
                        obj.userZoom(1);
                    end
                    
                    set(obj.figure, 'pointer', 'arrow');
                    set(obj.axes.main, 'buttondownfcn', '');
                    
                case 1
                    
                    if ~isempty(obj.data) && ~isempty(obj.peaks.name)
                        
                        obj.view.selectPeak = 1;
                        obj.controls.selectPeak.Value = 1;
                        
                        if strcmpi(obj.menu.view.zoom.Checked, 'on')
                            obj.userZoom(0);
                        end
                        
                        set(obj.figure, 'pointer', 'circle');
                        set(obj.axes.main, 'buttondownfcn', @obj.peakTimeSelectCallback);
                        
                    end
                    
            end
            
        end
        
        function keyboardCallback(obj, ~, evt)
            
            if any(isprop(obj.figure.CurrentObject, 'tag'))
                if strcmpi(obj.figure.CurrentObject.Tag, 'datatable')
                    return
                end
            end
            
            if isprop(obj.figure.CurrentObject, 'style')
                if any(strcmpi(obj.figure.CurrentObject.Style, {'edit', 'slider'}))
                    return
                end
            end
            
            switch evt.Key
                
                case 'c'
                    
                    if ~isempty(evt.Modifier) && obj.view.index
                        
                        if strcmpi(evt.Modifier{:}, 'command') && ismac
                            obj.copyFigure();
                        elseif strcmpi(evt.Modifier{:}, 'control') && ~ismac
                            obj.copyFigure();
                        end
                        
                    end
                    
                case obj.settings.keyboard.selectPeak %'space'
                    
                    if isempty(evt.Modifier)
                        
                        if obj.view.selectPeak
                            obj.userPeak(0);
                            obj.figure.CurrentObject = obj.axes.main;
                        else
                            obj.userPeak(1);
                            obj.figure.CurrentObject = obj.controls.peakList;
                        end
                        
                    end
                    
                case obj.settings.keyboard.clearPeak %'backspace'
                    
                    if isempty(evt.Modifier)
                        obj.clearPeak();
                    end
                    
                case obj.settings.keyboard.previousPeak %'uparrow'
                    
                    if isempty(evt.Modifier)
                        obj.selectPeak(-1);
                    end
                    
                case obj.settings.keyboard.nextPeak %'downarrow'
                    
                    if isempty(evt.Modifier)
                        obj.selectPeak(1);
                    end
                    
                case obj.settings.keyboard.previousSample %'leftarrow'
                    
                    if isempty(evt.Modifier)
                        obj.selectSample(-1);
                    end
                    
                case obj.settings.keyboard.nextSample %'rightarrow'
                    
                    if isempty(evt.Modifier)
                        obj.selectSample(1);
                    end
                    
                case 'tab'
                    
                    if isempty(evt.Modifier)
                        obj.selectTab();
                    end
                    
            end
            
        end
        
        function validatePeakFields(obj, varargin)
            
            str = obj.settings.peakFields;
            
            for i = 1:length(str)
                
                if ~isfield(obj.peaks, str{i})
                    obj.peaks.(str{i}) = {};
                end
                
            end
            
        end
        
        function validatePeakData(obj, rows, cols)
            
            x = fields(obj.peaks);
            x(strcmp(x,'name')) = [];
            
            for i = 1:length(x)
                
                if ~isfield(obj.peaks, x{i})
                    obj.peaks.(x{i}) = {};
                end
                
                if size(obj.peaks.(x{i}),1) < rows
                    obj.peaks.(x{i}){rows,1} = [];
                elseif size(obj.peaks.(x{i}),1) > rows
                    obj.peaks.(x{i})(rows+1:end,:) = [];
                end
                
                if size(obj.peaks.(x{i}),2) < cols
                    obj.peaks.(x{i}){1,cols} = [];
                elseif size(obj.peaks.(x{i}),2) > cols
                    obj.peaks.(x{i})(:,cols+1:end) = [];
                end
                
            end
            
        end
        
        function closeRequest(obj, varargin)
            
            try
                
                if obj.settings.autosave
                    
                    try
                        obj.toolboxSettings([], [], 'save_default');
                        obj.toolboxPeakList([], [], 'save_default');
                    catch
                    end
                    
                end
                
                if ishandle(obj.figure)
                    delete(obj.figure);
                end
                
            catch
                closereq();
            end
            
        end
        
    end
    
    methods (Static = true)
        
        function x = getPlatform()
            x = computer;
        end
        
        function x = getScreenSize()
            
            x = get(0, 'screensize');
            
            if length(x) == 4
                x = x(3:4);
            end
            
        end
        
        function x = getEnvironment()
            
            if ~isempty(ver('MATLAB'))
                x = ver('MATLAB');
                x = ['MATLAB ', x.Release];
            elseif ~isempty(ver('OCTAVE'))
                x = 'OCTAVE';
            else
                x = 'UNKNOWN';
            end
            
        end
        
        function x = getFont()
            
            sysFonts = listfonts;
            x = 'FixedWidth';
            
            fontPref = {'Avenir'; 'SansSerif'; 'Helvetica Neue';
                'Lucida Sans Unicode'; 'Microsoft Sans Serif'; 'Arial'};
            
            for i = 1:length(fontPref)
                if any(strcmpi(fontPref{i}, sysFonts))
                    x = fontPref{i};
                    return
                end
            end
            
        end
        
        function x = validateData(x, rows, cols)
            
            if size(x,1) < rows
                x{rows,1} = [];
            elseif size(x,1) > rows
                x(rows+1:end,:) = [];
            end
            
            if size(x,2) < cols
                x{1,cols} = [];
            elseif size(x,2) > cols
                x(:,cols+1:end) = [];
            end
            
        end
        
    end
    
end