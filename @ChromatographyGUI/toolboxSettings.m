function toolboxSettings(obj, ~, ~, varargin)

if isempty(varargin) || ~ischar(varargin{1})
    return
end

switch varargin{1}
    
    case {'initialize'}
        initalizeSettings(obj);
    
    case {'load_default', 'load_custom'}
        loadSettings(obj, varargin{1});
        
    case {'save_default', 'save_custom'}
        saveSettings(obj, varargin{1});
        
    case {'apply'}
        applySettings(obj);
        
    otherwise
        return
        
end

end

function initalizeSettings(obj, varargin)

% ---------------------------------------
% Graphic Settings
% ---------------------------------------

% Font
obj.settings.gui.fontname       = obj.font;
obj.settings.labels.fontname    = obj.font;

% Font Size
obj.settings.gui.fontsize       = 11.0;
obj.settings.labels.fontsize    = 11.0;

% Line Width
obj.settings.plot.linewidth     = 1.25;
obj.settings.baseline.linewidth = 1.50;
obj.settings.peaks.linewidth    = 2.00;

% Line Color
obj.settings.plot.color         = [0.10, 0.10, 0.10];
obj.settings.baseline.color     = [0.95, 0.22, 0.17];
obj.settings.peaks.color        = [0.00, 0.30, 0.53];

% Peak Label
obj.settings.labels.margin      = 3;
obj.settings.labels.precision   = '%.2f';

% ---------------------------------------
% Menu Options
% ---------------------------------------

% Default Zoom
obj.settings.selectZoom = 0;

% Default Peak Label
obj.settings.labels.peak = {
    'peakName'};

% Default Sample Label
obj.settings.labels.data = {...
    'row_num',...
    'instrument',...
    'datetime',...
    'sample_name'};

% ---------------------------------------
% Analysis Settings
% ---------------------------------------

% Default Baseline Parameters
obj.settings.baselineSmoothness = 5.5;
obj.settings.baselineAsymmetry  = -5.5;

% Default Peak Area Settings
obj.settings.peakModel = 'egh';     % 'nn' or 'egh'
obj.settings.peakArea  = 'rawData'; % 'rawData' or 'fitData'

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
    obj.settings = data.data;
    applySettings(obj);
end

end

function saveSettings(obj, varargin)

obj.settings.showPlotLabel      = obj.view.showPlotLabel;
obj.settings.showBaseLine       = obj.controls.showBaseline.Value;
obj.settings.showPeaks          = obj.controls.showPeak.Value;
obj.settings.showPeakLabel      = obj.view.showPeakLabel;
obj.settings.showPeakLine       = obj.view.showPeakLine;
obj.settings.showZoom           = obj.menu.view.zoom.Checked;
obj.settings.selectZoom         = obj.view.selectZoom;
obj.settings.xmode              = obj.axes.xmode;
obj.settings.ymode              = obj.axes.ymode;
obj.settings.xlim               = obj.axes.xlim;
obj.settings.ylim               = obj.axes.ylim;
obj.settings.baselineAsymmetry  = obj.controls.asymSlider.Value;
obj.settings.baselineSmoothness = obj.controls.smoothSlider.Value;

user_settings.version = obj.version;
user_settings.name    = 'global_settings';
user_settings.data    = obj.settings;

exportMAT(user_settings,...
    'path', [obj.toolbox_path, filesep, obj.toolbox_config],...
    'name', 'user_settings',...
    'suggest', obj.default_settings);

end

function applySettings(obj, varargin)

obj.view.showPlotLabel = obj.settings.showPlotLabel;
obj.view.showBaseLine  = obj.settings.showBaseLine;
obj.view.showPeakLabel = obj.settings.showPeakLabel;
obj.view.showPeakLine  = obj.settings.showPeakLine;
obj.view.selectZoom    = obj.settings.selectZoom;
obj.axes.xmode         = obj.settings.xmode;
obj.axes.ymode         = obj.settings.ymode;
obj.axes.xlim          = obj.settings.xlim;
obj.axes.ylim          = obj.settings.ylim;

if isfield(obj.settings, 'baselineAsymmetry')
    obj.controls.asymSlider.Value   = obj.settings.baselineAsymmetry;
end

if isfield(obj.settings, 'baselineSmoothness')
    obj.controls.smoothSlider.Value = obj.settings.baselineSmoothness;
end

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

switch obj.settings.peakModel
    
    case 'nn'
        obj.menu.peakNeuralNetwork.Checked = 'on';
        obj.menu.peakExpGaussian.Checked = 'off';
        
    case 'egh'
        obj.menu.peakNeuralNetwork.Checked = 'off';
        obj.menu.peakExpGaussian.Checked = 'on';
        
end

switch obj.settings.peakArea
    
    case 'rawData'
        obj.menu.peakOptionsAreaActual.Checked = 'on';
        obj.menu.peakOptionsAreaFit.Checked = 'off';
        
    case 'fitData'
        obj.menu.peakOptionsAreaActual.Checked = 'off';
        obj.menu.peakOptionsAreaFit.Checked = 'on';
        
end

if obj.settings.showPlotLabel
    obj.menu.view.plotLabel.Checked = 'on';
else
    obj.menu.view.plotLabel.Checked = 'off';
end

if obj.settings.showBaseLine
    obj.controls.showBaseline.Value = 1;
else
    obj.controls.showBaseline.Value = 0;
end

if obj.settings.showPeaks
    obj.controls.showPeak.Value = 1;
else
    obj.controls.showPeak.Value = 0;
end

if obj.settings.showPeakLabel
    obj.menu.view.peakLabel.Checked = 'on';
else
    obj.menu.view.peakLabel.Checked = 'off';
end

if obj.settings.showPeakLine
    obj.menu.view.peakLine.Checked = 'on';
else
    obj.menu.view.peakLine.Checked = 'off';
end

if strcmpi(obj.settings.showZoom, 'on')
    obj.menu.view.zoom.Checked = 'on';
    obj.view.selectZoom = 1;
    obj.userZoom(1);
    obj.userPeak(0);
else
    obj.menu.view.zoom.Checked = 'off';
    obj.view.selectZoom = 0;
    obj.userZoom(0);
end

obj.updateAxesLimitToggle();
obj.updateAxesLimitMode();

if strcmpi(obj.axes.xmode, 'manual')
    obj.axes.main.XLim = obj.axes.xlim;
end

if strcmpi(obj.axes.ymode, 'manual')
    obj.axes.main.YLim = obj.axes.ylim;
end

obj.updateAxesLimitEditText();
obj.updatePlot();

end