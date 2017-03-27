function toolboxButton(obj, varargin)

% ---------------------------------------
% Push Buttons
% ---------------------------------------

% Select Tab --> Previous, Next
p1(1) = 0.50 + 0.05;
p1(2) = 0.05;
p1(3) = 0.30;
p1(4) = 0.25;

p2(1) = 0.50 - 0.05 - p1(3);
p2(2) = p1(2);
p2(3) = p1(3);
p2(4) = p1(4);

obj.controls.next = newPushButton(...
    obj, obj.panel.selectTab, 'Next', 'nextsample', p1);

obj.controls.prev = newPushButton(...
    obj, obj.panel.selectTab, 'Previous', 'prevsample', p2);

% Integrate Tab --> Peak List --> Add, Edit, Delete
pl1(1) = 0.6 + 0.01 * 2;
pl1(2) = 0.685 + 0.01;
pl1(3) = 0.4 - 0.01 * 4;
pl1(4) = 0.275;

pl2(1) = pl1(1);
pl2(2) = pl1(2) - pl1(4) - 0.05;
pl2(3) = pl1(3);
pl2(4) = pl1(4);

pl3(1) = pl1(1);
pl3(2) = pl2(2) - pl2(4) - 0.05;
pl3(3) = pl1(3);
pl3(4) = pl1(4);

obj.controls.addPeak = newPushButton(...
    obj, obj.panel.peakList, 'Add', 'addpeak', pl1);

obj.controls.editPeak = newPushButton(...
    obj, obj.panel.peakList, 'Edit', 'editpeak', pl2);

obj.controls.delPeak = newPushButton(...
    obj, obj.panel.peakList, 'Delete', 'delpeak', pl3);

% Integrate Tab --> Baseline --> Refresh, Clear
b2(1) = 0.50 - 0.15;
b2(2) = 0.03;
b2(3) = 0.30;
b2(4) = 0.30;

b3(1) = b2(1) + b2(3) + 0.02;
b3(2) = b2(2);
b3(3) = b2(3);
b3(4) = b2(4);

obj.controls.applyBaseline = newPushButton(...
    obj, obj.panel.baseline, 'Apply', 'applybaseline', b2);

obj.controls.clearBaseline = newPushButton(...
    obj, obj.panel.baseline, 'Clear', 'clearbaseline', b3);

% ---------------------------------------
% Static Text
% ---------------------------------------

% Select Tab --> ID, Sample Name
t1(1) = 0.15;
t1(2) = 1.00 - 0.30;
t1(3) = 0.20;
t1(4) = 0.20;

t2(1) = t1(1);
t2(2) = t1(2) - t1(4);
t2(3) = t1(3);
t2(4) = t1(4);

obj.controls.selectID = newStaticText(...
    obj, obj.panel.selectTab, 'ID', 'idtext', t1);

obj.controls.selectName = newStaticText(...
    obj, obj.panel.selectTab, 'Sample', 'nametext', t2);

% View Tab --> X-Limits, Y-Limits
t3(1) = 0.45;
t3(2) = (0.15 + 0.25) / 2;
t3(3) = 0.10;
t3(4) = 0.25 / 2;

obj.controls.xSeparator = newStaticText(...
    obj, obj.panel.xlim, '-', 'xdash', t3);

obj.controls.ySeparator = newStaticText(...
    obj, obj.panel.ylim, '-', 'ydash', t3);

% Integrate Tab --> Options
i1(1) = 0.075;
i1(2) = 0.02 * 5 + 0.15 * 4 + 0.075; 
i1(3) = 0.25;
i1(4) = 0.15;

i2(1) = i1(1);
i2(2) = 0.02 * 4 + 0.15 * 3 + 0.075; 
i2(3) = i1(3);
i2(4) = i1(4);

i3(1) = i1(1);
i3(2) = 0.02 * 3 + 0.15 * 2 + 0.075; 
i3(3) = i1(3);
i3(4) = i1(4);

