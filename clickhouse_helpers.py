from contextlib import contextmanager
from os import environ
from urllib.parse import quote_plus as urlquote
from typing import List, Dict, Union

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import Connection

from logger import get_logger

logger = get_logger(__name__)


def get_clickhouse_params_from_env_vars() -> Dict[str, Union[str, int]]:
    return dict(
        username=environ["KAFKA_CH_USERNAME"],
        password=environ["KAFKA_CH_PASSWORD"],
        host=environ["KAFKA_CH_HOST"],
        database=environ["KAFKA_CH_DATABASE"],
        port=int(environ["KAFKA_CH_PORT"]),
        protocol=environ["KAFKA_CH_PROTOCOL"],
        table=environ["KAFKA_CH_TABLE"],
    )


def _create_clickhouse_connection_string(
    username: str,
    password: str,
    host: str,
    port: int,
    database: str,
    protocol: str,
) -> str:
    # Double quoting is needed to fix a problem with special character '?' in password
    quoted_password = urlquote(urlquote(password))
    conn_str = (
        f"clickhouse+{protocol}://{username}:{quoted_password}@{host}:{port}/{database}"
    )

    return conn_str


@contextmanager  # type: ignore
def get_clickhouse_connection(  # type: ignore
    *,
    username: str,
    password: str,
    host: str,
    port: int,
    database: str,
    table: str,
    protocol: str,
    #     verbose: bool = False,
) -> Connection:
    if protocol != "native":
        raise ValueError()
    conn_str = _create_clickhouse_connection_string(
        username=username,
        password=password,
        host=host,
        port=port,
        database=database,
        protocol=protocol,
    )

    db_engine = create_engine(conn_str)
    # args, kwargs = db_engine.dialect.create_connect_args(db_engine.url)
    with db_engine.connect() as connection:
        logger.info(f"Connected to database using {db_engine}")
        yield connection


def _get_unique_account_ids_model_ids(
    host: str,
    port: int,
    username: str,
    password: str,
    database: str,
    protocol: str,
    table: str,
) -> List[Dict[str, int]]:
    with get_clickhouse_connection(  # type: ignore
        username=username,
        password=password,
        host=host,
        port=port,
        database=database,
        table=table,
        protocol=protocol,
    ) as connection:
        query = (
            f"select DISTINCT on (AccountId, ModelId, ApplicationId) AccountId, ModelId, ApplicationId from {table}"
        )
        df = pd.read_sql(sql=query, con=connection)
    return df.to_dict("records")


def get_unique_account_ids_model_ids() -> List[Dict[str, int]]:
    db_params = get_clickhouse_params_from_env_vars()
    # Replace infobip_data with infobip_start_training_data for table param
    db_params["table"] = "infobip_start_training_data"
    return _get_unique_account_ids_model_ids(**db_params)
