# IRIS - Integrated Retrieval and Inventory System
[![Build Status](https://travis-ci.org/ndlib/annex-ims.svg?branch=master)](https://travis-ci.org/ndlib/annex-ims)
[![Coverage Status](https://coveralls.io/repos/ndlib/annex-ims/badge.svg)](https://coveralls.io/r/ndlib/annex-ims)
[![Code Climate](https://codeclimate.com/github/ndlib/annex-ims/badges/gpa.svg)](https://codeclimate.com/github/ndlib/annex-ims)

IRIS - Integrated Retrieval and Inventory System for offsite storage facilities

## Getting Started:

Requirements:

* Ruby (~> 2.1.4)
* RabbitMQ (~> 3.5.0) - https://www.rabbitmq.com/download.html
* Postgres - (~> 9.4) - http://www.postgresql.org/download/

Installation:

On Mac, install Qt@5.5 following directions here: https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#homebrew

Also on Mac, near the top of .bashrc (or similar), add `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` - see https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/

```console
$ bundle install
$ bundle exec rake db:create db:migrate db:seed
```

Start thin; This will fire up the application. Solr, sneakers and Postgres should also be running.

```console
$ brew services restart postgresql
$ thin start -C config/thin.yml
$ rake sunspot:solr:start
$ brew services start rabbitmq
$ rake sneakers:start
```

## Chron tasks

The system uses chron to schedule some tasks that are necessary for system operation (e.g. - ensuring that sneakers is running and retrieving open requests from the ILS). The tasks that are configured to run under chron are documented in <app-dir>/config/schedule.rb.

## Indexing records

The system uses Solr to index records. Given the potentially high volume of records handled by the IMS, this is necessary for performance reasons. In order to initiate a complete reindex of the records, use the following command:

```console
$ export RAILS_ENV=<environment>
$ bundle exec rake sunspot:reindex
```

Please note: depending on the number of records, reindexing the entire database could take significant time and during reindexing certain application functions will not work or operate in a degraded fashion.
