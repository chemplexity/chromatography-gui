function toolboxPanel(obj, varargin)

% ---------------------------------------
% Defaults
% ---------------------------------------
margin = 0.01;

% ---------------------------------------
% Panels
% ---------------------------------------

% Table (upper right)
p1(1) = 0.20 + margin;
p1(2) = 0.75 + margin;
p1(3) = 1.00 - p1(1) - margin;
p1(4) = 1.00 - p1(2) - margin;

% Plot (lower right)
p2(1) = p1(1);
p2(2) = margin;
p2(3) = p1(3);
p2(4) = 1.00 - p1(4) - margin * 3;

% Controls (lower left)
p3(1) = margin;
p3(2) = p2(2);
p3(3) = 1.00 - p2(3) - margin * 3;
p3(4) = p2(4);

% Selection (upper left)
p4(1) = p3(1);
p4(2) = p1(2);
p4(3) = p3(3);
p4(4) = p1(4);

obj.panel.table   = newPanel(obj.figure, '', 'tablepanel',   p1);
obj.panel.axes    = newPanel(obj.figure, '', 'axespanel',    p2);
obj.panel.control = newPanel(obj.figure, '', 'controlpanel', p3);
obj.panel.select  = newPanel(obj.figure, '', 'selectpanel',  p4);

% ---------------------------------------
% Tabs
% ---------------------------------------
obj.panel.controlGroup = newTabGroup(obj.panel.control);
obj.panel.viewTab      = newTab(obj.panel.controlGroup, 'View', 'viewtab');
obj.panel.peakTab      = newTab(obj.panel.controlGroup, 'Integrate', 'peaktab');

obj.panel.selectGroup  = newTabGroup(obj.panel.select);
obj.panel.selectTab    = newTab(obj.panel.selectGroup, 'Select', 'selecttab');

% ---------------------------------------
% Subpanels
% ---------------------------------------

% View Tab
v1(1) = margin * 4;
v1(2) = 0.70 + margin;
v1(3) = 1.00 - margin * 8;
v1(4) = 1.00 + margin * 2 - p1(2);

v2(1) = v1(1);
v2(2) = v1(2) - v1(4) - margin * 2;
v2(3) = v1(3);
v2(4) = v1(4);

v3(1) = v1(1);
v3(2) = margin * 2;
v3(3) = v1(3);
v3(4) = v2(2) - margin * 4;

obj.panel.xlim = newPanel(obj.panel.viewTab, 'X-Axis', 'xlimpanel', v1);
obj.panel.ylim = newPanel(obj.panel.viewTab, 'Y-Axis', 'ylimpanel', v2);
obj.panel.todo = newPanel(obj.panel.viewTab, '',       'todopanel', v3);

set(obj.panel.xlim, 'backgroundcolor', [0.99, 0.99, 0.99]);
set(obj.panel.ylim, 'backgroundcolor', [0.99, 0.99, 0.99]);
set(obj.panel.todo, 'backgroundcolor', [0.99, 0.99, 0.99]);

% Integrate Tab
i1(1) = margin * 4;
i1(2) = 0.65 + margin;
i1(3) = 1.00 - margin * 8;
i1(4) = 1.00 - margin * 2 - i1(2);

i2(1) = i1(1);
i2(2) = i1(2) - i1(4) / 1.25 - margin * 2;
i2(3) = i1(3);
i2(4) = i1(4) / 1.25;

i3(1) = i1(1);
i3(2) = margin * 2;
i3(3) = i1(3);
i3(4) = i2(2) - margin * 4;

obj.panel.peakList  = newPanel(obj.panel.peakTab,  'Peak List', 'peakpanel',      i1);
obj.panel.baseline  = newPanel(obj.panel.peakTab,  'Baseline',  'baselinepanel',  i2);
obj.panel.integrate = newPanel(obj.panel.peakTab,  'Options',   'integratepanel', i3);

set(obj.panel.peakList,  'backgroundcolor', [0.99, 0.99, 0.99]);
set(obj.panel.baseline,  'backgroundcolor', [0.99, 0.99, 0.99]);
set(obj.panel.integrate, 'backgroundcolor', [0.99, 0.99, 0.99]);

% ---------------------------------------
% Callbacks
% ---------------------------------------
set(obj.panel.table,   'resizefcn', @(src, evt) resizeTablePanel(obj, src, evt, p1));
set(obj.panel.axes,    'resizefcn', @(src, evt) resizeAxesPanel(obj,  src, evt, p2));
set(obj.panel.control, 'resizefcn', @(src, evt) resizeCtrlPanel(obj,  src, evt, p3));
set(obj.panel.select,  'resizefcn', @(src, evt) resizeSelPanel(obj,   src, evt, p4));
set(obj.panel.xlim,    'resizefcn', @(src, evt) resizeXlimPanel(obj,  src, evt, v1));
set(obj.panel.ylim,    'resizefcn', @(src, evt) resizeYlimPanel(obj,  src, evt, v2));

