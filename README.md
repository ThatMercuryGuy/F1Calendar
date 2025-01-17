This project is a variation of the traditional Travelling Salesman Algorithm
However, considerations have been made for

1. Weather

-European races before winter (< October) as it will snow in most parts
-Tropical races not in monsoon season (<July or >October) as it will rain and that hinders racecraft

2. Proximity
    -Main Objective, reducing total flight distance over the calendar year
    -Account for Spring Break in the middle of the year (All teams move to Britain/Italy)
    -Account for all teams having to ship new car from Britain/Italy factories

3. Cultural Considerations like Religious Holidays, Historical Contracts, etc.

[Methodology]
Using Geolocation Data, we optimize for the order of races given constraints, and then map the order to actual dates in the calendar

