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
  max: 2000
out:
  type: stdout
```

If, table name is changeable, then

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql_erb: 'SELECT price,category_id FROM [ecsite.products_<%= params["date"].strftime("%Y%m")  %>] GROUP BY category_id'
  erb_params:
    date: "require 'date'; (Date.today - 1)"
  columns:
    - {name: price, type: long}
    - {name: category_id, type: long}
    - {name: month, type: timestamp, format: '%Y-%m', eval: 'require "time"; Time.parse(params["date"]).to_i'}
```

### Determine columns from query results if columns definition is empty

```
in:
  type: bigquery
  project: 'project-name'
  keyfile: '/home/hogehoge/bigquery-keyfile.json'
  sql: 'SELECT price,category_id FROM [ecsite.products] GROUP BY category_id'
out:
  type: stdout
```

### Embed keyfile content as string into config

```
in:
  type: bigquery
  project: 'project-name'
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


## Optional Configuration
This plugin uses the gem [`google-cloud(Google Cloud Client Library for Ruby)`](https://github.com/GoogleCloudPlatform/google-cloud-ruby) and queries data using [the synchronous method](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L281).
Therefore some optional configuration items comply with the Google Cloud Client Library.

- [max](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L315) :
  - default value : **null** and null value is interpreted as [no maximum row count](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L319) in the Google Cloud Client Library.
- [cache](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L331) :
  - default value : **null** and null value is interpreted as [true](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L333) in the Google Cloud Client Library.
- [standard_sql](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L343):
  - default value : **null** and null value is interpreted as [true](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L351) in the Google Cloud Client Library.
- [legacy_sql](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L353):
  - default value : **null** and null value is interpreted as [false](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/google-cloud-bigquery/lib/google/cloud/bigquery/project.rb#L361) in the Google Cloud Client Library.
