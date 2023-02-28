# Acunetix Scan Automation

Acunetix-Scan-Automation is a bash script for automating vulnerability scanning with the Acunetix API. The script can be used to automate various aspects of vulnerability scanning, including starting a new scan, monitoring the scan progress, and generating a report.

## Installation

To use the script, you'll need to have bash and the following dependencies installed:

-   curl
-   jq

## Usage

The script can be used to run different types of scans with the Acunetix API, and includes options for configuring the scan parameters, scheduling the scan, and generating the report.

Here's an example of how to run the script:

`./acunetix_scan_automation.sh -k <api_key> -u <api_url> -t <target_id> -p <profile_id> -r <report_type> -o <output_dir>` 

For more details on the available options, run the script with the `-h` or `--help` option:

`./acunetix_scan_automation.sh -h` 

## Contributing

If you'd like to contribute to the project, feel free to submit a pull request or open an issue. You can also fork the project and modify it to suit your needs.
