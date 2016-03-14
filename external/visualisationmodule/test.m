axisHandle = show3dhead( header, data );
for i = 1 : 4000
    pause(0.01);
    update3dhead( axisHandle, 1, 1, 1, 1, i );
end