#!/bin/bash

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
NOMINATIM_PBF_PATH=${NOMINATIM_PBF_PATH:="maldives-latest.osm.pbf"}
wget -O $NOMINATIM_DATA_PATH https://www.nominatim.org/data/wikipedia_article.sql.bin
wget -O $NOMINATIM_DATA_PATH https://www.nominatim.org/data/wikipedia_redirect.sql.bin
wget -O $NOMINATIM_DATA_PATH https://www.nominatim.org/data/gb_postcode_data.sql.gz

# Allow user accounts read access to the data
chmod 755 $NOMINATIM_DATA_PATH

# Start PostgreSQL
service postgresql start

# Import data
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
useradd -m -p password1234 nominatim
sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_PBF_PATH --all --threads 2
sudo -u nominatim /srv/nominatim/build/utils/update.php --recompute-word-counts


# Tail Apache logs
tail -f /var/log/apache2/* &

# Run Apache in the foreground
/usr/sbin/apache2ctl -D FOREGROUND
