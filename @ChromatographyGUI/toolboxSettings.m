function toolboxSettings(obj, ~, ~, varargin)

% Settings (struct) > v0.0.5
%
% version (char) : 'x.y.z.date'
% name (char)    : 'global_settings'
% data (struct)  : GUI settings

if isempty(varargin) || ~ischar(varargin{1})
    return
end

switch varargin{1}
    
    case {'initialize'}
        initalizeSettings(obj);
        
    case {'load_default', 'load_custom'}
        loadSettings(obj, varargin{1});
        
    case {'save_default'}
        autosaveSettings(obj, varargin{1});
        
    case {'save_custom'}
        saveSettings(obj, varargin{1});
        
    case {'apply'}
        applySettings(obj);
        
    otherwise
        return
        
end

end

function initalizeSettings(obj, varargin)

% Figure
obj.settings.gui.position = [0.05, 0.125, 0.90, 0.80];
obj.settings.gui.color    = [1.00, 1.00, 1.00];

% Table
obj.settings.table.backgroundColor = '#0950D0';
obj.settings.table.textColor       = '#FFFFFF';
obj.settings.table.columnWidth     = 110;
obj.settings.table.minColumns      = 13;
obj.settings.table.showArea        = 1;
obj.settings.table.showTime        = 1;
obj.settings.table.showWidth       = 1;
obj.settings.table.showHeight      = 1;
obj.settings.table.showModel       = 0;

obj.settings.table.labelNames = {...
    'Area',...
    'Height',...
    'Time',...
    'Width',...
    'Model'};

% Font
obj.settings.gui.fontname    = obj.font;
obj.settings.table.fontname  = obj.font;
obj.settings.axes.fontname   = obj.font;
obj.settings.labels.fontname = obj.font;

% Font Size
obj.settings.gui.fontsize    = 11;
obj.settings.table.fontsize  = 10;
obj.settings.axes.fontsize   = 11;
obj.settings.labels.fontsize = 11;

% Line Width
obj.settings.plot.linewidth         = 1.25;
obj.settings.baseline.linewidth     = 1.25;
obj.settings.peaks.linewidth        = 1.25;
obj.settings.peakBaseline.linewidth = 1.00;

% Line Color
obj.settings.plot.color         = [0.10, 0.10, 0.10];
obj.settings.baseline.color     = [0.99, 0.22, 0.17];
obj.settings.peaks.color        = [0.00, 0.30, 0.53];
obj.settings.peakFill.color     = [0.00, 0.30, 0.53];
obj.settings.peakBaseline.color = [0.95, 0.49, 0.69];

% Alpha
obj.settings.peakFill.alpha = 0.3;

% Markersize
obj.settings.peakBaseline.markersize = 5;

% Peak Label
obj.settings.labels.margin = 3;
obj.settings.labels.precision = '%.2f';

% Auto-Save
obj.settings.autosave = 1;

% Zoom Settings
obj.settings.showZoom = 'off';
obj.settings.selectZoom = 0;

% Axes Settings
obj.settings.xmode = 'auto';
obj.settings.ymode = 'auto';

obj.settings.xlim  = [0,1];
obj.settings.ylim  = [0,1];

obj.settings.xpad  = 0.02;
obj.settings.ypad  = 0.02;

% Plot Settings
obj.settings.showPlotLabel    = 1;
obj.settings.showPlotBaseline = 1;

obj.settings.showPeaks        = 1;
obj.settings.showPeakLine     = 0;
obj.settings.showPeakLabel    = 1;
obj.settings.showPeakArea     = 1;
obj.settings.showPeakBaseline = 1;

% Label Settings
obj.settings.labels.data = {...
    'row_num',...
    'instrument',...
    'datetime',...
    'sample_name'};

obj.settings.labels.peak = {
    'peakName'};

% Baseline Parameters
obj.settings.baseline.minSmoothness = 1;
obj.settings.baseline.maxSmoothness = 10;

obj.settings.baseline.minAsymmetry = -10;
obj.settings.baseline.maxAsymmetry = -1;

obj.settings.baseline.smoothness = 5.5;
obj.settings.baseline.asymmetry  = -5.5;

% Peak Integration Settings
obj.settings.peakModel = 'nn2';     % 'egh', 'nn1', 'nn2'
obj.settings.peakArea  = 'rawdata'; % 'rawdata', 'fitdata'

