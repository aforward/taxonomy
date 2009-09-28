#!/bin/bash
mysqldump -u root -phe110 --opt taxonomy_production > /home/ralph/sites/Taxonomy/db/backup/taxonomy.sql
