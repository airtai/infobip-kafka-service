import asyncio
from os import environ
from pathlib import Path


from aiokafka import AIOKafkaProducer
from rocketry import Rocketry
from rocketry.conds import daily, weekly, hourly
from rocketry.log import TaskRunRecord
from redbird.logging import RepoHandler
from redbird.repos import CSVFileRepo

from clickhouse_helpers import get_unique_account_ids_model_ids
from helpers import aio_kafka_config, ModelTrainingRequest, StartPrediction
from logger import get_logger


root_path = Path(environ["ROOT_PATH"])
log_file = root_path / "rocketry_logs.csv"

csv_file_repo = CSVFileRepo(filename=log_file, model=TaskRunRecord)
app = Rocketry(execution="async", logger_repo=csv_file_repo)

logger = get_logger(__name__)
handler = RepoHandler(repo=csv_file_repo)


@app.task(weekly.on("Friday"))
async def start_weekly_training():
    rows = get_unique_account_ids_model_ids()
    producer = AIOKafkaProducer(**aio_kafka_config)
    await producer.start()
    try:
        for row in rows:
            model_training_req = ModelTrainingRequest(
                AccountId=row["AccountId"],
                ModelId=row["ModelId"],
                task_type="churn",
                total_no_of_records=0,
            )
            msg = (model_training_req.json()).encode("utf-8")
            logger.info(f"Sending weekly retraining for {msg=}")
            await producer.send_and_wait("infobip_start_training_data", msg)
    finally:
        await producer.stop()


# ToDo: Change hourly to daily
@app.task(hourly)
async def start_daily_prediction():
    rows = get_unique_account_ids_model_ids()
    producer = AIOKafkaProducer(**aio_kafka_config)
    await producer.start()
    try:
        for row in rows:
            start_prediction = StartPrediction(
                AccountId=row["AccountId"],
                ModelId=row["ModelId"],
                task_type="churn",
            )
            msg = (start_prediction.json()).encode("utf-8")
            logger.info(f"Sending daily retraining for {msg=}")
            await producer.send_and_wait("infobip_start_prediction", msg)
    finally:
        await producer.stop()


async def main():
    "Launch Rocketry app"
    rocketry_task = asyncio.create_task(app.serve())
    await rocketry_task


if __name__ == "__main__":
    asyncio.run(main())
