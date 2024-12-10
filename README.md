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
