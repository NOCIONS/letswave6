function [E, D, Er, Dr] = pcamat(vectors, firstEig, lastEig, ... 
                          s_interactive, s_verbose, b_npca, s_covar);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default values:
if nargin < 7, s_covar = 'off'; end
if nargin < 6, b_npca = 0; end
if nargin < 5, s_verbose = 'off'; end
if nargin < 4, s_interactive = 'off'; end
if nargin < 3, lastEig = size(vectors, 1); end
if nargin < 2, firstEig = 1; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check the optional parameters;
if strcmp(lower(s_verbose), 'on')
    b_verbose = 1;
  elseif strcmp(lower(s_verbose), 'off')
    b_verbose = 0;
  else
    error(sprintf('Illegal value [ %s ] for parameter: ''verbose''\n', s_verbose));
end

if strcmp(lower(s_covar), 'on')
    b_covar = 1;
  elseif strcmp(lower(s_covar), 'off')
    b_covar = 0;
  else
    error(sprintf('Illegal value [ %s ] for parameter: ''covar''\n', s_covar));
end

if strcmp(lower(s_interactive), 'on')
    b_interactive = 1;
  elseif strcmp(lower(s_interactive), 'off')
    b_interactive = 0;
  elseif strcmp(lower(s_interactive), 'gui')
    b_interactive = 2;
  else
    error(sprintf('Illegal value [ %s ] for parameter: ''interactive''\n', ...
          s_interactive));
end

oldDimension = size (vectors, 1);
if ~(b_interactive)
  if lastEig < 1 | lastEig > oldDimension
    error(sprintf('Illegal value [ %d ] for parameter: ''lastEig''\n', lastEig));
  end
  if firstEig < 1 | firstEig > lastEig
    error(sprintf('Illegal value [ %d ] for parameter: ''firstEig''\n', firstEig));
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate PCA

% Calculate the covariance matrix.
if b_verbose, fprintf ('Calculating covariance...\n'); end

if b_covar
  covarianceMatrix = vectors;
else
  covarianceMatrix = cov(vectors');
end;

maxLastEig = rank(covarianceMatrix);

% Calculate the eigenvalues and eigenvectors of covariance matrix.
[E, D] = eig(covarianceMatrix);

tmp=diag(D);
[tmp,ind]=sort(tmp);
tmp=flipud(tmp);
D=diag(tmp);
E=fliplr(E(:,ind));

% Sort the eigenvalues - decending.
eigenvalues = tmp;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interactive part - command-line
if b_interactive == 1

  % Show the eigenvalues to the user
  hndl_win=figure;
  bar(eigenvalues);
  title('Eigenvalues');

  % ask the range from the user...
  % ... and keep on asking until the range is valid :-)
  areValuesOK=0;
  while areValuesOK == 0
    firstEig = input('The index of the largest eigenvalue to keep? (1) ');
    lastEig = input(['The index of the smallest eigenvalue to keep? (' ...
                    int2str(oldDimension) ') ']);
    % Check the new values...
    % if they are empty then use default values
    if isempty(firstEig), firstEig = 1;end
    if isempty(lastEig), lastEig = oldDimension;end
    % Check that the entered values are within the range
    areValuesOK = 1;
    if lastEig < 1 | lastEig > oldDimension
      fprintf('Illegal number for the last eigenvalue.\n');
      areValuesOK = 0;
    end
    if firstEig < 1 | firstEig > lastEig
      fprintf('Illegal number for the first eigenvalue.\n');
      areValuesOK = 0;
    end
  end
  % close the window
  close(hndl_win);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interactive part - GUI
if b_interactive == 2

  % Show the eigenvalues to the user
  hndl_win = figure('Color',[0.8 0.8 0.8], ...
    'PaperType','a4letter', ...
    'Units', 'normalized', ...
    'Name', 'FastICA: Reduce dimension', ...
    'NumberTitle','off', ...
    'Tag', 'f_eig');
  h_frame = uicontrol('Parent', hndl_win, ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'Units', 'normalized', ...
    'Position',[0.13 0.05 0.775 0.17], ...
    'Style','frame', ...
    'Tag','f_frame');

b = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'HorizontalAlignment','left', ...
	'Position',[0.142415 0.0949436 0.712077 0.108507], ...
	'String','Give the indices of the largest and smallest eigenvalues of the covariance matrix to be included in the reduced data.', ...
	'Style','text', ...
	'Tag','StaticText1');
e_first = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'Callback',[ ...
          'f=round(str2num(get(gcbo, ''String'')));' ...
          'if (f < 1), f=1; end;' ...
          'l=str2num(get(findobj(''Tag'',''e_last''), ''String''));' ...
          'if (f > l), f=l; end;' ...
          'set(gcbo, ''String'', int2str(f));' ...
          ], ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[0.284831 0.0678168 0.12207 0.0542535], ...
	'Style','edit', ...
        'String', '1', ...
	'Tag','e_first');
b = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'HorizontalAlignment','left', ...
	'Position',[0.142415 0.0678168 0.12207 0.0542535], ...
	'String','Range from', ...
	'Style','text', ...
	'Tag','StaticText2');
e_last = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'Callback',[ ...
          'l=round(str2num(get(gcbo, ''String'')));' ...
          'lmax = get(gcbo, ''UserData'');' ...
          'if (l > lmax), l=lmax; fprintf([''The selected value was too large, or the selected eigenvalues were close to zero\n'']); end;' ...
          'f=str2num(get(findobj(''Tag'',''e_first''), ''String''));' ...
          'if (l < f), l=f; end;' ...
          'set(gcbo, ''String'', int2str(l));' ...
          ], ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[0.467936 0.0678168 0.12207 0.0542535], ...
	'Style','edit', ...
        'String', int2str(maxLastEig), ...
        'UserData', maxLastEig, ...
	'Tag','e_last');
% in the first version oldDimension was used instead of 
% maxLastEig, but since the program would automatically
% drop the eigenvalues afte maxLastEig...
b = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'HorizontalAlignment','left', ...
	'Position',[0.427246 0.0678168 0.0406901 0.0542535], ...
	'String','to', ...
	'Style','text', ...
	'Tag','StaticText3');
b = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'Callback','uiresume(gcbf)', ...
	'Position',[0.630697 0.0678168 0.12207 0.0542535], ...
	'String','OK', ...
	'Tag','Pushbutton1');
b = uicontrol('Parent',hndl_win, ...
	'Units','normalized', ...
	'Callback',[ ...
          'gui_help(''pcamat'');' ...
          ], ...
	'Position',[0.767008 0.0678168 0.12207 0.0542535], ...
	'String','Help', ...
	'Tag','Pushbutton2');

  h_axes = axes('Position' ,[0.13 0.3 0.775 0.6]);
  set(hndl_win, 'currentaxes',h_axes);
  bar(eigenvalues);
  title('Eigenvalues');

  uiwait(hndl_win);
  firstEig = str2num(get(e_first, 'String'));
  lastEig = str2num(get(e_last, 'String'));

  % close the window
  close(hndl_win);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See if the user has reduced the dimension enought

if lastEig > maxLastEig
  lastEig = maxLastEig;
  if b_verbose
    fprintf('Dimension reduced to %d due to the singularity of covariance matrix\n',...
           lastEig-firstEig+1);
  end
else
  % Reduce the dimensionality of the problem.
  if b_verbose
    if oldDimension == (lastEig - firstEig + 1)
      fprintf ('Dimension not reduced.\n');
    else
      fprintf ('Reducing dimension...\n');
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Drop the smaller eigenvalues
if lastEig < oldDimension
  lowerLimitValue = (eigenvalues(lastEig) + eigenvalues(lastEig + 1)) / 2;
else
  lowerLimitValue = eigenvalues(oldDimension) - 1;
end

lowerColumns = diag(D) > lowerLimitValue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Drop the larger eigenvalues
if firstEig > 1
  higherLimitValue = (eigenvalues(firstEig - 1) + eigenvalues(firstEig)) / 2;
else
  higherLimitValue = eigenvalues(1) + 1;
end
higherColumns = diag(D) < higherLimitValue;

% Combine the results from above
selectedColumns = lowerColumns & higherColumns;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print some info for the user
if b_verbose
  fprintf ('Selected [ %d ] dimensions.\n', sum (selectedColumns));
end
if sum (selectedColumns) ~= (lastEig - firstEig + 1),
  error ('Selected a wrong number of dimensions.');
end

if b_verbose
  fprintf ('Smallest remaining (non-zero) eigenvalue [ %g ]\n', eigenvalues(lastEig));
  fprintf ('Largest remaining (non-zero) eigenvalue [ %g ]\n', eigenvalues(firstEig));
  fprintf ('Sum of removed eigenvalues [ %g ]\n', sum(diag(D) .* ...
    (~selectedColumns)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select the colums which correspond to the desired range
% of eigenvalues.
if sum(~selectedColumns)>1
   Er = selcol (E, ~selectedColumns);
   Dr = selcol (selcol (D, ~selectedColumns)', ~selectedColumns);
else
   Er=1;
   Dr=1;
end;
E = selcol (E, selectedColumns);
D = selcol (selcol (D, selectedColumns)', selectedColumns);



if b_npca
   fprintf(' Estimate Noisy PCA eigenvectors');
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some more information
if b_verbose
  sumAll=sum(eigenvalues);
  sumUsed=sum(diag(D));
  retained = (sumUsed / sumAll) * 100;
  fprintf('[ %g ] %% of (non-zero) eigenvalues retained.\n', retained);
end

if b_npca == 1
   [E,D]=npca(covarianceMatrix,size(vectors,2)/3);
end;


