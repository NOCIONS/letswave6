function xtickinterval(interval,anchor,varargin)
% Force tick spacing to a specified interval regardless of axis limits
%
% SYNTAX
%
%   XTICKINTERVAL(INTERVAL)
%   XTICKINTERVAL(INTERVAL,ANCHOR)
%   XTICKINTERVAL('off') or XTICKINTERVAL off
%   XTICKINTERVAL(HANDLE,...)
%
% DESCRIPTION
% 
% XTICKINTERVAL(INTERVAL) Set the x-axis ticks to integer multiples
% of INTERVAL, regardless of the axis limits. INTERVAL must be real and
% positive.
%
% XTICKINTERVAL(INTERVAL,ANCHOR) Set the x-axis ticks to values passing
% through ANCHOR and spaced by INTERVAL.  ANCHOR does not have to be
% within the current axis limits.
%
% XTICKINTERVAL('off') Reset the axes tick and ticklabel state to their
% values before the first call to XTICKINTERVAL and delete the
% XTICKINTERVAL listener.
%
% XTICKINTERVAL(HANDLE,...) Set the tick interval of the axes specified by
% HANDLE instead of the current axes.
%
% REMARKS
%
% XTICKINTERVAL will create ticks at multiples of INTERVAL, regardless of
% the axis limits.  This can result in too many ticks if the interval is
% small relative to the limits, or no ticks if the interval is larger than
% the range of the axis limits.
%
% XTICKINTERVAL sets the axes' XTickLabelMode property to 'auto'.  If this
% property is changed, or if values for 'XTickLabel' are specified after
% calling XTICKLABEL, the tick labels may be incorrect if the axis limits
% change.
%
% Note that the current version of XTICKINTERVAL does not support
% log-scaled axes.  

% xtickinterval.m 
% Copyright (c) 2011 by John Barber
% Distribution and use of this software is governed by the terms in the 
% accompanying license file.

% Release History:
% v 1.0 : 2011-Mar-08
%       - Initial release


%% Parse inputs

if nargin == 0
    eID = [mfilename ':minrhs'];
    eStr = 'Not enough input arguments.';
    error(eID,eStr)
elseif nargin == 1
    hAx = gca;
    anchor = [];
else
    % nargin > 1
    if isscalar(interval) && ishandle(interval) && ...
            strcmp(get(interval,'type'),'axes')
        hAx = interval;
        interval = anchor;
        if ~isempty(varargin)
            anchor = varargin{1};
        else
            anchor = [];
        end
    else
        hAx = gca;
    end
end

