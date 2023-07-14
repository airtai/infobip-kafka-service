#!/usr/bin/bash

if [[ -z "${NUM_WORKERS}" ]]; then
  NUM_WORKERS=1
fi

echo NUM_WORKERS set to $NUM_WORKERS


KAFKA_BROKER="staging"
echo KAFKA_BROKER value set to $KAFKA_BROKER

# fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER downloading:app > ./downloading.log & 

fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER training:app > ./training.log & 


fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER downloading:app
