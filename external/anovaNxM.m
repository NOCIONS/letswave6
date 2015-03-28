function results=anovaNxM(data,subjects,wtFactors,wtFactorNames,btFactors,btFactorNames)
%
% results=anovaNxM(data,subjects,wtFactors,wtFactorNames,btFactors,btFactorNames);
% Carry out an NxM way anova. Look at the test data for data format.
% 
% Input: The way I construct the input data are similar to SPSS. Assuming
%        you have a dataset that works in SPSS anova, just stacking all
%        columns into a single column to form the data vector. What you need
%        to do is just group the within-subject factors and between-subject 
%        factors separately.
%
%        data: data vector/matrix for anova, each value is one observation. 
%              size(data)=[nbOfObs(number of observations),nbOfDataset]
%
%        subjects: numerical vector, can be the subject id, corresponds to
%                  each value in data. Length(subjects)=nbOfObs
%
%        wtFactors: within-subject factors. size(wtFactors)=[nbOfObs
%                   nbWtFactors]
%
%        wtFactorNames: cell array. each cell contains the name of the
%                       correspondent within-subject factor. For output
%                       purpose only.
% 
%        btFactors: between subject factor. size(btFactors)=[nbOfObs
%                   nbBtFactors]
% 
%        btFactorNames: cell array. each cell contains the name of the
%                       correspondent between-subject factor. For output
%                       purpose only.
%
%
% Output: Structure with varies information. Feel free to extract information you want. 
%
% If you are still confused because of poor English, try the program with
% the anovaTesting.mat.
%
%
% Thanks to Joshua Goh for the GLM codes. http://j-rand.blogspot.com/
%
% Original Author: Zheng Hui (zhenghui.zhh@gmail.com)
%                  Cognitive Neuroscience Laboratory,
%                  Duke-NUS Graduate Medical School,
%                  Singapore
% 


wtFactors=convertFactors(wtFactors);
btFactors=convertFactors(btFactors);
subjects=convertFactors(subjects);

nbWtFactors=length(wtFactors);
nbBtFactors=length(btFactors);

%All combinations of within-subjects effects
wtMatComb={};
for i=1:nbWtFactors
    wtMatComb{i}=nchoosek(1:nbWtFactors,i);
end

%All combinations of between-subjects effects
btMatComb={};
for i=1:nbBtFactors
    btMatComb{i}=nchoosek(1:nbBtFactors,i);
end

%All combinations of within X between-subjects effects
wtXbtMatComb={};
k=0;
for i=1:length(wtMatComb)
    for j=1:length(btMatComb)
        k=k+1;
        index=0;
        for bt=1:size(btMatComb{j},1)
            for wt=1:size(wtMatComb{i},1)
                index=index+1;
                wtXbtMatComb{k}(index,:)=[wtMatComb{i}(wt,:) btMatComb{j}(bt,:)+nbWtFactors];
            end
        end
    end
end

[xmatWt, pnameWt] = createX(wtFactors,wtFactorNames,wtMatComb);
[xmatBt, pnameBt] = createX(btFactors,btFactorNames,btMatComb);
[xmatWtXBt, pnameWtXBt] = createX([wtFactors btFactors],[wtFactorNames btFactorNames],wtXbtMatComb);


%All combinations of error terms-----
errMatComb={};
for i=1:length(wtMatComb)
    errMatComb{i}=wtMatComb{i};
    errMatComb{i}(:,end+1)=1+nbWtFactors;
end
[xmatErr, pnameErr] = createX([wtFactors subjects],[wtFactorNames {'(E)'}],errMatComb);



%Calling glm for anova----------------
xmat=[xmatWt xmatWtXBt xmatBt];
pname=[pnameWt pnameWtXBt pnameBt];

results=callGLMForAnova(data,pname,xmat,pnameErr,xmatErr,subjects);
%-----------------------end of main function-------------------------------


%------------------------calling glm for anova-----------------------------
function results=callGLMForAnova(data,pname,xmat,pnameErr,xmatErr,subjects)

nbSubj=size(subjects{1},2)+1;

R = stats_glm_anova(pname,xmat,data);
RE = stats_glm_anova(pnameErr,xmatErr,R.full.Residual);

%Computing stats-----------------------
DFTO=0;
%create effect terms
nbEff=length(xmat);
for i=1:nbEff
    stats(i).Name=pname{i};
    stats(i).X=xmat(i).p;
    stats(i).SSE=R.red(i).SSE-R.full.SSE;
    stats(i).DF=R.red(i).DFE-R.full.DFE;
    stats(i).MSE=stats(i).SSE./stats(i).DF;
    stats(i).errName='';
    DFTO=DFTO+stats(i).DF;
