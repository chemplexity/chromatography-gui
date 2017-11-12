function toolboxPeakList(obj, ~, ~, varargin)

% Peak List (struct) > v0.0.5
%
% version (char) : 'x.y.z.date'
% name (char)    : 'peaklist'
% data (cell)    : peak name (char)

if isempty(varargin) || ~ischar(varargin{1})
    return
end

switch varargin{1}
    
    case {'initialize'}
        initalizePeakList(obj);
    
    case {'load_default', 'load_custom'}
        loadPeakList(obj, varargin{1});
        
    case {'save_default'}
        autosavePeakList(obj, varargin{1});
        
    case {'save_custom'}
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
        
        filePath = [obj.toolbox_path, filesep, obj.toolbox_data];
        
        if exist([filePath, filesep, 'peaklists'], 'dir')
            filePath = [filePath, filesep, 'peaklists'];
        elseif ~exist(filePath, 'dir')
            filePath = pwd;
        end
            
        data = importMAT('path', filePath);
        
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
elseif ~isfield(data, 'data') || ~iscell(data.data)
    return
else
    data = data.data;
end

switch mode
    
    case 'load_default'
        
        obj.peaks.name = data;
        
    case 'load_custom'

        str = 'Overwrite existing peak list?';
        msg = questdlg(str, 'Import', 'OK', 'Cancel', 'OK');
        
        switch msg
            
            case {'OK'}
        
                if ~isempty(obj.peaks.name)
                    for i = length(obj.peaks.name):-1:1
                        obj.tableDeletePeakColumn(i);
                    end
                end
                
                for i = 1:length(data)
                    
                    if ~ischar(data{i})
                        continue
                    end
                    
                    if ~any(strcmpi(data{i}, obj.peaks.name))
                        obj.tableAddPeakColumn(data{i})
                    end
                    
                end
                
                obj.updatePeakText();
                
            case {'Cancel'}
                
                return
                
        end
        
end

end

function savePeakList(obj, varargin)

% Peaklist data
peaklist.version = obj.version;
peaklist.name = 'peaklist';
peaklist.date = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
peaklist.data = obj.peaks.name(:);

% Suggested path
filePath = [obj.toolbox_path, filesep, obj.toolbox_data];

if exist([filePath, filesep, 'peaklists'], 'dir')
    filePath = [filePath, filesep, 'peaklists'];
elseif ~exist(filePath, 'dir')
    filePath = pwd;
end

% Suggested file
fileName = [datestr(now(), 'yyyymmdd'), '-peaklist'];
fileName = [fileName, '-', num2str(length(obj.peaks.name)), '-peaks'];

% Save MAT file
exportMAT(peaklist,...
    'path', filePath,...
    'suggest', fileName,...
    'varname', 'user_peaks');

end

function autosavePeakList(obj, varargin)

% Peaklist data
peaklist.version = obj.version;
peaklist.name = 'peaklist';
peaklist.date = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
peaklist.data = obj.peaks.name(:);

% File info
filePath = [obj.toolbox_path, filesep, obj.toolbox_config];
fileName = obj.default_peaklist;

% Save MAT file
exportMAT(peaklist,...
    'path', filePath,...
    'file', fileName,...
    'varname', 'user_peaks');

end
