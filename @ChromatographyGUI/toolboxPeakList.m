function toolboxPeakList(obj, ~, ~, varargin)

% ------------------------------------------
% Peaklist (>v0.0.5)
% ------------------------------------------
% default_peaklist.mat (struct)
%
%   version (char) : 'x.y.z.date'
%   name    (char) : 'peaklist'
%   date    (char) : 'yyyy-mm-ddTHH:MM:SS'
%   data    (cell) : peak names

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

% ------------------------------------------
% Default Peaklist
% ------------------------------------------
function initalizePeakList(obj, varargin)

% Ocean Alkenones (../data/examples/*.D)
obj.peaks.name = {...
    'C36'; 'C37';...
    'C37:3 Me'; 'C37:2 Me';...
    'C38:3 Et'; 'C38:2 Et';...
    'C38:3 Me'; 'C38:2 Me';...
    'C39:3 Et'; 'C39:2 Et'};

end

% ------------------------------------------
% Load Peaklist (.mat)
% ------------------------------------------
function loadPeakList(obj, mode, varargin)

switch mode
    
    case 'load_default'
        
        file = [getDefaultFilepath(obj), filesep, getDefaultFilename(obj)];
        
        if exist(file, 'file')
            data = importMAT('file', file);
        else
            initalizePeakList(obj);
            return
        end
        
    case 'load_custom'
        
        data = importMAT('path', getSuggestedFilepath(obj));
        
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
        
        if ~isempty(obj.peaks.name)
            str = 'Overwrite existing peak list and peak data?';
            msg = questdlg(str, 'Import', 'OK', 'Cancel', 'OK');
        else
            msg = 'OK';
        end
        
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

% ------------------------------------------
% Save Peaklist (.mat)
% ------------------------------------------
function savePeakList(obj, varargin)

peaklist = compilePeaklist(obj);

exportMAT(peaklist,...
    'path',    getSuggestedFilepath(obj),...
    'suggest', getSuggestedFilename(obj),...
    'varname', 'user_peaks');

end

% ------------------------------------------
% Autosave Peaklist (default_peaklist.mat)
% ------------------------------------------
function autosavePeakList(obj, varargin)

peaklist = compilePeaklist(obj);

exportMAT(peaklist,...
    'path',    getDefaultFilepath(obj),...
    'file',    getDefaultFilename(obj),...
    'varname', 'user_peaks');

end

% ------------------------------------------
% Compile Peaklist (struct)
% ------------------------------------------
function peaklist = compilePeaklist(obj, varargin)

peaklist.version = obj.version;
peaklist.name    = 'peaklist';
peaklist.date    = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
peaklist.data    = obj.peaks.name(:);

end

% ------------------------------------------
% Default Filepath (../config/)
% ------------------------------------------
function filepath = getDefaultFilepath(obj, varargin)

filepath = [obj.toolbox_path, filesep, obj.toolbox_config];

end

% ------------------------------------------
% Default Filepath (default_peaklist.mat)
% ------------------------------------------
function filename = getDefaultFilename(obj, varargin)

filename = obj.toolbox_peaklist;

end

% ------------------------------------------
% Suggested Filepath (../data/peaklists/)
% ------------------------------------------
function filepath = getSuggestedFilepath(obj, varargin)

filepath = [obj.toolbox_path, filesep, obj.toolbox_data];

if exist([filepath, filesep, 'peaklists'], 'dir')
    filepath = [filepath, filesep, 'peaklists'];
else
    filepath = pwd;
end

end

% ------------------------------------------
% Suggested Filename (yyyymmdd-peaklist-#-peaks)
% ------------------------------------------
function filename = getSuggestedFilename(obj, varargin)

d = datestr(now(), 'yyyymmdd');
n = num2str(length(obj.peaks.name));

filename = [d, '-peaklist-', n, '-peaks'];

end