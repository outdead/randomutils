#!/bin/bash

set -e

# Volumes Init
if [ ! -f /var/www/html/data/index.php ]; then
  echo "Init data folder"
  cp -R /opt/src/dokuwiki/data/* /var/www/html/data/
  cp -R /opt/src/dokuwiki/data/.htaccess /var/www/html/data/
  chown -R www-data /var/www/html
fi

if [ ! -f /var/www/html/lib/index.html ]; then
  echo "Init lib folder"
  cp -R /opt/src/dokuwiki/lib/* /var/www/html/lib/
  chown -R www-data /var/www/html/lib
fi

if [ ! -f /var/www/html/conf/.htaccess ]; then
  echo "Init conf folder"
  cp -R /opt/src/dokuwiki/conf/* /var/www/html/conf/
  chown -R www-data /var/www/html/conf
fi

# Lib upgrade
function copy_extra_lib {
  FOLDER_ORIGIN=$1
  FOLDER_DESTINATION=$2
  for FILEPATH_ORIGIN in ${FOLDER_ORIGIN}/*; do
    if [ -d "${FILEPATH_ORIGIN}" ]; then
      FILENAME=$(basename "${FILEPATH_ORIGIN}")
      if [ ! -d "${FOLDER_DESTINATION}/${FILENAME}" ]; then
        echo "Keeping Lib: ${FILENAME}";
        cp -R ${FILEPATH_ORIGIN} ${FOLDER_DESTINATION}/${FILENAME}
      fi
    fi
  done
}

rm -fr /opt/tmp/lib
mkdir -p /opt/tmp/lib
cp -R /opt/src/dokuwiki/lib/* /opt/tmp/lib

copy_extra_lib "/var/www/html/lib/plugins" "/opt/tmp/lib/plugins"
copy_extra_lib "/var/www/html/lib/tpl" "/opt/tmp/lib/tpl"
rm -fr /var/www/html/lib/*
cp -R /opt/tmp/lib/* /var/www/html/lib/
chown -R www-data /var/www/html/lib

# Start Server
docker-php-entrypoint apache2-foreground
