from os import environ
from pathlib import Path

from airt.infobip.kafka_downloading import create_app


root_path = Path(environ["ROOT_PATH"])
downloading_group_id = environ["DOWNLOADING_GROUP_ID"]
# training_group_id = environ["TRAINING_GROUP_ID"]


app = create_app(
    root_path=root_path / downloading_group_id, group_id=downloading_group_id
)
