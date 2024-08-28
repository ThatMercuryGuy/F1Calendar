using Distances
using CSV
using DataFrames

csv_file = CSV.File("Formula1.csv", normalizenames = true)


#=
Constraints to Consider

1. Weather
- Try to optimise for dry and warm weather

-European races before winter (< October)
-Tropical races not in monsoon season (<July or >October)

2. Proximity
    -Main Objective, reducing total flight distance over the calendar year
    -Account for Spring Break in the middle of the year (All teams move to Britain/Italy)
    -Account for all teams having to ship new car from Britain/Italy factories

=#

df = DataFrame(csv_file)