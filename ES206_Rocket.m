% Rocket Parameters
m = 40/1000; %kg
A = 5.0*10^-4; %m
v0 = 30; % m/s
theta = 60; %deg, launch angle
p = 1.0583; %density at 5000 ft
Cd = 0.1; 
t = 0;
dt = 0.1;
g = 9.8; %m/s^2

% Positoin and Velocity 
x = [];
y = [];
vx = [];
vy = []; 
v0x = v0*cosd(theta);
v0y = v0*sind(theta);
x(1) = 0;
y(1) = 0;
vx(1)= v0x;
vy(1)= v0y;

for i = 1:1000000
    x(i+1) = x(i) + vx(i)*dt;
    y(i+1) = y(i) + vy(i)*dt;
    v = sqrt(vx(i)^2 + vy(i)^2)'; 
    Fd = 0.5*p*A*v^2*Cd; %Drag force equation

    Fdx = Fd*(vx(i)/v);
    Fdy = Fd*(vy(i)/v);
    vx(i+1) = vx(i) + dt*(-Fdx/m);
    vy(i+1) = vy(i) + dt*((-Fdy/m)-g);

    if y(i+1) < 0
        break
    end
end
    plot (x,y)