end

function resizeTablePanel(obj, varargin)

set(obj.panel.table, 'position', varargin{3});
set(obj.table.main,  'units', 'pixels');
set(obj.panel.table, 'units', 'pixels');

x1 = get(obj.panel.table, 'innerposition');
x2 = get(obj.panel.table, 'position');

x(1) = x1(1) - x2(1);
x(2) = x1(2) - x2(2);
x(3) = x1(3);
x(4) = x1(4);

set(obj.table.main,  'position', x);
set(obj.table.main,  'units', 'normalized');
set(obj.panel.table, 'units', 'normalized');

end

function resizeAxesPanel(obj, varargin)

set(obj.panel.axes, 'position', varargin{3});

x1 = get(obj.axes.main, 'position');
x2 = get(obj.axes.main, 'outerposition');

x(1) = x1(1) - x2(1);
x(2) = x1(2) - x2(2);
x(3) = x1(3) - (x2(3)-1);
x(4) = x1(4) - (x2(4)-1);

set(obj.axes.main, 'position', x);
set(obj.axes.secondary, 'position', x);

end

function resizeCtrlPanel(obj, varargin)

set(obj.panel.control, 'position', varargin{3});

end

function resizeSelPanel(obj, varargin)

set(obj.panel.select, 'position', varargin{3});

if isfield(obj.controls, 'selectID')

    x1 = get(obj.controls.selectID, 'extent');
    x2 = get(obj.controls.editID, 'outerposition');
    
    x(1) = 0.25 - (x1(3) / 2);
    x(3) = x1(3);
    x(4) = x1(4);
    x(2) = (x2(2) + (x2(4) / 2)) - (x1(4) / 2);
    
    set(obj.controls.selectID, 'position', x);
    
    x1 = get(obj.controls.selectName, 'extent');
    x2 = get(obj.controls.editName, 'outerposition');
    
    x(1) = 0.25 - (x1(3) / 2);
    x(3) = x1(3);
    x(4) = x1(4);
    x(2) = (x2(2) + (x2(4) / 2)) - (x1(4) / 2);
    
    set(obj.controls.selectName, 'position', x);
    
end

end

function resizeXlimPanel(obj, varargin)

set(obj.panel.xlim, 'position', varargin{3});

if isfield(obj.controls, 'xSeparator')
    
    x1 = get(obj.controls.xMin, 'outerposition');
    x2 = get(obj.controls.xSeparator, 'extent');
    
    x(3) = x2(3);
    x(4) = x2(4);
    x(1) = 0.5 - (x2(3) / 2);
    x(2) = (x1(2) + (x1(4) / 2)) - (x2(4) / 2);
    
    set(obj.controls.xSeparator, 'position', x);
    
end

end

function resizeYlimPanel(obj, varargin)

set(obj.panel.ylim, 'position', varargin{3});

if isfield(obj.controls, 'ySeparator')
    
    x1 = get(obj.controls.yMin, 'outerposition');
    x2 = get(obj.controls.ySeparator, 'extent');
    
    x(3) = x2(3);
    x(4) = x2(4);
    x(1) = 0.5 - (x2(3) / 2);
    x(2) = (x1(2) + (x1(4) / 2)) - (x2(4) / 2);
    
    set(obj.controls.ySeparator, 'position', x);
    
end

end

function panel = newPanel(parent, title, tag, position)

backgroundColor = [0.96, 0.96, 0.96];
foregroundColor = [0.00, 0.00, 0.00];
borderType      = 'line';
borderWidth     = 1.0;

panel = uipanel(...
    'parent',          parent,...
    'title',           title,...
    'tag',             tag,...
    'position',        position,...
    'units',           'normalized',...
    'titleposition',   'lefttop',...
    'backgroundcolor', backgroundColor,....
    'foregroundcolor', foregroundColor,...
    'bordertype',      borderType,...
    'borderwidth',     borderWidth);

end

function tabgroup = newTabGroup(parent)

tabgroup = uitabgroup(...
    'parent',   parent,...
    'units',    'normalized',...
    'position', [0.0, 0.0, 1.0, 1.0]);

end

function tab = newTab(parent, title, tag)

backgroundColor = [0.99, 0.99, 0.99];
foregroundColor = [0.00, 0.00, 0.00];

tab = uitab(...
    'parent',          parent,...
    'title',           title,...
    'tag',             tag,...
    'units',           'normalized',...
    'backgroundcolor', backgroundColor,....
    'foregroundcolor', foregroundColor);

end