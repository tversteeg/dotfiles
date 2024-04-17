#!/bin/bash

COUNT=$(wc -l < ~/Sync/todo.txt)
TODOS=$(cat ~/Sync/todo.txt | head -c -1 - | sed -z 's/\n/\\n/g')

printf '{"text": "%s", "tooltip": "%s"}\n' "$COUNT" "$TODOS"
