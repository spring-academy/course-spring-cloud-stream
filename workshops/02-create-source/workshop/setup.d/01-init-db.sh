# #!/bin/bash
# set +e
# LOG="/tmp/docker-services.log"

# # This script initializes the PostgreSQL database with the metadata tables required by Spring Batch

# function initialize_docker_services(){
#   while docker info | grep "Containers: 0" > /dev/null; do
#     echo "waiting for docker..." >> $LOG
#     sleep 0.1;
#   done;

#   echo "docker is running" >> $LOG

#   until docker exec postgres pg_isready | grep "accepting connections" > /dev/null; do
#     echo "waiting for postgres..." >> $LOG
#     sleep 0.1;
#   done;

#   echo "postgres is running" >> $LOG

#   initialize_schema
# }

# function initialize_schema(){
#   # It is known that pg_isready can lie.
#   # Sometimes postgres is ready, sometimes not
#   # This function retries initializing the schema 10 times
#   #   in order to give PG enough time to really start.

#   max_retries=10
#   retry=0

#   while [ $retry -lt $max_retries ]; do
#       sh ~/exercises/scripts/drop-create-database.sh 2>&1

#       if [ $? -eq 0 ]; then
#           echo "schema initialized" >> $LOG
#           break
#       else
#           echo "postgres is not actually ready. Retrying..." >> $LOG
#           retry=$((retry + 1))
#           sleep 0.5  # You can add a delay between retries if needed
#       fi
#   done

#   if [ $retry -eq $max_retries ]; then
#       echo "Schema never initialized!" >> $LOG
#       # Add your error logging code here
#       exit 1
#   fi
# }

# echo "Initializing docker services" >> $LOG
# initialize_docker_services & # run in background
# exit 0
