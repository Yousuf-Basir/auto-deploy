#!/bin/bash

for port in {6000..7000}; do
  (echo >/dev/tcp/127.0.0.1/$port) &>/dev/null || { AVAILABLE_PORT=$port; break; }
done

echo "Found available port: ${AVAILABLE_PORT}."
