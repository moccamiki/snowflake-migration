.DEFAULT_GOAL := help

MIGRATE_BIN=./bin/migrate
MIGRATIONS_DIR=./migrations
DB_URL=snowflake://$(SNOWFLAKE_USER):$(SNOWFLAKE_PASSWORD)@$(SNOWFLAKE_ACCOUNT)/$(SNOWFLAKE_DATABASE)/$(SNOWFLAKE_SCHEMA)?warehouse=$(SNOWFLAKE_WAREHOUSE)&role=$(SNOWFLAKE_ROLE)

help:  ## 利用可能なMakeコマンド一覧を表示します
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

create:  ## マイグレーションファイルを作成（例: make create テーブル追加）
	@NAME=$(word 2,$(MAKECMDGOALS)); \
	if [ "$$NAME" = "" ]; then \
		echo "ERROR: make create <マイグレーション名>"; \
		exit 1; \
	fi; \
	./create-migration.sh $$NAME

dryrun:  ## migration up ファイル一覧を表示
	@CURRENT_VERSION=`$(MIGRATE_BIN) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" version 2>/dev/null || echo 0`; \
	echo "  current version: $$CURRENT_VERSION"; \
	UP_FILES=`find $(MIGRATIONS_DIR) -type f -name '*.up.sql' | sort | \
	awk -F'/' -v curr=$$CURRENT_VERSION '{split($$NF,a,"_"); if (a[1]+0 > curr) printf "%s ", $$NF}'`; \
	DOWN_FILES=`find $(MIGRATIONS_DIR) -type f -name '*.down.sql' | sort -r | \
	awk -F'/' -v curr=$$CURRENT_VERSION '{split($$NF,a,"_"); if (a[1]+0 == curr) printf "%s ", $$NF}'`; \
	echo "  up file  :   $$UP_FILES"; \
	echo "  down file: $$DOWN_FILES"

up:  ## マイグレーションを適用します（例: make up 1）
	@COUNT=$(word 2,$(MAKECMDGOALS)); \
	if [ "$$COUNT" = "" ]; then \
		echo "  ERROR: Migration count is required. Usage: make up <number>"; \
		exit 1; \
	fi; \
	echo "  Applying $$COUNT migration(s)"; \
	$(MIGRATE_BIN) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" up $$COUNT

down:  ## マイグレーションを取り消します（例: make down 1）
	@COUNT=$(word 2,$(MAKECMDGOALS)); \
	if [ "$$COUNT" = "" ]; then \
		echo "  ERROR: Migration count is required. Usage: make down <number>"; \
		exit 1; \
	fi; \
	echo "  Reverting $$COUNT migration(s)"; \
	$(MIGRATE_BIN) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" down $$COUNT


version:  ## 現在のマイグレーションバージョンを確認します
	$(MIGRATE_BIN) -path $(MIGRATIONS_DIR) -database "$(DB_URL)" version

install:  ## golang-migrate CLI v4.16.2 を ./bin/ にインストールします
	GOBIN=$(PWD)/bin go install github.com/golang-migrate/migrate/v4/cmd/migrate@v4.16.2

# その他の単語がターゲット扱いされるのを防ぐ
%:
	@:
