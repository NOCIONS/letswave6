function LW_createPlugin(varargin)
    letswaveDir = which('letswave');
    [p, n, e] = fileparts(letswaveDir);
    pluginDir = fullfile(p, 'plugins');
    plgnInfo = inputdlg({'plugin description:', 'plugin function'});
    plugin_data.string = plgnInfo{1};    
    [p, n, e] = fileparts(plgnInfo{2});
    plugin_data.function = n;
    savePlugin = 'yes';
    if isempty(which('n'))
        savePlugin = questdlg(sprintf('WARNING: the function you added does not belong to the current matlab path. You will either have to add the funcion location to the path, or copy your function to the plugins folder in the letswave path.\n\nDo you want to add the plugin anyway?'), 'function not in path', 'yes', 'no', 'no');
    end
    if strcmp(savePlugin, 'yes')
        save([fullfile(pluginDir, n), '.plugin'],'-MAT','plugin_data');
    end
    