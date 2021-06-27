% Jun. 2021
% Sina Ameli

%% Parameter Setup
clear variables
close all
clc
load('Test18.mat')
Ts    = 0.00625;          %sample time
fc    = 0.25;             %low pass corner frequency
Alpha = exp(-2*pi*Ts*fc); %low pass filter coefficient 

%% Initialization at the rated vallues
v0      = 22;           %rated operating wind speed [m/s] 
P0      = 5296610;      %rated electrical power     [watt]
w0      = 12.1*pi/30;   %rated rotor speed          [rad/s]
omega_0 = w0;
Beta0   = 19.94;        %operating pitch angle [deg]

%% Actuator Parameters
PC_MaxPit   = 1.570796*180/pi;   %maximum pitch setting
PC_MaxRat   = 0.1396263*180/pi;  %maximum pitch rate (in absolute value)
PC_MinPit   = 0.0;

n           =  3;                %Number of actuators
zeta        =  0.6;              %damping ratio at free fault
wn          =  11.11;            %The natural frequency at free fault
zeta_0      =  0.6;              %damping ratio at free fault
wn_0        =  11.11;            %The natural frequency at free fault
wn0         =  11.11;            %The natural frequency at free fault
zeta0       =  0.6;              %damping ratio at free fault

%% Mechanical + Aerodaynamic Parameters
P0  = 5296610;       % Rated Power [Watt]
J   = 43784700;                  % rotor inertia     [kg-m^2]
rho = 1.225;                     % air density       [kgm^-3]
A   = (pi/4)*(126*cosd(2.5))^2;  % rotor sweep area  [m^2]
R   = sqrt(A/pi);                %radius of swept area
Ng  = 97;                        % gear ratio        [dimensionless]
c   =    rho*A*R;                %coeffient in the aerodynamic torque model


%% High-level loop parameters
Beta_max =  90;                  %maximum pitch angle [deg]
phi_0    =  Beta0^2;             %nominal feedforward [deg^2]
phi_bar  =  3*Beta_max^2;        %maximum control authority [deg^2]


%% Faulty parameters
%leakage (drop pressure) (fault 6)
wn2   = 5.73;  %faulty natural frequency
zeta2 = 0.45;  %faulty damping ratio

%high air content (fault 7)
wn3   = 3.42;  %faulty natural frequency 
zeta3 = 0.9;   %faulty damping ratio
%% Fault models
%transfers to ss models
[Apb,Bpb,Cpb,Dpb]     = tf2ss([wn_0^2],[1 2*zeta_0*wn_0 wn_0^2]); %nominal model
[Apb1,Bpb1,Cpb1,Dpb1] = tf2ss([wn2^2],[1 2*zeta2*wn2 wn2^2]);     %hydraulic leakge state space faulty model
[Apb2,Bpb2,Cpb2,Dpb2] = tf2ss([wn3^2],[1 2*zeta3*wn3 wn3^2]);     %high-air content state space faulty model


%% Bounded gain forgetting factor (least squre method) 
mu0       =    30;       % Maximum forgetting rate
k0        =    40;       % Bound for the gain matrix magnitude
af        =    5;        % Low-pass filter cutoff frequency
%% Controller parameters
eta     =  1;                % Integrator gain
C       =  [1 0 0 0 0 0;0 0 1 0 0 0;0 0 0 0 1 0];
l0      =  [1;1;1];         
k1      =  61;               % High-level gain
k2      =  [50;1;50;1;50;1]; % Low-level gain
epslon  =  1;
B0      =  [0;wn0^2;0;wn0^2;0;wn0^2];
%% Mapping indicator parameters
wn0sqr      = 123.4321; %wn0^2
twozetawn0  = 13.332;   %2*zeta0*wn0
dwn         = 111.7357; % maximum deviation for wn0^2
dzeta       = 10.254;   % maximum deviation for 2zeta0wn0