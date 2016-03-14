function update3dhead( axisHandle, epoch, index, z, y, x )
% UPDATE3DHEAD update the top head colors of the corresponding axis 
% Arguments are from 6 dimension data
% No need to put number of electrodes because it is related to the axis Handle

    global lw_3dHeadHandles; % struct
    global lw_DataToKeepDictionary; %java Hashtable
    
    if ( ~ isjava(lw_DataToKeepDictionary) )
        return;
    end

    index3dHead = lw_DataToKeepDictionary.get( num2str(axisHandle) );
      
    values = lw_3dHeadHandles(index3dHead).values;
   
    map = colormap(axisHandle);
    colormapLength = length(map);
    [ cmin cmax ] = caxis(axisHandle);
     
    colors = get( lw_3dHeadHandles(index3dHead).headHandle, 'FaceVertexCData' );

    for i = 1 : lw_3dHeadHandles(index3dHead).nbElectrodes
        colorIndex = fix( ( ( values( epoch, i, index, z, y, x ) - cmin ) / ...
            ( cmax - cmin ) ) * colormapLength ) + 1;
        colorIndex ( colorIndex < 1 ) = 1;
        colorIndex ( colorIndex > colormapLength ) = colormapLength;
        colorIndex = map(  int32(colorIndex), 1:3 );
        colors( i, 1:3 ) = colorIndex;
    end
    
    set( lw_3dHeadHandles(index3dHead).headHandle, 'FaceVertexCData', colors );