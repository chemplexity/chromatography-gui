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

% ---------------------------------------
% Resize Callbacks
% ---------------------------------------
set(obj.panel.axes, 'resizefcn', @(src,evt) resizeAxesPanel(obj, src, evt, plotPos));

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

if isfield(obj.view, 'plotLabel')
    obj.updatePlotLabelPosition();
end

end