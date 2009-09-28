#!/bin/bash
mysqldump -u root -phe110 --opt asktell_production > /home/ralph/sites/asktell/db/backup/asktell.sql
