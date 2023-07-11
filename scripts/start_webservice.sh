#!/usr/bin/bash

if [[ -z "${NUM_WORKERS}" ]]; then
  NUM_WORKERS=1
fi

echo NUM_WORKERS set to $NUM_WORKERS

# if [[ $DOMAIN == "api.airt.ai" ]]; then
#     KAFKA_BROKER="production"
# elif [[ $DOMAIN == "api.staging.airt.ai" ]]; then
#     KAFKA_BROKER="staging"
# else
#     KAFKA_BROKER="dev"
# fi
echo KAFKA_BROKER value set to $KAFKA_BROKER

fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER downloading:app > ./downloading.log & 

fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER training:app > ./training.log & 

tail -f training.log