end

%create error terms
nbErr=length(xmatErr);
for i=nbErr:-1:1
    errTerms(i).Name=pnameErr{i};
    errTerms(i).X=xmatErr(i).p;
    errTerms(i).SSE=RE.red(i).SSE-RE.full.SSE;
    effUsingThisErr=[];
    for j=1:nbEff
        if (isempty(stats(j).errName) & ~isempty(strfind(stats(j).Name,errTerms(i).Name(1:end-3))))
            effUsingThisErr(end+1)=j;
            stats(j).errName=errTerms(i).Name;
            stats(j).errSSE=errTerms(i).SSE;
        end
    end
    errTerms(i).DF=stats(effUsingThisErr(1)).DF*nbSubj-sum([stats(effUsingThisErr).DF]);
    errTerms(i).MSE=errTerms(i).SSE./errTerms(i).DF;
    DFTO=DFTO+errTerms(i).DF;
    for j=1:length(effUsingThisErr)
        stats(effUsingThisErr(j)).errDF=errTerms(i).DF;
        stats(effUsingThisErr(j)).errMSE=errTerms(i).MSE;
    end
end
errTerms(end+1).DF=size(data,1)-1-DFTO;
errTerms(end).SSE=RE.full.SSE;
errTerms(end).MSE=errTerms(end).SSE./errTerms(end).DF;
errTerms(end).Name='Residual';
errTerms(end).X=RE.full.Residual;
%finalize the F values
for i=1:nbEff
    if isempty(stats(i).errDF)
        stats(i).errDF=errTerms(end).DF;
        stats(i).errSSE=errTerms(end).SSE;
        stats(i).errMSE=errTerms(end).MSE;
    end
    stats(i).F=stats(i).MSE./stats(i).errMSE;
    stats(i).p=1-cdf('F',stats(i).F,stats(i).DF,stats(i).errDF);
    
end

results.eff=stats;
results.err=errTerms;
%-----------------------end of callGLMForAnova-----------------------------


%-------------create design matrix using combination and factors-----------
function [xmat, pname] = createX(factors,factorNames,combinations)

if isempty(combinations)
    xmat=[];
    pname={};
    return
end
index=0;
for i=1:length(combinations)
    nWayX=size(combinations{i},1);
    for j=1:nWayX
        nWays=size(combinations{i},2);%n-way interactions(including main effects, one way)
        firstFactor=combinations{i}(j,1);
        index=index+1;
        xmat(index).p=factors{firstFactor};
        pname{index}=factorNames{firstFactor};
        for k=2:nWays
            thisFactor=combinations{i}(j,k);
            [xmat(index).p pname{index}]=createAXB(xmat(index).p,factors{thisFactor},pname{index},factorNames{thisFactor});
        end
    end
end

%--------------------------end of createX----------------------------------


%------------------create interaction matrix from two matrix---------------
function [xMat, pName]=createAXB(matA,matB,nameA,nameB)

lengthA=size(matA,2);
lengthB=size(matB,2);

xMat=zeros(size(matA,1),lengthA*lengthB);

k=0;
for i=1:lengthA
    for j=1:lengthB
        k=k+1;
        xMat(:,k)=matA(:,i).*matB(:,j);
    end
end
if strcmp(nameB,'(E)')
    pName=[nameA nameB];
else
    pName=[nameA '*' nameB];
end

%----------------------------end of createAXB------------------------------

%-----------------------transform factors to 1:N---------------------------
function transformedFactors=convertFactors(rawFactors)

if isempty(rawFactors)
    transformedFactors=[];
    return
end

[nbObs, nbFactors]=size(rawFactors);

for i=1:nbFactors
    
    thisFactor=rawFactors(:,i);
    
    %change value of predictors to values 1:N
    levels=sort(unique(thisFactor));
    for j=1:length(levels)
        thisFactor(thisFactor==levels(j))=j+1980;
        %1980 is just a random large number for test case when the value in
        %dummy variable is between 1:j (j<1980). Hopefully no one will do a
        %anova with more than 1980 levels. Well, I was born in 1980, so
        %maybe it is not so random in that sense. 
    end
    thisFactor=thisFactor-1980;
    %change matrix to sigma-restricted design matrix
    nbLevels=max(thisFactor);
    thisMat=zeros(nbObs,nbLevels-1);    
    for j=1:nbObs
        if thisFactor(j)==nbLevels
            thisMat(j,:)=-1;
        else
            thisMat(j,thisFactor(j))=1;
        end
    end
    transformedFactors{i}=thisMat;

