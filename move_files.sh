#!/bin/bash
cd /home/runner/work/rmotly/rmotly/remotly_server
mkdir -p lib/src/models
mv lib/src/user.spy.yaml lib/src/models/user.yaml 2>/dev/null || true
mv lib/src/notification_topic.spy.yaml lib/src/models/notification_topic.yaml 2>/dev/null || true
echo "Files moved successfully"
