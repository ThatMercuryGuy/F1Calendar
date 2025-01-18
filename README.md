This project is a variation of the traditional Travelling Salesman Algorithm
However, considerations have been made for

1. Weather

-European races before winter (< October) as it will snow in most parts - IMPLEMENTED
-Tropical races not in monsoon season (<July or >October) as it will rain and that hinders racecraft [TODO]

2. Proximity [IMPLEMENTED]
    -Main Objective, reducing total flight distance over the calendar year
    -Account for Spring Break in the middle of the year (All teams move to Britain/Italy)

3. Cultural Considerations like Religious Holidays, Historical Contracts, etc. [IMPLICITLY IMPLEMENTED]

[Methodology]
Using Geolocation Data, we optimize for the order of races given constraints, and then map the order to actual dates in the calendar

The JuMP Framework in Julia is used to model the Linear Programming Problem, and the HiGHS solver
is used to solve the problem.

![Current Optimal Route](plot_1.svg)