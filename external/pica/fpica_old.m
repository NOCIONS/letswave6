function [A, W, round] = fpica(X,  whiteningMatrix, dewhiteningMatrix, ...
        approach, numOfIC, g, a1, a2, epsilon, maxNumIterations, ...
        initState, guess, displayMode, displayInterval, s_verbose);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default values

if nargin < 1, error('Not enought arguments!'); end
[vectorSize, numSamples] = size(X);
if nargin < 15, s_verbose = 'off'; end
if nargin < 14, displayInterval = 1; end
if nargin < 13, displayMode = 'off'; end
if nargin < 12, guess = 1; end
if nargin < 11, initState = 'rand'; end
if nargin < 10, maxNumIterations = 100; end
if nargin < 9, epsilon = 0.00001; end
if nargin < 8, a2 = 1; end
if nargin < 7, a1 = 1; end
if nargin < 6, g = 'pow3'; end
if nargin < 5, numOfIC = vectorSize; end     % vectorSize = Dim
if nargin < 4, approach = 'symm'; end
if nargin < 3, dewhiteningMatrix=eye(vectorSize); end
if nargin < 2, whiteningMatrix=eye(vectorSize); end
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the data

if max(max(abs(imag(X)))) > 0,
  error('Input has an imaginary part.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for verbose

if strcmp(lower(s_verbose), 'on'),
    b_verbose = 1;
  elseif strcmp(lower(s_verbose), 'off'),
    b_verbose = 0;
  else
    error(sprintf('Illegal value [ %s ] for parameter: ''verbose''\n', s_verbose));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for approach

if strcmp(lower(approach), 'symm')
  approachMode = 1;
elseif strcmp(lower(approach), 'defl')
  approachMode = 2;
else
  error(sprintf('Illegal value [ %s ] for parameter: ''approach''\n', approach));
end
if b_verbose, fprintf('Used approach [ %s ].\n', approach); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for numOfIC

if (approachMode == 1) & (vectorSize ~= numOfIC)
  error('Symmetric approach must have: numOfIC = Dimension.');
end
if (approachMode == 2) & (vectorSize < numOfIC)
  error('Deflation approach must have: numOfIC <= Dimension.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for nonlinearity.

if strcmp(lower(g), 'pow4'),
  usedNlinearity = 1;
elseif strcmp(lower(g), 'tanh'),
  usedNlinearity = 2;
elseif strcmp(lower(g), 'gaus'),
  usedNlinearity = 3;
elseif strcmp(lower(g), 'gauss'),
  usedNlinearity = 3;
elseif strcmp(lower(g), 'pow3'),
  usedNlinearity = 4;
  a1=2.3;
elseif strcmp(lower(g), 'pow5'),
  usedNlinearity = 5;
elseif strcmp(lower(g), 'custom'),
  usedNlinearity = 6;
  a1=0.1;
else
  error(sprintf('Illegal value [ %s ] for parameter: ''g''\n', g));
end
if b_verbose,
  fprintf('Used nonlinearity [ %s ].\n', g);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for initial state.

if strcmp(lower(initState), 'rand'),
  initialStateMode = 0;
elseif strcmp(lower(initState), 'guess'),
  if approachMode == 7 %%% == 2 original CBchange
    initialStateMode = 0;
    if b_verbose, fprintf('Warning: Deflation approach - Ignoring initial guess.\n'); end
  else
    % Check the size of the initial guess. If it's not right then
    % use random initial guess
    if (size(whiteningMatrix,1)>=size(guess,2)) & ...
       (size(whiteningMatrix,2)==size(guess,1))
      initialStateMode = 1;
      if b_verbose, fprintf('Using initial guess.\n'); end
    else
      initialStateMode = 0;
      if b_verbose
        fprintf('Warning: size of initial guess is incorrect. Using random initial guess.\n');
      end
    end
  end
else
  error(sprintf('Illegal value [ %s ] for parameter: ''initState''\n', initState));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for display mode.

if strcmp(lower(displayMode), 'off'),
  usedDisplay = 0;
elseif strcmp(lower(displayMode), 'on'),
  usedDisplay = 1;
else
  error(sprintf('Illegal value [ %s ] for parameter: ''displayMode''\n', displayMode));
end

% Warn the user if the data vectors are very long, because
% it might take a long time to plot them...
if (b_verbose & (usedDisplay > 0) & (numSamples > 10000))
  fprintf('Warning: data vectors very long. Suggest setting ''displayMode'' to ''off''.\n');
end

% And the displayInterval can't be less than 1...
if displayInterval < 1
  displayInterval = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How many times do we try for convergence until we give up.
failureLimit = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if b_verbose, fprintf('Starting ICA calculation...\n'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRIC APPROACH

if approachMode == 1,
  %fprintf('.');
  A = zeros(vectorSize); % Dewhitened basis vectors.
  
  if initialStateMode == 0
    % Take random orthonormal initial vectors.
    B = orth(rand(vectorSize) - .5);
    %B = orth(diag(diag(ones(vectorSize))) - .5);
  elseif initialStateMode == 1
    % Use the given initial vector as the initial state
    B = orth(rand(vectorSize) - .5);
    if b_verbose
       fprintf('you have specified %f guesses \n',size(guess,2));
    end
    B(:,1:size(guess,2)) = whiteningMatrix * guess;
  end

  BOld = zeros(size(B));

  % This is the actual fixed-point iteration loop.
  for round = 1 : maxNumIterations + 1,

    if round == maxNumIterations + 1,
      if b_verbose 
        fprintf('No convergence after %d steps\n', maxNumIterations);
      end
      break;
    end

    % Symmetric orthogonalization.
    tmpB = inv(B'*B);
    [tmpE,tmpD]=eig(tmpB);
    B=B*tmpE*sqrt(tmpD)*tmpE';
    
    %B=B*tmpE;
    %B = B*real(sqrtm(inv(B'*B)));

    % Test for termination condition. Note that we consider opposite
    % directions here as well.
    minAbsCos = min(abs(diag(B'*BOld)));
    if (1 - minAbsCos < epsilon),
      if b_verbose, fprintf('Convergence after %d steps\n', round); end

      % Calculate the de-whitened vectors.
      A = dewhiteningMatrix * B;
      %A = B;
      break;
    end
    A = dewhiteningMatrix * B;
  
    BOld = B;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Show the progress...
    if b_verbose
      if round == 1
        fprintf('Step no. %d\n', round);
      else
        fprintf('Step no. %d, change in value of estimate: %.3f \n', round, 1 - minAbsCos);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Also plot the current state...
    if usedDisplay > 0,
      if rem(round, displayInterval) == 0,
        % There was and may still be other displaymodes...
        % 1D signals
        dispsig(X'*B);
        drawnow;
      end
    end

    % First calculate the independent components (u_i's).
    % u_i = b_i' x = x' b_i. For all x:s simultaneously this is
    U = X' * B;
    
    if usedNlinearity == 1,
      % pow4
      B = (X * (U .^ 3)) / numSamples - 3 * B;
    elseif usedNlinearity == 2,
      % tanh
      hypTan = tanh(a1 * U);
      B = X * hypTan / numSamples - ones(size(B,1),1) * sum((1 - hypTan .^ 2)) .* B / numSamples * a1; 
    elseif usedNlinearity == 3,
      % gauss
      Usquared=U.^2;
      gauss =  U.*exp(-a2 * Usquared/2);
      dGauss = (1 - a2 * Usquared) .*exp(-a2 * Usquared/2);
      B = X * gauss / numSamples - ...
          ones(size(B,1),1) * sum(ones(size(U)) .*  dGauss)...
          .* B / numSamples ;
      
    elseif usedNlinearity ==4,
       %pow3
       U2=U/a1;
      B = 3*(X * (U2 .^ 2)) / numSamples - 2* ones(size(B,1),1) * sum(U2) .* B / numSamples;
     elseif usedNlinearity ==5,
       %pow5
      B = 5*(X * (U .^ 4)) / numSamples - 15* ones(size(B,1),1) * sum(U.^3) .* B / numSamples;
     elseif usedNlinearity ==6,
       %custom
       U2=a1*U;
       U3=U2.*U;
       tanh1=tanh(U3);
       tanh2=tanh1.^2;
       Dcustom =  tanh1 +2*U3 -2*U3.*tanh2;
       DDcustom = U2.*(6 + tanh2 .* ( 8* U3 -6) - 8.*U3.*tanh1);
      B = X * Dcustom / numSamples - ones(size(B,1),1) * sum(DDcustom) .* B / numSamples;
    else
      error('Code for desired nonlinearity not found!');
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Also plot the last one...
  if usedDisplay > 0,
    % There was and may still be other displaymodes...
    % 1D signals
    dispsig(X'*B);
    drawnow;
  end

  % Calculate ICA filters.
  W = B' * whiteningMatrix;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFLATION APPROACH
if approachMode == 2

  B = zeros(vectorSize);
  
  NumGuess=size(guess,2);
  guess=whiteningMatrix*guess;
  

  % The search for a basis vector is repeated numOfIC times.
  round = 1;

  numFailures = 0;
  while round <= numOfIC,

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Show the progress...
    if b_verbose, fprintf('IC %d ', round); end

    % Take a random initial vector of lenght 1 and orthogonalize it
    % with respect to the other vectors.
    if initialStateMode == 0
      w = rand(vectorSize, 1) - .5;
    elseif (initialStateMode == 1) & (round <= NumGuess)
      w = guess(:,round);
      fprintf('Adopt guess %f \n',round);
    end
    
    w = w - B * B' * w;
    w = w / norm(w);

    wOld = zeros(size(w));

   
    % This is the actual fixed-point iteration loop.
    for i = 1 : maxNumIterations + 1,
        %  fprintf('.');
      if i == maxNumIterations + 1,
        if b_verbose,
          fprintf('\nComponent number %d did not converge in %d iterations.\n', round, maxNumIterations);
        end
        round = round - 1;

        numFailures = numFailures + 1;
        if numFailures > failureLimit,
          if b_verbose,
            fprintf('Too many failures to converge (%d). Giving up.\n', numFailures);
          end
          return;
        end
        break;
      end

      % Project the vector into the space orthogonal to the space
      % spanned by the earlier found basis vectors. Note that we can do
      % the projection with matrix B, since the zero entries do not
      % contribute to the projection.
      w = w - B * B' * w;
      w = w / norm(w);

      % Test for termination condition. Note that the algorithm has
      % converged if the direction of w and wOld is the same, this
      % is why we test the two cases.
      if norm(w - wOld) < epsilon | norm(w + wOld) < epsilon,

        numFailures = 0;
        % Save the vector and print the number of rounds used for convergence.
        B(:, round) = w;

        % Calculate the de-whitened vector.
        A(:,round) = dewhiteningMatrix * w;
        % Calculate ICA filter.
        W(round,:) = w' * whiteningMatrix;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show the progress...
        if b_verbose, fprintf('computed ( %d steps ) \n', i); end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Also plot the current state...
        if usedDisplay > 0,
          if rem(round, displayInterval) == 0,
            % There was and may still be other displaymodes...   
            % 1D signals
            temp = X'*B;
            dispsig(temp(:,1:numOfIC));
            drawnow;
          end
        end

        break;
      end

      wOld = w;

      % First calculate the independent components (u_i's) for this w.
      % u_i = b_i' x = x' b_i. For all x:s simultaneously this is
      u = X' * w;
      u = shrink(u);
      if usedNlinearity == 1,
        % pow3
        w = (X * (u .^ 3)) / numSamples - 3 * w;
      elseif usedNlinearity == 2,
        % tanh
        hypTan = tanh(a1 * u);
        w = (X * hypTan - a1 * sum(1 - hypTan .^ 2)' * w) / numSamples;
      elseif usedNlinearity == 3,
        % gauss
        gauss =  u.*exp(-a2 * u.^2/2);
        dGauss = (1 - a2 * u.^2) .*exp(-a2 * u.^2/2);
        w = (X * gauss - sum(dGauss)' * w) / numSamples;
      else
        error('Code for desired nonlinearity not found!');
      end

      % Normalize the new w.
      w = w / norm(w);
    end
    round = round + 1;
  end
  if b_verbose, fprintf('\n'); end
 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Also plot the ones that may not be plotted.
  if (usedDisplay > 0) & (rem(round-1, displayInterval) ~= 0)
    % There was and may still be other displaymodes...
    % 1D signals
    temp = X'*B;
    dispsig(temp(:,1:numOfIC));
    drawnow;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the end let's check the data for some security
if max(max(abs(imag(A)))) > 0,
  if b_verbose, fprintf('Warning: removing the imaginary part from the result.\n'); end
  A = real(A);
  W = real(W);
end
