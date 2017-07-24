function toolboxPeakList(obj, ~, ~, varargin)

% Peak List (struct) > v0.0.5
%
% version (char)    : 'x.y.z.date'
% name (char)       : 'peaklist'
% data (cell) (nx1) : peak name (char) 

if isempty(varargin) || ~ischar(varargin{1})
    return
end

switch varargin{1}
    
    case {'initialize'}
        initalizePeakList(obj);
    
    case {'load_default', 'load_custom'}
        loadPeakList(obj, varargin{1});
        
    case {'save_default', 'save_custom'}
        savePeakList(obj, varargin{1});
        
    case {'apply'}
        applyPeakList(obj);
        
    otherwise
        return
        
end

end

function initalizePeakList(obj, varargin)

obj.peaks.name = {...
    'C36'; 'C37';...
    'C37:3 Me'; 'C37:2 Me';...
    'C38:3 Et'; 'C38:2 Et';...
    'C38:3 Me'; 'C38:2 Me';...
    'C39:3 Et'; 'C39:2 Et'};

% obj.peaks.name = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};

end

function loadPeakList(obj, mode, varargin)

switch mode
    
    case 'load_default'
        
        file = [...
            obj.toolbox_path, filesep,...
            obj.toolbox_config, filesep,....
            obj.default_peaklist];
        
        if exist(file, 'file')
            data = importMAT('file', file);
        else
            initalizePeakList(obj);
            return
        end
        
    case 'load_custom'
        
        data = importMAT('path', obj.toolbox_path);
        
    otherwise
        return
        
end

if isempty(data) || ~isstruct(data) || ~isfield(data, 'user_peaks')
    return
else
    data = data.user_peaks;
end

if ~isfield(data, 'name') || ~strcmpi(data.name, 'peaklist')
    return
elseif ~isfield(data, 'data') || isempty(data.data) || ~iscell(data.data)
    return
else
    data = data.data;
end

switch mode
    
    case 'load_default'
        
        obj.peaks.name = data;
        
    case 'load_custom'

        for i = 1:length(data)
    
            if ~ischar(data{i})
                continue
            end
    
            if ~any(strcmpi(data{i}, obj.peaks.name))
                obj.peakAddColumn(data{i})
            end
            
        end
    
end

end

function savePeakList(obj, varargin)

if isempty(obj.peaks.name)
    return
end

user_peaks.version = obj.version;
user_peaks.name    = 'peaklist';
user_peaks.data    = obj.peaks.name;

exportMAT(user_peaks,...
    'path', [obj.toolbox_path, filesep, obj.toolbox_config],...
    'varname', 'user_peaks',...
    'suggest', 'default_peaklist');

end