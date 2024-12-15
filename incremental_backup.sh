#!/bin/bash
export ORACLE_SID=LegendOfZelda
export ORACLE_HOME=/Home/Oracle

rman target / <<EOF
RUN {
  BACKUP INCREMENTAL LEVEL 1 DATABASE FORMAT '/Home/Oracle/incremental_backup_%d_%T';
  BACKUP PLUGGABLE DATABASE ALL FORMAT '/Home/Oracle/pluggable_incremental_backup_%d_%T'
    FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE', '/Home/Oracle/Pluggable/FREE');
  DELETE OBSOLETE;
}
EOF

# Remove backups older than 7 days
find "/Home/Oracle" -name "pluggable_incremental_backup_*" -type f -mtime +7 -exec rm {} \;
# backup shell file located in /Home/Oracle/Script/
