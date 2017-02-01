# Embulk::Input::Bigquery

This is Embulk input plugin from Bigquery.

## Installation

Add this line to your application's Gemfile:

    gem 'embulk-input-bigquery'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install embulk-input-bigquery

## Usage

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql: 'SELECT price,category_id FROM [ecsite.products] GROUP BY category_id'
  columns:
    - {name: price, type: long}
    - {name: category_id, type: string}
out:
  type: stdout
```
