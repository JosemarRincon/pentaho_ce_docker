#!/bin/bash
set -e
: "${MODO_EXEC:="default"}"

: "${PG_HOST:="pentaho-db"}"
: "${PG_PORT:="5432"}"

: "${SERVER_PORT:="8080"}"
: "${SERVER_PORT_AJP:="8009"}"
: "${SERVER_CONNECTION_TIME:="60000"}"
: "${SERVER_HOST:="localhost"}"
: "${CORS_REQUESTS_ALLOWED:="http:\\/\\/localhost:8080"}"

: "${PG_USER:="pentaho"}"
: "${PG_PASSWORD:="pentahouser"}"

: "${PG_HIBERNATE_DB:="hibernate"}"
: "${PG_JACKRABBIT_DB:="jackrabbit"}"
: "${PG_QUARTZ_DB:="quartz"}"

: "${PG_URL:="jdbc:postgresql:\\/\\/$PG_HOST:$PG_PORT"}"

: "${PG_HIBERNATE_URL:="$PG_URL\\/$PG_HIBERNATE_DB"}"
: "${PG_JACKRABBIT_URL:="$PG_URL\\/$PG_JACKRABBIT_DB"}"
: "${PG_QUARTZ_URL:="$PG_URL\\/$PG_QUARTZ_DB"}"

: "${DRIVER_CLASS_NAME:="org.postgresql.Driver"}"
: "${HIBERNATE_DIALECT:="org.hibernate.dialect.PostgreSQLDialect"}"
: "${VALIDATION_QUERY:="select 1"}"

: "${PENTAHO_LOG_LEVEL:="WARN"}"
: "${WEBDETAILS_LOG_LEVEL:="WARN"}"
: "${MONDRIAN_LOG_LEVEL:="DEBUG"}"


export \
SERVER_PORT \
SERVER_PORT_AJP  \
SERVER_CONNECTION_TIME  \
SERVER_HOST \

#Carrega escript de migração para postgres
source scripts/config-postgres.sh
config_pg


if [ "$1" = 'run' ]; then
  echo "***** iniciando pentaho server *****"
  
  sh ${PENTAHO_HOME}/pentaho-server/start-pentaho.sh
else
  exec "$@"
fi
