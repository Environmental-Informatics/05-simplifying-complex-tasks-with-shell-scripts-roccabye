#!/bin/bash
#Created on Feb. 20,2020
#Author: Alka Tiwari (tiwari13)
#This script has three parts

# Part I:
# Identify and separate out "high elevation" stations from the rest.

#Search through the contents of the station files in the StationData directory
#Checking whether StationDatadirectory exist
if [ ! -d StationData/ ]
then
    echo 'Error:StationData Directory does not exist'
    echo
    exit
fi

#Identify those stations at altitudes equal to or greater than 200 feet (try: grep or awk), and
#Copy those stations above an elevation of 200 feet (try: cp) to a new directory called "HigherElevation" (try: mkdir).
#Check whether HigherElevation directory exists, if not create one.
if [ -d "HigherElevation" ]
then 
	echo -e "\t'HigherElevation' directory already exists"
else
	mkdir HigherElevation
fi
#Copy files from StationData to HigherElevation by filtering only the station which has elevation >200feet
for file in StationData/*
do
        if
	grep 'Altitude: [>200]' $file # checking files with altitude>200 in stationData directory
	then
	        fileName=`basename $file` # using basename function to extract only the filename
		cp $file HigherElevation/$fileName # copying the files in the new directory HigherElevation
	fi
done
echo "HigherElevation files populated from Stationdata directory with station altitude>200feet: Part I Completed"

echo

#Part II:
#Plot the locations of all stations, while highlighting the higher elevation stations.

#Use command line tools to extract latitude and longitude for each file in the StationData folder, and again in the HigherElevation folder.

# extract longitude and latitude from StationData directory

awk '/Latitude/ {print 1 * $NF}' StationData/Station_*.txt > Lat.list
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list #'-' is used because it is West of Prime Meridian.
paste Long.list Lat.list > AllStation.xy #Yes, the output file does look like the Long and Lat values.

# extract longitude and latitude from HigherElevation directory

awk '/Latitude/ {print 1 * $NF}' HigherElevation/Station_*.txt > HELat.list
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list #'-' is used because it is West of Prime Meridian.
paste HELong.list HELat.list >  HEStation.xy


module load gmt # loading required library

# Generate Plots (basic figures)
#The gmt pscoast command will draw land and water surfaces as well as politcal boundaries. Details of the command and its options can be found at http://gmt.soest.hawaii.edu/doc/5.3.2/pscoast.html.
# plotting coastlines, rivers and political boundaries in this case.

gmt pscoast -JU16/4i -R-93/-86/36/43 -Dh -B2f0.5 -Ia/blue -Na/orange -P -Sblue -K -V -W > SoilMoistureStations.ps

#The gmt psxy command will draw X-Y pairs of data in cartesian or geographic coordinates. Details of the command and its options can be found at http://gmt.soest.hawaii.edu/doc/5.3.2/psxy.html.
# adding small black circles for all station locations.

gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps

# adding small red circles for all higher elevation stations.

gmt psxy HEStation.xy -J -R -Sc0.06 -Gred -O -V >> SoilMoistureStations.ps

# use the below command 'gv SoilMoistureStations.ps &' to view the figure.
# Note that you can leave it running and use the "reload" button as you complete the next steps.

#gv SoilMoistureStations.ps &
echo
echo "Maps generated: Part II Completed"
echo
echo Part III takes time so be patient....
#Part III:
#Convert the figure into other image formats

#Convert PostScript (.ps) to Encapsulated PostScript Interchange (.epsi) Format

ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

#Convert the EPSI file into a TIF image, using a density of 150 dots per inch (dpi).

convert -density 150x150 SoilMoistureStations.epsi SoilMoistureStations.tif

echo "Generated plots from Part II are converted from PS to EPSI to TIF format : Part III Completed"


