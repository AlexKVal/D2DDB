require_relative 'config'
require_relative 'central/received_data_queue'
require_relative 'shared/pvsw'

module Central
  class Applier
    def initialize(rdq = ReceivedDataQueue.new)
      @received_data_queue = rdq
    end

    def run
      ODBC::connect(CENTRAL_ALIAS) do |dbc|
        pvsw = Pvsw.new(dbc)

        received_rows = @received_data_queue.data
        received_rows.each do |row|
          p sql = case row.action
          when 'I'
            sql_for_insert(row.tblname, row.data)
          when 'U'
            sql_for_update(row.tblname, row.data)
          when 'D'
            sql_for_delete(row.tblname, row.rowid, row.data)
          end

          pvsw.run_simple sql
        end
      end

      @received_data_queue.clear!
    end

    private
      def sql_for_insert(table, json_data)
        "INSERT INTO #{table} #{columns_for_insert(json_data)}"
      end

      def sql_for_update(table, json_data)
        "UPDATE #{table} #{columns_for_update(json_data)}"
      end

      def sql_for_delete(table, rowid, idname)
        "DELETE FROM #{table} WHERE #{idname} = #{rowid}"
      end

      def val_to_s(val)
        case val
        when String
          "'#{val}'"
        when nil
          'null'
        else
          val
        end        
      end

      def names_values_for_insert_from(jsondata)
        columns_hash = JSON.parse(jsondata)
        names, values = [], []

        columns_hash.each do |key, val|
          names  << key
          values << val_to_s(val)
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
        idcol = columns_hash.shift

        sets = columns_hash.inject([])  do |sets, (k,v)|
          sets << "#{k} = #{val_to_s(v)}"
        end.join(', ')

        "SET #{sets} WHERE #{idcol[0]} = #{idcol[1]}"
      end
  end
end
