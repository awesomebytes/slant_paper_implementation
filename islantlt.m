function y = islantlt(s)
%  islantlt  inverse slantlet transform.
%
%  See also slantlt, sislet, isislet, sltmtx.
%
%  % example
%  x = sin(sin([1:2^5]/3));
%  s = slantlt(x);
%  y = islantlt(s);
%  max(abs(x-y))

%  Ivan Selesnick, 1997
%  subprograms: getg.m


N = length(s);
l = log2(N);
if l ~= round(l)
        disp('sorry, need length(s) a power of 2.')
	y = [];
        error('sorry, need length(s) a power of 2.')
end

u0 = zeros(size(s(1:N/2)));
u1 = u0;

m = 2^l;
u0(1) = s(1)/sqrt(m) + s(2)*sqrt(3*(m-1)/(m*(m+1)));   % dc component
u1(1) = -s(2)*2*sqrt(3/(m*(m^2-1)));                   % linear component

L = N/2;
for i = 1:l-1
	n0 = 1:L:N/2;
	n1 = n0+L/2;
	L = L/2;
	u0(n1) = u0(n0)+2^(l-i)*u1(n0);
  	u1(n1) = u1(n0);

        [a0,a1,b0,b1,a0r,a1r,b0r,b1r] = getg(l-i);

	k0 = 2^i+[1:2:2^i];
	k1 = k0+1;
	u0(n0) = u0(n0) + a0*s(k0) + a0r*s(k1);
	u0(n1) = u0(n1) + b0*s(k0) + b0r*s(k1);
        u1(n0) = u1(n0) + a1*s(k0) + a1r*s(k1);
        u1(n1) = u1(n1) + b1*s(k0) + b1r*s(k1);
end

y = zeros(size(s));
y(1:2:N) = u0;
y(2:2:N) = u0+u1;


