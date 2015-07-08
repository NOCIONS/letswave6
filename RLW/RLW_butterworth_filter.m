%b,a
switch filter_type
    case 'lowpass'
        message_string{end+1}='Building lowpass filter.';
        [b,a]=butter(filtOrder,high_cutoff/fnyquist,'low');
    case 'highpass'
        message_string{end+1}='Building highpass filter.';
        [b,a]=butter(filtOrder,low_cutoff/fnyquist,'high');
    case 'bandpass'
        if mod(filter_order,2);
            message_string{end+1}='Warning : even number of filter order is needed.';
            message_string{end+1}=['Converting order from ' num2str(filtOrder) ' to ' num2str(filtOrder-1) '.'];
            filtOrder=filtOrder-1;
            filter_order=filtOrder;
        end
        filtOrder=filtOrder/2;
        message_string{end+1}='Building bandpass filter.';
        [bLow,aLow]=butter(filtOrder,high_cutoff/fnyquist,'low');
        [bHigh,aHigh]=butter(filtOrder,low_cutoff/fnyquist,'high');
        b=[bLow;bHigh];
        a=[aLow;aHigh];
    case 'notch'
        message_string{end+1}='Building notch filter.';
        [b,a]=butter(filtOrder,[low_cutoff/fnyquist high_cutoff/fnyquist],'stop');
end;
