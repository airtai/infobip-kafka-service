#!/bin/bash
set -e

echo "Running mypy..."
mypy infobip_kafka_service

echo "Running bandit..."
bandit -r infobip_kafka_service

echo "Running semgrep..."
semgrep scan --config auto --error