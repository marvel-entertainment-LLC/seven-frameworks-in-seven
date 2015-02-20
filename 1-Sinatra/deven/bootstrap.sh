#!/usr/bin/env bash

# Created for Ubuntu 14.04

apt-get update

apt-get install -y ruby-dev
apt-get install -y libsqlite3-dev

gem install sinatra
gem install rspec rack-test
gem install sqlite3 data_mapper dm-sqlite-adapter
gem install dm-serializer


echo "Provisioning Complete!"
