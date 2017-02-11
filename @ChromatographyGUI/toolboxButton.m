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

obj.controls.next = newPushButton(obj, obj.panel.selectTab, 'Next',     'nextsample', p1);
obj.controls.prev = newPushButton(obj, obj.panel.selectTab, 'Previous', 'prevsample', p2);

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

obj.controls.addPeak  = newPushButton(obj, obj.panel.peakList, 'Add',    'addpeak',  pl1);
obj.controls.editPeak = newPushButton(obj, obj.panel.peakList, 'Edit',   'editpeak', pl2);
obj.controls.delPeak  = newPushButton(obj, obj.panel.peakList, 'Delete', 'delpeak',  pl3);

% Integrate Tab --> Baseline --> Refresh, Clear
b2(1) = 0.50 - 0.15;
b2(2) = 0.03;
b2(3) = 0.30;
b2(4) = 0.30;

b3(1) = b2(1) + b2(3) + 0.02;
b3(2) = b2(2);
b3(3) = b2(3);
b3(4) = b2(4);

obj.controls.applyBaseline = newPushButton(obj, obj.panel.baseline, 'Apply', 'applybaseline', b2);
obj.controls.clearBaseline = newPushButton(obj, obj.panel.baseline, 'Clear', 'clearbaseline', b3);

% ---------------------------------------
% Static Text
% ---------------------------------------

% Select Tab --> ID, Sample Name
t1(1) = 0.15;
t1(2) = 1.00 - 0.30;
t1(3) = 0.15;
t1(4) = 0.20;

t2(1) = t1(1);
t2(2) = t1(2) - t1(4) - 0.10;
t2(3) = t1(3);
t2(4) = t1(4);

obj.controls.selectID   = newStaticText(obj, obj.panel.selectTab, 'ID',     'idtext',   t1);
obj.controls.selectName = newStaticText(obj, obj.panel.selectTab, 'Sample', 'nametext', t2);

correctPosition(obj.controls.selectID);
correctPosition(obj.controls.selectName);

% View Tab --> X-Limits, Y-Limits
t3(1) = 0.45;
t3(2) = (0.15 + 0.25) / 2;
t3(3) = 0.10;
t3(4) = 0.25 / 2;

obj.controls.xSeparator = newStaticText(obj, obj.panel.xlim, '-', 'xdash', t3);
obj.controls.ySeparator = newStaticText(obj, obj.panel.ylim, '-', 'ydash', t3);

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

obj.controls.peakIDText     = newStaticText(obj, obj.panel.integrate, 'ID',     'peakidtext',     i1);
obj.controls.peakTimeText   = newStaticText(obj, obj.panel.integrate, 'Time',   'peaktimetext',   i2);
obj.controls.peakWidthText  = newStaticText(obj, obj.panel.integrate, 'Width',  'peakwidthtext',  i3);
obj.controls.peakHeightText = newStaticText(obj, obj.panel.integrate, 'Height', 'peakheighttext', i4);
obj.controls.peakAreaText   = newStaticText(obj, obj.panel.integrate, 'Area',   'peakareatext',   i5);

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

obj.controls.editID   = newEditText(obj, obj.panel.selectTab, obj.view.id,   'idedit',   e2);
obj.controls.editName = newEditText(obj, obj.panel.selectTab, obj.view.name, 'nameedit', e1);

% View Tab --> X-Limits, Y-Limits
e3(1) = 0.50 - 0.35 - 0.05;
e3(2) = 0.15;
e3(3) = 0.35;
e3(4) = 0.30;

e4(1) = 0.50 + 0.05;
e4(2) = e3(2);
e4(3) = e3(3);
e4(4) = e3(4);

obj.controls.xMin = newEditText(obj, obj.panel.xlim, num2str(obj.axes.xlim(1)), 'xminedit', e3);
obj.controls.xMax = newEditText(obj, obj.panel.xlim, num2str(obj.axes.xlim(2)), 'xmaxedit', e4);
obj.controls.yMin = newEditText(obj, obj.panel.ylim, num2str(obj.axes.ylim(1)), 'yminedit', e3);
obj.controls.yMax = newEditText(obj, obj.panel.ylim, num2str(obj.axes.ylim(2)), 'ymaxedit', e4);

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

