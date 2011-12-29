require_relative 'config'
require_relative 'central/received_data_queue'
require_relative 'shared/pvsw'

module Central
  class Applier
    def initialize(rdq = ReceivedDataQueue.new)
      @received_data_queue = rdq
    end

    def run
      received_rows = @received_data_queue.data

      received_rows.each do |row|
        case row.action
        when 'I'
          do_sql
        when 'U'
        when 'D'
        end
      end

      @received_data_queue.clear!
    end

    private
      def names_values_for_insert_from(jsondata)
        columns_hash = JSON.parse(jsondata)
        names, values = [], []

        columns_hash.each do |key, val|
          names  << "'#{key}'"
          values << (val.kind_of?(String) ? "'#{val}'" : val)
        end
        [names, values]
      end

      # "(columns) values (vals)"
      def columns_for_insert(jsondata)
        names, values = names_values_for_insert_from(jsondata)
        "(#{names.join(', ')}) VALUES (#{values.join(', ')})"
      end
      
      def columns_for_update(jsondata)
        columns_hash = JSON.parse(jsondata)
        columns_hash.shift # remove id column

        columns_hash.inject([])  do |sets, (k,v)|
          sets << "SET #{k} = #{String === v ? "'#{v}'" : v}"
        end.join(', ')
      end
  end
end
