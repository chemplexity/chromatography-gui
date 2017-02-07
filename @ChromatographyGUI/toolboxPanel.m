function toolboxPanel(obj, varargin)

% ---------------------------------------
% Panels
% ---------------------------------------
margin = 0.01;

% Table (upper right)
tablePos(1) = 0.20 + margin;
tablePos(2) = 0.75 + margin;
tablePos(3) = 1.00 - tablePos(1) - margin;
tablePos(4) = 1.00 - tablePos(2) - margin;

% Plot (lower right)
plotPos(1) = tablePos(1);
plotPos(2) = margin;
plotPos(3) = tablePos(3);
plotPos(4) = 1.00 - tablePos(4) - margin * 3;

% Controls (lower left)
ctrlPos(1) = margin;
ctrlPos(2) = plotPos(2);
ctrlPos(3) = 1.00 - plotPos(3) - margin * 3;
ctrlPos(4) = plotPos(4);

% Selection (upper left)
selectPos(1) = ctrlPos(1);
selectPos(2) = tablePos(2);
selectPos(3) = ctrlPos(3);
selectPos(4) = tablePos(4);

obj.panel.table   = newPanel(obj, obj.figure, '', 'tablepanel',   tablePos);
obj.panel.axes    = newPanel(obj, obj.figure, '', 'axespanel',    plotPos);
obj.panel.control = newPanel(obj, obj.figure, '', 'controlpanel', ctrlPos);
obj.panel.select  = newPanel(obj, obj.figure, '', 'selectpanel',  selectPos);

set(obj.panel.axes, 'backgroundcolor', 'white');

% ---------------------------------------
% Tabs
% ---------------------------------------
obj.panel.controlGroup = newTabGroup(obj.panel.control);
obj.panel.viewTab      = newTab(obj.panel.controlGroup, 'View',      'viewtab');
obj.panel.peakTab      = newTab(obj.panel.controlGroup, 'Integrate', 'peaktab');

obj.panel.selectGroup  = newTabGroup(obj.panel.select);
obj.panel.selectTab    = newTab(obj.panel.selectGroup, 'Select', 'selecttab');

% ---------------------------------------
% Subpanels
% ---------------------------------------

% View Tab
xLimPos(1) = margin * 4;
xLimPos(2) = 0.70 + margin;
xLimPos(3) = 1.00 - margin * 8;
xLimPos(4) = 1.00 + margin * 2 - tablePos(2);

yLimPos(1) = xLimPos(1);
yLimPos(2) = xLimPos(2) - xLimPos(4) - margin * 2;
yLimPos(3) = xLimPos(3);
yLimPos(4) = xLimPos(4);

obj.panel.xlim = newPanel(obj, obj.panel.viewTab, 'X-Axis', 'xlimpanel', xLimPos);
obj.panel.ylim = newPanel(obj, obj.panel.viewTab, 'Y-Axis', 'ylimpanel', yLimPos);

% Integrate Tab
peakPos(1) = margin * 4;
peakPos(2) = 0.65 + margin;
peakPos(3) = 1.00 - margin * 8;
peakPos(4) = 1.00 - margin * 2 - peakPos(2);

basePos(1) = peakPos(1);
basePos(2) = peakPos(2) - peakPos(4) / 1.25 - margin * 2;
basePos(3) = peakPos(3);
basePos(4) = peakPos(4) / 1.25;

intPos(1) = peakPos(1);
intPos(2) = margin * 2;
intPos(3) = peakPos(3);
intPos(4) = basePos(2) - margin * 4;

obj.panel.peakList  = newPanel(obj, obj.panel.peakTab, 'Peak List', 'peakpanel',      peakPos);
obj.panel.baseline  = newPanel(obj, obj.panel.peakTab, 'Baseline',  'baselinepanel',  basePos);
obj.panel.integrate = newPanel(obj, obj.panel.peakTab, 'Options',   'integratepanel', intPos);

end

% ---------------------------------------
% Panel
% ---------------------------------------
function panel = newPanel(obj, parent, title, tag, position)

backgroundColor = [0.99, 0.99, 0.99];
foregroundColor = [0.00, 0.00, 0.00];
highlightColor  = [0.20, 0.20, 0.20];
borderType      = 'line';
borderWidth     = 1;
fontsize        = 12;

panel = uipanel(...
    'parent',          parent,...
    'title',           title,...
    'tag',             tag,...
    'position',        position,...
    'units',           'normalized',...
    'titleposition',   'lefttop',...
    'backgroundcolor', backgroundColor,....
    'foregroundcolor', foregroundColor,...
    'highlightcolor',  highlightColor,...
    'bordertype',      borderType,...
    'borderwidth',     borderWidth,...
    'fontname',        obj.font,...
    'fontsize',        fontsize);

end

% ---------------------------------------
% Tab Group
% ---------------------------------------
function tabgroup = newTabGroup(parent)

tabgroup = uitabgroup(...
    'parent',   parent,...
    'units',    'normalized',...
    'position', [0.0, 0.0, 1.0, 1.0]);

end

% ---------------------------------------
% Tab
% ---------------------------------------
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