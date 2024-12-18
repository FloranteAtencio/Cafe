#!/bin/bash
export ORACLE_SID=FREE
export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree

rman target / <<EOF
RUN {
  BACKUP DATABASE PLUS ARCHIVELOG FORMAT '/home/oracle/backup/full_backup_%d_%T';
  BACKUP PLUGGABLE DATABASE ALL FORMAT '/home/oracle/backup/pluggable_full_backup_%d_%T'
    FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE', '/Home/Oracle/Pluggable/FREE');
  DELETE OBSOLETE;
}
EOF

# Remove backups older than 30 days
find "/home/oracle/backup" -name "full_backup_*" -type f -mtime +30 -exec rm {} \;
find "/home/oracle/backup" -name "pluggable_full_backup_*" -type f -mtime +30 -exec rm {} \;
# backup shell file located in /Home/Oracle/Script/
