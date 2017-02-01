require "embulk/input/bigquery/version"
require "google/cloud/bigquery"

module Embulk
  module Input
    class InputBigquery < InputPlugin
			Plugin.register_input('bigquery', self)

			def self.transaction(config, &control)

				task = {project: config[:project], keyfile: config[:keyfile], sql: config[:sql], columns: config[:columns]}
				columns = []
				config[:columns].each_with_index do |c, i|
					columns << Column.new(i, c['name'], c['type'].to_sym)
				end

				yield(task, columns, 1)

				return {}
			end

			def run
				bq = Google::Cloud::Bigquery.new(project: @task[:project], keyfile: @task[:keyfile])
				rows = bq.query(@task[:sql])
				rows.each do |row|
					columns = []
					@task[:columns].each do |c|
						columns << row[c['name']]
					end
					@page_builder.add(columns)
				end
				@page_builder.finish
				return {}
			end
    end
  end
end
