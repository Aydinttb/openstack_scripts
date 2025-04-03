# Openstack security group migration

this script help you to export all security groups of a project and import them to other project in same DC or another DC

### notices

this scrip don't work for default security group

The security group names in the source project should not contain spaces, and their names should follow formats like these:
example_sec
example_team
example.srvs
Not example sec

## how to use
1. clone scripts
`git clone https://github.com/Aydinttb/openstack_scripts.git`
2. change dir
`cd security_group_migration`
3. exute export script
`bash export-secG.sh`
4. enter workinkg directory make directory for this project security groups 
5. enter source project for export security groups
## 6. cd working directory 
7. exute import script after change dir
`bash ../import-secG.sh` 
---

### done
