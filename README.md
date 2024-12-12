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

-- Download oracle inside docker

sudo docker run -itd --name LegendOfZelda \
-e ORACLE_PWD='p1a2s0s3word' \
-p 1521:1521 \
-v /home/oracle : /opt/oracle/oradata \
container-registry.oracle.com/database/free:latest

-- Execute sql

sudo docker exec -it LegendOfZelda bash

-- Login as admin 
-- For safer way sqlplus sys@locahost:1521 as sysdba
sqlplus sys/p1a2s0s3word@locahost:1521 as sysdba

-- PLUGGABLE DATABASE
CREATE PLUGGABLE DATABASE Dev_Cafe admin user Links IDENTIFIED BY zelda \
create_file_dest='/home/oracle';

-- Set permision
ALTER PLUGGABLE DATABASE Dev_Cafe OPEN;
EXIT

-- Log in to the database
-- For safer way sqlplus sys@localhost:1521/Dev_cafe as sysdba
sqlplus sys/p1a2s0s3word@localhost:1521/Dev_Cafe as sysdba

-- Grant access to Link
GRANT DBA to link CONTAINER = ALL

-- Developer Acess

CREATE ROLE dev_ROLE;

GRANT CONNECT, CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE TRIGGER, CREATE SYNONYM TO dev_ROLE;

CREATE USER Dev_Hyrule IDENTIFIED BY dev_Password

GRANT dev_ROLE TO Dev;

GRANT UNLIMITED TABLESPACE TO Dev;

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
sqlplus Link/zelda@localhost:1521/Dev_Cafe


-- back up automation in shell 

chmod +x /Home/Oracle/Script/full_backup.sh

chmod +x /Home/Oracle/Script/incremental_backup.sh

crobtab -e

0 8 1 * * /Home/Oracle/Script/full_backup.sh

0 8 1 * 7 /Home/Oracle/Script/incremental_backup.sh
