function toolboxAlign(obj, varargin)

% ---------------------------------------
% Text Size
% ---------------------------------------
x = {...
    'selectID',...
    'selectName',...
    'xSeparator',...
    'ySeparator',...
    'peakIDText',...
    'peakTimeText',...
    'peakWidthText',...
    'peakHeightText',...
    'peakAreaText'};

textPosition(obj,x);

% ---------------------------------------
% Vertical Alignment
% ---------------------------------------
x = {};
h = 'none';
v = 'middle';

x{end+1} = {'selectID', 'editID'};
x{end+1} = {'selectName', 'editName'};
x{end+1} = {'prev', 'next'};
x{end+1} = {'xSeparator', 'xMin', 'xMax'};
x{end+1} = {'ySeparator', 'yMin', 'yMax'};
x{end+1} = {'xUser', 'xAuto'};
x{end+1} = {'yUser', 'yAuto'};
x{end+1} = {'showBaseline', 'applyBaseline' 'clearBaseline'};
x{end+1} = {'peakIDText', 'peakIDEdit'};
x{end+1} = {'peakTimeText', 'peakTimeEdit'};
x{end+1} = {'peakWidthText', 'peakWidthEdit'};
x{end+1} = {'peakHeightText', 'peakHeightEdit'};
x{end+1} = {'peakAreaText', 'peakAreaEdit'};

alignComponents(obj,x,h,v)

% ---------------------------------------
% Horizontal Alignment
% ---------------------------------------
x = {};
h = 'center';
v = 'none';

x{end+1} = {'selectID', 'selectName'};
x{end+1} = {'editID', 'editName'};
x{end+1} = {'showPeak', 'selectPeak', 'clearPeak'};
x{end+1} = {'addPeak', 'editPeak', 'delPeak'};
x{end+1} = {'peakIDText', 'peakTimeText', 'peakWidthText', 'peakHeightText', 'peakAreaText'};
x{end+1} = {'peakIDEdit', 'peakTimeEdit', 'peakWidthEdit', 'peakHeightEdit', 'peakAreaEdit'};

alignComponents(obj,x,h,v)

end

function alignComponents(obj,x,h,v)

for i = 1:length(x)
    
    y = [];
    
    for j = 1:length(x{i})
        y = [y, obj.controls.(x{i}{j})];
    end
    
    align(y,h,v);
    
end

end

function textPosition(obj,x)

for i = 1:length(x)
    
    t = obj.controls.(x{i});
    
    t.Units = 'characters';
    
    p = t.Position;
    
    if isprop(t, 'Extent')
        w = t.Extent(3);
        h = t.Extent(4);
    else
        w = length(t.String) + 1;
        h = 1.25;
    end
    
    if p(3) < w
        
        t.Position(3) = w + 0.1;
        
        dx = p(1) - ((w - p(3) - 0.1) / 2);
        
        if dx > 0
            t.Position(1) = dx;
        end
        
    end
    
    if p(4) < h
        
        t.Position(4) = h;
        
        dx = p(2) - (h - p(4));
        
        if dx > 0
            t.Position(2) = dx;
        end
        
    end
    
    t.Units = 'normalized';
    
end

end