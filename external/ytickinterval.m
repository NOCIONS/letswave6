function ytickinterval(interval,anchor,varargin)
% Force tick spacing to a specified interval regardless of axis limits
%
% SYNTAX
%
%   YTICKINTERVAL(INTERVAL)
%   YTICKINTERVAL(INTERVAL,ANCHOR)
%   YTICKINTERVAL('off') or YTICKINTERVAL off
%   YTICKINTERVAL(HANDLE,...)
%
% DESCRIPTION
% 
% YTICKINTERVAL(INTERVAL) Set the y-axis ticks to integer multiples
% of INTERVAL, regardless of the axis limits. INTERVAL must be real and
% positive.
%
% YTICKINTERVAL(INTERVAL,ANCHOR) Set the y-axis ticks to values passing
% through ANCHOR and spaced by INTERVAL.  ANCHOR does not have to be
% within the current axis limits.
%
% YTICKINTERVAL('off') Reset the axes tick and ticklabel state to their
% values before the first call to YTICKINTERVAL and delete the
% YTICKINTERVAL listener.
%
% YTICKINTERVAL(HANDLE,...) Set the tick interval of the axes specified by
% HANDLE instead of the current axes.
%
% REMARKS
%
% YTICKINTERVAL will create ticks at multiples of INTERVAL, regardless of
% the axis limits.  This can result in too many ticks if the interval is
% small relative to the limits, or no ticks if the interval is larger than
% the range of the axis limits.
%
% YTICKINTERVAL sets the axes' YTickLabelMode property to 'auto'.  If this
% property is changed, or if values for 'YTickLabel' are specified after
% calling YTICKLABEL, the tick labels may be incorrect if the axis limits
% change.
%
% Note that the current version of YTICKINTERVAL does not support
% log-scaled axes.  

% ytickinterval.m 
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

% Handle ">> ytickinterval('off')" function call
if ischar(interval) 
    if any(strcmpi(interval,{'off','delete'}))
        prevState = getappdata(hAx,'YTickIntervalPreviousState');
        hListener = getappdata(hAx,'YTickIntervalListener');
        set(hListener,'Enable','off')
            if ~isempty(prevState)
                set(hAx,prevState)
            else
                set(hAx,'YTickMode','auto','YTickLabelMode','auto')
            end
        rmappdata(hAx,'YTickIntervalListener')
        rmappdata(hAx,'YTickIntervalPreviousState')
        rmappdata(hAx,'YTickIntervalInterval')
        rmappdata(hAx,'YTickIntervalAnchor')
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
    lims = get(hAx,'YLim');
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
hL = getappdata(hAx,'YTickIntervalListener');
if ~isempty(hL) && ishandle(hL)
    set(hL,'Enabled','off')
    hasListener = true;
else
    hasListener = false;
end

%% If this is the first call to the function, save the current 
% tick/ticklabel state so we can restore it later

if ~isappdata(hAx,'YTickIntervalPreviousState') || ...
        isempty(getappdata(hAx,'YTickIntervalPreviousState'))

    s = struct;
    if strcmp(get(hAx,'YTickMode'),'auto')
        s.YTickMode = 'auto';
    else
        s.YTick = get(hAx,'YTick');
    end
    if strcmp(get(hAx,'YTickLabelMode'),'auto')
        s.YTickLabelMode = 'auto';
    else
        s.YTickLabel = get(hAx,'YTickLabel');
    end

    setappdata(hAx,'YTickIntervalPreviousState',s)
end

%% Store values and set up the listener

setappdata(hAx,'YTickIntervalInterval',interval)
setappdata(hAx,'YTickIntervalAnchor',anchor)

% Make sure tickLabelMode is 'auto'
set(hAx,'YTickLabelMode','auto')

% Call the listener function manually to set the ticks initial value
ytickIntervalListener([],[],hAx)

if ~hasListener
    % Create listener if it doesn't exist
    try
        p = findprop(handle(hAx),'YLim');
        hL = handle.listener(handle(hAx),p,'PropertyPostSet',...
            {@ytickIntervalListener,hAx});
    catch %#ok<CTCH>
        % For older MATLAB versions
        hL = handle.listener(handle(hAx),p,'PostSet',...
            {@ytickIntervalListener,hAx});
    end
    
    % Store the listener handle
    setappdata(hAx,'YTickIntervalListener',hL)
    
else
    % Re-enable the listener
    set(hL,'Enabled','on')
end

end % End of ytickinterval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ytickIntervalListener(src,evntData,hAx) %#ok<INUSL>
% Update hAx.YTick in response to a change in hAx.YLim

% Disable the listener
hL = getappdata(hAx,'YTickIntervalListener');
set(hL,'Enable','off')

% Get interval and anchor
interval = getappdata(hAx,'YTickIntervalInterval');
anchor = getappdata(hAx,'YTickIntervalAnchor');

% If interval is empty or corrupted, clean up and exit
if isempty(interval) || ~isscalar(interval) || interval <= 0
    prevState = getappdata(hAx,'YTickIntervalPreviousState');
    if ~isempty(prevState)
        set(hAx,prevState)
    else
        set(hAx,'YTickMode','auto','YTickLabelMode','auto')
    end
    rmappdata(hAx,'YTickIntervalAnchor')
    rmappdata(hAx,'YTickIntervalInterval')
    rmappdata(hAx,'YTickIntervalListener')
    rmappdata(hAx,'YTickIntervalPreviousState')
    return
end

% Get new limits
lims = get(hAx,'YLim');

% Get an anchor point if we don't have one.
if isempty(anchor)
    anchor = ceil(lims(1)./interval)*interval;
    setappdata(hAx,'YTickIntervalAnchor',anchor);
end

% If stored anchor is outside of current limits, calculate a new value to
% avoid generating a large tick vector
if anchor < lims(1) || anchor > lims(2)
    offset = ceil(anchor./interval)*interval - anchor;
    anchor = ceil(lims(1)./interval)*interval - offset;
end

% Calculate tick locations and update the axes tick property
ytick = [fliplr(anchor:-interval:(lims(1)-interval/2)) ...
         (anchor+interval):interval:(lims(2)+interval/2)];
ytick(ytick<lims(1)) = [];
ytick(ytick>lims(2)) = [];

set(hAx,'YTick',ytick)

% Reenable the listener
set(hL,'Enable','on')

end % End of ytickinterval/ytickIntervalListener
