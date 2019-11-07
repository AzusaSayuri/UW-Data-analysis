function chi = MakeEnsemble(varargin)

Nr=varargin{1}; %ensemble size
cov=varargin{2}; %coefficient of variation

if nargin==3,
    seed=varargin{3}; %optional random number generator seed
    s = RandStream('mt19937ar','Seed',seed);
    RandStream.setGlobalStream(s);    
end

m=1; %mean of the log-normal
v=(cov*m)^2; %variance of the log-normal
[mu,sigma] = logninvstat(m,v); %get parameter of associated normal distribution
chi=lognrnd(mu,sigma,Nr,1);

end