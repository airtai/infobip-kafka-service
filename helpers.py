from enum import Enum
from os import environ
from typing import Optional

from aiokafka.helpers import create_ssl_context
from pydantic import BaseModel, Field, NonNegativeInt

kafka_server_url = environ["KAFKA_HOSTNAME"]
kafka_server_port = environ["KAFKA_PORT"]

kafka_bootstrap_servers = (
    f":{kafka_server_port},".join(kafka_server_url.split(",")) + f":{kafka_server_port}"
)

aio_kafka_config = {
    "bootstrap_servers": kafka_bootstrap_servers,
    "security_protocol": "SASL_SSL",
    "sasl_mechanism": environ["KAFKA_SASL_MECHANISM"],
    "sasl_plain_username": environ["KAFKA_API_KEY"],
    "sasl_plain_password": environ["KAFKA_API_SECRET"],
    "ssl_context": create_ssl_context(),
}


class TaskType(str, Enum):
    churn = "churn"
    propensity_to_buy = "propensity_to_buy"


class ModelTrainingRequest(BaseModel):
    AccountId: NonNegativeInt = Field(
        ..., example=202020, description="ID of an account"
    )
    ApplicationId: Optional[str] = Field(
        default=None,
        example="TestApplicationId",
        description="Id of the application in case there is more than one for the AccountId",
    )
    ModelId: str = Field(
        ...,
        example="ChurnModelForDrivers",
        description="User supplied ID of the model trained",
    )
    task_type: TaskType = Field(
        ..., description="Model type, only 'churn' is supported right now"
    )
    total_no_of_records: NonNegativeInt = Field(
        ...,
        example=1_000_000,
        description="approximate total number of records (rows) to be ingested",
    )


class StartPrediction(BaseModel):
    AccountId: NonNegativeInt = Field(
        ..., example=202020, description="ID of an account"
    )
    ApplicationId: Optional[str] = Field(
        default=None,
        example="TestApplicationId",
        description="Id of the application in case there is more than one for the AccountId",
    )
    ModelId: str = Field(
        ...,
        example="ChurnModelForDrivers",
        description="User supplied ID of the model trained",
    )

    task_type: TaskType = Field(
        ...,
        example="churn",
        description="Name of the model used (churn, propensity to buy)",
    )
