function [ resultAxisHandle resultFigureHandle ] = show3dhead( header, data, figure_name )
% let's wave function - show new 3D head
% 2 argument needed :
% first = header variable
% second = data variable
% return value = handle to axis

    import java.util.Hashtable;
    
    global lw_3dHeadHandles; % struct
    global lw_3dHeadIndex;
    global lw_DataToKeepDictionary;
    
    topHeadScale = 10;
    textScale = 12;
    lineScale = 11;
    
    if ( ~ isjava(lw_DataToKeepDictionary) )
        lw_DataToKeepDictionary = java.util.Hashtable;
    end
    
    if ( isempty(lw_3dHeadIndex) )
        lw_3dHeadIndex = 1;
    end
          
    % KEEP DATA WHERE TOPO IS ENABLED  
    valuesToKeep = logical( [ header.chanlocs.topo_enabled ] );
    electrodesInfos = header.chanlocs( valuesToKeep );
    numberOfValidElectrodes = length(electrodesInfos); 
    values = data( :, [valuesToKeep], :, :, :, : ); 

    % CREATE TOP HEAD FROM ELECTRODE POSITION
    electrodesPositions = zeros( [ numberOfValidElectrodes 3 ] );
    electrodesPositions = cat( 2, [electrodesInfos.X]', [electrodesInfos.Y]', [electrodesInfos.Z]' );
    electrodesPositions = electrodesPositions * topHeadScale;
    indexes = convhulln( electrodesPositions, {'Qt'} );
   % electrodesPositions(:,3) = electrodesPositions(:,3) * 1.2;
    % DRAW FIGURE
    figHandle = figure( 'Position', [ 20 100 500 400 ] );
    set(figHandle,'Name',figure_name);
    set(figHandle,'MenuBar','none');
    rotate3d on
    axisHandle = gca;  
    
    % LOAD BOTTOM HEAD
    numberOfVertices = dlmread( 'head.ply',' ', [ 3 2 3 2 ] );
    numberOfIndices = dlmread( 'head.ply',' ', [ 11 2 11 2 ] );
    modelHeadVertices = dlmread( 'head.ply',' ', [ 15 0 (15+numberOfVertices-1) 2 ] );
    modelHeadIndices = dlmread( 'head.ply',' ', [ (15+numberOfVertices) 1 (15+numberOfVertices+numberOfIndices-1) 3 ] );
    modelHeadNormals = zeros( [ numberOfValidElectrodes+numberOfVertices 3 ] );   
    modelHeadNormals(numberOfValidElectrodes+1:end, : ) = dlmread( 'head.ply',' ', [ 15 3 (15+numberOfVertices-1) 5 ] );


    % MODIFY MODEL HEAD POSITON AND ORIENTATION
    
    % INITIAL TRANSLATION
    modelHeadVertices(:,2) = ( modelHeadVertices(:,2) + 3.5 );
    modelHeadVertices(:,3) = ( modelHeadVertices(:,3) - 73 );

    % SCALING
    modelHeadVertices = modelHeadVertices * 2; 
    
    % ROTATION
    matrixRotation = eye(3,3);
    matrixRotation(1,1) = cos( pi / 2 );
    matrixRotation(1,2) = sin( pi / 2 );
    matrixRotation(2,1) = - sin( pi / 2 );
    matrixRotation(2,2) = cos( pi / 2 );
    
    for i = 1 : length(modelHeadVertices)
        modelHeadVertices(i,:) = modelHeadVertices(i,:) * matrixRotation;
    end
    
    % FINAL TRANSLATION
    modelHeadVertices(:,2) = ( modelHeadVertices(:,2) - 1 );
    modelHeadVertices(:,2) =  modelHeadVertices(:,2) * 1.1;
    
    % CREATE PATCH 
    headColor = zeros( [ numberOfValidElectrodes 1 ] );  
    modelHeadColor = zeros( [ length(modelHeadVertices) 1 ] ); 
    defaultColors = zeros( [ ( length(headColor) + length(modelHeadColor) ) 3 ] ); 
    defaultColors( 1 : length(headColor), 1:3 ) = 0.2;
    defaultColors( ( length(headColor) + 1 ) : end, 1:3 ) = 0.5;    
    modelHeadIndices = modelHeadIndices + 1 + numberOfValidElectrodes; % because indices in the file start at zero          
    allIndices = cat( 1, indexes, modelHeadIndices );
    xVertices = cat( 1, electrodesPositions( :, 1 ), modelHeadVertices( :, 1 ) );
    yVertices = cat( 1, electrodesPositions( :, 2 ), modelHeadVertices( :, 2 ) );
    zVertices = cat( 1, electrodesPositions( :, 3 ), modelHeadVertices( :, 3 ) );   
    
    % DRAW PATCH
    patchHandle = trisurf( allIndices, xVertices, yVertices, zVertices, 'FaceVertexCData', defaultColors );
    
   % FIGURE PROPERTIES
    xlabel('X axis');
    ylabel('Y axis');
    zlim( [ -15 15 ] );
    ylim( [ -15 15 ] );
    xlim( [ -15 15 ] );
    set( figHandle, 'Renderer', 'OpenGL' );
    set( figHandle, 'DoubleBuffer', 'on' );   
    axis off;
    grid off;
    opengl hardware;
    camva( 'manual' );
    camproj( 'orthographic' );
    camzoom(2);
    
    % COLORMAP
    colorbar( 'Position', [ 0.011 0.602 0.017 0.384 ]);
    caxis( [-20 20] );
    
    % CHANGE X AXIS ORIENTATION 
    set(gca,'XDir','reverse');
    
    % LIGHTING
    camlight;
    lighting gouraud;
    shading interp;
    set( gca, 'AmbientLightColor', [ 1 1 1 ] );
    set( patchHandle, 'VertexNormals',  modelHeadNormals, 'AmbientStrength', 1 );
    
    % DRAW LABELS ON HEAD MESH
    for i = 1 : length(electrodesInfos)
    text( electrodesInfos(i).X*textScale, electrodesInfos(i).Y*textScale, electrodesInfos(i).Z*textScale, ...
        electrodesInfos(i).labels, 'Color', [0.6 0.6 0.6], 'FontSize', 9, ...
        'HorizontalAlignment', 'center' );
    line( [ 0 electrodesInfos(i).X*lineScale ], [ 0 electrodesInfos(i).Y*lineScale ], ...
        [ 0 electrodesInfos(i).Z*lineScale ], 'Color', [1 1 1] );
    end

    % SAVE TO GLOBAL
  	lw_DataToKeepDictionary.put( num2str(axisHandle), lw_3dHeadIndex );
    lw_3dHeadHandles(lw_3dHeadIndex).handle = axisHandle;
    lw_3dHeadHandles(lw_3dHeadIndex).values = values;
    lw_3dHeadHandles(lw_3dHeadIndex).nbElectrodes = numberOfValidElectrodes;
    lw_3dHeadHandles(lw_3dHeadIndex).headHandle = patchHandle; 
    lw_3dHeadHandles(lw_3dHeadIndex).defaultColor = defaultColors; 
    lw_3dHeadIndex = lw_3dHeadIndex + 1;
    
    % OUTPUT
    resultAxisHandle = axisHandle;
    resultFigureHandle = figHandle;
    

%--------------------------------------------------------------------------    
