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

3. Ramadan Months - Avoid Scheduling Races in Islamic Nations
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

function find(i::Int64, z)
    for j in [1:(i-1); (i+1):n]
        if value(z[i, j]) ≈ 1
            return j
        end
    end
end

function extractOrder(z)
    arr = [2]
    i = 2
    while true
        k = find(i, z)
        push!(arr, k)
        i = k

        if i == 2
            break
        end
    end

    return arr[1:23]
end

function parseOrder(v::Vector{Int64})
    returnVec = Vector{String}([])
    for i in v
        push!(returnVec, df[i,2])
    end

    return returnVec
end

using PlotlyBase
function draw_map(points, travel_route, z)
    trace_points = scattergeo(
        locationmode="ISO-3",
        lon=points[!, 3],
        lat=points[!, 2],
        hovertext=points[!, 1],
        textposition="bottom right",
        textfont=attr(family="Arial Black", size=7, color="blue"),
        mode="markers+text",
        marker=attr(size=8, color="blue"),
        name="Race Location",
        projection="mercator",
        width = 1280,
        height = 720
    )

    trace_line = scattergeo(
        locationmode="ISO-3",
        lat=[points[i, 2] for i in travel_route],
        lon=[points[i, 3] for i in travel_route],
        mode="lines",
        line=attr(width=2, color="red"),
        name="Route",
        projection="mercator",
        width = 1280,
        height = 720
    )

    return [trace_points, trace_line]
end


using JuMP
import HiGHS

model = JuMP.Model(HiGHS.Optimizer)

set_optimizer_attributes(model, 
    "parallel" => "on",
    "time_limit" => 600.0  # Set time limit
)


n = 23
@variable(model, z[i in 1:n, j in [1:(i-1); (i+1):n]], Bin);

@variable(model, is_european_race[1:n], Bin)
@constraint(model, [i in 1:n], is_european_race[i] == df[i, :is_european_race])


@variable(model, is_tropical_race[1:n], Bin)
@constraint(model, [i in 1:n], is_tropical_race[i] == df[i, :is_tropical_race])

@variable(model, 1 <= place[1:n] <= n, Int)

@constraint(model, one_incoming_edge[j in 1:n], sum(z[i, j] for i in 1:n if i != j) == 1)
@constraint(model, one_outgoing_edge[i in 1:n], sum(z[i, j] for j in 1:n if i != j) == 1)

# European race constraint (early in the sequence)
@constraint(model, european_race_position[i in 1:n], sum(z[i,j] for j in 17:n if i != j) == (1 - is_european_race[i]))


@constraint(model, mtz[i in 1:n, j in 1:n; i != j && j != 1], n * (1 - z[i, j]) + place[i] >= place[j] + 1)
@objective(model, Min, sum(z[i, j] * haversine([df[i, :].Latitude, df[i, :].Longitude], [df[j, :].Latitude, df[j, :].Longitude]) for i in 1:n for j in 1:n if i != j));

optimize!(model)

using PlotlyJS
Plot(draw_map(df[!, [2,4,5]], extractOrder(z), z), Layout(
    width=1280, height=720,
    margin=attr(l=10,r=10,t=10,b=10),
    showcountries=true,
    countrycolor="green"
))

