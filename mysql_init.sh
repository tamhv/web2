#!/bin/bash

service mysqld start 

sleep 10

/usr/bin/mysqladmin -u root password 'Anhyeuem123'

service mysqld stop

chown -R mysql:mysql /var/lib/mysql