% this method abandoned the big M method.
% Because the optimum solution will never let simultaneous charge/discharge 
% process happen, which is definitely a loss of energy.

clear % clear variables 

clc % clear command window
tic
load Pspot % spot market 
load P_single % production of 72 MW wind turbines

%% constant values
T = 24;
% charge and discharge efficiency
eta_charge = 0.95;
eta_discharge = 0.95;

Capa_battery = 10;

SOC_initial = 0.5 * Capa_battery;
SOC_min = 0.1 * Capa_battery;
SOC_max = 0.9 * Capa_battery; 

% production of ome day with turbine
P_single2 = P_single( 145: 168 );

% max charge/discharge rate
max_charge = min( 0.9 * Capa_battery / eta_charge * ones ( T , 1 ), P_single2); 
max_discharge = 0.9 * Capa_battery * eta_discharge * ones( T, 1);

%% define variables
P_charge = sdpvar( T , 1 );
P_discharge = sdpvar( T, 1 );

% It is not necessary anymore for this situation
%delta_charge = binvar ( T , 1 );
%delta_discharge = binvar ( T , 1 );

SOC = sdpvar ( T + 1, 1 );

%% set constraints 

constraints = [ ];

% battery cannot be charged while being discharged
% not necessary for this situation either
% constraints = [ constraints, delta_charge + delta_discharge <=1];

% maximum charge/discharge rate
constraints = [ constraints, 0 <=P_charge <= max_charge];
constraints = [ constraints, -max_discharge <= P_discharge <= 0];

% SOC constraints
constraints = [ constraints, SOC_min <= SOC<= SOC_max ];
constraints = [ constraints, SOC( 1, 1 ) == SOC_initial ];
constraints = [ constraints, SOC( end, 1 ) == SOC_initial ];

 for t = 1: T
 constraints = [ constraints, SOC( t+1 ,1 ) == SOC( t, 1 ) + ...
 P_charge(t ,1)* eta_charge + P_discharge(t ,1) / eta_discharge  ];
 end

Objective = - Pspot' * ( P_single2 - P_charge - P_discharge );

options = sdpsettings( 'solver', 'gurobi' );

result = optimize ( constraints, Objective, options);

P_disc = value( P_discharge );
P_char = value( P_charge );

SOC1 = value( SOC );

benchmark = Pspot' * P_single2 ;
toc


















