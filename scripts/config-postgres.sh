#!/bin/bash

function waiting_db(){
  pg_isready -h $PG_HOST -p $PG_PORT
  echo $?
  echo -n "-----> waiting for database on $PG_HOST:$PG_PORT ...\n"
  while ! (pg_isready -h $PG_HOST -p $PG_PORT)
  do
    echo -n '.'
    sleep 2
  done
    echo '[OK]'
}


function config_pg() {
#-------configurando hibernate
rm -rf "$PENTAHO_HOME/pentaho-server/tomcat/conf/Catalina/*"
rm -rf "$PENTAHO_HOME/pentaho-server/tomcat/temp/*"
rm -rf "$PENTAHO_HOME/pentaho-server/tomcat/work/*"

sed -i 's/hsql/postgresql/g' ${SOLUTION_HOME}/system/hibernate/hibernate-settings.xml

sed -i "s/driver_class.*/driver_class\">${DRIVER_CLASS_NAME}<\/property>/g" $SOLUTION_HOME/system/hibernate/postgresql.hibernate.cfg.xml
sed -i "s/jdbc:.*/${PG_HIBERNATE_URL}<\/property>/g" $SOLUTION_HOME/system/hibernate/postgresql.hibernate.cfg.xml
sed -i "s/username.*/username\">${PG_SERVER_USER}<\/property>/g" $SOLUTION_HOME/system/hibernate/postgresql.hibernate.cfg.xml
sed -i "s/password.*/password\">${PG_SERVER_PWD}<\/property>/g" $SOLUTION_HOME/system/hibernate/postgresql.hibernate.cfg.xml
sed -i "s/org.hibernate.dialect.*ct/${HIBERNATE_DIALECT}/g" $SOLUTION_HOME/system/hibernate/postgresql.hibernate.cfg.xml

sed -i "s/driver=.*/driver=${DRIVER_CLASS_NAME}/g" $SOLUTION_HOME/system/applicationContext-spring-security-hibernate.properties
sed -i "s/jdbc:.*/${PG_HIBERNATE_URL}/g" $SOLUTION_HOME/system/applicationContext-spring-security-hibernate.properties
sed -i "s/username=.*/username=${PG_SERVER_USER}/g" $SOLUTION_HOME/system/applicationContext-spring-security-hibernate.properties
sed -i "s/password=.*/password=${PG_SERVER_PWD}/g" $SOLUTION_HOME/system/applicationContext-spring-security-hibernate.properties
sed -i "s/org.hibernate.dialect.*ct/${HIBERNATE_DIALECT}/g" $SOLUTION_HOME/system/applicationContext-spring-security-hibernate.properties
cp -f $PENTAHO_HOME/config/applicationContext-spring-security.xml $SOLUTION_HOME/system && \

#-------configurando thema do pentaho opçoes crystal | ruby | sapphire
sed -i "s/\@THEMA\@/$THEMA/g" $PENTAHO_HOME/config/pentaho.xml && \

#sed -i "s/\@CORS_REQUESTS_ALLOWED\@/${CORS_REQUESTS_ALLOWED}/g" $PENTAHO_HOME/config/pentaho.xml && \ 
cp -f $PENTAHO_HOME/config/pentaho.xml $SOLUTION_HOME/system && \
cp -f $PENTAHO_HOME/config/defaultUser.spring.xml $SOLUTION_HOME/system && \
cp -f $PENTAHO_HOME/config/repository.spring.xml $SOLUTION_HOME/system && \

#-------configurando conexoes metadados jackrabbit
sed -i "s/\@URL_JCR\@/${PG_JACKRABBIT_URL}/g" $PENTAHO_HOME/config/repository.xml && \
sed -i "s/\@USERNAME\@/${PG_SERVER_USER}/g" $PENTAHO_HOME/config/repository.xml && \
sed -i "s/\@PASSWORD\@/${PG_SERVER_PWD}/g" $PENTAHO_HOME/config/repository.xml && \
cp -f $PENTAHO_HOME/config/repository.xml $SOLUTION_HOME/system/jackrabbit

#-------configurando conexoes metadados hibernate e quartz
sed -i "s/\@URL_HIBER\@/${PG_HIBERNATE_URL}/g" $PENTAHO_HOME/config/context.xml && \
sed -i "s/\@URL_QUARTZ\@/${PG_QUARTZ_URL}/g" $PENTAHO_HOME/config/context.xml && \
sed -i "s/\@USERNAME\@/${PG_SERVER_USER}/g" $PENTAHO_HOME/config/context.xml && \
sed -i "s/\@PASSWORD\@/${PG_SERVER_PWD}/g" $PENTAHO_HOME/config/context.xml && \
sed -i "s/\@DRIVER_CLASS_NAME\@/${DRIVER_CLASS_NAME}/g" $PENTAHO_HOME/config/context.xml && \
sed -i "s/\@VALIDATION_QUERY\@/${VALIDATION_QUERY}/g" $PENTAHO_HOME/config/context.xml && \
cp -f $PENTAHO_HOME/config/context.xml $PENTAHO_HOME/pentaho-server/tomcat/webapps/pentaho/META-INF


sed -i "s/\@PENTAHO_LOG_LEVEL\@/${PENTAHO_LOG_LEVEL}/g" $PENTAHO_HOME/config/log4j.xml && \
sed -i "s/\@WEBDETAILS_LOG_LEVEL\@/${WEBDETAILS_LOG_LEVEL}/g" $PENTAHO_HOME/config/log4j.xml && \
sed -i "s/\@MONDRIAN_LOG_LEVEL\@/${MONDRIAN_LOG_LEVEL}/g" $PENTAHO_HOME/config/log4j.xml && \
cp -f $PENTAHO_HOME/config/log4j.xml $PENTAHO_HOME/pentaho-server/tomcat/webapps/pentaho/WEB-INF/classes


sed -i "s/\@SOLUTION_HOME\@//g" $PENTAHO_HOME/config/web.xml && \
sed -i "s/@START_COMMENT_HSQLDB@/\<\!\-\-/g" $PENTAHO_HOME/config/web.xml && \
sed -i "s/@END_COMMENT_HSQLDB@/\-\-\>/g" $PENTAHO_HOME/config/web.xml && \
cp -f $PENTAHO_HOME/config/web.xml $PENTAHO_HOME/pentaho-server/tomcat/webapps/pentaho/WEB-INF

sed -i "s/.*GettingStartedDB.*//g" ${SOLUTION_HOME}/system/pentaho-spring-beans.xml

#requestParameterAuthenticationEnabled=true | false
sed -i "2s/true/false/g" ${SOLUTION_HOME}/system/security.properties

#config parametros do java
sed -i "s/=.*256m/=\"${JAVA_OPTS}/g" ${PENTAHO_HOME}/pentaho-server/start-pentaho.sh
sed -i 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/pentaho-server/tomcat/bin/startup.sh

# configura banco
sed -i "s/jackrabbit/${PG_JACKRABBIT_DB}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql
sed -i "s/jcr_user/${PG_SERVER_USER}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql
sed -i "s/password/${PG_SERVER_PWD}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql
# remove drop e create user
sed -i "s/drop user.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql
sed -i "s/CREATE USER.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql

sed -i "s/hibernate/${PG_HIBERNATE_DB}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql
sed -i "s/hibuser/${PG_SERVER_USER}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql
sed -i "s/password/${PG_SERVER_PWD}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql
# remove drop e create user
sed -i "s/drop user.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql
sed -i "s/CREATE USER.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql

sed -i "s/quartz/${PG_QUARTZ_DB}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql
sed -i "s/pentaho_user/${PG_SERVER_USER}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql
sed -i "s/password/${PG_SERVER_PWD}/g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql
#sed -i "s/qrtz5_/qrtz_/g" ${PENTAHO_HOME}/pentaho-server/data/create_quartz_postgresql.sql
# remove drop e create user
sed -i "s/drop user.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql
sed -i "s/CREATE USER.*//g" ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql

# script para config do server.xml
python3 scripts/config_server.py  server_xml
python3 scripts/config_server.py  context_xml

# Aguarda postgres subir
#waiting_db

export PGPASSWORD=$PG_PASSWORD
if ! psql -lqt -U $PG_USER -h $PG_HOST -c "SELECT usename FROM pg_user;" | grep -w ${PG_SERVER_USER}; then
    
    echo $(psql -lqt -U $PG_USER -h $PG_HOST -c "SELECT usename FROM pg_user;")

    echo "-----> creating user ${PG_SERVER_USER}"
    psql -U $PG_USER -h $PG_HOST -c "DROP USER IF EXISTS ${PG_SERVER_USER} ;"
    psql -U $PG_USER -h $PG_HOST -c "CREATE USER ${PG_SERVER_USER} WITH LOGIN ENCRYPTED PASSWORD '${PG_SERVER_PWD}';"
    
    echo "-----> importing sql files"

    psql -U ${PG_USER} -h ${PG_HOST} -f ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_jcr_postgresql.sql
    psql -U ${PG_USER} -h ${PG_HOST} -f ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_quartz_postgresql.sql
    psql -U ${PG_USER} -h ${PG_HOST} -f ${PENTAHO_HOME}/pentaho-server/data/postgresql/create_repository_postgresql.sql

fi
unset PGPASSWORD


}
