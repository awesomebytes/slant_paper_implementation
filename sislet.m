function s = sislet(x);
%  sislet    shift invariant (redundant) slantlet transform. 
%
%  See also slantlt, islantlt, isislet, sltmtx.
%
%  % example
%  x = sin(sin([1:2^5]/3));
%  s = sislet(x);
%  y = isislet(s);
%  max(abs(x-y))

%  Ivan Selesnick, 1997
%  subprograms: getg.m


N = length(x);
l = log2(N);
if l ~= round(l)
	disp('sorry, need length(x) a power of 2.')
	s = [];
	break
end

s = zeros(2*l,N);
u = zeros(1,N);		% dc "moments"
v = zeros(1,N);		% linear "moments"

u(1:N/2) = x(1:2:N) + x(2:2:N);
v(1:N/2) = x(2:2:N);

% offset shift
u(N/2+1:N) = x(2:2:N) + x([3:2:N, 1]);
v(N/2+1:N) = x([3:2:N, 1]);

L = N/2;		% length of "moment" vector sections

for i = 1:l-1
   [a0,a1,b0,b1,a0r,a1r,b0r,b1r] = getg(i);
   for j = 0:2^i-1
      k = j*L;
      in1 = k+[1:2:L];	% indicies
      in2 = k+[2:2:L];
      in3 = k+[3:2:L,1];

      % offset by 0
      s(2*l-2*i+1,k+[1:L/2]) = a0*u(in1) + b0*u(in2) + a1*v(in1) + b1*v(in2);
      s(2*l-2*i+2,k+[1:L/2]) = a0r*u(in1)+ b0r*u(in2)+ a1r*v(in1)+ b1r*v(in2);

      % offset by 2
      s(2*l-2*i+1,k+[L/2+1:L]) = a0*u(in2) + b0*u(in3) + a1*v(in2) + b1*v(in3);
      s(2*l-2*i+2,k+[L/2+1:L]) = a0r*u(in2)+ b0r*u(in3)+ a1r*v(in2)+ b1r*v(in3);

      % update moment vectors
      v0 = v(in1) + v(in2) + 2^i*u(in2);
      u0 = u(in1) + u(in2);
      v1 = v(in2) + v(in3) + 2^i*u(in3);
      u1 = u(in2) + u(in3);

      v(k+[1:L/2])   = v0;
      v(k+[L/2+1:L]) = v1;
      u(k+[1:L/2])   = u0;
      u(k+[L/2+1:L]) = u1; 
   end
   L = L/2;
end

m = 2^l;
dc = u(1)/sqrt(m);
lin = sqrt(3*(m-1)/(m*(m+1)))*u(1:N) - 2*sqrt(3/(m*(m^2-1)))*v(1:N);

s(1,1:N) = dc(ones(1,N));
s(2,1:N) = lin;





