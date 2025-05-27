# Snowflake マイグレーション管理
このリポジトリは [golang-migrate](https://github.com/golang-migrate/migrate) を使用して
Snowflake のスキーママイグレーションを管理するためのプロジェクトです。

Makefile のコマンドを使って、マイグレーションの作成・適用・ダウンロール・プレビューが簡単に行えます。

## セットアップ
### 1. golang-migrate CLI のインストール
```bash
make install
```

「./bin/migrate」 に CLI がインストールされます。

### 2. 環境変数の設定
.env.example を元に .env ファイルを作成してください。
```env
ENVIRONMENT=dev
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_DATABASE=sv_leauge_${ENVIRONMENT}
SNOWFLAKE_SCHEMA=mbk_schema
SNOWFLAKE_WAREHOUSE=mbk_wh_${ENVIRONMENT}
SNOWFLAKE_ROLE=SYSADMIN
```

## ディレクトリ構成
```
.
├── Makefile
├── create-migration.sh
├── migrations/
│   ├── 001_xxx.up.sql
│   └── 001_xxx.down.sql
└── bin/
    └── migrate
```

## 使い方
### マイグレーションファイルの作成

```bash
make create <名前>
```

例:

```bash
make create add_email_column
```

```
migrations/002_add_email_column.up.sql
migrations/002_add_email_column.down.sql
```

### dryrun で適用予定ファイルの一括表示
```bash
make dryrun
```

出力例:
```
Current version: 2
Up files to apply: 003_add_profile.up.sql 004_add_index.up.sql
Down files to revert: 002_add_email.down.sql
```

### マイグレーションの適用
```bash
make up <適用する件数>
```

```bash
make up 1
```

バージョンを 1 つだけ進めます

### マイグレーションのロールバック
```bash
make down <戻す件数>
```
```bash
make down 1
```

直前のマイグレーションを 1 つ戻します

### 現在のバージョン確認
```bash
make version
```

## 注意
* `make up` や `make down` は、必ず数値定義あり (1 以上) で実行するようにしています
* `make up 2` なら、現在のバージョンから2件分だけ up されます
* `goto` や `reset` などの強制操作はこのプロジェクトでは使用しません

## 権限について
初期構築や DDL 適用には Snowflake の `SYSADMINのみで行います`。ACCOUNTADMINは使用しません。
.env 内の `SNOWFLAKE_ROLE` を適切に設定してください