i4(1) = i1(1);
i4(2) = 0.02 * 2 + 0.15 * 1 + 0.075; 
i4(3) = i1(3);
i4(4) = i1(4);

i5(1) = i1(1);
i5(2) = 0.02 * 1 + 0.15 * 0 + 0.075;
i5(3) = i1(3);
i5(4) = i1(4);

obj.controls.peakIDText = newStaticText(...
    obj, obj.panel.integrate, 'ID', 'peakidtext', i1);

obj.controls.peakTimeText = newStaticText(...
    obj, obj.panel.integrate, 'Time', 'peaktimetext', i2);

obj.controls.peakWidthText = newStaticText(...
    obj, obj.panel.integrate, 'Width', 'peakwidthtext', i3);

obj.controls.peakHeightText = newStaticText(...
    obj, obj.panel.integrate, 'Height', 'peakheighttext', i4);

obj.controls.peakAreaText = newStaticText(...
    obj, obj.panel.integrate, 'Area', 'peakareatext', i5);

% ---------------------------------------
% Edit Text
% ---------------------------------------

% Select Tab --> ID, Sample Name
e1(1) = 0.45;
e1(2) = 0.10 + 0.25 + 0.025;
e1(3) = 1.00 - e1(1) - 0.10;
e1(4) = 0.25;

e2(1) = 0.45;
e2(2) = 0.10 + 0.25 + 0.025 + 0.25 + 0.025;
e2(3) = 1.00 - e1(1) - 0.10;
e2(4) = e1(4);

obj.controls.editID = newEditText(...
    obj, obj.panel.selectTab, obj.view.id, 'idedit', e2);

obj.controls.editName = newEditText(...
    obj, obj.panel.selectTab, obj.view.name, 'nameedit', e1);

% View Tab --> X-Limits, Y-Limits
e3(1) = 0.50 - 0.35 - 0.05;
e3(2) = 0.15;
e3(3) = 0.35;
e3(4) = 0.30;

e4(1) = 0.50 + 0.05;
e4(2) = e3(2);
e4(3) = e3(3);
e4(4) = e3(4);

obj.controls.xMin = newEditText(...
    obj, obj.panel.xlim, sprintf('%.3f', obj.axes.xlim(1)), 'xminedit', e3);

obj.controls.xMax = newEditText(...
    obj, obj.panel.xlim, sprintf('%.3f', obj.axes.xlim(2)), 'xmaxedit', e4);

obj.controls.yMin = newEditText(...
    obj, obj.panel.ylim, sprintf('%.3f', obj.axes.ylim(1)), 'yminedit', e3);

obj.controls.yMax = newEditText(...
    obj, obj.panel.ylim, sprintf('%.3f', obj.axes.ylim(2)), 'ymaxedit', e4);

% Integrate Tab --> Options
ie1(1) = 0.075 + 0.05 + 0.25;
ie1(2) = 0.02 * 5 + 0.15 * 4 + 0.075; 
ie1(3) = 0.28;
ie1(4) = 0.15;

ie2(1) = ie1(1);
ie2(2) = 0.02 * 4 + 0.15 * 3 + 0.075; 
ie2(3) = ie1(3);
ie2(4) = ie1(4);

ie3(1) = ie1(1);
ie3(2) = 0.02 * 3 + 0.15 * 2 + 0.075; 
ie3(3) = ie1(3);
ie3(4) = ie1(4);

ie4(1) = ie1(1);
ie4(2) = 0.02 * 2 + 0.15 * 1 + 0.075; 
ie4(3) = ie1(3);
ie4(4) = ie1(4);

ie5(1) = ie1(1);
ie5(2) = 0.02 * 1 + 0.15 * 0 + 0.075; 
ie5(3) = ie1(3);
ie5(4) = ie1(4);

if ~isempty(obj.peaks.name)
    peakText = obj.peaks.name{1};
else
    peakText = '';
end

