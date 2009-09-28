#!/bin/bash
cd /home/ralph/sites/asktell
/usr/local/bin/mongrel_rails start -e production -d -p 20124 -l /home/ralph/log/asktell_mongrel.log -P /home/ralph/log/asktell_mongrel.pid --prefix=/awf2	
