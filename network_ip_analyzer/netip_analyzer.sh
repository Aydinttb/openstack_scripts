#!/usr/bin/env bash
# OpenStack Network IP Analyzer
# Description: Finds available IP addresses in an OpenStack network by comparing allocation pools with used IPs
# Usage: . netip_analyzer.sh

set -euo pipefail # Strict error handling

read -p "Please enter the OpenStack Network ID: " network_id

# Initialize files
echo -n "" >all-ips.txt
echo -n "" >used-ips.txt
echo -n "" >free-ips.txt

# Function to validate IP format
validate_ip() {
	[[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Generate ALL possible IPs in allocation pools
echo "Generating all possible IPs..."
subnet_ids=$(openstack network show "$network_id" -c subnets -f json | jq -r '.subnets[]')

for subnet_id in $subnet_ids; do
	pool_data=$(openstack subnet show "$subnet_id" -c allocation_pools -f json)
	start_ip=$(echo "$pool_data" | jq -r '.allocation_pools[0].start')
	end_ip=$(echo "$pool_data" | jq -r '.allocation_pools[0].end')

	if ! validate_ip "$start_ip" || ! validate_ip "$end_ip"; then
		echo "Skipping invalid IP range in subnet $subnet_id: $start_ip-$end_ip" >&2
		continue
	fi

	start_octet=$(cut -d'.' -f4 <<<"$start_ip")
	end_octet=$(cut -d'.' -f4 <<<"$end_ip")
	base_ip=$(cut -d'.' -f1-3 <<<"$start_ip")

	if [ "$start_octet" -gt "$end_octet" ]; then
		echo "Invalid range in subnet $subnet_id: $start_ip > $end_ip" >&2
		continue
	fi

	seq "$start_octet" "$end_octet" | while read -r octet; do
		echo "$base_ip.$octet" >>all-ips.txt
	done
done

# Get USED IPs from ports
echo "Collecting used IPs..."
openstack port list --network "$network_id" -c "Fixed IP Addresses" -f json |
	jq -r '.[]."Fixed IP Addresses"[]?.ip_address' |
	grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' >>used-ips.txt

# Find FREE IPs (in all-ips.txt but not in used-ips.txt)
echo "Calculating free IPs..."
# Using grep to find lines in all-ips.txt that aren't in used-ips.txt
grep -Fxv -f used-ips.txt all-ips.txt >free-ips.txt

# Generate report
total_ips=$(wc -l <all-ips.txt)
used_ips=$(wc -l <used-ips.txt)
free_ips=$(wc -l <free-ips.txt)

echo "================================="
echo "IP Address Report:"
echo "Total IPs:    $total_ips"
echo "Used IPs:     $used_ips"
echo "Free IPs:     $free_ips"
echo "================================="
echo "Free IPs saved to free-ips.txt"
