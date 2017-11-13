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

obj.panel.table   = newPanel(obj, obj.figure, '', 'tablepanel', tablePos);
obj.panel.axes    = newPanel(obj, obj.figure, '', 'axespanel', plotPos);
obj.panel.control = newPanel(obj, obj.figure, '', 'controlpanel', ctrlPos);
obj.panel.select  = newPanel(obj, obj.figure, '', 'selectpanel', selectPos);

set(obj.panel.axes, 'backgroundcolor', obj.settings.axes.backgroundColor);

% ---------------------------------------
% Tabs
% ---------------------------------------
obj.panel.controlGroup = newTabGroup(obj.panel.control);
obj.panel.sampleGroup  = newTabGroup(obj.panel.select);

obj.panel.viewTab   = newTab(obj, obj.panel.controlGroup, 'View', 'view');
obj.panel.peakTab   = newTab(obj, obj.panel.controlGroup, 'Integrate', 'peak');
obj.panel.sampleTab = newTab(obj, obj.panel.sampleGroup,  'Sample', 'sample');

% ---------------------------------------
% Subpanels
% ---------------------------------------

% View Tab
xPos(1) = margin * 4;
xPos(2) = 0.70 + margin;
xPos(3) = 1.00 - margin * 8;
xPos(4) = 1.00 + margin * 2 - tablePos(2);

yPos(1) = xPos(1);
yPos(2) = xPos(2) - xPos(4) - margin * 2;
yPos(3) = xPos(3);
yPos(4) = xPos(4);

obj.panel.xlim = newPanel(obj, obj.panel.viewTab, 'X-Axis', 'xlim', xPos);
obj.panel.ylim = newPanel(obj, obj.panel.viewTab, 'Y-Axis', 'ylim', yPos);

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

obj.panel.peaklist  = newPanel(obj, obj.panel.peakTab, 'Peak List', '', peakPos);
obj.panel.baseline  = newPanel(obj, obj.panel.peakTab, 'Baseline',  '', basePos);
obj.panel.integrate = newPanel(obj, obj.panel.peakTab, 'Peak Data', '', intPos);

end

% ---------------------------------------
% Panel
% ---------------------------------------
function panel = newPanel(obj, parent, title, tag, position)

panel = uipanel(...
    'parent',          parent,...
    'tag',             tag,...
    'title',           title,...
    'titleposition',   'lefttop',...
    'units',           'normalized',...
    'position',        position,...
    'backgroundcolor', obj.settings.panel.backgroundColor,....
    'foregroundcolor', obj.settings.panel.foregroundColor,...
    'highlightcolor',  obj.settings.panel.highlightColor,...
    'bordertype',      obj.settings.panel.borderType,...
    'borderwidth',     obj.settings.panel.borderWidth,...
    'fontname',        obj.settings.panel.fontname,...
    'fontsize',        obj.settings.panel.fontsize);

end

% ---------------------------------------
% Tab Group
% ---------------------------------------
function tabgroup = newTabGroup(parent)

tabgroup = uitabgroup(...
    'parent',   parent,...
    'units',    'normalized',...
    'position', [0,0,1,1]);

end

% ---------------------------------------
% Tab
% ---------------------------------------
function tab = newTab(obj, parent, title, tag)

tab = uitab(...
    'parent',          parent,...
    'title',           title,...
    'tag',             tag,...
    'units',           'normalized',...
    'backgroundcolor', obj.settings.tab.backgroundColor,....
    'foregroundcolor', obj.settings.tab.foregroundColor);

end