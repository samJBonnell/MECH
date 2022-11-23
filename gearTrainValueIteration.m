%{
    The following code is used to iterate towards the best combination of
    parameters for the gear train value of an arbitrary gear box.

    The following parameters are defined by the user:
    - V_user_max:    maximum velocity the user will be able to move their hand
    - F_user_max:    maximum input force the user will provide to the handle
    - mu:       proportion of vehicle mass the device must lift
    - m:        mass of vehicle to be lifted
    - a:        max acceleration upwards of lift

    All other parameters will be optimized by the program. Ensure all units
    are self-consistent prior to using.

    For Development -
        - Set the maximum acceptable values for each of the parameters
        - Linearize between the points
        - Calculate e for each of the sets of points
        - Minimize R*F/V_t which will minimize the space requirements and
        maximize the velocity the rack moves at
%}

% Constants
V_t = 0.05; % ft/s
mu = 0.667; % unit-less
m = 100;    % slug
g = 32.17;  % ft/s^2
a = 4.75;   % ft/s^2

outPutPrompt = "Define precision of search: ";
h = input(outPutPrompt);   % "Mesh" Precision

tStart = tic;    % Start the timer

% Maximum and minimum allowable values - will be iterated up until
V_user_max = 0.75;  % ft/s
F_user_max = 50; % lbf
R_user_max = 1;  % ft

V_user_min = 0.05;  % ft/s
F_user_min = 0.05; % lbf
R_user_min = 0.1;  % ft

% Defining the Gearing System

P_d = [3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32];
%P_d = [3, 4, 5, 6, 8];

N_max = 60;
N_min = 12;
N = linspace(N_min, N_max, N_max - (N_min - 1));

if size(N,2)>1  % Check if the initial conditions are in column vector form - if not, change them to column vector form.
    N = N(:);
end

D_p = N./(12*P_d);   % Create a list of all the diametrical pitches to check

V_user_vec = linspace(V_user_min, V_user_max, h);
F_user_vec = linspace(F_user_min, F_user_max, h);
R_user_vec = linspace(R_user_min, R_user_max, h);

minimumMetric = -1;
optF = 0;
optV = 0;
optR = 0;
optD = 0;
optS = 0;

optMaxE = 0;
optMinE = 0;

tempMinE = 0;
tempMaxE = 0;

% Run the check for the optimal solution

for D_0 = 1:size(D_p, 1)                % Checking all pitch diameters
    fprintf("Checking D_p = %.3f - Starting at %.6f\n", D_p(D_0), toc(tStart));
    for V_0 = 1:size(V_user_vec, 2)     % Checking all input velocities
        for F_0 = 1:size(F_user_vec, 2) % Checking all input forces
            for R_0 = 1:size(R_user_vec, 2) % Checking all input radii
                F = F_user_vec(F_0);
                V = V_user_vec(V_0);
                R = R_user_vec(R_0);
                D = D_p(D_0);

                tempMinE = lowerBound(V, V_t, R, D);
                tempMaxE = upperBound(F, R, mu, m, D, g, a);

                S = 22*F*R/(D*tempMaxE);

                if eq(minimumMetric, -1) && tempMaxE - tempMinE > 0         % if the metric has not been calculated before, set the initial metric
                    minimumMetric = checkMin(F,R,V,D,S,tempMaxE);
                end

                tempMetric = checkMin(F,R,V,D,S,tempMaxE);

                if tempMetric < minimumMetric && tempMaxE - tempMinE > 0    % If a smaller metric is found, set the minimumMetric equal to the new metric
                    minimumMetric = tempMetric;
                    optF = F;
                    optV = V;
                    optR = R;
                    optD = D;
                    optS = S;
                    
                    optMaxE = tempMaxE;
                    optMinE = tempMinE;
                end
                
            end
        end
    end
end

if optMaxE ~= 0 || optMinE ~= 0
    fprintf("\nGear train bounds: %.3f <= GR <= %.3f\n", 1/optMaxE, 1/optMinE);
    fprintf("Optimum values: F = %.3f lbf, V = %.3f ft/s, R = %.3f ft, D_p = %.3f in, S = %.3f lbf\n\n", optF, optV, optR, 12*optD, optS);
else
    fprintf("\nNo solutions found - Change parameters of search.\n");
end

fprintf("Bounds determined in %.6f seconds with a mesh size of %i\n", toc(tStart),h);