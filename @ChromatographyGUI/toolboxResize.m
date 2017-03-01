function toolboxResize(obj, varargin)

% ---------------------------------------
% Positions
% ---------------------------------------
margin = 0.01;

tablePos(1) = 0.20 + margin;
tablePos(2) = 0.75 + margin;
tablePos(3) = 1.00 - tablePos(1) - margin;
tablePos(4) = 1.00 - tablePos(2) - margin;

plotPos(1) = tablePos(1);
plotPos(2) = margin;
plotPos(3) = tablePos(3);
plotPos(4) = 1.00 - tablePos(4) - margin * 3;

ctrlPos(1) = margin;
ctrlPos(2) = plotPos(2);
ctrlPos(3) = 1.00 - plotPos(3) - margin * 3;
ctrlPos(4) = plotPos(4);

selectPos(1) = ctrlPos(1);
selectPos(2) = tablePos(2);
selectPos(3) = ctrlPos(3);
selectPos(4) = tablePos(4);

xLimPos(1) = margin * 4;
xLimPos(2) = 0.70 + margin;
xLimPos(3) = 1.00 - margin * 8;
xLimPos(4) = 1.00 + margin * 2 - tablePos(2);

yLimPos(1) = xLimPos(1);
yLimPos(2) = xLimPos(2) - xLimPos(4) - margin * 2;
yLimPos(3) = xLimPos(3);
yLimPos(4) = xLimPos(4);

% ---------------------------------------
% Resize Callbacks
% ---------------------------------------
set(obj.panel.table, 'resizefcn', @(src,evt) resizeTablePanel(obj, src, evt, tablePos));
set(obj.panel.axes, 'resizefcn', @(src,evt) resizeAxesPanel(obj, src, evt, plotPos));
set(obj.panel.control, 'resizefcn', @(src,evt) resizeCtrlPanel(obj, src, evt, ctrlPos));
set(obj.panel.select, 'resizefcn', @(src,evt) resizeSelectPanel(obj, src, evt, selectPos));
set(obj.panel.xlim, 'resizefcn', @(src,evt) resizeXlimPanel(obj, src, evt, xLimPos));
set(obj.panel.ylim, 'resizefcn', @(src,evt) resizeYlimPanel(obj, src, evt, yLimPos));

end

% ---------------------------------------
% Table Panel
% ---------------------------------------
function resizeTablePanel(obj, ~, ~, pos)

obj.panel.table.Position = pos;

if isprop(obj.panel.table, 'InnerPosition')
    
    obj.table.main.Units  = 'pixels';
    obj.panel.table.Units = 'pixels';
    
    x1 = obj.panel.table.InnerPosition;
    x2 = obj.panel.table.Position;
    
    x(1) = x1(1) - x2(1);
    x(2) = x1(2) - x2(2);
    x(3) = x1(3);
    x(4) = x1(4);
    
    obj.table.main.Position = x;
    
    obj.table.main.Units  = 'normalized';
    obj.panel.table.Units = 'normalized';
    
end

end

% ---------------------------------------
% Axes Panel
% ---------------------------------------
function resizeAxesPanel(obj, ~, ~, pos)

obj.panel.axes.Position = pos;

if isprop(obj.axes.main, 'OuterPosition')
    
    x1 = obj.axes.main.Position;
    x2 = obj.axes.main.OuterPosition;
    
    x(1) = x1(1) - x2(1);
    x(2) = x1(2) - x2(2);
    x(3) = x1(3) - (x2(3)-1);
    x(4) = x1(4) - (x2(4)-1);
    
    if all(x > 0)
        obj.axes.main.Position = x;
        obj.axes.secondary.Position = x;
    end
    
end

end

% ---------------------------------------
% Control Panel
% ---------------------------------------
function resizeCtrlPanel(obj, ~, ~, pos)

obj.panel.control.Position = pos;

end

% ---------------------------------------
% Selection Panel
% ---------------------------------------
function resizeSelectPanel(obj, ~, ~, pos)

obj.panel.select.Position = pos;

if isprop(obj.controls.editID, 'OuterPosition')
    
    x1 = obj.controls.selectID.Extent;
    x2 = obj.controls.editID.OuterPosition;
    
    x(1) = 0.25 - (x1(3) / 2);
    x(2) = (x2(2) + (x2(4) / 2)) - (x1(4) / 2);
    x(3) = x1(3);
    x(4) = x1(4);
    
    if all(x > 0)
        obj.controls.selectID.Position = x;
    end
    
    x1 = obj.controls.selectName.Extent;
    x2 = obj.controls.editName.OuterPosition;
    
    x(1) = 0.25 - (x1(3) / 2);
    x(3) = x1(3);
    x(4) = x1(4);
    x(2) = (x2(2) + (x2(4) / 2)) - (x1(4) / 2);
    
    if all(x > 0)
        obj.controls.selectName.Position = x;
    end
    
end

end

% ---------------------------------------
% X-Limit Panel
% ---------------------------------------
function resizeXlimPanel(obj, ~, ~, pos)

obj.panel.xlim.Position = pos;

if isprop(obj.controls.xMin, 'OuterPosition')
    
    x1 = obj.controls.xMin.OuterPosition;
    x2 = obj.controls.xSeparator.Extent;
    
    x(3) = x2(3);
    x(4) = x2(4);
    x(1) = 0.5 - (x2(3) / 2);
    x(2) = (x1(2) + (x1(4) / 2)) - (x2(4) / 2);
    
    if all(x > 0)
        obj.controls.xSeparator.Position = x;
    end
    
end

end

% ---------------------------------------
% Y-Limit Panel
% ---------------------------------------
function resizeYlimPanel(obj, ~, ~, pos)

obj.panel.ylim.Position = pos;

if isprop(obj.controls.yMin, 'OuterPosition')
    
    x1 = obj.controls.yMin.OuterPosition;
    x2 = obj.controls.ySeparator.Extent;
    
    x(3) = x2(3);
    x(4) = x2(4);
    x(1) = 0.5 - (x2(3) / 2);
    x(2) = (x1(2) + (x1(4) / 2)) - (x2(4) / 2);
    
    if all(x > 0)
        obj.controls.ySeparator.Position = x;
    end
    
end

end
