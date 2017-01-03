function dataNew = migrateGrid(gOld, dataOld, gNew)
% dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%
% Output: dataNew    - equivalent data corresponding to new grid structure

dataDims = numDims(dataOld);
if dataDims == gOld.dim
  dataNew = migrateGridSingle(gOld, dataOld, gNew);
  
elseif dataDims == gOld.dim + 1
  numTimeSteps = size(dataOld, dataDims);
  dataNew = zeros([gNew.N' numTimeSteps]);
  colons = repmat({':'}, 1, gOld.dim);
  for i = 1:numTimeSteps
    dataNew(colons{:},i) = migrateGridSingle(gOld, dataOld(colons{:},i), gNew);
  end
  
else
  error('Inconsistent input data dimensions!')
end

end

function dataNew = migrateGridSingle(gOld, dataOld, gNew)
% dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%
% Output: dataNew    - equivalent data corresponding to new grid structure
%
% Mo Chen, 2015-08-27

gNew_xsVec = zeros(prod(gNew.N), gOld.dim);
for i = 1:gOld.dim
  gNew_xsVec(:,i) = gNew.xs{i}(:);
end

dataNew = eval_u(gOld, dataOld, gNew_xsVec);
dataNew = reshape(dataNew, gNew.N');
dataNew(isnan(dataNew)) = max(dataNew(:));
end