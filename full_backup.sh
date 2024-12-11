#!/bin/bash
export ORACLE_SID=LegendOfZelda
export ORACLE_HOME=/Home/Oracle

rman target / <<EOF
RUN {
  BACKUP DATABASE PLUS ARCHIVELOG FORMAT '/Home/Oracle/full_backup_%d_%T';
  DELETE OBSOLETE;
}
EOF

# Remove backups older than 30 days
find "/Home/Oracle" -name "full_backup_*" -type f -mtime +30 -exec rm {} \;
# backup shell file located in /Home/Oracle/Script/