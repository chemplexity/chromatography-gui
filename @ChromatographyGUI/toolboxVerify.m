function toolboxVerify(obj, varargin)

filePath = fileparts(fileparts(mfilename('fullpath')));

% importagilent.m --> importAgilent.m
x = 'importAgilent.m';
xPath = [filePath, filesep, 'src', filesep, 'file', filesep, x];

renameFile(x, xPath);

end

function renameFile(x, xPath)

if exist(xPath, 'file')
    
    [~, xName] = fileattrib(xPath);
    
    if isstruct(xName)
    
        [xPath, xName] = fileparts(xName.Name);
        
        if ~strcmp([xName, '.m'], x)
            
            x1 = [xPath, filesep, xName, '.m'];
            x2 = [xPath, filesep, '_', x];
            
            movefile(x1, x2, 'f');
            
            x1 = x2;
            x2 = [xPath, filesep, x];
            
            movefile(x1, x2, 'f');
            
        end 
        
    end
    
end

end