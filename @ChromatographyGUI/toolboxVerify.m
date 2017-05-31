function toolboxVerify(obj, varargin)

filePath = fileparts(fileparts(mfilename('fullpath')));

% importagilent.m --> importAgilent.m
x1 = 'importagilent';
x2 = 'importAgilent';

xPath = [filePath, filesep, 'src', filesep, 'file'];

renameFile(x1, x2, xPath);

end

function renameFile(x1, x2, xPath)

if exist(xPath, 'dir')
    
    xDir = dir(xPath);
    
    if any(strcmp([x1, '.m'], {xDir.name}))
        
        y1 = [xPath, filesep, x1, '.m'];
        y2 = [xPath, filesep, '_', x1, '.m'];
        
        movefile(y1, y2, 'f');
        
        y1 = y2;
        y2 = [xPath, filesep, x2, '.m'];
        
    	movefile(y1, y2, 'f');
        
    end
    
end
    
end