obj.controls.peakIDEdit     = newEditText(obj, obj.panel.integrate, obj.peaks.name{1}, 'peakidedit', ie1);
obj.controls.peakTimeEdit   = newEditText(obj, obj.panel.integrate, '', 'peaktimeedit',   ie2);
obj.controls.peakWidthEdit  = newEditText(obj, obj.panel.integrate, '', 'peakwidthedit',  ie3);
obj.controls.peakHeightEdit = newEditText(obj, obj.panel.integrate, '', 'peakheightedit', ie4);
obj.controls.peakAreaEdit   = newEditText(obj, obj.panel.integrate, '', 'peakareaedit',   ie5);

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

obj.controls.xManual = newToggleButton(obj, obj.panel.xlim, 'Manual', 'xmanual', 0, x1);
obj.controls.yManual = newToggleButton(obj, obj.panel.ylim, 'Manual', 'ymanual', 0, x1);
obj.controls.xAuto   = newToggleButton(obj, obj.panel.xlim, 'Auto',   'xauto',   1, x2);
obj.controls.yAuto   = newToggleButton(obj, obj.panel.ylim, 'Auto',   'yauto',   1, x2);

% Integrate Tab --> Show Baseline
b1(1) = 0.03;
b1(2) = b2(2);
b1(3) = b2(3);
b1(4) = b2(4);

obj.controls.showBaseline = newToggleButton(obj, obj.panel.baseline, 'Show', 'showbaseline', 0, b1);

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

obj.controls.showPeak   = newToggleButton(obj, obj.panel.integrate, 'Show',   'showpeak',   1, it1);
obj.controls.selectPeak = newToggleButton(obj, obj.panel.integrate, 'Select', 'selectpeak', 0, it2);
obj.controls.clearPeak  = newPushButton(obj, obj.panel.integrate,   'Clear',  'clearpeak',     it3);

% ---------------------------------------
% Listbox
% ---------------------------------------

l1(1) = 0.0;
l1(2) = 0.0;
l1(3) = 0.6;
l1(4) = 1.0;

obj.controls.peakList = newListbox(obj, obj.panel.peakList, obj.peaks.name, 'peaklist', l1);

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

obj.controls.smoothSlider = newSlider(obj, obj.panel.baseline, 's', 'smoothslider', s1);
obj.controls.asymSlider   = newSlider(obj, obj.panel.baseline, 'a', 'asymslider',   s2);

set(obj.controls.smoothSlider, 'min', 1,   'max', 10, 'value',  5.5);
set(obj.controls.asymSlider,   'min', -10, 'max', -1, 'value', -5.5);

