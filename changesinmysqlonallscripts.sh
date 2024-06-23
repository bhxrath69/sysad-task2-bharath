#!/bin/bash

# MySQL connection details
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-password}"
MYSQL_DB="${MYSQL_DB:-my_database}"

# Execute MySQL queries
mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -D"${MYSQL_DB}" <<EOF
    # SQL queries go here
EOF

