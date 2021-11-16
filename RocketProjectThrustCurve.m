function [tT, T] = RocketProjectThrustCurve

%Thrust Profile Estes A8-3 taken from 
%https://www.thrustcurve.org/simfiles/5f4294d20002e900000004e3/
tF = [0 0.041 0.084 0.127 0.166 0.192 0.206 0.226 0.236 0.247 0.261 0.277];
tF = [tF 0.306 0.351 0.405 0.467 0.532 0.589  0.632 0.652 0.668 0.684 0.703 0.73];
F = [0 0.512 2.115 4.358 6.794 8.588 9.294 9.73 8.845 7.179 5.063 3.717];
F = [F 3.205 2.884 2.499 2.371 2.307  2.371 2.371  2.243 1.794 1.153 0.448 0];

plot(tF,F, 'r-o')
hold on

tT = 0:.001:.73;     %time where thrust is active
T = linspace(0,0,length(tT));
n = 1;
m = 1;

while tT(n) < .73
    if tT(n+1) > tF(m) 
        m = m+1;
    end
    if m == 1 
        T(n) = F(m);
    else 
        T(n) = (F(m)-F(m-1))/(tF(m)-tF(m-1)) * (tT(n)-tF(m-1)) + F(m-1);
    end
    n = n+1;
end

plot(tT,T,'b-')
ylabel("F(N)");
xlabel("t(s)");

hold off
end