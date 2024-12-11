#!/bin/bash
export ORACLE_SID=LegendOfZelda
export ORACLE_HOME=/Home/Oracle

rman target / <<EOF
RUN {
  BACKUP INCREMENTAL LEVEL 1 DATABASE FORMAT '/Home/Oracle/incremental_backup_%d_%T';
  DELETE OBSOLETE;
}
EOF

# Remove backups older than 7 days
find "/Home/Oracle" -name "incremental_backup_*" -type f -mtime +7 -exec rm {} \;
# backup shell file located in /Home/Oracle/Script/
