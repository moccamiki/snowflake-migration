# Snowflake マイグレーション管理
このリポジトリは [golang-migrate](https://github.com/golang-migrate/migrate) を使用して
Snowflake のスキーママイグレーションを管理するためのプロジェクトです。

Makefile のコマンドを使って、マイグレーションの作成・適用・ダウンロール・プレビューが簡単に行えます。

## Local環境構築
### 1. go　のインストール
このプロジェクトでは Go が必要です（バージョン 1.21 以上推奨）。
Go をインストールしていない場合は、以下からインストールしてください：
- [Go公式サイト](https://go.dev/dl/)

### 2. golang-migrate CLI のインストール
```bash
make install
```
「./bin/migrate」 に CLI がインストールされます。

### 3. 環境変数の設定
まず、テンプレートとして提供されている `env_sample/` 配下のファイルを `env/` ディレクトリへコピーしてください。
```bash
cp -r env_sample env
```

コピー後、`env/` ディレクトリに以下のような環境ごとの設定ファイルが作成されます。
```
env/
├── dev.env
├── stg.env
├── prd.env
└── poc.env
```
各 `.env` ファイルの中身を自分の接続情報に応じて編集してください。
（例：Snowflakeのユーザー名・パスワード・アカウント・ロールなど）

## ディレクトリ構成
```
.
├── .github/
│   └── workflows/
│       ├── migrate-dev.yml
│       ├── migrate-poc.yml
│       ├── migrate-prd.yml
│       └── migrate-stg.yml
├── bin/
│   └── migrate
├── env/
│   ├── dev.env
│   ├── poc.env
│   ├── prd.env
│   └── stg.env
├── env_sample/
│   ├── dev.env
│   ├── poc.env
│   ├── prd.env
│   └── stg.env
├── migrations/
│   ├── 001_xxx.up.sql
│   └── 001_xxx.down.sql
├── .env                # ローカル実行用に env からコピーされる
├── .gitignore
├── Makefile
├── create-migration.sh
└── README.md
```

## マイグレーションの使い方
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
make dryrun env=dev
```
出力例:
```
current version: 0
up files  :   001_first_pipeline.up.sql
down files:
```

### マイグレーションの適用
```bash
make up env=dev count=1
```
バージョンを 1 つだけ進めます

### マイグレーションのロールバック
```bash
make down env=dev count=1
```
直前のマイグレーションを 1 つ戻します

### 現在のマイグレーションバージョン確認
```bash
make version
```

## 注意
* `make up` や `make down` は、必ず数値定義あり (1 以上) で実行するようにしています
* `make up 2` なら、現在のバージョンから2件分だけ up されます
* `goto` や `reset` などの強制操作はこのプロジェクトでは使用しません
* マイグレーション中にエラーが発生した場合、それ以降の処理は実行されませんが、**エラー発生前に実行されたクエリは Snowflake 上で既に反映済みとなります**。再実行時はバージョン管理とマイグレーション状態の整合性に十分注意してください

## 権限について
初期構築や DDL 適用には Snowflake の `SYSADMIN` のみで行います。`ACCOUNTADMIN` は使用しません。
`.env` 内の `SNOWFLAKE_ROLE` を適切に設定してください。

## GitHub Actions による実行
このリポジトリでは、GitHub Actions を利用して POC 環境などへのマイグレーションを実行できます。

- 対象ファイル: `.github/workflows/migrate-poc.yml`
- 実行方法: GitHub UI 上から「Run workflow」を選択し、以下を指定して実行
  - `operation`: `up`, `down`, `dryrun` のいずれか
  - `count`: `1` 以上の整数（`up` や `down` 時のみ）
- 認証情報（ユーザー名やパスワードなど）は GitHub Secrets に登録し、`.env` は使用しません。

Secrets 名（例: `SNOWFLAKE_USER_POC`, `SNOWFLAKE_PASSWORD_POC` など）に対応して `env:` に渡されています。

これにより、`.env` ファイルをGitHubに置かず、安全にCI/CDマイグレーションを行う構成としています。

# Snowflake接続確認
# セットアップ
```bash
go mod tidy
```

## env修正
env/*.env を修正してください

## 接続確認
go run test_connection.go poc

## トラブルシューティング
このリポジトリには `go.mod` / `go.sum` が含まれているため、以下で依存が自動取得されます
もし接続コマンドを打ってもうまく行かない場合は以下のコマンドを実行してください
```bash
# 1. Goプロジェクト初期化
go mod init snowflake-migration

# 2. ライブラリのインストール
go get github.com/joho/godotenv
go get github.com/snowflakedb/gosnowflake
```