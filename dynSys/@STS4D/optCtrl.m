function uOpt = optCtrl(obj, ~, x, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, x, deriv, uMode, dMode, MIEdims)

%% Input processing
if nargin < 5
  uMode = 'min';
end

R1 = obj.R1;
R2 = obj.R2;
M1 = obj.M1;
M2 = obj.M2;
L1 = obj.L1;
grav = 9.81;


p = deriv;
%dx(1) = x(2);

%dx(2) = tau1.*(tau1num1/denom1) + tau2.*(tau2num1/denom1) + (num1/denom1);
denom1 = (L1.^2.*M2.*R2 + M1.*R1.^2.*R2 - ...
  L1.^2.*M2.*R2.*cos(x(3)).^2);
num1 = grav.*(M1.*R1.*R2 + M2.*L1.*R2).*sin(x(1)) + ...
  (x(2) + x(4)).^2.*L1.*M2.*R2.^2.*sin(x(3)) - ...
  grav.*M2.*L1.*R2.*sin(x(1)+x(3)).*cos(x(3)) + ...
  M2.*L1.^2.*R2.*x(2).^2.*cos(x(3)).*sin(x(3));
tau1num1 = R2;
tau2num1 = -(R2+L1.*cos(x(3)));

%dx(3) = x(4);

%dx(4) = tau1.*(tau1num2/denom2) + tau2.*(tau2num2/denom2)  + (num2/denom2);
num2 = -((M2.^2.*R2.^2.*L1.*grav + M1.*M2.*R1.*R2.^2.*grav).*sin(x(1)) + ...
  (-M2.^2.*R2.*L1.^2.*grav - M1.*M2.*R1.^2.*R2.*grav).*sin(x(1) + x(3)) + ...
  ((M2.^2.*R2.*L1.^3+M1.*M2.*R1.^2.*R2.*L1).*x(2).^2+ ...
  (M2.^2.*R2.^3.*L1).*(x(2)+x(4)).^2).*sin(x(3)) + ...
  (M2.^2.*R2.*L1.^2.*grav + M1.*M2.*R1.*R2.*L1.*grav).*cos(x(3)).*sin(x(1)) + ...
  (M2.^2.*R2.^2.*L1.^2.*(2.*x(2).^2 + 2.*x(2).*x(4) + x(4).^2)).*cos(x(3)).*sin(x(3)) - ...
  M2.^2.*R2.^2.*L1.*grav.*sin(x(1) + x(3)).*cos(x(3)));
denom2 = (M2.*R2.^2.*(M1.*R1.^2 + M2.*L1.^2 - M2.*L1.^2.*cos(x(3)).^2));
tau1num2 = -(M2.*R2.^2 + M2.*R2.*L1.*cos(x(3)));
tau2num2= -(-M1.*R1.^2 - M2.*R2.^2 - M2.*L1.^2 - 2.*M2.*R2.*L1.*cos(x(3)));

% tau1.*(p{2}.*(tau1num1/denom1)+p{4}.*(tau1num2/denom2)) +...
% tau2.*(p{2}.*(tau2num1/denom1)+p{4}.*(tau2num2/denom2)) +...
% p{1}.*x(2)+p{3}.*x(4) + p{2}.*(num1/denom1) + p{4}.* (num2/denom2)



extraTerms = p(1).*x(2) + p(3).*x(4) + p(2).*num1./denom1+p(4).*num2./denom2;
tau1Multiplier = (p(2).*tau1num1./denom1 + p(4).*tau1num2./denom2);
tau2Multiplier = (p(2).*tau2num1./denom1 + p(4).*tau2num2./denom2);
tau1 = obj.tau1Test;
tau2 = obj.tau2Test;
hamValue = zeros(1,length(tau1));
for i = 1:length(tau1)
  hamValue(i) = extraTerms + tau1Multiplier.*tau1(i)+tau2Multiplier.*tau2(i);
end


%% Optimal control
if iscell(deriv)
  uOpt = cell(obj.nu, 1);
  if strcmp(uMode, 'max')
    [~,Ind] = max(hamValue(:));
    uOpt{1} = tau1(Ind);
    uOpt{2} = tau2(Ind);

  elseif strcmp(uMode, 'min')
    [~,Ind] = min(hamValue(:));
    uOpt{1} = tau1(Ind);
    uOpt{2} = tau2(Ind);
  else
    error('Unknown uMode!')
  end  
  
else
  uOpt = zeros(obj.nu, 1);
  if strcmp(uMode, 'max')
    [~,Ind] = max(hamValue(:));
    uOpt(1) = tau1(Ind);
    uOpt(2) = tau2(Ind);
  elseif strcmp(uMode, 'min')
    [~,Ind] = min(hamValue(:));
    uOpt(1) = tau1(Ind);
    uOpt(2) = tau2(Ind);
  else
    error('Unknown uMode!')
  end
end




end