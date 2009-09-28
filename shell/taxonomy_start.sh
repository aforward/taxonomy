#!/bin/bash
cd /home/ralph/sites/Taxonomy
/usr/local/bin/mongrel_rails start -e production -d -p 20123 -l /home/ralph/log/taxonomy_mongrel.log -P /home/ralph/log/taxonomy_mongrel.pid --prefix=/awf