% ---------------------------------------
% Selection Callback
% ---------------------------------------
set(obj.controls.next,...
    'callback', @(src, evt) sampleSelectionCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.prev,...
    'callback', @(src, evt) sampleSelectionCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.editID,...
    'callback', @(src, evt) editIDCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.editName,...
    'callback', @(src, evt) editNameCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

% ---------------------------------------
% Axes Callback
% ---------------------------------------
set(obj.controls.xManual,...
    'callback', @(src, evt) axesToggleCallback(obj, src, evt));

set(obj.controls.xAuto,...
    'callback', @(src, evt) axesToggleCallback(obj, src, evt));

set(obj.controls.yManual,...
    'callback', @(src, evt) axesToggleCallback(obj, src, evt));

set(obj.controls.yAuto,...
    'callback', @(src, evt) axesToggleCallback(obj, src, evt));

set(obj.controls.xMin,...
    'callback', @(src, evt) axesLimitCallback(obj, src, evt));

set(obj.controls.xMax,...
    'callback', @(src, evt) axesLimitCallback(obj, src, evt));

set(obj.controls.yMin,...
    'callback', @(src, evt) axesLimitCallback(obj, src, evt));

set(obj.controls.yMax,...
    'callback', @(src, evt) axesLimitCallback(obj, src, evt));

% ---------------------------------------
% Baseline Callback
% ---------------------------------------
set(obj.controls.applyBaseline,...
    'callback', @(src, evt) baselineCallback(obj, src, evt));

set(obj.controls.clearBaseline,...
    'callback', @(src, evt) baselineCallback(obj, src, evt));

set(obj.controls.showBaseline,...
    'callback', @(src, evt) baselineCallback(obj, src, evt));

% ---------------------------------------
% Peak Callback
% ---------------------------------------
set(obj.controls.peakList,...
    'callback', @(src, evt) peakListboxCallback(obj, src, evt));

set(obj.controls.addPeak,...
    'callback', @(src, evt) peakListCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.editPeak,...
    'callback', @(src, evt) peakListCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.delPeak,...
    'callback', @(src, evt) peakListCallback(obj, src, evt),...
    'keypressfcn', @(src, evt) browseKeyCallback(obj, src, evt));

set(obj.controls.peakIDEdit,...
    'callback', @(src, evt) peakEditTextCallback(obj, src, evt));

set(obj.controls.peakTimeEdit,...
    'callback', @(src, evt) peakEditTextCallback(obj, src, evt));
            
set(obj.controls.peakWidthEdit,...
    'callback', @(src, evt) peakEditTextCallback(obj, src, evt));

set(obj.controls.peakHeightEdit,...
    'callback', @(src, evt) peakEditTextCallback(obj, src, evt));

set(obj.controls.peakAreaEdit,...
    'callback', @(src, evt) peakEditTextCallback(obj, src, evt));

set(obj.controls.showPeak,...
    'callback', @(src, evt) peakDisplayCallback(obj, src, evt));
    
set(obj.controls.clearPeak,...
    'callback', @(src, evt) peakClearCallback(obj, src, evt));

set(obj.controls.selectPeak,...
    'callback', @(src, evt) peakSelectCallback(obj, src, evt));

end

% ---------------------------------------
% Peak Options
% ---------------------------------------
function peakListCallback(obj, src, ~)

switch get(src, 'string')
    
    case 'Add'
        
        dlgMsg = {'Enter name for new peak:'};
        dlgTop = '';
        dlgAns = {num2str(length(obj.peaks.name)+1)};
        
        x = inputdlg(dlgMsg, dlgTop, 1, dlgAns);
        
        if ~isempty(x) && ~isempty(x{1,1})
            obj.peakAddColumn(x(1,1));
        end
        
    case 'Edit'
        
        m = get(obj.controls.peakList, 'value');
        
        if m < 1 || m > length(obj.peaks.name)
            return
        end
        
        dlgMsg = {'Enter  name for peak:'};
        dlgTop = '';
        dlgAns = {obj.peaks.name{m,1}};
        
        x = inputdlg(dlgMsg, dlgTop, 1, dlgAns);
        
        if ~isempty(x) && ~isempty(x{1,1})
            if ~strcmp(obj.peaks.name(m,1), x{1,1})
                x = {strtrim(deblank(x{1,1}))};
                obj.peakEditColumn(m,x);
            end
        end
        
    case 'Delete'
        
        m = get(obj.controls.peakList, 'value');
        
        if isempty(m) || m < 1 || m > length(obj.peaks.name)
            return
        end
        
        x = questdlg('Delete this peak?', 'Delete', 'Yes', 'No', 'Yes');
        
        if strcmpi(x, 'Yes')
            
            obj.peakDeleteColumn(m);
        
            if m > length(obj.peaks.name)
                set(obj.controls.peakList, 'value', length(obj.peaks.name));
            end
           
            obj.updatePeakEditText();
            
        end
        
end

end

% ---------------------------------------
% Selection Buttons
% ---------------------------------------
function sampleSelectionCallback(obj, src, ~)

if obj.view.index == 0
    return
else
    row = obj.view.index;
end

if isempty(obj.data)
    
    obj.view.index = 0;
    obj.view.id    = 'N/A';
    obj.view.name  = 'N/A';
    
    updateSelectionText(obj);
    
    return
    
end

switch get(src, 'tag')
    
    case 'nextsample'
        
        if row + 1 > length(obj.data)
            obj.view.index = 1;
            obj.view.id    = '1';
            obj.view.name  = obj.data(1).sample_name;
        elseif row + 1 <= length(obj.data)
            obj.view.index = row + 1;
            obj.view.id    = num2str(row+1);
            obj.view.name  = obj.data(row+1).sample_name;
        end
        
    case 'prevsample'
        
        if row - 1 < 1
            obj.view.index = length(obj.data);
            obj.view.id    = num2str(length(obj.data));
            obj.view.name  = obj.data(end).sample_name;
        elseif row - 1 >= 1
            obj.view.index = row-1;
            obj.view.id    = num2str(row-1);
            obj.view.name  = obj.data(row-1).sample_name;
        end
        
end
  
updateSelectionText(obj);

end

% ---------------------------------------
% Keyboard Callback
% ---------------------------------------
function browseKeyCallback(obj, src, evt)

if strcmpi(evt.EventName, 'KeyPress')
    
    switch evt.Key
        
        case 'leftarrow'
            sampleSelectionCallback(obj, obj.controls.prev);
            
        case 'rightarrow'
            sampleSelectionCallback(obj, obj.controls.next);
            
        case 'return'
            
            switch get(src, 'tag')                
                
                case {'addpeak', 'editpeak', 'delpeak'}
                    peakListCallback(obj, src);
                    
                case {'nextsample', 'prevsample'}
                    sampleSelectionCallback(obj, src);
            end
            
        case 'space'
            return
 
    end
    
end

end

% ---------------------------------------
% Selection Text
% ---------------------------------------
function updateSelectionText(obj, varargin)

set(obj.controls.editID,   'string', obj.view.id);
set(obj.controls.editName, 'string', obj.view.name);

if ~isempty(obj.data) && obj.view.index ~= 0
    obj.updatePeakEditText();
    obj.updatePlot();
end

end

% ---------------------------------------
% Selection ID
% ---------------------------------------
function editIDCallback(obj, varargin)

n = get(obj.controls.editID, 'string');

if isempty(n) || isnan(str2double(n)) || isempty(obj.data)
    updateSelectionText(obj);
    return
elseif str2double(n) > length(obj.data)
    obj.view.index = length(obj.data);
    obj.view.id    = num2str(length(obj.data));
    obj.view.name  = obj.data(end).sample_name;
elseif str2double(n) < 1
    obj.view.index = 1;
    obj.view.id    = '1';
    obj.view.name  = obj.data(1).sample_name;
else
    obj.view.index = floor(str2double(n));
    obj.view.id    = num2str(floor(str2double(n)));
    obj.view.name  = obj.data(obj.view.index).sample_name;
end

updateSelectionText(obj);

end

% ---------------------------------------
% Selection Name
% ---------------------------------------
function editNameCallback(obj, ~, ~)

updateSelectionText(obj);

end

% ---------------------------------------
% Axes Toggle
% ---------------------------------------
function axesToggleCallback(obj, src, ~)

if ~strcmpi(get(src, 'style'), 'togglebutton')
    return
end

switch get(src, 'tag')
    
    case 'xmanual'
        
        if get(src, 'value')
            set(obj.controls.xAuto, 'value', 0);
        else
            set(obj.controls.xAuto, 'value', 1);
        end
        
    case 'xauto'
        
        if get(src, 'value')
            set(obj.controls.xManual, 'value', 0);
        else
            set(obj.controls.xManual, 'value', 1);
        end
        
    case 'ymanual'
        
        if get(src, 'value')
            set(obj.controls.yAuto, 'value', 0);
        else
            set(obj.controls.yAuto, 'value', 1);
        end
        
    case 'yauto'
        
        if get(src, 'value')
            set(obj.controls.yManual, 'value', 0);
        else
            set(obj.controls.yManual, 'value', 1);
        end
        
    otherwise
        return
        
end

obj.updateAxesLimitMode();
obj.updatePlot();

end

% ---------------------------------------
% Axes Limits
% ---------------------------------------
function axesLimitCallback(obj, src, ~)

if ~strcmpi(get(src, 'style'), 'edit')
    return
end

getStr = @(x) sprintf('%.3f', x);

str = get(src, 'string');
val = str2double(str);

switch get(src, 'tag')
    
    case 'xminedit'
        
        if isempty(str) || isnan(val) || isinf(val)
            set(src, 'string', getStr(obj.axes.xlim(1)));
        elseif val < obj.axes.xlim(2)
            obj.axes.xmode = 'manual';
            obj.axes.xlim(1) = val;
            obj.updateAxesXLim();
        else
            set(src, 'string', getStr(obj.axes.xlim(1)));
        end
        
    case 'xmaxedit'
        
        if isempty(str) || isnan(val) || isinf(val)
            set(src, 'string', getStr(obj.axes.xlim(2)));
        elseif val > obj.axes.xlim(1)
            obj.axes.xmode = 'manual';
            obj.axes.xlim(2) = val;
            obj.updateAxesXLim();
        else
            set(src, 'string', getStr(obj.axes.xlim(2)));
        end
        
    case 'yminedit'
        
        if isempty(str) || isnan(val) || isinf(val)
            set(src, 'string', getStr(obj.axes.ylim(1)));
            return
        elseif val < obj.axes.ylim(2)
            obj.axes.ymode = 'manual';
            obj.axes.ylim(1) = val;
            obj.updateAxesYLim();
        else
            set(src, 'string', getStr(obj.axes.ylim(1)));
            return
        end
        
    case 'ymaxedit'
        
        if isempty(str) || isnan(val) || isinf(val)
            set(src, 'string', getStr(obj.axes.ylim(2)));
            return
        elseif val > obj.axes.ylim(1)
            obj.axes.ymode = 'manual';
            obj.axes.ylim(2) = val;
            obj.updateAxesYLim();
        else
            set(src, 'string', getStr(obj.axes.ylim(2)));
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
function baselineCallback(obj, src, ~)

if isempty(obj.data) || obj.view.index == 0
    return
end

switch get(src, 'tag')
    
    case 'showbaseline'
        obj.plotBaseline();
        
    case 'applybaseline'
        obj.getBaseline();
        obj.plotBaseline();
        
    case 'clearbaseline'
        
        axesChildren = get(obj.axes.main, 'children');
        
        if ~isempty(axesChildren)
            axesTag = get(axesChildren, 'tag');
            
            if ~isempty(axesTag)
                axesBaseline = strcmpi(axesTag, 'baseline');
                
                if any(axesBaseline)
                    axesBaseline = axesChildren(axesBaseline);
                    
                    for i = 1:length(axesBaseline)
                        set(axesBaseline(i), 'visible', 'off');
                    end
                end
            end
        end
        
        if get(obj.controls.showBaseline, 'value')
            set(obj.controls.showBaseline, 'value', 0);
        end
        
        if isempty(obj.data) || obj.view.index == 0
            return
        elseif ~isempty(obj.data(obj.view.index).baseline)
            obj.data(obj.view.index).baseline = [];
        end
        
        set(obj.controls.smoothSlider, 'value', 5.5);
        set(obj.controls.asymSlider, 'value', -5.5);
        
end

end

% ---------------------------------------
% Peak Listbox
% ---------------------------------------
function peakListboxCallback(obj, ~, ~)

obj.updatePeakEditText();
obj.userPeak(1);

end

% ---------------------------------------
% Peak Edit Text
% ---------------------------------------
function peakEditTextCallback(obj, src, ~)

switch get(src, 'tag')
    
    case 'peakidedit'
        
        if ~isempty(obj.peaks.name)
            str = obj.peaks.name(get(obj.controls.peakList, 'value'), 1);
            set(obj.controls.peakIDEdit, 'string', str);
        end
        
    case 'peaktimeedit'
        
        getStr = @(x) sprintf('%.3f', x);
        
        str = get(obj.controls.peakTimeEdit, 'string');
        val = str2double(str);
        
        if isempty(obj.data) || obj.view.index == 0
            str = '';
        end
        
        if isempty(str) || isnan(val) || isinf(val)
            str = '';
        else
            str = getStr(val);
        end
        
        col = get(obj.controls.peakList, 'value');
        row = obj.view.index;
        
        if row ~= 0 && ~isempty(obj.peaks.time)
            time = obj.peaks.time{row,col};
        else
            time = val;
        end
        
        if val < obj.axes.xlim(1) || val > obj.axes.xlim(2)
            str = checkPeakEditText(obj, 'time');
            newPeak = 0;
        elseif isnumeric(time) && round(time * 1000) / 1000 ~= val
            newPeak = 1;
        else
            newPeak = 0;
        end
        
        set(obj.controls.peakTimeEdit, 'string', str);
        
        if strcmpi(get(obj.axes.zoom, 'enable'), 'off')
            if strcmpi(get(obj.menu.view.zoom, 'checked'), 'on')
                set(obj.axes.zoom, 'enable', 'on');
                set(obj.figure, 'windowbuttonmotionfcn', @(src, evt) figureMotionCallback(obj, src, evt));
            end
        end
        
        if ~isempty(get(obj.axes.main, 'buttondownfcn'))
            set(obj.axes.main, 'buttondownfcn', '');
        end
        
        if ~isempty(str) && newPeak == 1
            obj.getPeakFit();
        elseif isempty(str)
            set(obj.controls.peakWidthEdit, 'string', '');
            set(obj.controls.peakHeightEdit, 'string', '');
            set(obj.controls.peakAreaEdit, 'string', '');
        end
              
    case 'peakwidthedit'
        str = checkPeakEditText(obj, 'width');
        set(obj.controls.peakWidthEdit, 'string', str);

    case 'peakheightedit'
        str = checkPeakEditText(obj, 'height');
        set(obj.controls.peakHeightEdit, 'string', str);
        
    case 'peakareaedit'
        str = checkPeakEditText(obj, 'area');
        set(obj.controls.peakAreaEdit, 'string', str);
        
end
        
end

% ---------------------------------------
% Check Peak Edit Text
% ---------------------------------------
function str = checkPeakEditText(obj, field)

getStr = @(x) sprintf('%.3f', x);

if isempty(obj.data) || obj.view.index == 0
    str = '';
    return
end

col = get(obj.controls.peakList, 'value');
row = obj.view.index;

if isempty(col) || col == 0
    str = '';
    return
end

if length(obj.peaks.(field)(1,:)) >= col
    str = obj.peaks.(field){row, col};
else
    str = '';
end

if ~isempty(str)
    str = getStr(str);
end

end

% ---------------------------------------
% Display Peak
% ---------------------------------------
function peakDisplayCallback(obj, ~, ~)

obj.plotPeaks();

end

% ---------------------------------------
% Clear Peak
% ---------------------------------------
function peakClearCallback(obj, ~, ~)

if isempty(obj.data) || obj.view.index == 0
    return
end

col = get(obj.controls.peakList, 'value');
row = obj.view.index;

if isempty(col) || col == 0
    return
end

if length(obj.peaks.time(1,:)) >= col
    obj.peaks.time{row,col}   = [];
    obj.peaks.width{row,col}  = [];
    obj.peaks.height{row,col} = [];
    obj.peaks.area{row,col}   = [];
    obj.peaks.error{row,col}  = [];
    obj.peaks.fit{row,col}    = [];
end

set(obj.controls.peakTimeEdit,   'string', '');
set(obj.controls.peakWidthEdit,  'string', '');
set(obj.controls.peakHeightEdit, 'string', '');
set(obj.controls.peakAreaEdit,   'string', '');

offset = length(obj.peaks.name);

obj.table.main.Data{row, col+14 + offset*0} = [];
obj.table.main.Data{row, col+14 + offset*1} = [];
obj.table.main.Data{row, col+14 + offset*2} = [];
obj.table.main.Data{row, col+14 + offset*3} = [];

obj.plotPeaks();

end

% ---------------------------------------
% Select Peak
% ---------------------------------------
function peakSelectCallback(obj, src, evt)

switch evt.EventName
    
    case 'Action'
        
        currentObject = get(get(obj.figure, 'currentobject'), 'tag');
        
        if strcmpi(currentObject, src.Tag)
            
            if src.Value
                obj.userPeak(1);
            else
                obj.userPeak(0);
            end
            
        else
            set(src, 'value', obj.view.selectPeak);
        end
        
end

end

function correctPosition(x)

p1 = get(x, 'position');
p2 = get(x, 'extent');

if p1(3) < p2(3)
    p1(3) = p2(3);
end

if p1(4) < p2(4)
    p1(4) = p2(4);
end

set(x, 'position', p1);

end

% ---------------------------------------
% Push Button
% ---------------------------------------
function button = newPushButton(obj, parent, title, tag, position)

backgroundColor = [0.94, 0.94, 0.94];
foregroundColor = [0.00, 0.00, 0.00];
fontSize        = 11;

button = uicontrol(...
    'style',           'pushbutton',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
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
fontSize        = 11;

button = uicontrol(...
    'style',           'togglebutton',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'value',           value,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
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
fontSize        = 11;

text = uicontrol(...
    'style',           'text',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
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
fontSize        = 11;

text = uicontrol(...
    'style',           'edit',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
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
fontSize        = 10;

listbox = uicontrol(...
    'style',           'listbox',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor);

end

% ---------------------------------------
% Slider
% ---------------------------------------
function slider = newSlider(obj, parent, title, tag, position)

backgroundColor = [1.00, 1.00, 1.00];
foregroundColor = [0.00, 0.00, 0.00];
fontSize        = 11;

slider = uicontrol(...
    'style',           'slider',...
    'units',           'normalized',...
    'parent',          parent,...
    'string',          title,...
    'tag',             tag,...
    'position',        position,...
    'fontname',        obj.font,...
    'fontsize',        fontSize,...
    'backgroundcolor', backgroundColor,...
    'foregroundcolor', foregroundColor,...
    'horizontalalignment', 'center');

end