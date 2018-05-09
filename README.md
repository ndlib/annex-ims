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
