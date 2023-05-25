# Given a polygon with n vertices represented by latitude (φ) and longitude (λ) coordinates:
# Let (φi, λi) be the coordinates of the i-th vertex.
# A = (1/2) * Σ[(λi + λi+1) * (φi+1 - φi)], for i = 1 to n-1

long = [27.38398646394512,27.39258889279089,27.39245499456955,27.38437029168849,27.38398646394512]
lat = [46.06741616081491,46.06818620108033,46.06941815343022,46.06861137285969,46.06741616081491]

def get_area(lat, lon):
    res = 0
    for i in range(len(lat) - 1):
        res += (lon[i] + lon[i+1]) * (lat[i+1] - lat[i])
    res = abs(res) / 2
    # Conversion factor for latitude and longitude degrees to kilometers (approximation)
    conversion_factor = 93 # Approximately 93 km per degree (at the equator)

    area_ha = 100 *  res * conversion_factor**2
    print(area_ha)

get_area(lat,long)

0.114