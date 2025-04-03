#!/bin/bash
###################################################################

echo "please enter working directory"
read -r working_directory
working_directory=$working_directory
mkdir -p ./$working_directory/


echo "please enter source project ID "
read -r src_project_id
export secGProjectID=$src_project_id

for i in $(openstack security group list --project $secGProjectID -c Name -f value); do
	openstack security group rule list --quote minimal -f csv -c \
		"Direction" -c "Port Range" -c \
		"IP Protocol" -c "IP Range" \
		"$i" >./$working_directory/"$i"
done

sed -i '/^IP Protocol/d' ./$working_directory/*

sed -i 's/,/    /' ./$working_directory/*
sed -i 's/,/    /' ./$working_directory/*
sed -i 's/,/    /' ./$working_directory/*
sed -i 's/,/    /' ./$working_directory/*

sed -i '/egress/d' ./$working_directory/*

sed -i 's/tcp/--protocol tcp/' ./$working_directory/*
sed -i 's/udp/--protocol udp/' ./$working_directory/*
sed -i 's/icmp/--protocol icmp/' ./$working_directory/*

sed -i 's/ingress/--ingress/' ./$working_directory/*
sed -i 's/^\([^ ]* [^ ]*\) /\1 --remote-ip /' ./$working_directory/*
sed -i 's/\([0-9]\+:[0-9]\+\)/ --dst-port \1/g' ./$working_directory/*
sed -i 's/^/$OP_CLI /' ./$working_directory/*
