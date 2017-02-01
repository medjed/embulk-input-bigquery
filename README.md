# Embulk::Input::Bigquery

This is Embulk input plugin from Bigquery.

## Installation

install it yourself as:

    $ embulk gem install embulk-input-bigquery

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

If, table name is changeable, then

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql: 'SELECT price,category_id FROM [ecsite.products_<%= params["date"].strftime("%Y%m")  %>] GROUP BY category_id'
  erb_params:
    date: "require 'date'; (Date.today - 1)"
  columns:
    - {name: price, type: long}
    - {name: category_id, type: long}
    - {name: month, type: timestamp, format: '%Y-%m', eval: 'require "time"; Time.parse(params["date"]).to_i'}
```