obj.controls.peakIDEdit = newEditText(...
    obj, obj.panel.integrate, peakText, 'peakidedit', ie1);

obj.controls.peakTimeEdit = newEditText(...
    obj, obj.panel.integrate, '', 'peaktimeedit', ie2);

obj.controls.peakWidthEdit = newEditText(...
    obj, obj.panel.integrate, '', 'peakwidthedit', ie3);

obj.controls.peakHeightEdit = newEditText(...
    obj, obj.panel.integrate, '', 'peakheightedit', ie4);

obj.controls.peakAreaEdit = newEditText(...
    obj, obj.panel.integrate, '', 'peakareaedit', ie5);

% ---------------------------------------
% Toggle Buttons
% ---------------------------------------

% View Tab --> X-Limits, Y-Limits
x1(1) = 0.50 - 0.05 - 0.35;
x1(2) = 0.50 + 0.10;
x1(3) = 0.35;
x1(4) = 0.30;

x2(1) = 0.50 + 0.05;
x2(2) = x1(2);
x2(3) = x1(3);
x2(4) = x1(4);

obj.controls.xUser = newToggleButton(...
    obj, obj.panel.xlim, 'Manual', 'xmanual', 0, x1);

obj.controls.yUser = newToggleButton(...
    obj, obj.panel.ylim, 'Manual', 'ymanual', 0, x1);

obj.controls.xAuto = newToggleButton(...
    obj, obj.panel.xlim, 'Auto', 'xauto', 1, x2);

obj.controls.yAuto = newToggleButton(...
    obj, obj.panel.ylim, 'Auto', 'yauto', 1, x2);

% Integrate Tab --> Show Baseline
b1(1) = 0.03;
b1(2) = b2(2);
b1(3) = b2(3);
b1(4) = b2(4);

obj.controls.showBaseline = newToggleButton(...
    obj, obj.panel.baseline, 'Show', 'showbaseline', 0, b1);

% Integrate Tab --> Show Peaks
it1(1) = 0.725;
it1(2) = 0.05 + 0.28 * 2 + 0.03 * 2;
it1(3) = 0.225;
it1(4) = 0.28;

it2(1) = it1(1);
it2(2) = 0.05 + 0.28 * 1 + 0.03 * 1;
it2(3) = it1(3);
it2(4) = it1(4);

it3(1) = it1(1);
it3(2) = 0.05 + 0.28 * 0 + 0.03 * 0;
it3(3) = it1(3);
it3(4) = it1(4);

obj.controls.showPeak = newToggleButton(...
    obj, obj.panel.integrate, 'Show', 'showpeak', 1, it1);

obj.controls.selectPeak = newToggleButton(...
    obj, obj.panel.integrate, 'Select', 'selectpeak', 0, it2);

obj.controls.clearPeak = newPushButton(...
    obj, obj.panel.integrate, 'Clear', 'clearpeak', it3);

% ---------------------------------------
% Listbox
% ---------------------------------------
l1(1) = 0.0;
l1(2) = 0.0;
l1(3) = 0.6;
l1(4) = 1.0;

obj.controls.peakList = newListbox(...
    obj, obj.panel.peakList, obj.peaks.name, 'peaklist', l1);

% ---------------------------------------
% Sliders
% ---------------------------------------
s1(1) = 0.05;
s1(2) = 0.65;
s1(3) = 0.90;
s1(4) = 0.20;

s2(1) = s1(1);
s2(2) = 0.40;
s2(3) = s1(3);
s2(4) = s1(4);

obj.controls.smoothSlider = newSlider(...
    obj, obj.panel.baseline, 's', 'smoothslider', s1);

obj.controls.asymSlider = newSlider(...
    obj, obj.panel.baseline, 'a', 'asymslider', s2);

s = obj.settings.baselineSmoothness;
a = obj.settings.baselineAsymmetry;

