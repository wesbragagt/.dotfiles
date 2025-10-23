#!/bin/bash

# Simple Harlequin Database Launcher
# Prompts for database type and connection details

echo "Select database type:"
echo "1) DuckDB"
echo "2) Postgres"
echo "3) SQLite"
read -p "Enter choice (1-3): " db_choice

case $db_choice in
  1)
    read -p "Enter DuckDB file path or S3 URL (or press Enter for in-memory): " db_path
    if [[ -z "$db_path" ]]; then
      echo "Launching Harlequin with in-memory DuckDB..."
      harlequin
    elif [[ "$db_path" == s3://* ]]; then
      # S3 path detected, prompt for AWS credentials
      read -p "Enter AWS profile (or press Enter for default): " aws_profile
      if [[ -n "$aws_profile" ]]; then
        echo "Using AWS profile: $aws_profile"
        export AWS_PROFILE="$aws_profile"
      fi

      read -p "Enter AWS region (or press Enter for default): " aws_region
      if [[ -n "$aws_region" ]]; then
        echo "Using AWS region: $aws_region"
        export AWS_DEFAULT_REGION="$aws_region"
      fi

      echo "Launching Harlequin with DuckDB S3 path: $db_path"
      harlequin "$db_path"
    else
      echo "Launching Harlequin with DuckDB: $db_path"
      harlequin "$db_path"
    fi
    ;;
  2)
    read -p "Enter Postgres connection URL: " postgres_url
    if [[ -z "$postgres_url" ]]; then
      echo "Error: Postgres connection URL is required"
      exit 1
    fi
    echo "Launching Harlequin with Postgres..."
    harlequin -a postgres "$postgres_url"
    ;;
  3)
    read -p "Enter SQLite database file path (or press Enter for in-memory): " db_path
    if [[ -z "$db_path" ]]; then
      echo "Launching Harlequin with in-memory SQLite..."
      harlequin -a sqlite
    else
      echo "Launching Harlequin with SQLite: $db_path"
      harlequin -a sqlite "$db_path"
    fi
    ;;
  *)
    echo "Invalid choice. Please select 1, 2, or 3."
    exit 1
    ;;
esac
