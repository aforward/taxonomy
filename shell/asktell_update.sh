#!/bin/bash
/home/ralph/shell/asktell_stop.sh
/home/ralph/shell/asktell_database_backup.sh
cd ../sites/asktell/db/backup
svn commit -m "backing up the database bfore updating the asktell website"
cd ../../
svn update
rake environment RAILS_ENV=production db:migrate
/home/ralph/shell/asktell_start.sh
