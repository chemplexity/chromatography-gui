classdef ChromatographyGUI < handle
    
    properties (Constant = true)
        
        name        = 'Chromatography Toolbox';
        url         = 'https://github.com/chemplexity/chromatography-gui';
        version     = '0.0.9.20180130-dev';
        
        platform    = ChromatographyGUI.getPlatform();
        environment = ChromatographyGUI.getEnvironment();
        screensize  = ChromatographyGUI.getScreenSize();
        datetime    = ChromatographyGUI.getDatetime();
        
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
        settings        
        statusbar

    end
    
    properties (Hidden = true)
        
        % Paths
        toolbox_path       = fileparts(fileparts(mfilename('fullpath')));
        toolbox_file       = fileparts(mfilename('fullpath'));
        toolbox_config     = 'config';
        toolbox_data       = 'data';
        toolbox_src        = 'src';
        toolbox_settings   = 'default_settings.mat';
        toolbox_peaklist   = 'default_peaklist.mat';
        toolbox_checkpoint = '';
        
        % Plots
        view = struct(...
            'row',          0,...
            'col',          1,...
            'id',           'N/A',...
            'name',         'N/A',...
            'selectPeak',   0,...
            'plotLine',     [],...
            'plotLabel',    [],...
            'plotBaseline', [],...
            'peakName',     '',...
            'peakLine',     [],...
            'peakLabel',    [],...
            'peakBaseline', [],...
            'peakArea',     []);
        
        % Other
        font = ChromatographyGUI.getFont();
        
        % Java
        java
        
    end
    
    methods
        
        function obj = ChromatographyGUI(varargin)
            
            % ---------------------------------------
            % Warnings
            % ---------------------------------------
            warning off all
            
            % ---------------------------------------
            % Path
            % ---------------------------------------
            addpath(obj.toolbox_path);
            addpath(genpath([obj.toolbox_path, filesep, obj.toolbox_src]));
            addpath(genpath([obj.toolbox_path, filesep, obj.toolbox_config]));
            
            % ---------------------------------------
            % Settings
            % ---------------------------------------
            obj.toolboxSettings([], [], 'initialize');
            obj.table.selection = [];
            
            for i = 1:length(obj.settings.peakFields)
                obj.peaks.(obj.settings.peakFields{i}) = {};
            end
            
            obj.toolboxSettings([], [], 'load_default');
            obj.toolboxPeakList([], [], 'load_default');
            
            % ---------------------------------------
            % GUI
            % ---------------------------------------
            obj.initializeGUI();
            obj.toolboxSettings([], [], 'apply');
            
        end
        
        % ---------------------------------------
        % Figure - update all
        % ---------------------------------------
        function updateFigure(obj, varargin)
            
            obj.removeTableHighlightText();
            
            if obj.view.row == 0 && ~isempty(obj.data)
                obj.view.row = 1;
                obj.view.id    = '1';
                obj.view.name  = obj.data(1).sample_name;
            elseif obj.view.row > 0 && ~isempty(obj.data)
                obj.view.id    = num2str(obj.view.row);
                obj.view.name  = obj.data(obj.view.row).sample_name;
            elseif isempty(obj.data)
                obj.view.row = 0;
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
            
            if isempty(obj.data) || obj.view.row == 0
                return
            else
                row = obj.view.row;
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
                    
                    set(obj.view.plotLine,...
                        'xdata',     x,...
                        'ydata',     y,...
                        'color',     obj.settings.plot.color,...
                        'linewidth', obj.settings.plot.linewidth);
                    
                else
                    
                    obj.view.plotLine = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.plot.color,...
                        'linewidth', obj.settings.plot.linewidth,...
                        'visible',   'on',...
                        'hittest',   'off',...
                        'tag',       'plotLine');
                    
                end
                
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
        % Load Agilent data
        % ---------------------------------------
        function loadAgilentData(obj, varargin)
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                i = varargin{1};
            else
                i = obj.view.row;
            end
            
            if i < 1 || i > length(obj.data)
                return
            end
            
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
            
            str = fields(x);
            
            for j = 1:length(str)
                if isfield(obj.data, str{j})
                    if ~isempty(x.(str{j})) && isempty(obj.data(i).(str{j}))
                        obj.data(i).(str{j}) = x.(str{j});
                    end
                end
            end
            
        end
        
        % ---------------------------------------
        % Update x-axes limits
        % ---------------------------------------
        function updateAxesXLim(obj, varargin)
            
            switch obj.settings.xmode
                
                case 'auto'

                    if obj.view.row ~= 0 && ~isempty(obj.data(obj.view.row).time)
                        
                        xmin = min(obj.data(obj.view.row).time);
                        xmax = max(obj.data(obj.view.row).time);
                        xpad = (xmax - xmin) * obj.settings.xpad;
                        
                        if xmin >= 0 && xmin - xpad < 0
                            xmin = 0;
                        else
                            xmin = xmin - xpad;
                        end
                        
                        xmax = xmax + xpad;
                        obj.settings.xlim = [xmin, xmax];
                        
                    end
                    
                    if ~all(obj.axes.main.XLim == obj.settings.xlim)
                        obj.axes.main.XLim = obj.settings.xlim;
                    end
                    
                case 'manual'
                    
                    if all(obj.axes.main.XLim == obj.settings.xlim)
                        return
                        
                    elseif obj.view.row ~= 0
                        
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
            
            row = obj.view.row;
            
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
                        
                        if ~isempty(y)
                            
                            ymin = min(y);
                            ymax = max(y);
                            ypad = (ymax - ymin) * obj.settings.ypad;
                            
                            if ypad == 0
                                ypad = 1;
                            end
                            
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
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPlotBaseline
                return
            else
                row = obj.view.row;
            end
            
            if isempty(obj.data(row).baseline)
                obj.getBaseline();
            end
            
            if ~isempty(obj.data(row).baseline)
                
                x = obj.data(row).baseline(:,1);
                y = obj.data(row).baseline(:,2);
                
                if any(ishandle(obj.view.plotBaseline))
                    
                    set(obj.view.plotBaseline,...
                        'xdata',     x,...
                        'ydata',     y,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth);
                    
                else
                    
                    obj.view.plotBaseline = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth,...
                        'visible',   'on',...
                        'hittest',   'off',...
                        'tag',       'plotBaseline');
                    
                end
                
            else
                obj.clearLine('plotBaseline');
            end
            
        end
        
        % ---------------------------------------
        % Plot - peak fit data
        % ---------------------------------------
        function plotPeaks(obj, varargin)

            for i = 1:length(obj.peaks.name)
                obj.clearPeakLine(i);
                obj.clearPeakArea(i);
                obj.clearPeakBaseline(i);
                obj.clearPeakLabel(i);
            end
            
            obj.updateAxesLimits();
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPeaks || isempty(obj.peaks.fit)
                return
            else
                row = obj.view.row;
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
                            'tag',       'peakLine');
                        
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
            elseif isempty(obj.data) || obj.view.row == 0
                return
            elseif isempty(obj.peaks.fit)
                return
            else
                row = obj.view.row;
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
                    
                    if length(obj.view.peakLabel) < col(i)
                        obj.view.peakLabel{col(i)} = [];
                    end
                    
                    if any(ishandle(obj.view.peakLabel{col(i)}))
                        if ~isempty(obj.view.peakLabel{col(i)}.String)
                            obj.clearPeakLabel(col(i));
                        end
                    end
                    
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
                    
                    % Peak text
                    if any(ishandle(obj.view.peakLabel{col(i)}))
                        
                        set(obj.view.peakLabel{col(i)},...
                            'string',   str,...
                            'position', [textX, textY, 0],...
                            'fontsize', obj.settings.labels.fontsize,...
                            'fontname', obj.settings.labels.fontname,...
                            'margin',   obj.settings.labels.margin);
                        
                    else
                        
                        obj.view.peakLabel{col(i)} = text(textX, textY, str,...
                            'parent',   obj.axes.main,...
                            'clipping', 'on',...
                            'hittest',  'off',...
                            'tag',      'peakLabel',...
                            'fontsize', obj.settings.labels.fontsize,...
                            'fontname', obj.settings.labels.fontname,...
                            'margin',   obj.settings.labels.margin,...
                            'units',    'data',...
                            'pickableparts',       'none',...
                            'horizontalalignment', 'center',...
                            'verticalalignment',   'bottom',...
                            'selectionhighlight',  'off');
                        
                    end
                    
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
                    axesMain = strcmpi(axesTag, 'plotLine');
                    
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
            
            row = obj.view.row;
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
            
            y = movingAverage(y);
            
            b = baseline(y,...
                'asymmetry',  10 ^ obj.settings.baseline.asymmetry,...
                'smoothness', 10 ^ obj.settings.baseline.smoothness,...
                'iterations', obj.settings.baseline.iterations);
            
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
                
                idx = obj.table.selection(:,1);
                
                obj.removeTableHighlightText();
                
                obj.dataDeleteRow(idx);
                obj.peakDeleteRow(idx);
                obj.table.main.Data(idx, :) = [];
                
                if isempty(obj.data)
                    obj.view.row = 0;
                    obj.view.id    = 'N/A';
                    obj.view.name  = 'N/A';
                elseif obj.view.row > length(obj.data)
                    obj.view.row = length(obj.data);
                    obj.view.id    = num2str(length(obj.data));
                    obj.view.name  = obj.data(end).sample_name;
                else
                    obj.view.id   = num2str(obj.view.row);
                    obj.view.name = obj.data(obj.view.row).sample_name;
                end
                
                obj.updateSampleText();
                obj.updateAllPeakListText();
                obj.updatePeakText();
                obj.updatePlot();
                
                obj.addTableHighlightText();
                
                obj.validatePeakData(length(obj.data), length(obj.peaks.name));
                
                if isempty(obj.data)
                    obj.clearAxesChildren('plotLine');
                    obj.clearAxesChildren('plotLabel');
                    obj.clearAxesChildren('plotBaseline');
                    obj.clearAxesChildren('peakLine');
                    obj.clearAxesChildren('peakLabel');
                    obj.clearAxesChildren('peakBaseline');
                    obj.clearAxesChildren('peakArea');
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Table - update column header
        % ---------------------------------------
        function updateTableHeader(obj, varargin)
            
            str = obj.settings.table.labelNames;
            
            m = obj.settings.table.minColumns;
            n = obj.peaks.name;
            
            x = obj.table.main.ColumnName(1:m);
            
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
        % Table - update peak data
        % ---------------------------------------
        function updateTablePeakData(obj, varargin)
            
            if isempty(obj.data) || isempty(obj.table.main.Data)
                obj.table.main.Data = [];
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
            
            obj.removeTableHighlightText();
            obj.addTableHighlightText();
            
        end
        
        % ---------------------------------------
        % Table - add peak column
        % ---------------------------------------
        function tableAddPeakColumn(obj, str)
            
            if ischar(str) && ~iscell(str)
                str = {str};
            end
            
            if isempty(obj.peaks.name)
                obj.peaks.name(1,1) = str;
            else
                obj.peaks.name(end+1,1) = str;
            end
            
            obj.validatePeakNames();
            obj.validatePeakData(length(obj.data), length(obj.peaks.name));
            
            obj.updateTableHeader();
            obj.updateTableProperties();
            obj.updateTablePeakData();
            
            obj.updatePeakListbox();
            
            obj.removeTableHighlightText();
            obj.addTableHighlightText();
            
        end
        
        % ---------------------------------------
        % Table - edit peak column names
        % ---------------------------------------
        function tableEditPeakColumn(obj, col, str)
            
            if col == 0 || col > length(obj.peaks.name)
                return
            end
            
            x = obj.settings.table.labelNames;
            m = obj.settings.table.minColumns;
            n = length(obj.peaks.name);
            
            a = [' (', str{1}, ')'];
            b = 0;
            
            for i = 1:length(x)
                
                if ~isfield(obj.settings.table, ['show', x{i}])
                    continue
                end
                
                if obj.settings.table.(['show', x{i}])
                    obj.table.main.ColumnName{(col+m)+(n*b)} = [x{i}, a];
                    b = b + 1;
                end
                
            end
            
            obj.peaks.name(col,1) = str;
            obj.controls.peakIDEdit.String = str;
            
            obj.updatePeakListText();
            obj.plotPeakLabels(col);
            
        end
        
        % ---------------------------------------
        % Table - delete peak column
        % ---------------------------------------
        function tableDeletePeakColumn(obj, col)
            
            if col == 0 || col > length(obj.peaks.name)
                return
            end
            
            obj.peakDeleteCol(col);
            
            obj.updateTableHeader();
            obj.updateTableProperties();
            obj.updateTablePeakData();
            
            obj.updatePeakListbox();
            
            obj.removeTableHighlightText();
            obj.addTableHighlightText();
            
            obj.clearPeakLine(col);
            obj.clearPeakArea(col);
            obj.clearPeakBaseline(col);
            obj.clearPeakLabel(col);
            
            obj.deletePlotObject('peakLine', col);
            obj.deletePlotObject('peakLabel', col);
            obj.deletePlotObject('peakArea', col);
            obj.deletePlotObject('peakBaseline', col);
            
        end
        
        % ---------------------------------------
        % Listbox - update peak list
        % ---------------------------------------
        function updatePeakListbox(obj, varargin)
            
            obj.controls.peakList.String = obj.peaks.name;
            
            if isempty(obj.view.col)
                obj.view.col = 1;
            elseif obj.view.col > length(obj.peaks.name)
                obj.view.col = length(obj.peaks.name);
            elseif obj.view.col < 1
                obj.view.col = 1;
            end
            
            obj.updateAllPeakListText();
            
        end
        
        % ---------------------------------------
        % Peak data - delete column
        % ---------------------------------------
        function peakDeleteCol(obj, col)
            
            x = fields(obj.peaks);
            x(strcmp(x,'name')) = [];
            
            for i = 1:length(x)
                
                if size(obj.peaks.(x{i}),2) >= col
                    obj.peaks.(x{i})(:,col) = [];
                end
                
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
        % Data - delete row
        % ---------------------------------------
        function dataDeleteRow(obj, row)
            
            obj.data(row) = [];
            
        end
        
        % ---------------------------------------
        % Figure - copy to clipboard
        % ---------------------------------------
        function copyFigure(obj, varargin)
            
            statusText = 'Copying figure to clipboard... ';
            obj.setStatusBarText(statusText);
            
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
                axesLabel = axesChildren(strcmpi(axesTag, 'plotLabel'));
                
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
            
            statusText = [statusText, 'COMPLETE'];
            obj.setStatusBarText(statusText);
                        
        end
        
        % ---------------------------------------
        % Table - copy to clipboard
        % ---------------------------------------
        function copyTable(obj, varargin)
            
            if isempty(obj.table.main.Data)
                return
            end
            
            statusText = 'Copying table data to clipboard... ';
            obj.setStatusBarText(statusText);
                        
            % Get table and peak data
            str = obj.settings.table.labelNames;
            
            m = obj.settings.table.minColumns;
            n = obj.peaks.name;
            
            x = obj.table.main.ColumnName(1:m);
            f = obj.table.main.ColumnFormat(1:m);
            
            obj.removeTableHighlightText();
            y = obj.table.main.Data(:,1:m);
            obj.addTableHighlightText();
            
            for i = 1:length(str)
                
                a = [str{i}, ' ('];
                x = [x; cellfun(@(x) [a,x,')'], n, 'uniformoutput', 0)];
                y = [y, obj.peaks.(lower(str{i}))];
                
                switch lower(str{i})
                    case {'model'}
                        xtype = 'char';
                    otherwise
                        xtype = 'numeric';
                end
                
                f = [f, repmat({xtype}, 1, length(n))];
                
            end
            
            if size(x,1) ~= 1 && size(x,2) == 1
                x = x';
            end
            
            str = '';
            
            % Format table header
            for i = 1:size(x,2)
                str = sprintf('%s%s\t', str, x{i});
            end
            
            str = sprintf('%s\n', str);
            
            % Format table data
            for i = 1:size(y,1)
                
                for j = 1:size(y,2)
                    
                    if j <= length(f)
                        x = f{j};
                    else
                        x = 'char';
                    end
                    
                    switch x
                        case 'char'
                            str = sprintf('%s%s\t', str, y{i,j});
                        case 'numeric'
                            str = sprintf('%s%f\t', str, y{i,j});
                        otherwise
                            str = sprintf('%s%s\t', str, y{i,j});
                    end
                    
                end
                
                if i == size(y,1)
                    str = sprintf('%s', str);
                else
                    str = sprintf('%s\n', str);
                end
                
            end
            
            clipboard('copy', str);
            
            statusText = [statusText, 'COMPLETE'];
            obj.setStatusBarText(statusText);
            
        end
        
        % ---------------------------------------
        % MD5 Checksum
        % ---------------------------------------
        function getFileChecksum(obj, row)
            
            if isempty(obj.data) || row < 1 || row > length(obj.data)
                return
            elseif isfield(obj.data, 'file_checksum') && ~isempty(obj.data(row).file_checksum)
                return
            end
            
            file = [obj.data(row).file_path, filesep, obj.data(row).file_name];
            str = getFileChecksum(file, 'hash', 'MD5', 'verbose', false);
            
            if iscell(str) && ~isempty(str{1})
                obj.data(row).file_checksum = str{1};
            end
            
        end
        
        % ---------------------------------------
        % Exit
        % ---------------------------------------
        function exit(obj, varargin)
            
            obj.closeRequest();
            
        end
        
    end
    
    methods (Hidden = true)
        
        % ---------------------------------------
        % GUI - select sample
        % ---------------------------------------
        function selectSample(obj, varargin)
            
            if ~isempty(obj.view.row) && obj.view.row ~= 0
                
                if length(varargin) == 1
                    increment = varargin{1};
                elseif length(varargin) == 3
                    increment = varargin{3};
                end
                
                obj.removeTableHighlightText(obj.view.row);
                nextIndex = obj.view.row + increment;
                
                if length(obj.data) == 1
                    return
                elseif nextIndex <= length(obj.data) && nextIndex >= 1
                    obj.view.row = nextIndex;
                elseif nextIndex > length(obj.data)
                    obj.view.row = 1;
                elseif nextIndex < 1
                    obj.view.row = length(obj.data);
                end
                
                numPeaks = obj.updateSample();

                % Check sample auto-step
                if ~isempty(numPeaks) && numPeaks ~= -1
                    peakAutoStep = 1;
                elseif ~any(obj.data(obj.view.row).intensity)
                    peakAutoStep = 1;
                else
                    peakAutoStep = 0;
                end
                
                if obj.settings.peakAutoStep && peakAutoStep
                    if obj.view.row < length(obj.data) && isempty([obj.peaks.time{obj.view.row+1,:}])
                        obj.selectSample(1);
                    end
                end
                
            end
            
        end
        
        % ---------------------------------------
        % GUI - update current sample
        % ---------------------------------------
        function numPeaks = updateSample(obj, varargin)

            obj.view.id = num2str(obj.view.row);
            obj.view.name = obj.data(obj.view.row).sample_name;
            
            statusText = ['Loading sample ', num2str(obj.view.row), '/', num2str(length(obj.data)), '... '];
            obj.setStatusBarText(statusText);
            
            obj.figure.CurrentObject = obj.axes.main;
            
            obj.updateSampleText();
            obj.updateAllPeakListText();
            obj.updatePeakText();
            obj.updatePlot();
            obj.addTableHighlightText();
            obj.userPeak(0);
            
            statusText = ['Loading sample ', num2str(obj.view.row), '/', num2str(length(obj.data)), '... COMPLETE'];
            obj.setStatusBarText(statusText);
            drawnow();
            
            % Peak auto-detection
            n = obj.view.col;
            
            if isempty([obj.peaks.time{obj.view.row,:}])
                numPeaks = obj.peakAutoDetectionCallback();
            else
                numPeaks = [];
            end
            
            obj.updateJavaScrollpane();
            
            obj.view.col = n;
            obj.controls.peakList.Value = obj.view.col;
            obj.updatePeakText();
            
        end
        
        % ---------------------------------------
        % GUI - clear peak data
        % ---------------------------------------
        function clearPeak(obj, varargin)
            
            row = obj.view.row;
            col = obj.view.col;
            isVerbose = false;
            
            if isempty(obj.data) || row == 0
                return
            end
            
            if ~isempty(varargin)
                if isnumeric(varargin{1})
                    col = varargin{1}(1);
                elseif islogical(varargin{1})
                    isVerbose = varargin{1};
                end 
            end
            
            if col <= 0 || col > length(obj.peaks.name)
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
                
                if isVerbose
                    statusText = ['Cleared ', obj.peaks.name{col}, ' peak data...'];
                    obj.setStatusBarText(statusText);
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Peak data - auto-detection (single peak)
        % ---------------------------------------
        function status = peakAutoDetection(obj, varargin)
            
            status = 1;
            row = obj.view.row;
            col = obj.view.col;
            
            if isempty(obj.peaks.name) || isempty(obj.data)
                return
            end
            
            if ~isempty(obj.peaks.time{row,col})
                if isempty(varargin)
                    return
                elseif isnumeric(varargin{1}) && ~varargin{1} == 1
                    return
                end
            elseif isempty([obj.peaks.time{:,col}])
                return
            end
            
            % Method filter
            str = obj.data(row).method_name;
            method = strcmpi(str, {obj.data.method_name});
            
            % Channel filter
            str = obj.data(row).channel;
            channel = {obj.data.channel};
            channel(cellfun(@isempty, channel)) = {''};
            channel(~cellfun(@ischar, channel)) = {''};
            channel = strcmpi(str, channel);
            
            % Sequence filter
            sequence = [];
            
            if isfield(obj.data, 'sequence_name')
                str = obj.data(row).sequence_name;
                
                if ~isempty(str)
                    sequence = {obj.data.sequence_name};
                    sequence(cellfun(@isempty, sequence)) = {''};
                    sequence = strcmpi(str, sequence);
                end
                
            end
            
            if isempty(sequence) && isfield(obj.data, 'sequence_path')
                str = obj.data(row).sequence_path;
                
                if ~isempty(str)
                    sequence = {obj.data.sequence_path};
                    sequence(cellfun(@isempty, sequence)) = {''};
                    sequence = strcmpi(str, sequence);
                end
                
            end
            
            if isempty(sequence)
                sequence = true(1, length(obj.data));
            end
            
            % Date filter
            minDays = 7;
            dateoffset = abs(obj.data(row).datevalue - [obj.data.datevalue]);
            datevalue = dateoffset <= minDays;
            
            % Group filter
            if length(method) == length(channel)
                
                if length(method) == length(sequence)
                    group = method & channel & sequence;
                else
                    group = method & channel;
                end
                
            else
                return
            end
            
            % Median retention time
            if isempty(group) || ~any(group)
                return
                
            elseif length(group) == size(obj.peaks.time,1)
                
                % New sequence filter
                if isempty([obj.peaks.time{group,col}])
                    group = method & channel & datevalue;
                end
                
                % Existing retention times
                xf = ~cellfun(@isempty, obj.peaks.time(group,col));
                
                if any(xf)
                    
                    % Sort by nearest date
                    x0 = dateoffset(group);
                    x0 = x0(xf);
                    
                    t0 = obj.peaks.time(group,col);
                    t0 = cell2mat(t0(xf));
                    
                    [~,ii] = sort(x0, 'ascend');
                    
                    x0 = round(x0(ii));
                    t0 = t0(ii);
                    
                    x1 = unique(x0);
                    time = t0(x0 == x1(1));
                    
                else
                    time = [obj.peaks.time{group,col}];
                end
                
                numValues = 3;
                
                if length(time) > numValues
                    time = time(1:numValues);
                end
                
                x = median(time);
                
            else
                return
            end
            
            % Get peak data
            if ~isnan(x)
                obj.peakTimeSelectCallback([], x);
            else
                return
            end
            
            % Check peak data
            minArea   = 0.40;
            minHeight = 0.10;
            minError  = 150;
            
            if ~isempty(obj.peaks.area{row,col})
                
                peakArea   = obj.peaks.area{row,col};
                peakWidth  = obj.peaks.width{row,col};
                peakHeight = obj.peaks.height{row,col};
                peakError  = obj.peaks.error{row,col};
                
                AW = peakArea / peakWidth;
                HW = peakHeight / peakWidth;
                
                if AW <= 100 && (HW < AW * 0.08263 - 0.25 || HW > AW * 0.22465 + 0.7)
                    obj.clearPeak();
                elseif peakArea <= 0.1 || peakHeight <= 0.05
                    obj.clearPeak();
                elseif peakArea <= minArea && peakError > 15
                    obj.clearPeak();
                elseif peakHeight <= minHeight && peakError > 15
                    obj.clearPeak();
                elseif peakError >= minError
                    obj.clearPeak();
                elseif length([obj.peaks.time{row,:}]) > 1
                    
                    dx = cellfun(@(x) x - obj.peaks.time{row,col},...
                        obj.peaks.time(row,:), 'uniformoutput', 0);
                    
                    dx = cellfun(@(x) abs(x) <= 1E-2,...
                        dx, 'uniformoutput', 0);
                    
                    if sum([dx{:}]) > 1
                        
                        for i = 1:length(dx)
                            
                            if i == col
                                continue
                            end
                            
                            if dx{i}
                                
                                % Check for duplicate
                                a0 = obj.peaks.area{row,col};
                                a1 = obj.peaks.area{row,i};
                                
                                if abs(a0-a1) <= mean([a0,a1]) * 1E-2
                                    
                                    t0 = obj.peaks.time{row,col};
                                    t1 = obj.peaks.time{row,i};
                                    
                                    y = median([obj.peaks.time{group,i}]);
                                    
                                    if abs(t0-x) >= abs(t1-y)
                                        obj.clearPeak();
                                    else
                                        obj.clearPeak(i);
                                        obj.view.col = col;
                                    end
                                    
                                    break
                                    
                                end
                                
                            end
                        end
                        
                    end
                    
                    drawnow();
                    
                else
                    drawnow();
                end
                
            end
            
            status = 0;
            
        end
        
        % ---------------------------------------
        % Peak data - auto-detection (all peaks)
        % ---------------------------------------
        function numPeaks = peakAutoDetectionCallback(obj, varargin)
            
            numPeaks = [];
            
            if isempty(obj.data) || isempty(obj.peaks.name)
                return
            elseif ~obj.settings.peakAutoDetect
                return
            elseif ~isempty([obj.peaks.time{obj.view.row,:}])
                return
            else
                peakStatus = 0;
                numPeaks = 0;
            end
            
            if obj.settings.selectZoom
                obj.userZoom(0);
            end
            
            set(obj.figure, 'KeyPressFcn', {@obj.keyboardInterruptCallback, 2});
            
            % Peak auto-detection
            obj.setStatusBarText('Running peak auto-detection... ');
            
            for i = 1:length(obj.peaks.name)
                
                if obj.menu.peakOptionsAutoDetect.UserData == 2
                    numPeaks = -1;
                    obj.menu.peakOptionsAutoDetect.UserData = obj.settings.peakAutoDetect;
                    return
                end
                
                peakStatus = peakStatus + obj.peakAutoDetection();
                
                if peakStatus == 0
                    numPeaks = numPeaks + 1;
                end
                
                if obj.view.col + 1 > length(obj.peaks.name)
                    obj.view.col = 1;
                else
                    obj.view.col = obj.view.col + 1;
                end

                if peakStatus == length(obj.peaks.name)
                    numPeaks = -1;
                    obj.keyboardInterruptCallback(1);
                    obj.setStatusBarText('Peak auto-detection not available. Please select peaks for current sample... ');
                    return
                end
                
            end
            
            % Refresh peak textbox
            obj.keyboardInterruptCallback(1);
            obj.updatePeakText();
            obj.userPeak(0);
            
            obj.setStatusBarText('Running peak auto-detection... COMPLETE');
            
        end
        
        % ---------------------------------------
        % GUI - status bar
        % ---------------------------------------
        function setStatusBarText(obj, varargin)
            
            if ~isempty(obj.statusbar)
                
                if ~isempty(varargin) && ischar(varargin{1})
                    str = varargin{1};
                else
                    str = ' ';
                end
                
                if ~isempty(str)
                    str = ['[', obj.getTime, '] ', str];
                end
                
                obj.statusbar.setText(str);
                
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
            obj.initializeStatusBar();
            
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
        
        function selectPeak(obj, varargin)
            
            if ~isempty(obj.view.col) && obj.view.col ~= 0
                
                if ~isempty(varargin) && isnumeric(varargin{1})
                    increment = varargin{1};
                else
                    increment = 0;
                end
                
                index = obj.view.col + increment;
                
                if length(obj.peaks.name) == 1
                    return
                elseif index <= length(obj.peaks.name) && index >= 1
                    obj.view.col = index;
                elseif index > length(obj.peaks.name)
                    obj.view.col = 1;
                elseif index < 1
                    obj.view.col = length(obj.peaks.name);
                end

                if increment ~= 0
                    
                    obj.figure.CurrentObject = obj.controls.peakList;
                    obj.controls.peakList.Value = obj.view.col;
                    obj.updatePeakText();
                    
                    if obj.view.selectPeak
                        statusText = ['Selecting ', obj.peaks.name{obj.view.col}, ' peak...'];
                        obj.setStatusBarText(statusText);
                    else
                        obj.userPeak(1);
                    end
                    
                end
                
            end
            
        end
        
        function addTableHighlightText(obj, varargin)
            
            width = cell2mat(obj.table.main.ColumnWidth);
            fmt = obj.table.main.ColumnFormat;
            row = obj.view.row;
            col = length(fmt);
            
            if row < 1 || isempty(obj.table.main.Data)
                return
            elseif col > size(obj.table.main.Data,2)
                obj.table.main.Data{end,col} = [];
            end
            
            x = obj.table.main.Data(row,:);
            
            str = ['<html><body ',...
                'bgcolor="', obj.settings.table.highlightColor, '" ',...
                'text="',    obj.settings.table.highlightText, '" ',...
                'width="'];
            
            for i = 1:length(x)
                
                switch fmt{i}
                    
                    case 'char'
                        
                        if isempty(x{i})
                            x{i} = '';
                        elseif i > obj.settings.table.minColumns
                            if ~isnan(str2double(x{i}))
                                x{i} = sprintf('%.4f', str2double(x{i}));
                            end
                        end
                        
                        x{i} = [str, '1000">', x{i}, '&nbsp</html>'];
                        
                    case 'numeric'
                        
                        if ~isempty(x{i}) && ischar(x{i})
                            x{i} = str2double(x{i});
                        end
                        
                        if isempty(x{i}) || ~isnumeric(x{i}) || isnan(x{i})
                            x{i} = '';
                        elseif i > obj.settings.table.minColumns
                            x{i} = sprintf('%.4f', x{i});
                        else
                            x{i} = num2str(x{i});
                        end
                        
                        n = [num2str(width(i)), '" align="right">'];
                        x{i} = [str, n, x{i}, '&nbsp</html>'];
                        
                end
                
            end
            
            if obj.settings.other.useJavaTable && ~isempty(obj.java.table)
                
                for i = 1:length(x)
                    obj.java.table.setValueAt(java.lang.String(x{i}), row-1, i-1);
                end
                
            else
                obj.table.main.Data(row,:) = x;
            end
            
        end
        
        function addCellHighlightText(obj, row, col)
            
            if row < 1 || isempty(obj.table.main.Data)
                return
            elseif row > size(obj.table.main.Data,1)
                obj.table.main.Data{row,1} = [];
            end
            
            if col > size(obj.table.main.Data,2)
                obj.table.main.Data{end,col} = [];
            end
            
            width = obj.table.main.ColumnWidth{col};
            fmt = obj.table.main.ColumnFormat{col};
            
            x = obj.table.main.Data{row,col};
            
            str = ['<html><body ',...
                'bgcolor="', obj.settings.table.highlightColor, '" ',...
                'text="',    obj.settings.table.highlightText, '" ',...
                'width="'];
            
            switch fmt
                
                case 'char'
                    
                    if isempty(x)
                        x = '';
                    elseif col > obj.settings.table.minColumns
                        if ~isnan(str2double(x))
                            x = sprintf(obj.settings.table.precision, str2double(x));
                        end
                    end
                    
                    x = [str, '1000">', x, '&nbsp</html>'];
                    
                case 'numeric'
                    
                    if ~isempty(x) && ischar(x)
                        x = str2double(x);
                    end
                    
                    if isempty(x) || ~isnumeric(x) || isnan(x)
                        x = '';
                    elseif col > obj.settings.table.minColumns
                        x = sprintf('%.4f', x);
                    else
                        x = num2str(x);
                    end
                    
                    n = [num2str(width), '" align="right">'];
                    x = [str, n, x, '&nbsp</html>'];
                    
            end
            
            if obj.settings.other.useJavaTable && ~isempty(obj.java.table)
                obj.java.table.setValueAt(java.lang.String(x), row-1, col-1);
            else
                obj.table.main.Data{row, col} = x;
            end
            
        end
        
        function removeTableHighlightText(obj, varargin)
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                row = varargin{1};
            else
                row = obj.view.row;
            end
            
            fmt = obj.table.main.ColumnFormat;
            col = length(fmt);
            
            if isempty(obj.table.main.Data)
                return
            elseif row < 1 || row > length(obj.data)
                return
            elseif col > size(obj.table.main.Data,2)
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
                
                if ~isempty(str) && strcmpi(fmt{i}, 'numeric')
                    str = str2double(str);
                    if isnan(str)
                        str = [];
                    end
                end
                
                x{i} = str;
                
            end
            
            if obj.settings.other.useJavaTable && ~isempty(obj.java.table)
                
                for i = 1:length(x)
                    obj.java.table.setValueAt(java.lang.String(x{i}), row-1, i-1);
                end
                
            else
                obj.table.main.Data(row,:) = x;
            end
            
        end
        
        function updateSampleText(obj, varargin)
            
            obj.controls.editID.String = obj.view.id;
            obj.controls.editName.String = obj.view.name;
            
        end
        
        function updatePeakListText(obj, varargin)
            
            if isempty(obj.controls.peakList.String)
                return
            elseif ~obj.view.col
                return
            elseif size(obj.peaks.time, 1) < obj.view.row
                return
            end
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                col = varargin{1};
            else
                col = obj.view.col;
            end
            
            if col < 1 || col > length(obj.peaks.name)
                return
            end
            
            row = obj.view.row;
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
            elseif ~obj.view.col
                return
            elseif size(obj.peaks.time, 1) < length(obj.data)
                return
            elseif size(obj.peaks.time, 2) < length(obj.controls.peakList.String)
                return
            end
            
            for i = 1:length(obj.controls.peakList.String)
                
                if obj.view.row == 0
                    str = obj.peaks.name{i};
                elseif ~isempty(obj.peaks.time{obj.view.row,i})
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
            
            row = obj.view.row;
            col = obj.view.col;
            
            if ~isempty(col) && col ~= 0 && length(obj.peaks.name) >= col
                obj.view.peakName = obj.peaks.name{col};
            else
                obj.view.peakName = '';
            end
            
            obj.controls.peakIDEdit.String = obj.view.peakName;
            
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
                obj.view.plotLabel.String = '';
            end
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPlotLabel
                return
            else
                row = obj.view.row;
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
                
                if any(ishandle(obj.view.plotLabel))
                    
                    set(obj.view.plotLabel,...
                        'string', str,...
                        'position', [x, y, 0],...
                        'fontsize', obj.settings.labels.fontsize,...
                        'fontname', obj.settings.labels.fontname,...
                        'margin',   obj.settings.labels.margin);
                    
                else
                    
                    obj.view.plotLabel = text(x, y, str,...
                        'parent',   obj.axes.main,...
                        'clipping', 'on',...
                        'hittest',  'off',...
                        'tag',      'plotLabel',...
                        'fontsize', obj.settings.labels.fontsize,...
                        'fontname', obj.settings.labels.fontname,...
                        'margin',   obj.settings.labels.margin,...
                        'units',    'data',...
                        'pickableparts',       'none',...
                        'horizontalalignment', 'right',...
                        'verticalalignment',   'bottom',...
                        'selectionhighlight',  'off');
                    
                end
                
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
            
            if isempty(obj.data) || obj.view.row == 0
                return
            end
            
            if isfield(obj.data, 'intensity_units')
                str = obj.data(obj.view.row).intensity_units;
            else
                str = '';
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
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakLine
                return
            else
                row = obj.view.row;
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
                        
                        set(obj.view.peakLine{col(i)},...
                            'xdata',     x,...
                            'ydata',     y,...
                            'color',     obj.settings.peaks.color,...
                            'linewidth', obj.settings.peaks.linewidth);
                        
                    else
                        
                        obj.view.peakLine{col(i)} = plot(x, y,...
                            'parent',    obj.axes.main,...
                            'color',     obj.settings.peaks.color,...
                            'linewidth', obj.settings.peaks.linewidth,...
                            'visible',   'on',...
                            'hittest',   'off',...
                            'tag',       'peakLine');
                        
                    end
                end
            end
            
        end
        
        function updatePeakArea(obj, varargin)
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakArea
                return
            else
                row = obj.view.row;
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
                        
                        set(obj.view.peakArea{col(i)},...
                            'xdata',     xArea,...
                            'ydata',     yArea,...
                            'facecolor', obj.settings.peakFill.color,...
                            'facealpha', obj.settings.peakFill.alpha);
                        
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
                            'tag',       'peakArea');
                        
                    end
                end
            end
            
        end
        
        function updatePeakBaseline(obj, varargin)
            
            if isempty(obj.data) || obj.view.row == 0
                return
            elseif ~obj.settings.showPeaks || ~obj.settings.showPeakBaseline
                return
            else
                row = obj.view.row;
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
                        
                        set(obj.view.peakBaseline{col(i)},...
                            'xdata',      x,...
                            'ydata',      y,...
                            'color',      obj.settings.peakBaseline.color,...
                            'markersize', obj.settings.peakBaseline.markersize,...
                            'linewidth',  obj.settings.peakBaseline.linewidth);
                        
                    else
                        
                        obj.view.peakBaseline{col(i)} = plot(x, y, '-',...
                            'parent',     obj.axes.main,...
                            'color',      obj.settings.peakBaseline.color,...
                            'markersize', obj.settings.peakBaseline.markersize,...
                            'linewidth',  obj.settings.peakBaseline.linewidth,...
                            'visible',    'on',...
                            'hittest',    'off',...
                            'tag',        'peakBaseline');
                        
                    end
                    
                end
            end
            
        end
        
        function updatePlotBaseline(obj, varargin)
            
            if ~obj.settings.showPlotBaseline
                return
            elseif isempty(obj.data) || obj.view.row == 0
                return
            end
            
            if isempty(obj.data(obj.view.row).baseline)
                obj.getBaseline();
            end
            
            if ~isempty(obj.data(obj.view.row).baseline) && size(obj.data(obj.view.row).baseline,2) == 2
                
                x = obj.data(obj.view.row).baseline(:,1);
                y = obj.data(obj.view.row).baseline(:,2);
                
                if any(ishandle(obj.view.plotBaseline))
                    
                    set(obj.view.plotBaseline,...
                        'xdata',     x,...
                        'ydata',     y,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth);
                    
                else
                    
                    obj.view.plotBaseline = plot(x, y,...
                        'parent',    obj.axes.main,...
                        'color',     obj.settings.baseline.color,...
                        'linewidth', obj.settings.baseline.linewidth,...
                        'visible',   'on',...
                        'tag',       'plotBaseline');
                    
                end
                
            else
                obj.clearLine('plotBaseline');
            end
            
        end
        
        function appendTableData(obj, varargin)
            
            if isempty(obj.data)
                return
            end
            
            row = size(obj.table.main.Data, 1) + 1;
            
            obj.table.main.Data{row,1}  = obj.data(end).file_path;
            obj.table.main.Data{row,2}  = obj.data(end).file_name;
            obj.table.main.Data{row,3}  = obj.data(end).datetime;
            obj.table.main.Data{row,4}  = obj.data(end).instrument;
            obj.table.main.Data{row,6}  = obj.data(end).method_name;
            obj.table.main.Data{row,7}  = obj.data(end).operator;
            obj.table.main.Data{row,8}  = obj.data(end).sample_name;
            obj.table.main.Data{row,9}  = obj.data(end).sample_info;
            obj.table.main.Data{row,10} = obj.data(end).seqindex;
            obj.table.main.Data{row,11} = obj.data(end).vial;
            obj.table.main.Data{row,12} = obj.data(end).replicate;
            
            if isfield(obj.data, 'sequence_name')
                obj.table.main.Data{row,5} = obj.data(end).sequence_name;
            end
            
            if isfield(obj.data, 'injvol') && ~isempty(obj.data(end).injvol)
                obj.table.main.Data{row,13} = num2str(obj.data(end).injvol);
            end
            
        end
        
        function clearTableData(obj, varargin)
            
            obj.table.main.Data = [];
            
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
            
            str = obj.settings.peakFields;
            
            for i = 1:length(str)
                
                if strcmpi(str{i}, 'name')
                    continue
                end
                
                if isfield(obj.peaks, str{i})
                    obj.peaks.(str{i}){row,col} = [];
                end
                
            end
            
        end
        
        function updatePeakData(obj, row, col, peak)
            
            obj.peaks.time{row,col}   = peak.time;
            obj.peaks.width{row,col}  = peak.width;
            obj.peaks.height{row,col} = peak.height;
            obj.peaks.area{row,col}   = peak.area;
            obj.peaks.error{row,col}  = peak.error;
            obj.peaks.fit{row,col}    = peak.fit;
            
            if isfield(peak, 'areaOf')
                obj.peaks.areaOf{row,col} = peak.areaOf;
            else
                obj.peaks.areaOf{row,col} = obj.settings.peakAreaOf;
            end
            
            if isfield(peak, 'model')
                obj.peaks.model{row,col} = peak.model;
            else
                obj.peaks.model{row,col} = [];
            end
            
            if isfield(peak, 'revision')
                obj.peaks.model{row,col} = [obj.peaks.model{row,col}, '_', peak.revision];
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
            
            if isfield(peak, 'input_x')
                obj.peaks.input_x{row,col} = peak.input_x;
            end
            
            if isfield(peak, 'input_y')
                obj.peaks.input_y{row,col} = peak.input_y;
            end
            
            if isfield(peak, 'input_mode')
                obj.peaks.input_mode{row,col} = peak.input_mode;
            end
            
            if isfield(peak, 'date_created')
                obj.peaks.date_created{row,col} = peak.date_created;
            end
            
        end
        
        function clearPeakTable(obj, row, col)
            
            x = obj.settings.table.labelNames;
            m = obj.settings.table.minColumns;
            n = length(obj.peaks.name);
            
            xi = 0;
            
            for i = 1:length(x)
                
                if ~isfield(obj.settings.table, ['show', x{i}])
                    continue
                end
                
                if obj.settings.table.(['show', x{i}])
                    
                    idx = (col+m) + (n*xi);
                    
                    if obj.settings.other.useJavaTable
                        obj.java.table.setValueAt(' ', row-1, idx-1);
                    else
                        obj.table.main.Data{row, idx} = [];
                    end
                    
                    if obj.view.row == row
                        obj.addCellHighlightText(row, idx);
                    end
                    
                    xi = xi + 1;
                    
                end
            end
            
        end
        
        function updatePeakTable(obj, row, col)
            
            x = obj.settings.table.labelNames;
            m = obj.settings.table.minColumns;
            n = length(obj.peaks.name);
            
            xi = 0;
            
            for i = 1:length(x)
                
                if ~isfield(obj.settings.table, ['show', x{i}])
                    continue
                end
                
                if obj.settings.table.(['show', x{i}])
                    
                    str = obj.peaks.(lower(x{i})){row,col};
                    idx = (col+m) + (n*xi);
                    
                    if obj.settings.other.useJavaTable
                        
                        if isnumeric(str)
                            str = sprintf(obj.settings.table.precision, str);
                        elseif isempty(str) || ~ischar(str)
                            str = [];
                        end
                        
                        obj.java.table.setValueAt(str, row-1, idx-1);
                        
                    else
                        obj.table.main.Data{row, idx} = str;
                    end
                    
                    if obj.view.row == row
                        obj.addCellHighlightText(row, idx);
                    end
                    
                    xi = xi + 1;
                    
                end
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
                
                if isempty(obj.view.peakLabel{col}.String)
                    return
                elseif isprop(obj.view.peakLabel{col}, 'extent')
                    
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
                
                obj.view.peakLabel{col}.String = '';
                
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
                        set(x, 'string', '');
                    end
                    
                end
                
            end
            
        end
        
        function deletePlotObject(obj, str, col)
            
            if ~isfield(obj.view, str)
                return
            end
            
            if length(obj.view.(str)) >= col
                
                if any(ishandle(obj.view.(str){col}))
                    delete(obj.view.(str){col});
                end
                
                obj.view.(str)(col) = [];
                
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
            
            obj.updateTableHeader();
            obj.updateTableProperties();
            obj.updateTablePeakData();
            
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
            
            m = obj.settings.table.minColumns;
            n = length(obj.peaks.name);
            
            x = obj.settings.table.labelNames;
            
            for i = 1:nRow
                
                % Sample information
                obj.table.main.Data{i,1}  = obj.data(i).file_path;
                obj.table.main.Data{i,2}  = obj.data(i).file_name;
                obj.table.main.Data{i,3}  = obj.data(i).datetime;
                obj.table.main.Data{i,4}  = obj.data(i).instrument;
                obj.table.main.Data{i,6}  = obj.data(i).method_name;
                obj.table.main.Data{i,7}  = obj.data(i).operator;
                obj.table.main.Data{i,8}  = obj.data(i).sample_name;
                obj.table.main.Data{i,9}  = obj.data(i).sample_info;
                obj.table.main.Data{i,10} = obj.data(i).seqindex;
                obj.table.main.Data{i,11} = obj.data(i).vial;
                obj.table.main.Data{i,12} = obj.data(i).replicate;
                
                if isfield(obj.data, 'sequence_name')
                    obj.table.main.Data{i,5} = obj.data(i).sequence_name;
                end
                
                if isfield(obj.data, 'injvol') && ~isempty(obj.data(i).injvol)
                    obj.table.main.Data{i,13} = num2str(obj.data(i).injvol);
                end
                
                % Peak data
                for j = 1:nCol
                    
                    xi = 0;
                    
                    for k = 1:length(x)
                        
                        if ~isfield(obj.settings.table, ['show', x{k}])
                            continue
                        end
                        
                        if obj.settings.table.(['show', x{k}])
                            
                            str = obj.peaks.(lower(x{k})){i,j};
                            idx = (j+m) + (n*xi);
                            
                            obj.table.main.Data{i,idx} = str;
                            
                            xi = xi + 1;
                            
                        end
                    end
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Java - set scrollpane position
        % ---------------------------------------
        function updateJavaScrollpane(obj, varargin)
            
            if ~obj.settings.java.fixTableScrollpane
                return
            elseif isempty(obj.table.main.Data)
                return
            elseif ~isfield(obj.java, 'table') || isempty(obj.java.table)
                return
            elseif ~ismethod(obj.java.table, 'changeSelection')
                return
            end
            
            drawnow();
            
            if ismethod(obj.java.table, 'getRowCount')
                numRows = obj.java.table.getRowCount;
            else
                numRows = length(obj.data);
            end
            
            rowNum = obj.view.row - 1;
            
            try
                if rowNum <= numRows
                    obj.java.table.changeSelection(rowNum, 0, 0, 0);
                end
            catch
            end
            
        end
        
        % ---------------------------------------
        % Callback - zoom event
        % ---------------------------------------
        function zoomCallback(obj, varargin)
            
            if obj.view.row ~= 0
                
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
        
        % ---------------------------------------
        % Callback - user zoom selection
        % ---------------------------------------
        function userZoom(obj, state, varargin)
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                state = varargin{1};
            elseif obj.settings.selectZoom == state
                return
            end
            
            switch state
                
                case 0
                    
                    obj.settings.selectZoom    = 0;
                    obj.settings.showZoom      = 'off';
                    obj.axes.zoom.Enable       = 'off';
                    obj.menu.view.zoom.Checked = 'off';

                    set(obj.figure, 'Pointer', 'arrow');
                    set(obj.figure, 'WindowKeyPressFcn', @obj.keyboardCallback);
                    set(obj.figure, 'WindowButtonMotionFcn', @obj.figureMotionCallback);
                    
                case 1
                    
                    obj.settings.selectZoom    = 1;
                    obj.settings.showZoom      = 'on';
                    obj.axes.zoom.Enable       = 'on';
                    obj.menu.view.zoom.Checked = 'on';
                    
                    x = uigetmodemanager(obj.figure);
                    
                    try
                        set(x.WindowListenerHandles, 'Enable', 'off');
                    catch
                        [x.WindowListenerHandles.Enabled] = deal(false);
                    end
                    
                    set(obj.figure, 'KeyPressFcn', []);
                    set(obj.figure, 'WindowKeyPressFcn', @obj.keyboardCallback);
                    
            end
            
        end
        
        % ---------------------------------------
        % Callback - user peak selection
        % ---------------------------------------
        function userPeak(obj, state, varargin)
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                state = varargin{1};
            elseif obj.view.selectPeak == state
                return
            elseif isempty(obj.data) || isempty(obj.peaks.name)
                return
            end
            
            switch state
                
                case 0
                    
                    obj.view.selectPeak = 0;
                    obj.controls.selectPeak.Value = 0;
                    obj.settings.peakOverride = 0;
                    
                    if obj.settings.selectZoom
                        obj.userZoom(1);
                    end
                    
                    set(obj.figure, 'Pointer', 'arrow');
                    set(obj.axes.main, 'ButtonDownFcn', '');
                    
                case 1
                    
                    obj.view.selectPeak = 1;
                    obj.controls.selectPeak.Value = 1;
                    
                    if obj.settings.selectZoom
                        obj.userZoom(0);
                    end
                    
                    if obj.settings.peakOverride
                        cursorType = 'cross';
                    else
                        cursorType = 'circle';
                    end
                    
                    set(obj.figure, 'Pointer', cursorType);
                    set(obj.axes.main, 'ButtonDownFcn', @obj.peakTimeSelectCallback);

                    statusText = ['Selecting ', obj.peaks.name{obj.view.col}, ' peak...'];
                    obj.setStatusBarText(statusText);
                
            end
            
        end
        
        % ---------------------------------------
        % Callback - mouse peak selection
        % ---------------------------------------
        function peakTimeSelectCallback(obj, ~, evt)
            
            if isprop(evt, 'EventName')
                
                if strcmpi(evt.EventName, 'Hit')
                    
                    x = evt.IntersectionPoint(1);
                    y = evt.IntersectionPoint(2);
                    
                    if obj.view.row == 0 || isempty(obj.peaks.name)
                        obj.clearPeak();
                    elseif x > obj.settings.xlim(1) && x < obj.settings.xlim(2)
                        obj.toolboxPeakFit(x, y, 'selectionType', 'manual');
                    end
                    
                    obj.userPeak([], 0);
                    
                else
                    obj.userPeak(0);
                end
                
            elseif isnumeric(evt)
                
                x = evt;
                y = 0;
                
                if obj.view.row == 0 || isempty(obj.peaks.name)
                    obj.clearPeak();
                else
                    obj.toolboxPeakFit(x, y, 'selectionType', 'auto');
                end
                
            end
            
        end
        
        % ---------------------------------------
        % Callback - mouse double click
        % ---------------------------------------
        function tableButtonDownCallback(obj, ~, evt)
            
            if ~ismethod(evt, 'getButton')
                return
            elseif ~ismethod(evt, 'getClickCount')
                return
            end
            
            if evt.getButton == 1 && evt.getClickCount == 2
                
                if isempty(obj.table.selection)
                    return
                end
                
                idx = obj.view.row;
                row = obj.table.selection(1,1);
                
                if row == idx
                    return
                elseif row >= 1 && row <= length(obj.data)
                    obj.selectSample(row-idx);
                end
                
            end
            
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
        % Callback - keyboard interrupt
        % ---------------------------------------
        function keyboardInterruptCallback(obj, varargin)
            
            %obj.figure.WindowKeyPressFcn = @obj.keyboardCallback;
            obj.figure.KeyPressFcn = [];
            drawnow();
            
            if ~isempty(varargin)
                
                if length(varargin) == 3
                    x = varargin{3};
                elseif length(varargin) == 1
                    x = varargin{1};
                end
                
                obj.menu.peakOptionsAutoDetect.UserData = x;
                
                if x ~= 1
                    statusText = 'Peak auto-detection interrupted by keyboard... ';
                    obj.setStatusBarText(statusText);
                end
                
            end
            
            if strcmpi(obj.menu.view.zoom.Checked, 'on') && ~obj.settings.selectZoom
                obj.userZoom(1);
            end
           
        end
        
        % ---------------------------------------
        % Callback - keyboard shortcut
        % ---------------------------------------
        function keyboardCallback(obj, ~, evt)
            
            % CurrentObject: table
            if any(isprop(obj.figure.CurrentObject, 'tag'))
                if strcmpi(obj.figure.CurrentObject.Tag, 'datatable')
                    return
                end
            end
            
            % CurrentObject: slider, edit text
            if isprop(obj.figure.CurrentObject, 'style')
                if any(strcmpi(obj.figure.CurrentObject.Style, {'edit', 'slider'}))
                    return
                end
            end
            
            % Peak Auto-Detection in progress
            if ~isempty(obj.figure.KeyPressFcn)
                return
            end
            
            switch evt.Key
                
                % 'tab' - switch between 'view' and 'integrate' panels
                case 'tab'
                    
                    if isempty(evt.Modifier)
                        obj.selectTab();
                    end
                
                % 'CTRL-C'/'CMD-C' - copy figure to clipboard
                case 'c'
                    
                    if ~isempty(evt.Modifier) && obj.view.row
                        
                        if strcmpi(evt.Modifier{:}, 'command') && ismac
                            obj.copyFigure();
                        elseif strcmpi(evt.Modifier{:}, 'control') && ~ismac
                            obj.copyFigure();
                        end
                        
                    end
                    
                % 'up-arrow' - previous selection in peak list
                case obj.settings.keyboard.previousPeak
                    
                    if isempty(evt.Modifier)
                        obj.selectPeak(-1);
                    end
                    
                % 'down-arrow' - next selection in peak list
                case obj.settings.keyboard.nextPeak

                    if isempty(evt.Modifier)
                        obj.selectPeak(1);
                    end
                    
                % 'left-arrow' - previous selection in sample list
                case obj.settings.keyboard.previousSample
                    
                    if isempty(evt.Modifier)
                        obj.selectSample(-1);
                    end
                    
                % 'right-arrow' - next selection in sample list
                case obj.settings.keyboard.nextSample
                    
                    if isempty(evt.Modifier)
                        obj.selectSample(1);
                    end
                    
                % 'space' - toggle peak selection mode
                case obj.settings.keyboard.selectPeak
                    
                    if isempty(evt.Modifier)
                    
                        obj.setStatusBarText('');
                        
                        if obj.view.selectPeak && ~obj.settings.peakOverride
                            obj.userPeak(0);
                            obj.figure.CurrentObject = obj.axes.main;
                        else
                            obj.settings.peakOverride = 0;
                            obj.userPeak([],1);
                            obj.figure.CurrentObject = obj.controls.peakList;
                        end
                        
                    end
                    
                % 'o' - toggle peak override selection mode
                case obj.settings.keyboard.selectPeakOverride
                    
                    if isempty(evt.Modifier)
                        
                        obj.setStatusBarText('');
                        obj.settings.peakOverride = ~obj.settings.peakOverride;
                        
                        if obj.view.selectPeak && ~obj.settings.peakOverride
                            obj.userPeak(0);
                            obj.figure.CurrentObject = obj.axes.main;
                        else
                            obj.userPeak([],1);
                            obj.figure.CurrentObject = obj.controls.peakList;
                        end
                        
                    end
                    
                % 'backspace' - clear current peak data
                case obj.settings.keyboard.clearPeak
                    
                    if isempty(evt.Modifier)
                        obj.clearPeak(true);
                    end
                    
                % 'r' - reset/clear peak data for current sample
                case obj.settings.keyboard.resetPeaks
                    
                    if isempty(evt.Modifier)
                        
                        str = 'Clearing peak data for current sample...';
                        obj.setStatusBarText(str);

                        for i = 1:length(obj.peaks.name)
                            
                            obj.clearPeak();
                            
                            if obj.view.col + 1 > length(obj.peaks.name)
                                obj.view.col = 1;
                            else
                                obj.view.col = obj.view.col + 1;
                            end
                            
                        end
                        
                        obj.updatePeakText();
                                                
                        str = [str, ' COMPLETE'];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 'p' - redo peak auto-detection for current sample
                case obj.settings.keyboard.reprocessPeaks
                    
                    if isempty(evt.Modifier)
                        
                        n = obj.view.col;
                        x = obj.settings.peakAutoStep;
                        y = obj.settings.peakAutoDetect;
                        
                        obj.settings.peakAutoStep = 0;
                        obj.settings.peakAutoDetect = 1;
                        
                        for i = 1:length(obj.peaks.name)
                            
                            obj.clearPeak();
                            
                            if obj.view.col + 1 > length(obj.peaks.name)
                                obj.view.col = 1;
                            else
                                obj.view.col = obj.view.col + 1;
                            end
                            
                        end
                        
                        obj.peakAutoDetectionCallback();
                        
                        obj.view.col = n;
                        obj.settings.peakAutoStep = x;
                        obj.settings.peakAutoDetect = y;
                        
                        if obj.view.col ~= obj.controls.peakList.Value
                            obj.controls.peakList.Value = obj.view.col;
                        end
                        
                        obj.updatePeakText();
            
                    end
                    
                % 'm' - change peak model
                case obj.settings.keyboard.selectPeakModel
                    
                    if isempty(evt.Modifier)
                        
                        x = obj.menu.peakOptionsModel.Children;
                        
                        for i = 1:length(x)
                            x(i).Checked = 'off';
                        end
                        
                        switch obj.settings.peakModel
                            case 'nn1'
                                obj.settings.peakModel = 'nn2';
                                obj.menu.peakNN2.Checked = 'on';
                            case 'nn2'
                                obj.settings.peakModel = 'egh';
                                obj.menu.peakEGH.Checked = 'on';
                            case 'egh'
                                obj.settings.peakModel = 'nn1';
                                obj.menu.peakNN1.Checked = 'on';
                        end
                        
                        str = ['Peak Model: ', upper(obj.settings.peakModel)];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 's' - toggle sample auto-stepping
                case obj.settings.keyboard.toggleAutoStep
                    
                    if isempty(evt.Modifier)
                        
                        obj.settings.peakAutoStep = ~obj.settings.peakAutoStep;
                        
                        if obj.settings.peakAutoStep
                            obj.menu.peakOptionsAutoStep.Checked = 'on';
                        else
                            obj.menu.peakOptionsAutoStep.Checked = 'off';
                        end
                        
                        str = ['Sample Auto-Step: ', obj.menu.peakOptionsAutoStep.Checked];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 'd' - toggle peak auto-detection
                case obj.settings.keyboard.toggleAutoDetect
                    
                    if isempty(evt.Modifier)
                        
                        obj.settings.peakAutoDetect = ~obj.settings.peakAutoDetect;
                        
                        if obj.settings.peakAutoDetect
                            obj.menu.peakOptionsAutoDetect.Checked = 'on';
                        else
                            obj.menu.peakOptionsAutoDetect.Checked = 'off';
                        end
                        
                        str = ['Peak Auto-Detection: ', obj.menu.peakOptionsAutoDetect.Checked];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 'z' - toggle zoom mode
                case obj.settings.keyboard.toggleZoom
                    
                    if isempty(evt.Modifier)
                        
                        obj.userZoom(~obj.settings.selectZoom);
                        
                        str = ['Manual Zoom: ', obj.menu.view.zoom.Checked];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 'x' - toggle manual/auto x-axis limits
                case obj.settings.keyboard.toggleXAxisMode
                    
                    if isempty(evt.Modifier)
                        
                        switch obj.settings.xmode
                            case 'manual'
                                obj.settings.xmode = 'auto';
                            case 'auto'
                                obj.settings.xmode = 'manual';
                        end
                        
                        obj.updateAxesLimitToggle();
                        obj.updateAxesLimits();
                        obj.updatePlotLabelPosition();
                        
                        str = ['X-Axis Mode: ', obj.settings.xmode];
                        obj.setStatusBarText(str);
                        
                    end
                    
                % 'y' - toggle manual/auto y-axis limits
                case  obj.settings.keyboard.toggleYAxisMode
                    
                    if isempty(evt.Modifier)
                        
                        switch obj.settings.ymode
                            case 'manual'
                                obj.settings.ymode = 'auto';
                            case 'auto'
                                obj.settings.ymode = 'manual';
                        end
                        
                        obj.updateAxesLimitToggle();
                        obj.updateAxesLimits();
                        obj.updatePlotLabelPosition();
                        
                        str = ['Y-Axis Mode: ', obj.settings.ymode];
                        obj.setStatusBarText(str);
                        
                    end
                    
            end

        end
        
        function initializeStatusBar(obj, varargin)
           
            try
                
                % Get Java root pane
                javaFrame = get(handle(obj.figure), 'JavaFrame');
                javaPanel = get(javaFrame, 'FigurePanelContainer');
                javaRootPane = javaPanel.getComponent(0).getRootPane;
                
                n = 10;
                
                while isempty(javaRootPane) && n > 0
                    drawnow; pause(0.001);
                    n = n - 1;
                    javaRootPane = javaPanel.getComponent(0).getRootPane;
                end
            
                obj.java.rootpane = javaRootPane.getTopLevelAncestor;
                
                % Get status bar
                if ~isempty(obj.java.rootpane)
                    obj.statusbar = obj.java.rootpane.getStatusBar;
                else
                    return
                end
                
                % Set status bar
                if isempty(obj.statusbar)
                    
                    obj.statusbar = com.mathworks.mwswing.MJStatusBar;
                    
                    javaProgressBar = javax.swing.JProgressBar;
                    javaProgressBar.setVisible(false);
                    
                    obj.statusbar.add(javaProgressBar, 'West');
                    obj.java.rootpane.setStatusBar(obj.statusbar);
                    
                else
                    return
                end
                
                obj.statusbar.setText(' ');
                javaRootPane.setStatusBarVisible(1);
                
                % Add status bar properties
                h = handle(obj.statusbar);
                s = {'CornerGrip', 'TextPanel', 'ProgressBar'};
                
                for i = 1:length(s)
                    
                    if ~isprop(h, s{i})
                        schema.prop(h, s{i}, 'mxArray');
                    end
                    
                    switch s{i}
                        case 'CornerGrip'
                            set(h, s{i}, h.getParent.getComponent(0));
                        case 'TextPanel'
                            set(h, s{i}, h.getComponent(0));
                        case 'ProgressBar'
                            set(h, s{i}, h.getComponent(1).getComponent(0));
                    end
                    
                end
                
            catch
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
        
        function validatePeakNames(obj, varargin)
            
            obj.peaks.name = obj.peaks.name(:);
            obj.peaks.name(~cellfun(@ischar, obj.peaks.name)) = {''};
            
        end
        
        function validatePeakData(obj, varargin)
            
            if ~isempty(varargin) && length(varargin) == 2
                rows = varargin{1};
                cols = varargin{2};
            else
                rows = length(obj.data);
                cols = length(obj.peaks.name);
            end
            
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
                    
                    obj.settings.gui.position = obj.figure.Position;
                    
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
            
            x = [];
            
            if isprop(0, 'Units')
                str = get(0, 'Units');
            else
                return
            end
            
            if ~strcmp(str, 'pixels')
                set(0, 'pixels');
            end
            
            if isprop(0, 'ScreenSize')
                x = get(0, 'ScreenSize');
            end
            
            if ~strcmp(str, 'pixels')
                set(0, str);
            end
            
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
            
            str = listfonts;
            
            if isprop(0, 'FixedWidthFontName')
                x = get(0, 'FixedWidthFontName');
            else
                x = 'FixedWidth';
            end
            
            fontPref = {'Avenir'; 'SansSerif'; 'Helvetica Neue';...
                'Lucida Sans Unicode'; 'Microsoft Sans Serif'; 'Arial'};
            
            for i = 1:length(fontPref)
                if any(strcmpi(fontPref{i}, str))
                    x = fontPref{i};
                    return
                end
            end
            
        end
        
        function x = getDatetime()
            
            x = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
            
        end
        
        function x = getTime()
            
            x = datestr(now(), 'HH:MM:SS');
            
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