set(obj.controls.smoothSlider, 'min', 1,   'max', 10, 'value', s);
set(obj.controls.asymSlider,   'min', -10, 'max', -1, 'value', a);

% ---------------------------------------
% Selection Callback
% ---------------------------------------
set(obj.controls.next,...
    'callback', {@obj.selectSample, 1},... 
    'keypressfcn', {@browseKeyCallback, obj});

set(obj.controls.prev,...
    'callback', {@obj.selectSample, -1},... 
    'keypressfcn', {@browseKeyCallback, obj});

set(obj.controls.editID,   'callback', {@editIDCallback, obj});
set(obj.controls.editName, 'callback', @obj.updateSampleText);

% ---------------------------------------
% Axes Callback
% ---------------------------------------
set(obj.controls.xUser, 'callback', {@axesToggleCallback, obj});
set(obj.controls.xAuto, 'callback', {@axesToggleCallback, obj});
set(obj.controls.yUser, 'callback', {@axesToggleCallback, obj});
set(obj.controls.yAuto, 'callback', {@axesToggleCallback, obj});
set(obj.controls.xMin,  'callback', {@axesLimitCallback, obj});
set(obj.controls.xMax,  'callback', {@axesLimitCallback, obj});
set(obj.controls.yMin,  'callback', {@axesLimitCallback, obj});
set(obj.controls.yMax,  'callback', {@axesLimitCallback, obj});

% ---------------------------------------
% Baseline Callback
% ---------------------------------------
set(obj.controls.applyBaseline, 'callback', {@baselineCallback, obj});
set(obj.controls.clearBaseline, 'callback', {@baselineCallback, obj});
set(obj.controls.showBaseline,  'callback', {@baselineCallback, obj});

% ---------------------------------------
% Peak Callback
% ---------------------------------------
set(obj.controls.addPeak,        'callback', {@peakListCallback, obj});
set(obj.controls.editPeak,       'callback', {@peakListCallback, obj});
set(obj.controls.delPeak,        'callback', {@peakListCallback, obj});
set(obj.controls.peakList,       'callback', {@peakListboxCallback, obj});
set(obj.controls.peakIDEdit,     'callback', {@peakEditTextCallback, obj});
set(obj.controls.peakTimeEdit,   'callback', {@peakEditTextCallback, obj});
set(obj.controls.peakWidthEdit,  'callback', {@peakEditTextCallback, obj});
set(obj.controls.peakHeightEdit, 'callback', {@peakEditTextCallback, obj});
set(obj.controls.peakAreaEdit,   'callback', {@peakEditTextCallback, obj});
set(obj.controls.showPeak,       'callback', @obj.plotPeaks);
set(obj.controls.clearPeak,      'callback', @obj.clearPeak);
set(obj.controls.selectPeak,     'callback', {@peakSelectCallback, obj});

set(obj.controls.addPeak,  'keypressfcn', {@browseKeyCallback, obj});
set(obj.controls.editPeak, 'keypressfcn', {@browseKeyCallback, obj});
set(obj.controls.delPeak,  'keypressfcn', {@browseKeyCallback, obj});

end

% ---------------------------------------
% Peak Options
% ---------------------------------------
function peakListCallback(src, ~, obj)

