
%Thrust Profile Estes A8-3 taken from 
%https://www.thrustcurve.org/simfiles/5f4294d20002e900000004e3/

%Finding Thrust values based on interpolation
[tT,T] = RocketProjectThrustCurve;

% Rocket Design inputs
mRocket = 19.25; %g
mSand = 0; %g
m = (mRocket + mSand)/1000; %kg
A = 5.0*10^-4; %Cross sectional area of the rocket

%Chute design inputs
Cd = .1;
CdChute = 1.3;
delayCharge = 3;
dChute = 13.75; %in, Diameter of the chute
dChute = dChute*2.54/10;
AChute = (dChute^2) * pi/4;

%Launch Inputs
theta = 45; %deg, launch angle, measured from the vertical
RAIL_LENGTH = 2; %ft, length of rail the rocket will launch from
RAIL_LENGTH = RAIL_LENGTH/3.28084; %Conversion from ft to m

%Initial conditions
vWind = 0; %check on day of launch
    %Start at rest
    x(1) = 0;
    y(1) = 0;
    s(1) = 0;
    Vn(1) = 0;
    Vx(1) = 0;
    Vy(1) = 0;
    apogee = RAIL_LENGTH*cosd(theta);
    t = 0;
deltaT = 0.001;
n = 1;

g = 9.81;
PRESCOTT_ELEVATION = 5367; %ft
[Temp, a, P, rho] = atmosisa(PRESCOTT_ELEVATION * 0.3048);

%TODO: Implement Chute stage and relative velocity (Vrel)

%initial velocity loop
while Vy(n) <= 0 || s(n) <= RAIL_LENGTH
    V = sqrt(Vx(n)^2 + Vy(n)^2);
    if Vy(n) <= 0
        x(n+1) = 0;
        y(n+1) = 0;
        s(n+1) = 0;
        
        %Drag = 0
        FD = 0;
    else
        s(n+1) = s(n) + deltaT * V; 
        x(n+1) = s(n+1)*sind(theta);
        y(n+1) = s(n+1)*cosd(theta);

        %Drag
        FD = 0.5 * rho * A * V^2 * Cd;
    end

    %Normal-Tangential Coordinate System
    Vn(n+1) = Vn(n) + deltaT * (T(n) - FD - m*g*cosd(theta))/m;
        %Vt = 0

    %X-Y Coordinate System    
        %Based on [s(t) -c(t); c(t) s(t)] Transformation matrix
    Vx(n+1) = Vn(n+1) * sind(theta);
    Vy(n+1) = Vn(n+1) * cosd(theta);

    t = t + deltaT;

    n = n+1;
    if n>length(T)
        fprintf("Vehicle too heavy to liftoff with A8-3 motor");
        break
    end
end

fprintf("Velocity off the rail is %.2f, Vx = %.2f, Vy = %.2f\n", V, Vx(n), Vy(n))
fprintf("n = %.0f\n", n);

%Main trajectory loop rocket off the rail, direction based on orientation determined from speed
while n <= 20000
    if n <= length(T)    % Boost
        x(n+1) = x(n) + Vx(n)*deltaT;
        y(n+1) = y(n) + Vy(n)*deltaT;
        V = sqrt(Vx(n)^2 + Vy(n)^2);
   
        %Drag due to rocket
        FD = 0.5 * rho * A * V^2 * Cd;
        FDx = FD*Vx(n)/V;
        FDy = FD*Vy(n)/V;

        %Thrust Components
        Tx = T(n) * Vx(n)/V;
        Ty = T(n) * Vy(n)/V;

        %Positioning
        Vx(n+1) = Vx(n) + deltaT * (-FDx/m + Tx/m);
        Vy(n+1) = Vy(n) + deltaT * (-FDy/m - g + Ty/m);
        t = t + deltaT;

%{
    elseif t >= delayCharge  %chute deployed
        x(n+1) = x(n) + Vx(n)*deltaT;
        y(n+1) = y(n) + Vy(n)*deltaT;
        V = sqrt(Vx(n)^2 + Vy(n)^2);
        
        %Drag due to rocket
        FD = 0.5*rho*A*V^2*Cd;
        FDx = FD*Vx(n)/V;
        FDy = FD*Vy(n)/V;
        
        %Drag due to chute
        FD = FD + 0.5 * rho * AChute * V^2 * CdChute;
        FDx = FDx + FD * Vx(n)/V;
        FDy = FDy + FD * Vy(n)/V;
 
        %Positioning
        Vx(n+1)=Vx(n) + deltaT*-(FDx)/m;
        Vy(n+1) = Vy(n) + deltaT*(-FDy/m-g);
        t(n+1)=t(n) + deltaT;
%}
    else        % Burnout
        x(n+1) = x(n) + Vx(n)*deltaT;
        y(n+1) = y(n) + Vy(n)*deltaT;
        V = sqrt(Vx(n)^2 + Vy(n)^2);
        
        %Drag due to rocket
        FD = 0.5*rho*A*V^2*Cd;
        FDx = FD*Vx(n)/V;
        FDy = FD*Vy(n)/V;
        
        %Positioning
        Vx(n+1) = Vx(n) + deltaT*(-FDx/m);
        Vy(n+1) = Vy(n) + deltaT*(-FDy/m - g);

        t = t + deltaT;
    end
    
    if y(n) > apogee
        apogee = y(n);
    end
    
    if y(n+1) <= 0
        break
    end

    n=n+1;
end

hold off
plot(x,y)
xlabel("Distance (m)")
ylabel("Height (m)")
title("Rocket Trajectory")

fprintf("\nTotal flight time = %.3f seconds\n", t);
fprintf("Apogee = %.3f m\n", apogee);
fprintf("Ground hit velocity = %.4f m/s\n", V);
