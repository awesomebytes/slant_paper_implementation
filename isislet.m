function y = isislet(s)
%  isislet   inverse shift invariant slantlet transform.
%
%  See also slantlt, islantlt, sislet, sltmtx.
%
%  % example
%  x = sin(sin([1:2^5]/3));
%  s = sislet(x);
%  y = isislet(s);
%  max(abs(x-y))

%  Ivan Selesnick, 1997
%  subprograms: getg.m


si = size(s);

N = si(2);
l = log2(N);

if l ~= round(l)
        disp('sorry, need length(s) a power of 2.')
	y = [];
        break
end

u = zeros(1,N);
v = zeros(1,N);

m = 2^l;
u = s(1,1:N)/sqrt(m) + s(2,1:N)*sqrt(3*(m-1)/(m*(m+1)));
v = s(2,1:N) * (-2*sqrt(3/(m*(m^2-1))));

L = N/2;
for i = 1:l-1
   [a0,a1,b0,b1,a0r,a1r,b0r,b1r] = getg(l-i);
   t = 1:2^(i-1);
   g = 2^(i-1);
   for j = 0:2^(l-i)-1
	K = j*2^i;

	in1 = 1:2:2^i;	% indicies
	in2 = 2:2:2^i;

	v0 = zeros(1,2*g);
	u0 = zeros(1,2*g);
	v1 = zeros(1,2*g);
	u1 = zeros(1,2*g);

	u0(in1) = u(K+t);
        u0(in2) = u(K+t) + 2^(l-i)*v(K+t);
	v0(in1) = v(K+t);
	v0(in2) = v(K+t);

	u1(in1) = u(K+g+t);
        u1(in2) = u(K+g+t) + 2^(l-i)*v(K+g+t);
        v1(in1) = v(K+g+t);
        v1(in2) = v(K+g+t);

	u0(in1) = u0(in1) + a0*s(2*i+1,K+t) + a0r*s(2*i+2,K+t);
        u0(in2) = u0(in2) + b0*s(2*i+1,K+t) + b0r*s(2*i+2,K+t);
        v0(in1) = v0(in1) + a1*s(2*i+1,K+t) + a1r*s(2*i+2,K+t);
        v0(in2) = v0(in2) + b1*s(2*i+1,K+t) + b1r*s(2*i+2,K+t);

        u1(in1) = u1(in1) + a0*s(2*i+1,K+g+t) + a0r*s(2*i+2,K+g+t);
        u1(in2) = u1(in2) + b0*s(2*i+1,K+g+t) + b0r*s(2*i+2,K+g+t);
        v1(in1) = v1(in1) + a1*s(2*i+1,K+g+t) + a1r*s(2*i+2,K+g+t);
        v1(in2) = v1(in2) + b1*s(2*i+1,K+g+t) + b1r*s(2*i+2,K+g+t);

	% average
	u(K+[1:2*g]) = (u0 + u1([2*g, 1:2*g-1]))/2;
        v(K+[1:2*g]) = (v0 + v1([2*g, 1:2*g-1]))/2;
   end
end

y0 = zeros(1,N);
y1 = zeros(1,N);

y0(1:2:N) = u(1:N/2);
y0(2:2:N) = u(1:N/2)+v(1:N/2);

y1(2:2:N) = u(N/2+1:N);
y1(1:2:N) = [u(N)+v(N) u(N/2+1:N-1)+v(N/2+1:N-1)];

% average
y = (y0+y1)/2;