switch src.String
    
    case 'Add'
        
        dlgMsg = {'Enter name for new peak:'};
        dlgTop = '';
        dlgAns = {num2str(length(obj.peaks.name)+1)};
        
        x = inputdlg(dlgMsg, dlgTop, 1, dlgAns);
        
        if ~isempty(x) && ~isempty(x{1,1})
            obj.peakAddColumn(x(1,1));
        end
        
    case 'Edit'
        
        col = obj.controls.peakList.Value;
        
        if col < 1 || col > length(obj.peaks.name)
            return
        end
        
        dlgMsg = {'Enter name for peak:'};
        dlgTop = '';
        dlgAns = {obj.peaks.name{col,1}};
        
        x = inputdlg(dlgMsg, dlgTop, 1, dlgAns);
        
        if ~isempty(x) && ~isempty(x{1,1})
            if ~strcmp(obj.peaks.name(col,1), x{1,1})
                x = {strtrim(deblank(x{1,1}))};
                obj.peakEditColumn(col,x);
            end
        end
        
    case 'Delete'
        
        col = obj.controls.peakList.Value;
        
        if isempty(col) || col < 1 || col > length(obj.peaks.name)
            return
        end
        
        x = questdlg('Delete this peak?', 'Delete', 'Yes', 'No', 'Yes');
        
        if strcmpi(x, 'Yes')
            
            obj.peakDeleteColumn(col);
        
            if col > length(obj.peaks.name)
                obj.controls.peakList.Value = length(obj.peaks.name);
            end
           
            obj.updatePeakText();
            
        end
        
end

end

% ---------------------------------------
% Keyboard Callback
% ---------------------------------------
function browseKeyCallback(src, evt, obj)

if ~strcmpi(evt.EventName, 'KeyPress') || ~isprop(src, 'tag')
    return
end

switch evt.Key
    
    case 'return'
        
        switch src.Tag
            
            case {'addpeak', 'editpeak', 'delpeak'}
                peakListCallback(src, [], obj);
                
            case 'nextsample'
                obj.selectSample(1);
                
            case 'prevsample'
                obj.selectSample(-1);
        end
        
end

end

% ---------------------------------------
% Selection ID
% ---------------------------------------
function editIDCallback(~, ~, obj)

str = obj.controls.editID.String;
val = str2double(str);

if isempty(obj.data) || isempty(str) || isnan(val) || isinf(val) || ~isreal(val)
    obj.updateSampleText();
    return
    
elseif val > length(obj.data)
    obj.view.index = length(obj.data);
    obj.view.id    = num2str(length(obj.data));
    obj.view.name  = obj.data(end).sample_name;
    
elseif val < 1
    obj.view.index = 1;
    obj.view.id    = '1';
    obj.view.name  = obj.data(1).sample_name;
    
else
    obj.view.index = floor(val);
    obj.view.id    = num2str(floor(val));
    obj.view.name  = obj.data(obj.view.index).sample_name;
end

obj.updateSampleText();
obj.updatePeakText();
obj.updatePlot();

end

% ---------------------------------------
% Axes Toggle
% ---------------------------------------
function axesToggleCallback(src, ~, obj)

switch src.Tag
    
    case 'xmanual'
        obj.controls.xAuto.Value = ~src.Value;
    case 'xauto'
        obj.controls.xUser.Value = ~src.Value;
    case 'ymanual'
        obj.controls.yAuto.Value = ~src.Value;
    case 'yauto'
        obj.controls.yUser.Value = ~src.Value;
        
end

obj.updateAxesLimitMode();
obj.updatePlot();

end

% ---------------------------------------
% Axes Limits
% ---------------------------------------
function axesLimitCallback(src, ~, obj)

str = @(x) sprintf('%.3f', x);

row = obj.view.index;

n = src.String;
x = str2double(n);

