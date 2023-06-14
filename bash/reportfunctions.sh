#!/bin/bash

# Function to display a title
function title() {
  echo "==== $1 ===="
  echo
}

# Function to display labeled data
function labeled_data() {
  echo "$1: $2"
}

# Function to format size in human-friendly format
function human_readable_size() {
  local size=$1
  local unit="B"

  if ((size >= 1024)); then
    ((size /= 1024))
    unit="KB"
  fi

  if ((size >= 1024)); then
    ((size /= 1024))
    unit="MB"
  fi

  if ((size >= 1024)); then
    ((size /= 1024))
    unit="GB"
  fi

  echo "$size $unit"
}

# Function to format CPU speed in human-friendly format
function human_readable_speed() {
  local speed=$1
  local unit="MHz"

  if ((speed >= 1000)); then
    ((speed /= 1000))
    unit="GHz"
  fi

  echo "$speed $unit"
}

# Function to generate CPU report
function cpureport() {
  title "CPU Report"
  labeled_data "CPU manufacturer and model" "$(cat /proc/cpuinfo | grep 'model name' | uniq | cut -d':' -f2 | xargs)"
  labeled_data "CPU architecture" "$(uname -m)"
  labeled_data "CPU core count" "$(nproc)"
  labeled_data "CPU maximum speed" "$(lscpu | grep 'CPU MHz' | cut -d':' -f2 | xargs) MHz"
  labeled_data "Sizes of caches (L1, L2, L3)" "L1: $(lscpu | grep 'L1d cache' | cut -d':' -f2 | xargs), L2: $(lscpu | grep 'L2 cache' | cut -d':' -f2 | xargs), L3: $(lscpu | grep 'L3 cache' | cut -d':' -f2 | xargs)"
}

# Function to generate computer report
function computerreport() {
  title "Computer Report"
  labeled_data "Computer manufacturer" "$(dmidecode -s system-manufacturer)"
  labeled_data "Computer description or model" "$(dmidecode -s system-product-name)"
  labeled_data "Computer serial number" "$(dmidecode -s system-serial-number)"
}

# Function to generate OS report
function osreport() {
  title "OS Report"
  labeled_data "Linux distro" "$(lsb_release -d | cut -f2-)"
  labeled_data "Distro version" "$(lsb_release -r | cut -f2-)"
}

# Function to generate RAM report
function ramreport() {
  title "RAM Report"
  echo "Manufacturer | Model | Size | Speed | Location"
  echo "-----------------------------------------------"
  dmidecode -t memory | awk '/^[[:space:]]+Size: [0-9]+/{size=$2; units=$3} /^[[:space:]]+Speed: [0-9]+/{speed=$2; units=$3} /^[[:space:]]+Locator: /{print $0, size" "units, speed" "units}' | column -t
  echo
  labeled_data "Total size of installed RAM" "$(free -h | awk '/^Mem:/{print $2}')"
}

# Function to generate video report
function videoreport()
