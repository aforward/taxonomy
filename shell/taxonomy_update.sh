#!/bin/bash
/home/ralph/shell/taxonomy_stop.sh
/home/ralph/shell/taxonomy_database_backup.sh
cd ../sites/Taxonomy/db/backup
svn commit -m "backing up the database before update the taxonomy site"
cd ../../
svn update
rake environment RAILS_ENV=production db:migrate
/home/ralph/shell/taxonomy_start.sh
