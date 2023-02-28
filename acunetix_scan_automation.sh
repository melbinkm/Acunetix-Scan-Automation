#!/bin/bash

# Default values for configuration variables
api_url="https://localhost:3443/api"
report_type="PDF"

# Usage message for command line arguments
usage_message="Usage: $0 [options] -t <target_id> -p <profile_id>
Options:
    -k, --api-key        Acunetix API key (default: read from environment variable ACUNETIX_API_KEY)
    -u, --api-url        Acunetix API URL (default: $api_url)
    -r, --report-type    Report type (PDF, HTML, or CSV) (default: $report_type)
    -t, --target-id      Target ID (required)
    -p, --profile-id     Scan profile ID (required)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -k|--api-key)
            api_key="$2"
            shift 2
            ;;
        -u|--api-url)
            api_url="$2"
            shift 2
            ;;
        -r|--report-type)
            report_type="$2"
            shift 2
            ;;
        -t|--target-id)
            target_id="$2"
            shift 2
            ;;
        -p|--profile-id)
            profile_id="$2"
            shift 2
            ;;
        *)
            echo "Error: Invalid argument: $1" >&2
            echo "$usage_message" >&2
            exit 1
            ;;
    esac
done

# Check if required arguments are present
if [[ -z "$target_id" || -z "$profile_id" ]]; then
    echo "Error: Missing required arguments." >&2
    echo "$usage_message" >&2
    exit 1
fi

# Check if the API key is set in the environment variable
if [[ -z "$api_key" ]]; then
    if [[ -z "$ACUNETIX_API_KEY" ]]; then
        echo "Error: Acunetix API key is not set." >&2
        exit 1
    else
        api_key="$ACUNETIX_API_KEY"
    fi
fi

# Start a new scan
echo "Starting scan..."
scan_id=$(curl --silent --insecure --request POST \
    --header "X-Auth: $api_key" \
    --header "Content-Type: application/json" \
    --data "{\"target_id\":\"$target_id\",\"profile_id\":\"$profile_id\",\"schedule\":{\"disable\":\"false\",\"start_date\":null,\"time_sensitive\":\"false\"},\"report_template_id\":\"11111111-1111-1111-1111-111111111111\",\"incremental\":\"false\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36\",\"login_sequence_id\":\"00000000-0000-0000-0000-000000000000\",\"scan_speed\":\"moderate\",\"excluded_paths\":[],\"user_id\":\"00000000-0000-0000-0000-000000000000\"}" \
    "$api_url/v1/scans" | jq -r '.target.id')

# Check if the scan was started successfully
if [[ "$scan_id" = null ]]; then
    echo "Error: Failed to start scan." >&2
    exit 1
fi

echo "Scan started. Scan ID: $scan_id"

# Wait for the scan to complete
echo "Waiting for scan to complete..."
while true; do
    scan_status=$(curl --silent --insecure --request GET \
        --header "X-Auth: $api_key" \
        "$api_url/v1/scans/$scan_id" | jq -r '.current_session.status')

    if [[ "$scan_status" = "completed" ]]; then
        break
    fi

    sleep 30
done

echo "Scan completed. Retrieving scan report."

# Get the scan report
report_id=$(curl --silent --insecure --request POST \
    --header "X-Auth: $api_key" \
    --header "Content-Type: application/json" \
    --data "{\"source\":\"scan\",\"report_template_id\":\"11111111-1111-1111-1111-111111111111\",\"report_type\":\"$report_type\",\"source_id\":\"$scan_id\",\"create_time\":\"$(date -u +%FT%TZ)\"}" \
    "$api_url/v1/reports" | jq -r '.report_id')

# Check if the report was generated successfully
if [[ "$report_id" = null ]]; then
    echo "Error: Failed to generate report." >&2
    exit 1
fi

echo "Report generated. Report ID: $report_id"
