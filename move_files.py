#!/usr/bin/env python3
import os
import shutil

base_path = "/home/runner/work/rmotly/rmotly/remotly_server/lib/src"
models_path = os.path.join(base_path, "models")

# Create models directory
os.makedirs(models_path, exist_ok=True)

# Move and rename files
files_to_move = [
    ("user.spy.yaml", "user.yaml"),
    ("notification_topic.spy.yaml", "notification_topic.yaml")
]

for old_name, new_name in files_to_move:
    old_path = os.path.join(base_path, old_name)
    new_path = os.path.join(models_path, new_name)
    if os.path.exists(old_path):
        shutil.move(old_path, new_path)
        print(f"Moved {old_name} -> models/{new_name}")
    else:
        print(f"File {old_name} not found")

print("Done!")
