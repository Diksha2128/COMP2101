#!/bin/bash

# Check if the user has root privilege
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Function to check command success and print error message if failed
check_command() {
  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve $1."
  fi
}

# Section: System Description
echo "=== System Description ==="
manufacturer=$(dmidecode -s system-manufacturer)
check_command "system manufacturer"
echo "Computer manufacturer: $manufacturer"

model=$(dmidecode -s system-product-name)
check_command "system model"
echo "Computer description or model: $model"

serial=$(dmidecode -s system-serial-number)
check_command "system serial number"
echo "Computer serial number: $serial"

# Section: CPU Information
echo -e "\n=== CPU Information ==="
cpu_count=$(lshw -class processor | awk '/product/ {print $2}' | wc -l)
check_command "CPU count"

for ((i=1; i<=$cpu_count; i++)); do
  echo "CPU $i:"
  cpu_manufacturer=$(lshw -class processor | awk "/product:.*$i/ {getline; print}" | awk '{print $2}')
  check_command "CPU manufacturer"
  echo "CPU manufacturer and model: $cpu_manufacturer"

  cpu_arch=$(lshw -class processor | awk "/capabilities.*$i/ {getline; print}" | awk '{print $3}')
  check_command "CPU architecture"
  echo "CPU architecture: $cpu_arch"

  cpu_cores=$(lshw -class processor | awk "/core.*$i/ {print}" | awk '{print $2}')
  check_command "CPU core count"
  echo "CPU core count: $cpu_cores"

  cpu_max_speed=$(lshw -class processor | awk "/capacity.*$i/ {getline; print}" | awk '{print $2}')
  check_command "CPU maximum speed"
  echo "CPU maximum speed: $cpu_max_speed Hz"

  cache_sizes=$(lshw -class cache | awk "/processor:.*$i/ {getline; print}" | awk '{print $2}')
  check_command "cache sizes"

  cache_sizes_arr=($cache_sizes)
  l1_cache=${cache_sizes_arr[0]}
  l2_cache=${cache_sizes_arr[1]}
  l3_cache=${cache_sizes_arr[2]}

  echo "Sizes of caches (L1, L2, L3):"
  echo "L1 cache size: $l1_cache"
  echo "L2 cache size: $l2_cache"
  echo "L3 cache size: $l3_cache"

  echo ""
done

# Section: Operating System Information
echo -e "\n=== Operating System Information ==="
distro=$(lsb_release -ds)
check_command "Linux distro"
echo "Linux distro: $distro"

distro_version=$(lsb_release -rs)
check_command "distro version"
echo "Distro version: $distro_version"

# Section: RAM Information
echo -e "\n=== RAM Information ==="
ram_info=$(lshw -class memory | awk '/description/ {getline; print}')
check_command "RAM information"

echo "Installed Memory Components:"
echo "---------------------------------------"
echo -e "Manufacturer\tModel\t\tSize\tSpeed\tLocation"
echo "---------------------------------------"
echo -e "$ram_info"
