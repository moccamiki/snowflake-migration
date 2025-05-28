package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/snowflakedb/gosnowflake"
	"github.com/joho/godotenv"
)

func main() {
	envName := "poc"
	if len(os.Args) > 1 {
		envName = os.Args[1]
	}

	envPath := fmt.Sprintf("env/%s.env", envName)
	err := godotenv.Load(envPath)
	if err != nil {
		log.Fatalf("ERROR: loading %s: %v", envPath, err)
	}

	dsn := fmt.Sprintf("%s:%s@%s/%s/%s?warehouse=%s&role=%s",
		os.Getenv("SNOWFLAKE_USER"),
		os.Getenv("SNOWFLAKE_PASSWORD"),
		os.Getenv("SNOWFLAKE_ACCOUNT"),
		os.Getenv("SNOWFLAKE_DATABASE"),
		os.Getenv("SNOWFLAKE_SCHEMA"),
		os.Getenv("SNOWFLAKE_WAREHOUSE"),
		os.Getenv("SNOWFLAKE_ROLE"),
	)

	db, err := sql.Open("snowflake", dsn)
	if err != nil {
		log.Fatalf("ERROR: failed to create db handle: %v", err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatalf("ERROR: unable to connect: %v", err)
	}

	fmt.Printf("INFO: Snowflake connection succeeded [%s]\n", envName)
}
