#!/usr/bin/env bash

# OpenStack IP Search Tool
# Description: This script helps search for IP addresses (both server and floating IPs) across different OpenStack deployments
# Author: Aydin Tabatabaei
# Features:
#   - Requires user to source their openrc file first
#   - Supports multiple OpenStack deployments
#   - Searches both server instances and floating IPs
#   - Provides detailed project information for found IPs
# Dependencies: openstack-client, jq (optional), grep, awk
# Usage Examples:
#   source ~/path/to/your-openrc.sh
#   . openstack_ip_search.sh 182.82.21.2

IP=$1

function exact_server_ip_search {
	local pattern="(^|[^0-9.])${IP}($|[^0-9.])"
	grep -E -B 7 -A 3 --color "$pattern"
}

function exact_float_ip_search {
	openstack floating ip list -c "Floating IP Address" -c "ID" -c "Project" -c "Status" -f json |
		jq --arg ip "$IP" '.[] | select(.["Floating IP Address"] == $ip)'
}

function SERVE_LIST {
	echo "Searching for servers with IP: $IP"
	openstack server list -c ID -c Name -c Status -c "Task State" \
		-c "Power State" -c "Networks" -c "Host" -f yaml --all-projects | exact_server_ip_search
}

function FLOAT_IP_LIST {
	echo "Searching for floating IP: $IP"
	float_result=$(exact_float_ip_search)

	if [ -z "$float_result" ]; then
		echo "No floating IP found matching $IP"
	else
		echo "$float_result" | python -c 'import sys, yaml, json; print(yaml.dump(json.load(sys.stdin)))'
	fi
}

SERVE_LIST
echo "############################################"

FLOAT_IP_RESULTS=$(FLOAT_IP_LIST)
echo "$FLOAT_IP_RESULTS"
echo "############################################"

PROJECT_ID=$(echo "$FLOAT_IP_RESULTS" | awk '/Project:/ {print $2}')
if [ -z "$PROJECT_ID" ]; then
	echo "Floating IP $IP is RELEASED or NOT FOUND!"
else
	echo "Project details for $IP:"
	openstack project show $PROJECT_ID -f yaml \
		-c description -c enabled -c name
fi
