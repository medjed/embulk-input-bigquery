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
					params: params
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
				rows = bq.query(@task[:sql])

				@task[:columns] = values_to_sym(@task[:columns], 'name')

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

			def values_to_sym(hashs, key)
				hashs.map do |h|
					h[key] = h[key].to_sym
					h
				end
			end
    end
  end
end
