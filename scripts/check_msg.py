import asyncio
import os
from datetime import datetime

from aiokafka import AIOKafkaConsumer
from aiokafka.helpers import create_ssl_context


async def check_messages_for_today():
    kafka_hosts = os.getenv("KAFKA_HOSTNAME").split(",")
    bootstrap_servers = f":{os.getenv('KAFKA_PORT')},".join(kafka_hosts)
    # Define Kafka consumer configuration
    kafka_config = {
        "bootstrap_servers": bootstrap_servers,  # Replace with your Kafka broker address
        "security_protocol": "SASL_SSL",
        "sasl_mechanism": os.getenv("KAFKA_SASL_MECHANISM"),
        "sasl_plain_username": os.getenv("KAFKA_API_KEY"),
        "sasl_plain_password": os.getenv("KAFKA_API_SECRET"),
        "ssl_context": create_ssl_context(),
        "group_id": "ci-check-msg",  # Consumer group ID
        "auto_offset_reset": "earliest",  # Start consuming from the beginning of the topic
    }

    # Create a Kafka consumer
    consumer = AIOKafkaConsumer(
        "infobip_prediction", **kafka_config
    )

    # Subscribe to the 'prediction' topic
    await consumer.start()
    # consumer.subscribe(['prediction'])

    try:
        today = datetime.now().date()
        async for msg in consumer:
            # Check if the msg timestamp is for today
            msg_timestamp = datetime.fromtimestamp(
                msg.timestamp / 1000.0
            ).date()
            if msg_timestamp == today:
                print("Found a message for today:", msg.value.decode("utf-8"))
                break  # Exit the loop once a message for today is found

        else:
            raise ValueError("No messages for today found in the 'prediction' topic")

    finally:
        await consumer.stop()


if __name__ == "__main__":
    asyncio.run(check_messages_for_today())