end

%---------------------------end of convertFactors--------------------------


%-----------------------start of stats_glm_anova---------------------------
%**************************************************************************
% GENERAL LINEAR MODEL ANOVA - Function created by Josh Goh May 2006
%--------------------------------------------------------------------------
% Parameters:
%
% pname - name of each factor
% xmat  - design matrix as a structure with each factor at the higher level
%         (xmat), and each factor level (as individual predictor columns) in the
%         lower level (xmat.p)
% y     - data as a vector of values with same no. of rows as predictors in xmat
%**************************************************************************

function [R] = stats_glm_anova(pname,xmat,y)

xfull=[];

for p=1:length(xmat)

R.pname(p)=pname(p);
xfull=[xfull xmat(p).p];

xplist=[1:1:length(xmat)];
xplist(p)=[];

xred(p).p=[];

for pp=1:length(xplist)
xred(p).p=[xred(p).p xmat(xplist(pp)).p];
end

R.red(p)=stats_glm_matrix(1,xred(p).p,y);

end

R.full=stats_glm_matrix(1,xfull,y);

for p=1:length(xmat)
R.red(p).F=((R.red(p).SSE-R.full.SSE)/(R.red(p).DFE-R.full.DFE))/(R.full.SSE/R.full.DFE);
end

%------------------------end of stats_glm_anova----------------------------


%-----------------------start of stats_glm_matrix--------------------------
%**************************************************************************
% GENERAL LINEAR MODEL - Function created by Josh Goh January 2006
%--------------------------------------------------------------------------
% Fits given model (x) to data (y). 
% Outputs - Regression parameter estimates and fit.
%--------------------------------------------------------------------------
% Parameters:
%
% format        - 1=data variables; 0=text file data
% xfile         - x data file (model)
% yfile         - y data file (response variable)
% basedirname   - base directory of data files
%
% E.g. >>stats_glm_matrix('/data/test/','xdata.txt','ydata.txt')
%**************************************************************************

function [s] = stats_glm_matrix(format,xfile,yfile,basedirname)

if format<2
    basedirname='';
    x=xfile;
    y=yfile;
else
% INPUT FILES AND READ DATA INTO VARIABLES
%--------------------------------------------------------------------------
xdata=sprintf('%s/%s',basedirname,xfile);
ydata=sprintf('%s/%s',basedirname,yfile);

x=dlmread(xdata);
y=dlmread(ydata);
%--------------------------------------------------------------------------
end

n=size(x,1); 
npred=size(x,2);

x=[ones(n,1) x]; % Add one column of constants

b=inv(x'*x)*x'*y; % Betas


% Sums of Squares
%--------------------------------------------------------------------------
j=ones(size(y,1),size(y,1)); % Create J matrix

SSTO=(y'*y)-(1/n)*y'*j*y;
SSE=(y'*y)-(b'*x'*y);
SSTO=diag(SSTO);
SSE=diag(SSE);
SSR=SSTO-SSE;

DFTO=n-1;
DFR=npred;
DFE=DFTO-DFR;

MSE=SSE/DFE;
MSR=SSR/DFR;

residual=y-x*b;

varb=MSE(1)*(inv(x'*x));

for i=1:npred+1
    varcovarb(i)=varb(i,i);
    tbeta(i)=b(i)/sqrt(varcovarb(i));
end

% Statistical test values
%--------------------------------------------------------------------------
F=MSR./MSE; Rsquare=SSR./SSTO; Rsquareadj=1-((n-1)/(n-npred))*(SSE/SSTO);


% Enter general regression into structure variable
%--------------------------------------------------------------------------
s = struct('N',n,...
	'NoofPred',npred+1,... % include constant
	'SSTO',SSTO,...
	'SSE',SSE,...
	'SSR',SSR,...
	'DFTO',DFTO,...
	'DFE',DFE,...
	'DFR',DFR,...
	'MSE',MSE,...
        'MSR',MSR,...
        'betas',b,...
        'betavarcovar',varcovarb',...
        'betat',tbeta',...
        'F',F,...
        'R2',Rsquare,...
        'R2adj',Rsquareadj,...
        'Residual',residual);
                

% Contrasts for main effects and interactions
%--------------------------------------------------------------------------
%-------------------------end of stats_glm_matrix--------------------------


