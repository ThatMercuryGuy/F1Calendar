#This script serves to automatically generate
#Latitude and Longitude values for all the
#circuit locations in the Formula1.csv dataset


# Import the required library
from geopy.geocoders import Nominatim
import csv
# Initialize Nominatim API
geolocator = Nominatim(user_agent="MyApp")
with open ('Formula1.csv') as f:
    with open ('temp.csv', 'w', newline = '') as g:
        r = csv.reader (f)
        w = csv.writer (g)
        
        next (r)
        for i in r:
            location = geolocator.geocode (i[-1])
            w.writerow (i + [location.latitude, location.longitude])