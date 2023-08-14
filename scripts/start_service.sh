#!/usr/bin/bash

if [[ -z "${NUM_WORKERS}" ]]; then
  NUM_WORKERS=1
fi

echo NUM_WORKERS set to $NUM_WORKERS


KAFKA_BROKER="staging"
echo KAFKA_BROKER value set to $KAFKA_BROKER

fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER infobip_kafka_service.downloading:app &> ./downloading.log & 

fastkafka run --num-workers $NUM_WORKERS --kafka-broker $KAFKA_BROKER infobip_kafka_service.training:app &> ./training.log & 

venv/bin/python infobip_kafka_service/scheduler.py &> ./scheduler.log & 

tail -f training.log
