#!/bin/bash

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
# NOMINATIM_DATA_LABEL=${NOMINATIM_DATA_LABEL:="data"}
# NOMINATIM_PBF_PATH=${NOMINATIM_PBF_PATH:="maldives-latest.osm.pbf"}
NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://localhost/uploads/osm/maldives-latest.osm.pbf"}

# Retrieve Data Files
curl $NOMINATIM_PBF_URL --create-dirs -o $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf
curl http://localhost/uploads/osm/wikipedia_article.sql.bin --create-dirs -o $NOMINATIM_DATA_PATH/wikipedia_article.sql.bin
curl http://localhost/uploads/osm/wikipedia_article.sql.bin --create-dirs -o $NOMINATIM_DATA_PATH/wikipedia_article.sql.bin
curl http://localhost/uploads/osm/wikipedia_redirect.sql.bin --create-dirs -o $NOMINATIM_DATA_PATH/wikipedia_redirect.sql.bin
curl http://localhost/uploads/osm/gb_postcode_data.sql.gz --create-dirs -o $NOMINATIM_DATA_PATH/gb_postcode_data.sql.gz

# Allow user accounts read access to the data
chmod 755 $NOMINATIM_DATA_PATH

# Start PostgreSQL
service postgresql start

# Import data
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
useradd -m -p password1234 nominatim
sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf --all --threads 8
sudo -u nominatim /srv/nominatim/build/utils/update.php --recompute-word-counts


# Tail Apache logs
tail -f /var/log/apache2/* &

# Run Apache in the foreground
/usr/sbin/apache2ctl -D FOREGROUND
