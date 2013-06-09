function s = slantlt(x);
%  slantlt   slantlet transform.
%
%  See also islantlt, sislet, isislet, sltmtx.
%
%  % example
%  x = randn(1,2^l);
%  s = slantlt(x);
%  y = islantlt(s);
%  max(abs(x-y))

%  Ivan Selesnick, 1997
%  subprograms: getg.m

N = length(x);
l = log2(N);
if l ~= round(l)
        disp('sorry, the length of x must be a power of 2.')
        s = [];
        return
end

u0 = x(1:2:N) + x(2:2:N);   % initialize moment vectors
u1 = x(2:2:N);
L = N/2;                    % length of "moment" vectors

s = zeros(size(x));
for i = 1:l-1
        [a0,a1,b0,b1,a0r,a1r,b0r,b1r] = getg(i);
	k0 = 1:2:L;
	k1 = 2:2:L;
        s(k0+L) = a0*u0(k0) + b0*u0(k1) + a1*u1(k0) + b1*u1(k1);
        s(k1+L) = a0r*u0(k0) + b0r*u0(k1) + a1r*u1(k0) + b1r*u1(k1);

	u1 = u1(k0) + u1(k1) + 2^i*u0(k1);
	u0 = u0(k0) + u0(k1);
	L = L/2;
end

m = 2^l;
s(1) = u0(1)/sqrt(m);   % dc
s(2) = sqrt(3*(m-1)/(m*(m+1)))*u0(1) - 2*sqrt(3/(m*(m^2-1)))*u1(1); % lin


