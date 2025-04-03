#!/usr/bin/bash
###################################################################

echo "please enter destination project ID "
read -r dst_project_id
secGProjectID=$dst_project_id

echo ###
for j in *; do
	sed -i 's/$/ --project $secGProjectID/' ./$j
	sed -i 's/$/ $id/' ./$j
	id_line=$(openstack security group create --project "$secGProjectID" -f shell "$j" | awk '/^id/ {print}')
	{
		echo "$id_line"
		cat "$j"
	} >tmp && mv tmp "$j"
done

for file in ./*; do
	if [ -f "$file" ]; then
		sed -i '1i OP_CLI="openstack security group rule create"\n##$-------$##' "$file"
	fi
done

sed -i "1i $(echo "secGProjectID=$secGProjectID" | sed 's/[\/&]/\\&/g')" ./*

echo ###

cat ./* | bash