switch src.Tag
    
    case 'xminedit'
        
        if isempty(n)
            
            if row ~= 0
                xmin = min(obj.data(row).time(:,1));
                xmax = max(obj.data(row).time(:,1));
                obj.axes.xlim(1) = xmin - ((xmax - xmin) * 0.02);
            else
                obj.axes.xlim(1) = 0;
            end

            src.String = str(obj.axes.xlim(1));
            obj.axes.xmode = 'manual';
            obj.updateAxesXLim();
            
        elseif isnan(x) || isinf(x) || ~isreal(x)
            src.String = str(obj.axes.xlim(1));
            return
            
        elseif x < obj.axes.xlim(2)
            obj.axes.xmode = 'manual';
            obj.axes.xlim(1) = x;
            obj.updateAxesXLim();
            
        else
            src.String = str(obj.axes.xlim(1));
            return
        end
        
    case 'xmaxedit'
        
        if isempty(n) 
            
            if row ~= 0
                xmin = min(obj.data(row).time(:,1));
                xmax = max(obj.data(row).time(:,1));
                obj.axes.xlim(2) = xmax + ((xmax - xmin) * 0.02);
            else
                obj.axes.xlim(2) = 1;
            end

            src.String = str(obj.axes.xlim(2));
            obj.axes.xmode = 'manual';
            obj.updateAxesXLim();
            
        elseif isnan(x) || isinf(x) || ~isreal(x)
            src.String = str(obj.axes.xlim(2));
            return
            
        elseif x > obj.axes.xlim(1)
            obj.axes.xlim(2) = x;
            obj.axes.xmode = 'manual';
            obj.updateAxesXLim();
            
        else
            src.String = str(obj.axes.xlim(2));
            return
        end
        
    case 'yminedit'
        
        if isempty(n) 
            
            if row ~= 0
                x = obj.data(row).time(:,1);
                y = obj.data(row).intensity(:,1);
                y = y(x >= obj.axes.xlim(1) & x <= obj.axes.xlim(2));
                obj.axes.ylim(1) = min(y) - ((obj.axes.ylim(2) - min(y)) * 0.02);
            else
                obj.axes.ylim(1) = 0;
            end

            src.String = str(obj.axes.ylim(1));
            obj.axes.ymode = 'manual';
            obj.updateAxesYLim();
            
        elseif isnan(x) || isinf(x) || ~isreal(x)
            src.String = str(obj.axes.ylim(1));
            return
            
        elseif x < obj.axes.ylim(2)
            obj.axes.ymode = 'manual';
            obj.axes.ylim(1) = x;
            obj.updateAxesYLim();
            
        else
            src.String = str(obj.axes.ylim(1));
            return
        end
        
    case 'ymaxedit'
        
        if isempty(n)
            
            if row ~= 0
                x = obj.data(row).time(:,1);
                y = obj.data(row).intensity(:,1);
                y = y(x >= obj.axes.xlim(1) & x <= obj.axes.xlim(2));
                obj.axes.ylim(2) = max(y) + ((max(y) - obj.axes.ylim(1)) * 0.02);
            else
                obj.axes.ylim(2) = 1;
            end

            src.String = str(obj.axes.ylim(2));
            obj.axes.ymode = 'manual';
            obj.updateAxesYLim();
            
        elseif isnan(x) || isinf(x) || ~isreal(x)
            src.String = str(obj.axes.ylim(2));
            return
            
        elseif x > obj.axes.ylim(1)
            obj.axes.ymode = 'manual';
            obj.axes.ylim(2) = x;
            obj.updateAxesYLim();
            
        else
            src.String = str(obj.axes.ylim(2));
            return
        end
        
    otherwise
        return
        
end

obj.updateAxesLimitToggle();
obj.updatePlot();

end

% ---------------------------------------
% Baseline
% ---------------------------------------
function baselineCallback(src, ~, obj)

if isempty(obj.data) || obj.view.index == 0
    return
else
    row = obj.view.index;
end

switch src.Tag
    
    case 'showbaseline'
        
        if src.Value
            obj.view.showBaseLine = 1;
            obj.updateBaseLine();
        else
            obj.view.showBaseLine = 0;
            obj.clearAllBaseLine();
        end
        
    case 'applybaseline'
        
        obj.getBaseline();
        obj.updateBaseLine();
        
    case 'clearbaseline'
        
        obj.clearAllBaseLine();
        
        if ~isempty(obj.data(row).baseline)
            obj.data(row).baseline = [];
        end
        
end

end

% ---------------------------------------
% Peak Listbox
% ---------------------------------------
function peakListboxCallback(~, ~, obj)

obj.updatePeakText();
obj.userPeak(1);

end

% ---------------------------------------
% Peak Edit Text
% ---------------------------------------
function peakEditTextCallback(src, ~, obj)

