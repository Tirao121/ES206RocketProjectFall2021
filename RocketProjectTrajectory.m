
%Thrust Profile Estes A8-3 taken from 
%https://www.thrustcurve.org/simfiles/5f4294d20002e900000004e3/

%Finding Thrust values based on interpolation
[tT,T] = RocketProjectThrustCurve;

% Rocket Design inputs
%{
A = 
Cd = 
m =
%}
theta = 30; %deg, launch angle
deltaT = 0.001;

%initial conditions
vWind = 0; %check on day of launch
    %Start at rest
    x = [0];
    y = [0];
    Vx(1) = 0;
    Vy(1) = 0;
n = 1;

PRESCOTT_ELEVATION = 5367; %ft
[Temp, a, P, rho] = atmosisa(PRESCOTT_ELEVATION * 0.3048);

%{
%TODO: Implement Thrust (F) and relative velocity (Vrel)
while y(n) >= 0
    if F ~= 0   % Boost
        x = [x, x(n) + Vx(n)];
        y = [y, y(n) + Vy(n)];
        V = sqrt(Vx(n)^2 + Vy(n)^2);
        FD = 0.5*rho*A*V^2*CD;
        FDx = FD*Vx(n)/V;
        FDy = FD*Vy(n)/V;
        Vx(n+1)=V(n)*deltaT*-(FDx)/m;
        Vy(n+1) = Vy(n) + deltaT*(-FDy/m-g);
        t(n+1)=t(n)+deltaT;
    else        % Burnout
        x = [x, x(n) + Vx(n)];
        y = [y, y(n) + Vy(n)];
        V = sqrt(Vx(n)^2 + Vy(n)^2);
        FD = 0.5*rho*A*V^2*CD;
        FDx = FD*Vx(n)/V;
        FDy = FD*Vy(n)/V;
        Vx(n+1)=V(n)*deltaT*-(FDx)/m;
        Vy(n+1) = Vy(n) + deltaT*(-FDy/m-g);
        t(n+1)=t(n)+deltaT;
    end
    if y(n+1) < 0
        break
    end
    n=n+1;
end
%plot(x,y)
%}