% Other Peak Settings
obj.settings.peakOverride = 0;
obj.settings.peakAutoDetect = 1;
obj.settings.peakAutoStep = 0;

% Peak Data Fields
obj.settings.peakFields = {...
    'name',...
    'time',...
    'width',...
    'height',...
    'area',...
    'areaOf',...
    'error',...
    'fit',...
    'model',...
    'xlim',...
    'ylim'};

% Other Options
obj.settings.other.asyncMode = 1;

% Keyboard Shortcuts
obj.settings.keyboard.selectPeak         = 'space';
obj.settings.keyboard.clearPeak          = 'backspace';
obj.settings.keyboard.previousPeak       = 'uparrow';
obj.settings.keyboard.nextPeak           = 'downarrow';
obj.settings.keyboard.previousSample     = 'leftarrow';
obj.settings.keyboard.nextSample         = 'rightarrow';
obj.settings.keyboard.selectPeakOverride = 'o';

end

function loadSettings(obj, mode, varargin)

switch mode
    
    case 'load_default'
        
        file = [...
            obj.toolbox_path, filesep,...
            obj.toolbox_config, filesep,....
            obj.default_settings];
        
        if exist(file, 'file')
            data = importMAT('file', file);
        else
            return
        end
        
    case 'load_custom'
        
        data = importMAT('path', obj.toolbox_path);
        
    otherwise
        return
        
end

if isempty(data) || ~isstruct(data) || ~isfield(data, 'user_settings')
    return
else
    data = data.user_settings;
end

if ~isfield(data, 'name') || ~strcmpi(data.name, 'global_settings')
    return
elseif ~isfield(data, 'data') || isempty(data.data)
    return
else
    verifySettings(obj, data.data);
end

end

function autosaveSettings(obj, varargin)

user_settings.version = obj.version;
user_settings.name = 'global_settings';
user_settings.data = obj.settings;

exportMAT(user_settings,...
    'path', [obj.toolbox_path, filesep, obj.toolbox_config],...
    'file', obj.default_settings,...
    'varname', 'user_settings');

end

function saveSettings(obj, varargin)

user_settings.version = obj.version;
user_settings.name = 'global_settings';
user_settings.data = obj.settings;

exportMAT(user_settings,...
    'path', [obj.toolbox_path, filesep, obj.toolbox_config],...
    'varname', 'user_settings',...
    'suggest', obj.default_settings);

end

function applySettings(obj, varargin)

% UIControl --> Show Baseline
if obj.settings.showPlotBaseline
    obj.controls.showBaseline.Value = 1;
else
    obj.controls.showBaseline.Value = 0;
end

% UIControl --> Show Peaks
if obj.settings.showPeaks
    obj.controls.showPeak.Value = 1;
else
    obj.controls.showPeak.Value = 0;
end

% UIControl --> Baseline Settings
if isfield(obj.settings.baseline, 'asymmetry')
    obj.controls.asymSlider.Value = obj.settings.baseline.asymmetry;
elseif isfield(obj.settings, 'baselineAsymmetry')
    obj.controls.asymSlider.Value = obj.settings.baselineAsymmetry;
end

if isfield(obj.settings.baseline, 'smoothness')
    obj.controls.smoothSlider.Value = obj.settings.baseline.smoothness;
elseif isfield(obj.settings, 'baselineSmoothness')
    obj.controls.smoothSlider.Value = obj.settings.baselineSmoothness;
end

% Menu --> Options --> Sample --> Label
if isfield(obj.settings.labels, 'data')
    labelName = obj.settings.labels.data;
elseif isfield(obj.settings.labels, 'legend')
    labelName = obj.settings.labels.legend;
else
    labelName = ' ';
end

for i = 1:length(obj.menu.labelData.Children)
    if any(ishandle(obj.menu.labelData.Children(i)))
        if any(strcmpi(obj.menu.labelData.Children(i).Tag, labelName))
            obj.menu.labelData.Children(i).Checked = 'on';
        else
            obj.menu.labelData.Children(i).Checked = 'off';
        end
    end
end

% Menu --> Options --> Peak --> Label
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

% Menu --> Options --> Peak --> Model
switch lower(obj.settings.peakModel)
    case {'nn1'}
        obj.menu.peakNN1.Checked = 'on';
    case {'nn', 'nn2'}
        obj.menu.peakNN2.Checked = 'on';
    case {'egh'}
        obj.menu.peakEGH.Checked = 'on';
