#!/bin/bash
sudo apt update && sudo apt upgrade
sudo apt install postgresql postgresql-contrib postgis postgresql-9.5-postgis-2.2
sudo -u postgres -i
createuser osm
createdb -E UTF8 -O osm gis
psql -c "CREATE EXTENSION hstore;" -d gis
psql -c "CREATE EXTENSION postgis;" -d gis
exit
sudo adduser osm
su - osm
wget https://github.com/gravitystorm/openstreetmap-carto/archive/v2.41.0.tar.gz
tar xvf v2.41.0.tar.gz
wget -c http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
wget -c http://download.geofabrik.de/europe/great-britain-latest.osm.pbf
exit
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# sudo nano /etc/ssh/ssh_config
# paste the following text at the end of the file
# ServerAliveInterval 60
sudo apt install osm2pgsql
su - osm
osm2pgsql --slim -d gis -C 3600 --hstore -S openstreetmap-carto-2.41.0/openstreetmap-carto.style great-britain-latest.osm.pbf
exit
sudo apt install git autoconf libtool libmapnik-dev apache2-dev
git clone https://github.com/openstreetmap/mod_tile.git
cd mod_tile/
./autogen.sh
./configure
make
sudo make install
sudo make install-mod_tile
sudo apt install curl unzip gdal-bin mapnik-utils node-carto
su - osm
cd openstreetmap-carto-2.41.0/
./get-shapefiles.sh
carto project.mml > style.xml
exit
# sudo nano /usr/local/etc/renderd.conf
# In the [default] section, change the value of XML and HOST to the following.
# XML=/home/osm/openstreetmap-carto-2.41.0/style.xml
# HOST=localhost
# In [mapnik] section, change the value of plugins_dir.
# plugins_dir=/usr/lib/mapnik/3.0/input/
# save and close
sudo cp mod_tile/debian/renderd.init /etc/init.d/renderd
sudo chmod a+x /etc/init.d/renderd
# sudo nano /etc/init.d/renderd
# Change the following variable.
# DAEMON=/usr/local/bin/$NAME
# DAEMON_ARGS="-c /usr/local/etc/renderd.conf"
# RUNASUSER=osm
# Save the file.
# Create the following file and set osm the owner.
sudo mkdir -p /var/lib/mod_tile
sudo chown osm:osm /var/lib/mod_tile
sudo systemctl daemon-reload
sudo systemctl start renderd
sudo systemctl enable renderd
sudo apt install apache2
# Create a module load file.
# sudo nano /etc/apache2/mods-available/mod_tile.load
# Paste the following line into the file.
# LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so
# save and close
sudo ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
# edit the default virtual host file.
# Paste the following lines in <VirtualHost *:80>

# Save and close the file
sudo systemctl restart apache2
echo "In your browser go to $IPADD/osm_tiles/0/0/0.png"
echo "You should see the tile of world map. Congrats! You just successfully built your own OSM tile server."
cd /var/www/html
sudo wget https://github.com/openlayers/openlayers/releases/download/v4.3.4/v4.3.4.zip
sudo unzip v4.3.4.zip
# create the index.html file
# sudo nano /var/www/html/index.html
# Paste the following HTML code in the file. Replace red-colored text and adjust the longitude, latitude and zoom level according to your needs.

# Save and close the file. Now you can view your slippy map by typing your server IP address in browser.
echo "In your browser go to $IPADD/index.html"
exit 0
