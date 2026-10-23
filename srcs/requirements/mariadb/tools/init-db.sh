#!/bin/sh

set -eu

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

chown -R mysql:mysql /var/lib/mysql

if [ ! -e /var/lib/mysql/mysql ]
then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    cat > /tmp/init.sql << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mariadbd --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
fi

exec mariadbd --user=mysql