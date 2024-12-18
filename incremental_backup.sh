#!/bin/bash
export ORACLE_SID=FREE
export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree

rman target / <<EOF
RUN {
  BACKUP INCREMENTAL LEVEL 1 DATABASE FORMAT '/home/oracle/backup/incremental_backup_%d_%T';
  BACKUP PLUGGABLE DATABASE ALL FORMAT '/home/oracle/backup/pluggable_incremental_backup_%d_%T'
    FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE', '/Home/Oracle/Pluggable/FREE');
  DELETE OBSOLETE;
}
EOF

# Remove backups older than 7 days
find "/home/oracle/backup" -name "pluggable_incremental_backup_*" -type f -mtime +7 -exec rm {} \;
find "//home/oracle/backup" -name "incremental_backup_*" -type f -mtime +7 -exec rm {} \;
# backup shell file located in /Home/Oracle/Script/
