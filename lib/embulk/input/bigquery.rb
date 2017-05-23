require "embulk/input/bigquery/version"
require "google/cloud/bigquery"
require 'erb'

module Embulk
  module Input
    class InputBigquery < InputPlugin
			Plugin.register_input('bigquery', self)

			def self.transaction(config, &control)
				sql = config[:sql]
				params = {}
				unless sql
					sql_erb = config[:sql_erb]
					erb = ERB.new(sql_erb)
					erb_params = config[:erb_params]
					erb_params.each do |k, v|
						params[k] = eval(v)
					end

					sql = erb.result(binding)
				end

				task = {
					project: config[:project],
					keyfile: config[:keyfile],
					sql: sql,
					columns: config[:columns],
					params: params,
					option: {
						max: config[:max],
						cache: config[:cache],
						timeout: config[:timeout],
						dryrun:  config[:dryrun]
						standard_sql: config[:standard_sql],
						legacy_sql: config[:legacy_sql]
					}
				}

				columns = []
				config[:columns].each_with_index do |c, i|
					columns << Column.new(i, c['name'], c['type'].to_sym)
				end

				yield(task, columns, 1)

				return {}
			end

			def run
				bq = Google::Cloud::Bigquery.new(project: @task[:project], keyfile: @task[:keyfile])
				params = @task[:params]
				option = keys_to_sym(@task[:option])
				rows = bq.query(@task[:sql], **option)
				rows.each do |row|
					columns = []
					@task[:columns].each do |c|
						val = row[c['name']]
						if c['eval']
							val = eval(c['eval'], binding)
						end
						columns << val
					end

					@page_builder.add(columns)
				end
				@page_builder.finish
				return {}
			end

			def keys_to_sym(hash)
				ret = {}
				hash.each do |key, value|
					ret[key.to_sym] = value
				end
				ret
			end
    end
  end
end
