#!/bin/bash

DURATION=240
END=$((SECONDS + DURATION))

while [ $SECONDS -lt $END ]; do
  ts=$(date +"%Y-%m-%d %H:%M:%S")

  # Get Active connections from nginx_status
  active=$(curl -s http://127.0.0.1:9999/nginx_status | awk '/Active connections/ {print $3}')
  active=${active:-0}  # fallback if empty

  # Get health endpoint status
  health_code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9999/health)

  echo "$ts | Active connections: $active | Health status: $health_code"

  sleep 1
done