% Handle ">> xtickinterval('off')" function call
if ischar(interval) 
    if any(strcmpi(interval,{'off','delete'}))
        prevState = getappdata(hAx,'XTickIntervalPreviousState');
        hListener = getappdata(hAx,'XTickIntervalListener');
        set(hListener,'Enable','off')
            if ~isempty(prevState)
                set(hAx,prevState)
            else
                set(hAx,'XTickMode','auto','XTickLabelMode','auto')
            end
        rmappdata(hAx,'XTickIntervalListener')
        rmappdata(hAx,'XTickIntervalPreviousState')
        rmappdata(hAx,'XTickIntervalInterval')
        rmappdata(hAx,'XTickIntervalAnchor')
        return
    else
        eID = [mfilename ':UnknownCommand'];
        eStr = ['Unknown command: ''' interval '''.'];
        error(eID,eStr)
    end
end

% Validate interval
if isempty(interval) || ~isreal(interval) || ~isscalar(interval)
    eID = [mfilename ':InvalidInterval'];
    eStr = '''interval'' must be a non-empty, real, scalar value.';
    error(eID,eStr)
elseif interval <= 0
    eID = [mfilename ':InvalidInterval'];
    eStr = '''interval'' must be greater than zero.';
    error(eID,eStr)    
end

% Validate anchor
if ~isempty(anchor) && (~isreal(anchor) || ~isscalar(anchor))
    eID = [mfilename ':InvalidAnchor'];
    eStr = '''anchor'' must be a real, scalar value.';
    error(eID,eStr)
end

%% Get an anchor point if we don't have one
if isempty(anchor)
    lims = get(hAx,'XLim');
    anchor = ceil(lims(1)./interval)*interval;
    if anchor < lims(1) || anchor > lims(2)
        wID = [mfilename ':NoAnchorFound'];
        wStr = ['Could not find an anchor point within limits using ' ...
                'interval: ' num2str(interval,'%g') '.  Ticks will not '...
                'be visible until the limits are expanded to a range of'...
                'at least one interval.'];
        warning(wID,wStr)
    end    
end

%% Check for existing listener and disable it if found
hL = getappdata(hAx,'XTickIntervalListener');
if ~isempty(hL) && ishandle(hL)
    set(hL,'Enabled','off')
    hasListener = true;
else
    hasListener = false;
end

%% If this is the first call to the function, save the current 
% tick/ticklabel state so we can restore it later

if ~isappdata(hAx,'XTickIntervalPreviousState') || ...
        isempty(getappdata(hAx,'XTickIntervalPreviousState'))

    s = struct;
    if strcmp(get(hAx,'XTickMode'),'auto')
        s.XTickMode = 'auto';
    else
        s.XTick = get(hAx,'XTick');
    end
    if strcmp(get(hAx,'XTickLabelMode'),'auto')
        s.XTickLabelMode = 'auto';
    else
        s.XTickLabel = get(hAx,'XTickLabel');
    end

    setappdata(hAx,'XTickIntervalPreviousState',s)
end

%% Store values and set up the listener

setappdata(hAx,'XTickIntervalInterval',interval)
setappdata(hAx,'XTickIntervalAnchor',anchor)

% Make sure tickLabelMode is 'auto'
set(hAx,'XTickLabelMode','auto')

% Call the listener function manually to set the ticks initial value
xtickIntervalListener([],[],hAx)

if ~hasListener
    % Create listener if it doesn't exist
    try
        p = findprop(handle(hAx),'XLim');
        hL = handle.listener(handle(hAx),p,'PropertyPostSet',...
            {@xtickIntervalListener,hAx});
    catch %#ok<CTCH>
        % For older MATLAB versions
        hL = handle.listener(handle(hAx),p,'PostSet',...
            {@xtickIntervalListener,hAx});
    end
    
    % Store the listener handle
    setappdata(hAx,'XTickIntervalListener',hL)
    
else
    % Re-enable the listener
    set(hL,'Enabled','on')
end

end % End of xtickinterval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xtickIntervalListener(src,evntData,hAx) %#ok<INUSL>
% Update hAx.XTick in response to a change in hAx.XLim

% Disable the listener
hL = getappdata(hAx,'XTickIntervalListener');
set(hL,'Enable','off')

% Get interval and anchor
interval = getappdata(hAx,'XTickIntervalInterval');
anchor = getappdata(hAx,'XTickIntervalAnchor');

% If interval is empty or corrupted, clean up and exit
if isempty(interval) || ~isscalar(interval) || interval <= 0
    prevState = getappdata(hAx,'XTickIntervalPreviousState');
    if ~isempty(prevState)
        set(hAx,prevState)
    else
        set(hAx,'XTickMode','auto','XTickLabelMode','auto')
    end
    rmappdata(hAx,'XTickIntervalAnchor')
    rmappdata(hAx,'XTickIntervalInterval')
    rmappdata(hAx,'XTickIntervalListener')
    rmappdata(hAx,'XTickIntervalPreviousState')
    return
end

% Get new limits
lims = get(hAx,'XLim');

% Get an anchor point if we don't have one.
if isempty(anchor)
    anchor = ceil(lims(1)./interval)*interval;
    setappdata(hAx,'XTickIntervalAnchor',anchor);
end

% If stored anchor is outside of current limits, calculate a new value to
% avoid generating a large tick vector
if anchor < lims(1) || anchor > lims(2)
    offset = ceil(anchor./interval)*interval - anchor;
    anchor = ceil(lims(1)./interval)*interval - offset;
end

% Calculate tick locations and update the axes tick property
xtick = [fliplr(anchor:-interval:(lims(1)-interval/2)) ...
         (anchor+interval):interval:(lims(2)+interval/2)];
xtick(xtick<lims(1)) = [];
xtick(xtick>lims(2)) = [];

set(hAx,'XTick',xtick)

% Reenable the listener
set(hL,'Enable','on')

end % End of xtickinterval/xtickIntervalListener
