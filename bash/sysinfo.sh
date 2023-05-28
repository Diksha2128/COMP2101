#!/bin/bash
#Main Script




echo "FQDN: $(hostname -I)"
echo "Host Information"
hostnamectl
echo "IP adresses:"
hostname -I
echo "Root Filesystem Status:"
df -h /
