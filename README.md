# Embulk::Input::Bigquery

This is Embulk input plugin from Bigquery.

## Installation

install it yourself as:

    $ embulk gem install embulk-input-bigquery

# Configuration

## Options

### Query Options

This plugin uses the gem [`google-cloud(Google Cloud Client Library for Ruby)`](https://github.com/GoogleCloudPlatform/google-cloud-ruby) and queries data using [the synchronous method](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/c26b404d06f39d0c0c868e553255fb8f530c07b5/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L506). Optional configuration items comply with the Google Cloud Client Library.

| name                                 | type        | required?  | default                  | description            |
|:-------------------------------------|:------------|:-----------|:-------------------------|:-----------------------|
| max                                  | integer     | optional   | `null`                   | The maximum number of rows of data to return per page of results. Setting this flag to a small value such as 1000 and then paging through results might improve reliability when the query result set is large. In addition to this limit, responses are also limited to 10 MB. By default, there is no maximum row count, and only the byte limit applies. |
| cache                                | boolean     | optional   | true                     | Whether to look for the result in the query cache. The query cache is a best-effort cache that will be flushed whenever tables in the query are modified. The default value is true. For more information, see [query caching](https://developers.google.com/bigquery/querying-data). |
| standard\_sql                        | boolean     | optional   | true                     | Specifies whether to use BigQuery's [standard SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/) dialect for this query. If set to true, the query will use standard SQL rather than the [legacy SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql) dialect. When set to true, the values of `large_results` and `flatten` are ignored; the query will be run as if `large_results` is true and `flatten` is false. Optional. The default value is true. |
| legacy\_sql                          | boolean     | optional   | false                    | legacy_sql Specifies whether to use BigQuery's [legacy SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql) dialect for this query. If set to false, the query will use BigQuery's [standard SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/) When set to false, the values of `large_results` and `flatten` are ignored; the query will be run as if `large_results` is true and `flatten` is false. Optional. The default value is false. |
| location                             | string      | optional   | `null`                   | If your data is in a location other than the US or EU multi-region, you must specify the location. See also [Dataset Locations \| BigQuery \| Google Cloud](https://cloud.google.com/bigquery/docs/dataset-locations) |

## Example

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql: 'SELECT price,category_id FROM [ecsite.products] GROUP BY category_id'
  columns:
    - {name: price, type: long}
    - {name: category_id, type: string}
  max: 2000

  # # If your data is in a location other than the US or EU multi-region, you must specify the location.
  # location: asia-northeast1
out:
  type: stdout
```

If the table name is changeable, then

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql_erb: 'select price,category_id from [ecsite.products_<%= params["date"].strftime("%y%m")  %>] group by category_id'
  erb_params:
    date: "require 'date'; (date.today - 1)"
  columns:
    - {name: price, type: long}
    - {name: category_id, type: long}
    - {name: month, type: timestamp, format: '%y-%m', eval: 'require "time"; time.parse(params["date"]).to_i'}
```

If using SQL statement in the file, then

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql_file: '/path/to/sql_file.sql'
```

## Authentication

### JSON key of GCP's service account

You first need to create a service account (client ID), download its json key and deploy the key with embulk.

```
in:
  type: bigquery
  project: project_name
  keyfile: /path/to/keyfile.json
```

You can also embed contents of json_keyfile at config.yml.

```
in:
  type: bigquery
  project: project_name
  keyfile:
    content: |
      {
        "type": "service_account",
        "project_id": "example-project",
        "private_key_id": "1234567890ABCDEFG",
        "private_key": "**************************************",
        "client_email": "example-project@hogehoge.gserviceaccount.com",
        "client_id": "12345678901234567890",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://accounts.google.com/o/oauth2/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/hogehoge.gcp.iam.gserviceaccount.com"
      }
```

## Automatically determine column schema from query results

Column schema can be automatically determined from query results if `columns` definition is not given.
Please note that we have to wait until BigQuery query job complets to get the schema information.

```
in:
  type: bigquery
  project: project_name
  keyfile: /path/to/keyfile.json
  sql: 'SELECT price,category_id FROM [ecsite.products] GROUP BY category_id'
out:
  type: stdout
```

# Another Choice

`embulk-input-bigquery` queries to BigQuery, so it costs. To save money, you may take following procedures instead:

1. [Export data](https://cloud.google.com/bigquery/docs/exporting-data?hl=en) from BigQuery to GCS with avro format
2. Use [embulk-input-gcs](https://github.com/embulk/embulk-input-gcs) and [embulk-parser-avro](https://github.com/joker1007/embulk-parser-avro) to read the exported data from GCS.

# Development

## Run
```
embulk bundle install --path vendor/bundle
embulk run -X page_size=1 -b . -l trace example/example.yml
```

## Release gem

Upgrade `lib/embulk/input/bigquery/version.rb`, then

```
$ bundle exec rake release
```

# ChangeLog

[CHANGELOG.md](./CHANGELOG.md)
