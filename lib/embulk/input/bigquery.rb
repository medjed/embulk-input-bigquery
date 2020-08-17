require 'embulk/input/bigquery/version'
require 'google/cloud/bigquery'
require 'erb'

module Embulk
  module Input
    class InputBigquery < InputPlugin
      Plugin.register_input('bigquery', self)

      # support config by file path or content which supported by org.embulk.spi.unit.LocalFile
      # keyfile:
      #   content: |
      class LocalFile
        def self.load(v)
          if v.is_a?(String)
            v
          elsif v.is_a?(Hash)
            JSON.parse(v['content'])
          end
        end
      end

      def self.transaction(config, &control)
        sql = config[:sql]
        params = {}
        unless sql
          sql_erb = config[:sql_erb]
          erb = ERB.new(sql_erb)
          erb_params = config[:erb_params] || {}
          erb_params.each do |k, v|
            params[k] = eval(v)
          end

          sql = erb.result(binding)
        end

        task = {
          project: config[:project],
          keyfile: config.param(:keyfile, LocalFile, nil),
          sql: sql,
          params: params,
          option: {
            max: config[:max],
            cache: config[:cache],
            standard_sql: config[:standard_sql],
            legacy_sql: config[:legacy_sql],
            location: config[:location],
          }
        }

        if config[:columns]
          task[:columns] = config[:columns]
        else
          bq = Google::Cloud::Bigquery.new(project: task[:project], keyfile: task[:keyfile], timeout: 1800)
          task[:job_id], task[:columns] = determine_columns_by_query_results(sql, task[:option], bq)
        end

        columns = []
        task[:columns].each_with_index do |c, i|
          columns << Column.new(i, c['name'], c['type'].to_sym)
        end

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
      end

      def run
        bq = Google::Cloud::Bigquery.new(project: task[:project], keyfile: task[:keyfile], timeout: 1800)
        params = @task[:params]
        option = keys_to_sym(@task[:option])

        rows = if @task[:job_id].nil?
                 query_option = option.dup
                 query_option.delete(:location)

                 bq.query(@task[:sql], **query_option) do |job_updater|
                   job_updater.location = option[:location] if option[:location]
                 end
               else
                 job_option = {}
                 job_option[:location] = option[:location] if option[:location]

                 bq.job(@task[:job_id], **job_option).query_results(max: option[:max])
               end

        @task[:columns] = values_to_sym(@task[:columns], 'name')

        rows.all do |row|
          columns = []
          @task[:columns].each do |c|
            val = row[c['name'].to_sym]
            val = eval(c['eval'], binding) if c['eval']

            columns << as_serializable(val)
          end

          @page_builder.add(columns)
        end
        @page_builder.finish
        {}
      end

      def self.determine_columns_by_query_results(sql, option, bigquery_client)
        Embulk.logger.info 'determine columns using the getQueryResults API instead of the config.yml'

        query_option = option.dup
        query_option.delete(:max)
        query_option.delete(:location)
        job = bigquery_client.query_job(sql, **query_option) do |query|
          query.location = option[:location] if option[:location]
        end

        Embulk.logger.info 'waiting for the query job to complete to get schema from query results'
        job.wait_until_done!

        Embulk.logger.info "completed: job_id=#{job.job_id}"
        result = job.query_results(max: 0)

        columns = result.fields.map do |f|
          {
            'name' => f.name,
            'type' => embulk_column_type(f.type)
          }
        end
        Embulk.logger.info "determined columns: #{columns.inspect}"

        [job.job_id, columns]
      end

      def self.embulk_column_type(bq_data_type)
        case bq_data_type
        when 'BOOLEAN', 'BOOL'
          :boolean
        when 'INTEGER', 'INT64'
          :long
        when 'FLOAT', 'FLOAT64'
          :double
        when 'STRING', 'DATETIME', 'DATE', 'TIME'
          :string
        when 'TIMESTAMP'
          :timestamp
        when 'RECORD', 'BYTES'
          raise "unsupported type #{bq_data_type.inspect}"
        else
          raise "unknown type #{bq_data_type.inspect}"
        end
      end

      def keys_to_sym(hash)
        ret = {}
        hash.each do |key, value|
          ret[key.to_sym] = value
        end
        ret
      end

      def values_to_sym(hashs, key)
        hashs.map do |h|
          h[key] = h[key].to_sym
          h
        end
      end

      def as_serializable(v)
        case v
        when ::Google::Cloud::Bigquery::Time
          v.value
        when DateTime
          v.strftime('%Y-%m-%d %H:%M:%S.%6N')
        when Date
          v.strftime('%Y-%m-%d')
        else
          v
        end
      end
    end
  end
end
