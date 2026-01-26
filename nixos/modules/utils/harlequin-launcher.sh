#!/bin/bash

# Harlequin Database Launcher
# Launches Harlequin SQL IDE with selected database type and connection

echo "Select database type:"
echo "1) SQLite"
echo "2) Postgres"
echo "3) DuckDB"
read -p "Enter choice (1-3): " db_choice

case $db_choice in
  1)
    read -p "Enter SQLite database path (or press Enter for in-memory): " db_path
    if [[ -z "$db_path" ]]; then
      harlequin -a sqlite
    else
      harlequin -a sqlite "$db_path"
    fi
    ;;
  2)
    read -p "Enter Postgres connection string: " conn_string
    if [[ -z "$conn_string" ]]; then
      echo "Error: Postgres connection string is required"
      exit 1
    fi
    harlequin -a postgres "$conn_string"
    ;;
  3)
    echo "Select DuckDB connection type:"
    echo "1) Local file"
    echo "2) S3 path"
    echo "3) In-memory"
    read -p "Enter choice (1-3): " duckdb_choice
    
    case $duckdb_choice in
      1)
        read -p "Enter local DuckDB database path: " db_path
        if [[ -z "$db_path" ]]; then
          echo "Error: Local path is required"
          exit 1
        fi
        harlequin "$db_path"
        ;;
      2)
        read -p "Enter AWS profile (or press Enter for default): " aws_profile
        
        if [[ -n "$aws_profile" ]]; then
          echo "Using AWS profile: $aws_profile"
          export AWS_PROFILE="$aws_profile"
        else
          echo "Using default AWS credentials"
        fi
        
        read -p "Enter AWS region (or press Enter for default): " aws_region
        
        if [[ -n "$aws_region" ]]; then
          echo "Using AWS region: $aws_region"
          export AWS_DEFAULT_REGION="$aws_region"
        else
          echo "Using default AWS region"
        fi
        
        read -p "Enter S3 path (s3://bucket/path/to/db.duckdb): " s3_path
        if [[ -z "$s3_path" ]]; then
          echo "Error: S3 path is required"
          exit 1
        fi
        
        # Extract bucket name from S3 path for health check
        bucket_name=$(echo "$s3_path" | sed 's|^s3://||' | cut -d'/' -f1)
        
        echo "Testing S3 permissions for bucket: $bucket_name"
        
        # Test S3 access with health check
        if [[ -n "$aws_profile" ]]; then
          if aws s3 ls "s3://$bucket_name" --profile "$aws_profile" >/dev/null 2>&1; then
            echo "✓ S3 access verified"
          else
            echo "✗ S3 access failed. Check credentials and bucket permissions."
            exit 1
          fi
        else
          if aws s3 ls "s3://$bucket_name" >/dev/null 2>&1; then
            echo "✓ S3 access verified"
          else
            echo "✗ S3 access failed. Check credentials and bucket permissions."
            exit 1
          fi
        fi
        
        # Launch Harlequin with proper credentials
        if [[ -n "$aws_profile" ]]; then
          eval "$(aws configure export-credentials --format env)" && harlequin "$s3_path"
        else
          harlequin "$s3_path"
        fi
        ;;
      3)
        harlequin
        ;;
      *)
        echo "Invalid choice. Please select 1, 2, or 3."
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Invalid choice. Please select 1, 2, or 3."
    exit 1
    ;;
esac