# Cafe
Cafe Database
Initial set up for docker and oracle 23c free database version of oracle

--- Introduction ----------

Oracle 23c Structure

Oracle Database 23c:

Instance: The instance is the set of memory structures and background processes that manage the database files.

Container Database (CDB):

CDB: The CDB includes the root container (CDB$ROOT) and one or more Pluggable Databases (PDBs).

Pluggable Database (PDB):

PDB: Acts as an independent database within the CDB. Each PDB has its own users, schemas, and objects. PDBs share the instance’s memory and processes but are otherwise isolated from one another.

Schema:

Schema: A logical grouping of database objects (tables, views, indexes, etc.) under a single user within a PDB. Each user owns their own schema and objects.
So, within your Oracle 23c setup:

One instance manages one CDB.

The CDB contains multiple PDBs.

Each PDB is a self-contained database with its own schemas and objects.

Ubuntu Server 24.04.1 LTS for Database and docker for container.

==== Coder start here in Linux ========

-- Update server

sudo apt update

-- Install docker

sudo apt install docker.io

-- Create Volume for progress
sudo docker volume create oracle_volume

-- Download oracle inside docker this about worth 10 Gb of

sudo docker run -itd --name LegendOfZelda -p 1521:1521 -e ORACLE_PWD='1234' -v oracle_volume:/opt/oracle/oradata container-registry.oracle.com/database/free:latest

-- Execute sql

sudo docker exec -it LegendOfZelda bash

-- make Directory for  Pluggable and Script
mkdir pluggable
mkdir script
mkdir backup

-- Login as admin 
-- For safer way sqlplus sys@locahost:1521 as sysdba
sqlplus sys/1234@localhost:1521 as sysdba

-- PLUGGABLE DATABASE
CREATE PLUGGABLE DATABASE Dev_Cafe admin user Links IDENTIFIED BY zelda
create_file_dest='/home/oracle/pluggable';

-- Set permision
ALTER PLUGGABLE DATABASE Dev_Cafe OPEN;
EXIT

-- Log in to the database
-- For safer way sqlplus sys@localhost:1521/Dev_Cafe as sysdba
sqlplus sys@localhost:1521/Dev_Cafe as sysdba

-- Grant access to Link
GRANT DBA to Links
GRANT SYSDBA to Links

-- Developer Acess

CREATE ROLE dev_ROLE;

GRANT CONNECT, CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER, CREATE SYNONYM TO dev_ROLE;

CREATE USER Dev_Hyrule IDENTIFIED BY dev_Password;

GRANT dev_ROLE TO Dev_Hyrule;

GRANT UNLIMITED TABLESPACE TO Dev_Hyrule;

-- Production Access after the schema is created

CREATE ROLE prod_ROLE;

BEGIN
  FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'Dev_cafe') LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON ' || 'Dev_cafe' || t.table_name || ' TO prod_ROLE';
  END LOOP;
END;
/

CREATE USER Prod IDENTIFIED BY ProdPassword

GRANT prod_ROLE TO Prod

EXIT

--  DBA As link
-- safe way sqlplus Link@localhost:1521/Dev_Cafe
sqlplus Links/zelda@localhost:1521/Dev_Cafe
-- or 
sqlplus Dev_Hyrule/dev_Password@localhost:1521/Dev_Cafe

-- copy and paste the Cafe_schema.sql 

-- back up automation in shell 

chmod +x ./full_backup.sh

chmod +x ./incremental_backup.sh
crontab -e

0 8 1 * * /usr/bin/docker exec -it LegendOfZelda /bin/bash -c "/Home/Oracle/Script/full_backup.sh"

0 8 1 * 7 /usr/bin/docker exec -it LegendOfZelda /bin/bash -c "/Home/Oracle/Script/incremental_backup.sh"