switch src.Tag
    
    case 'peakidedit'
        
        if ~isempty(obj.peaks.name)
            str = obj.peaks.name(obj.controls.peakList.Value, 1);
            obj.controls.peakIDEdit.String = str;
        else
            obj.controls.peakIDEdit.String = '';
        end
        
    case 'peaktimeedit'
        obj.controls.peakTimeEdit.String = checkPeakEditText(obj, 'time');
              
    case 'peakwidthedit'
        obj.controls.peakWidthEdit.String = checkPeakEditText(obj, 'width');

    case 'peakheightedit'
        obj.controls.peakHeightEdit.String = checkPeakEditText(obj, 'height');
        
    case 'peakareaedit'
        obj.controls.peakAreaEdit.String = checkPeakEditText(obj, 'area');
        
end
        
end

% ---------------------------------------
% Check Peak Edit Text
% ---------------------------------------
function str = checkPeakEditText(obj, field)

col = obj.controls.peakList.Value;
row = obj.view.index;

if isempty(obj.data) || isempty(col) || col == 0 || row == 0
    str = '';
    return
end

if length(obj.peaks.(field)(1,:)) >= col
    str = obj.peaks.(field){row, col};
else
    str = '';
end

if ~isempty(str)
    str = sprintf('%.3f', str);
end

end

% ---------------------------------------
% Select Peak
% ---------------------------------------
function peakSelectCallback(src, evt, obj)

if isempty(obj.data) || isempty(obj.peaks.name)
    src.Value = 0;
    return
end

if strcmpi(evt.EventName, 'Action')
    
    if isprop(obj.figure.CurrentObject, 'Tag')
        
        currentObject = obj.figure.CurrentObject.Tag;
        
        if strcmpi(currentObject, src.Tag)
            
            if src.Value
                obj.userPeak(1);
            else
                obj.userPeak(0);
            end
            
        else
            src.Value = obj.view.selectPeak;
        end
        
    end
    
end

end

% ---------------------------------------
% Push Button
% ---------------------------------------
function button = newPushButton(obj, parent, title, tag, position)

backgroundColor = [0.94, 0.94, 0.94];
foregroundColor = [0.00, 0.00, 0.00];

button = uicontrol(...
    'style',           'pushbutton',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end

% ---------------------------------------
% Toggle Button
% ---------------------------------------
function button = newToggleButton(obj, parent, title, tag, value, position)

backgroundColor = [0.94, 0.94, 0.94];
foregroundColor = [0.00, 0.00, 0.00];

button = uicontrol(...
    'style',           'togglebutton',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'value',           value,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end

% ---------------------------------------
% Static Text
% ---------------------------------------
function text = newStaticText(obj, parent, title, tag, position)

backgroundColor = [0.99, 0.99, 0.99];
foregroundColor = [0.00, 0.00, 0.00];

text = uicontrol(...
    'style',           'text',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end

% ---------------------------------------
% Edit Text
% ---------------------------------------
function text = newEditText(obj, parent, title, tag, position)

backgroundColor = [1.00, 1.00, 1.00];
foregroundColor = [0.00, 0.00, 0.00];

text = uicontrol(...
    'style',           'edit',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end

% ---------------------------------------
% Listbox
% ---------------------------------------
function listbox = newListbox(obj, parent, title, tag, position)

backgroundColor = [1.00, 1.00, 1.00];
foregroundColor = [0.00, 0.00, 0.00];

listbox = uicontrol(...
    'style',           'listbox',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize-1,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor);

end

% ---------------------------------------
% Slider
% ---------------------------------------
function slider = newSlider(obj, parent, title, tag, position)

backgroundColor = [1.00, 1.00, 1.00];
foregroundColor = [0.00, 0.00, 0.00];

slider = uicontrol(...
    'style',           'slider',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.settings.gui.fontname,...
    'fontsize',        obj.settings.gui.fontsize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end