#!/bin/bash

NAME=$1
if [ -z "$NAME" ]; then
  echo "Usage: $0 migration_name"
  exit 1
fi

DIR="migrations"
mkdir -p $DIR

# 最新バージョン取得
VERSION=$(ls $DIR | grep '^[0-9]*_.*\.up\.sql' | sed 's/_.*//' | sort -n | tail -n 1)
NEXT_VERSION=$(printf "%03d" $((10#$VERSION + 1)))

UP_FILE="${DIR}/${NEXT_VERSION}_${NAME}.up.sql"
DOWN_FILE="${DIR}/${NEXT_VERSION}_${NAME}.down.sql"

touch "$UP_FILE"
touch "$DOWN_FILE"

echo "Created:"
echo "  $UP_FILE"
echo "  $DOWN_FILE"