end

% Menu --> Options --> Peak --> AreaOf
switch lower(obj.settings.peakArea)
    case {'rawdata'}
        obj.menu.peakOptionsAreaActual.Checked = 'on';
    case {'fitdata'}
        obj.menu.peakOptionsAreaFit.Checked = 'on';
end

% Menu --> Options --> Peak --> Auto-Detection
if isfield(obj.settings, 'peakAutoDetect')
    if obj.settings.peakAutoDetect
        obj.menu.peakOptionsAutoDetect.Checked = 'on';
    else
        obj.menu.peakOptionsAutoDetect.Checked = 'off';
    end
end

% Menu --> Options --> Peak --> Auto-Step
if isfield(obj.settings, 'peakAutoStep')
    if obj.settings.peakAutoStep
        obj.menu.peakOptionsAutoStep.Checked = 'on';
    else
        obj.menu.peakOptionsAutoStep.Checked = 'off';
    end
end

% Menu --> View --> Sample --> Show Plot Label
if obj.settings.showPlotLabel
    obj.menu.view.plotLabel.Checked = 'on';
else
    obj.menu.view.plotLabel.Checked = 'off';
end

% Menu --> View --> Peak --> Show Peak Label
if obj.settings.showPeakLabel
    obj.menu.view.peakLabel.Checked = 'on';
else
    obj.menu.view.peakLabel.Checked = 'off';
end

% Menu --> View --> Peak --> Show Peak Fit (line)
if obj.settings.showPeakLine
    obj.menu.view.peakLine.Checked = 'on';
else
    obj.menu.view.peakLine.Checked = 'off';
end

% Menu --> View --> Peak --> Show Peak Area (fill)
if obj.settings.showPeakArea
    obj.menu.view.peakArea.Checked = 'on';
else
    obj.menu.view.peakArea.Checked = 'off';
end

% Menu --> View --> Peak --> Show Peak Baseline (line)
if obj.settings.showPeakBaseline
    obj.menu.view.peakBaseline.Checked = 'on';
else
    obj.menu.view.peakBaseline.Checked = 'off';
end

% Menu --> Other --> Table --> Show Peak Columns
str = obj.settings.table.labelNames;

for i = 1:length(str)
    
    if isfield(obj.settings.table, ['show', str{i}])
        if isfield(obj.menu, ['tablePeak', str{i}])
            
            if obj.settings.table.(['show', str{i}])
                obj.menu.(['tablePeak', str{i}]).Checked = 'on';
            else
                obj.menu.(['tablePeak', str{i}]).Checked = 'off';
            end
            
        end
    end
    
end

% Menu --> Options --> Other --> Import --> Async Mode
if isfield(obj.settings, 'other')
    if isfield(obj.settings.other, 'asyncMode')
        
        if obj.settings.other.asyncMode
            obj.menu.optionsAsyncLoad.Checked = 'on';
        else
            obj.menu.optionsAsyncLoad.Checked = 'off';
        end
        
    end
end

% Menu --> View --> Zoom
if strcmpi(obj.settings.showZoom, 'on')
    obj.menu.view.zoom.Checked = 'on';
    obj.settings.selectZoom = 1;
    obj.userZoom(1);
    obj.userPeak(0);
else
    obj.menu.view.zoom.Checked = 'off';
    obj.settings.selectZoom = 0;
    obj.userZoom(0);
end

% Update Axes
obj.updateAxesLimitToggle();
obj.updateAxesLimitMode();

if strcmpi(obj.settings.xmode, 'manual')
    obj.axes.main.XLim = obj.settings.xlim;
end

if strcmpi(obj.settings.ymode, 'manual')
    obj.axes.main.YLim = obj.settings.ylim;
end

obj.updateAxesLimitEditText();

% Update Plot
obj.updatePlot();

end

function verifySettings(obj, varargin)

if isempty(varargin)
    return
else
    x = varargin{1};
end

str = fields(x);

for i = 1:length(str)
    
    if isstruct(x.(str{i}))
        substr = fields(x.(str{i}));
        
        for j = 1:length(substr)
            obj.settings.(str{i}).(substr{j}) = x.(str{i}).(substr{j});
        end
        
    else
        obj.settings.(str{i}) = x.(str{i});
    end
    
end

end