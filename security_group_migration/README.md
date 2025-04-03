# OpenStack Security Group Migration

This script helps you export all security groups from a project and import them into another project in the same or a different data center (DC).

## Notices
- This script does not work for the default security group.
- Security group names in the source project must follow these rules:
  - Must not contain spaces
  - Valid formats:
    - `example_sec`
    - `example_team`
    - `example.srvs`
  - Invalid format: `example sec`
## How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/Aydinttb/openstack_scripts.git

2. Change to the script directory
  ```bash
  cd security_group_migration
  ```

3. Run the export script:
  ```bash
  bash export-secG.sh 
  ```
4. Prepare working directory
Create a directory for the exported security groups.
5. Enter source project
Provide the source project name when prompted.
6. ⚠️ Change to working directory
Important: You must execute the import script from this working directory where your exported security groups are stored.
7. exute import script 
```bash 
bash ../import-secG.sh` 
```
---
Completion

✅ Security groups will be successfully migrated after these steps.
