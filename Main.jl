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

function haversine(coord1, coord2)
    R = 6371.0  # Earth's radius in kilometers
    
    # Extract latitudes and longitudes from the input vectors
    lat1, lon1 = coord1
    lat2, lon2 = coord2
    
    # Convert latitudes and longitudes from degrees to radians
    lat1_rad = deg2rad(lat1)
    lon1_rad = deg2rad(lon1)
    lat2_rad = deg2rad(lat2)
    lon2_rad = deg2rad(lon2)
    
    # Calculate the differences between latitudes and longitudes
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    
    # Apply the Haversine formula
    a = sin(dlat/2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon/2)^2
    c = 2 * atan(sqrt(a), sqrt(1-a))
    distance = R * c
    
    return distance
end


function extractOrder(z)
    arr = []
    for i in 1:n, j in [1:(i-1); (i+1):n]
        if value(z[i,j]) > 0
            println(df[i, 2], " to ", df[j, 2])
        end
    end
end

using JuMP
import HiGHS

model = JuMP.Model(HiGHS.Optimizer)

n = 23
@variable(model, z[i in 1:n, j in [1:(i-1); (i+1):n]], Bin);

@constraint(model, one_incoming_edge[j in 1:n], sum(z[i, j] for i in 1:n if i != j) == 1)
@constraint(model, one_outgoing_edge[i in 1:n], sum(z[i, j] for j in 1:n if i != j) == 1)

@objective(model, Min, sum(z[i, j] * haversine([df[i, :].Latitude, df[i, :].Longitude], [df[j, :].Latitude, df[j, :].Longitude]) for i in 1:n for j in 1:n if i != j));

optimize!(model)