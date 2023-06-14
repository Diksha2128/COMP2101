#!/bin/bash

# Function to display error message
function errormessage() {
  local error_message="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  echo "Error: $error_message" >&2
  echo "[$timestamp] $error_message" >> /var/log/systeminfo.log
}

# Check if the script is running with root permission
if [[ $EUID -ne 0 ]]; then
  errormessage "This script requires root permission."
  exit 1
fi

# Source the function library file
source bash/reportfunctions.sh

# Function to display script help
function display_help() {
  echo "Usage: ./systeminfo.sh [OPTIONS]"
  echo "Options:"
  echo "-h        Display help and exit"
  echo "-v        Run verbosely, showing errors to the user"
  echo "-system   Run computerreport, osreport, cpureport, ramreport, and videoreport"
  echo "-disk     Run diskreport"
  echo "-network  Run networkreport"
}

# Function to run the full system report
function full_system_report() {
  computerreport
  osreport
  cpureport
  ramreport
  videoreport
  diskreport
  networkreport
}

# Parse command line options
while getopts "hvsdn" opt; do
  case $opt in
    h)
      display_help
      exit 0
      ;;
    v)
      VERBOSE=true
      ;;
    s)
      SYSTEM_REPORT=true
      ;;
    d)
      DISK_REPORT=true
      ;;
    n)
      NETWORK_REPORT=true
      ;;
    *)
      display_help
      exit 1
      ;;
  esac
done

# Run system report based on options
if [[ -n $DISK_REPORT ]]; then
  diskreport
elif [[ -n $NETWORK_REPORT ]]; then
  networkreport
elif [[ -n $SYSTEM_REPORT ]]; then
  computerreport
  osreport
  cpureport
  ramreport
  videoreport
else
  full_system_report
fi

# Handle errors
if [[ -n $VERBOSE ]]; then
  # Display errors to the user
  cat /var/log/systeminfo.log >&2
else
  # Display a summary message to the user
  echo "System report generated. Please check /var/log/systeminfo.log for more details."
fi
