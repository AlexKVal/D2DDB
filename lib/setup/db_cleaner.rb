# copies all data to the new base
# copies only tables with files

require "odbc_utf8"
require_relative 'compile_create'

bases_path      = 'C:\D2Bases'
dirname_fromdb  = 'Old'
dirname_todb    = 'New'
odbc_alias_from = "#{dirname_fromdb}.NET"
odbc_alias_to   = "#{dirname_todb}.NET"
tmp_dir         = "#{bases_path}\\#{dirname_fromdb}\\#{dirname_todb}"
Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)

def values_to_s(row)
  vals = []
  row.each do |v|
    vals << case v
    when nil
      'null'
    when Integer, Float
      v
    when String
      "'#{v}'"
    else
      "'#{v.to_s}'"
    end
  end
  vals.join(',')
end

RealizColumns = "ID, TransType, aDate, aTime, Smena, DishID, DivID, CliID, PosID, WrkID, Quant, Amount, Discount, PayForm, DocNumber, OutDoor, Black, Nds, RealAttribute, EkkaNo, EkkaCheckNo, DocUID"
def copy_data_for(table, dbc_from, dbc_to)
  cols = (table == 'jRealizations' || table == 'jArcRealizations') ? RealizColumns : '*'
  insert_col = (table == 'jRealizations' || table == 'jArcRealizations')

  stmt = dbc_from.run("SELECT * FROM #{table}")
  id_col = stmt.columns.first.first.strip
  stmt.drop

  stmt = dbc_from.run("SELECT #{cols} FROM #{table} ORDER BY #{id_col}")
  stmt.columns.first.first
  stmt.each do |row|
    row.insert(19, 0) if insert_col # CardCode int(8)

    dbc_to.do("INSERT INTO #{table} VALUES (#{values_to_s(row)})")
    #print '.'
  end
  stmt.drop
end

def table_existed?(table_name, dbc)
  sql = "SELECT COUNT(*) FROM X$File WHERE Xf$Name = '#{table_name}'"
  stmt = dbc.run(sql)
  res = (stmt && stmt.first) ? stmt.first.first : nil
  stmt.drop
  res == 1
end

puts Time.now
tables = []
ODBC::connect(odbc_alias_from) do |dbc_from|
  ODBC::connect(odbc_alias_to) do |dbc_to|

    # copy_data_for('sPersonal', dbc_from, dbc_to)
    # raise 'STOP'

    # get all tables names
    sql = "SELECT Xf$Name, Xf$Loc, Xf$Id FROM X$File WHERE Xf$Flags=0 ORDER BY Xf$Name"
    stmt = dbc_from.run(sql)
    stmt.each do |row|
      tables << {name: row[0].strip, file: row[1].strip, id: row[2]}
    end
    stmt.drop
    #p tables

    # cache all existed tables names in the destination DB
    # for fast checking table_exist?
    existed_tables_in_new = []
    sql = "SELECT Xf$Name, Xf$Loc, Xf$Id FROM X$File WHERE Xf$Flags=0 ORDER BY Xf$Name"
    stmt = dbc_to.run(sql)
    stmt.each do |row|
      existed_tables_in_new << row.first.strip
    end
    stmt.drop
    #p existed_tables_in_new

    tables.each do |table|
      table_name = table[:name]
      table_file = table[:file]
      table_id   = table[:id]

      # table_name = 'jProtocol'
      # table_file = 'jProt.mkd'
      # table_id   = 233

      # read structure of table
      # columns names
      sql= "SELECT * FROM #{table_name}"
      stmt = dbc_from.run(sql)
      columns = stmt.columns
      stmt.drop
      # p columns

      # indexes
      indexes = []
      sql= "SELECT xe$name, xi$flags, xi$number, xi$part FROM x$index, x$field
            WHERE xi$file = #{table_id}  AND xe$id = xi$field"
      stmt = dbc_from.run(sql)
      stmt.each do |row|
        indexes << {field_name: row[0].strip, flags: row[1], number: row[2], part: row[3]}
      end
      stmt.drop
      #p indexes

      named_indexes = []
      sql = "SELECT xe$name, xe$offset FROM x$Field WHERE xe$file = #{table_id} AND xe$datatype = 255"
      stmt = dbc_from.run(sql)
      stmt.each do |row|
        named_indexes << {index_name: row[0].strip, offset: row[1]}
      end
      stmt.drop
      #p named_indexes


      # drop if exist
      dbc_to.do("DROP TABLE #{table_name}") if existed_tables_in_new.include?(table_name)

      sql_create = CompileCreate.new(table_name, table_file, columns, indexes, named_indexes)

      # create such table in the new db
      sql = sql_create.table_sql
      puts "#{table_name}" #{sql}"  #{sql_create.inspect}"
      dbc_to.do(sql)
      # create named indexes
      sql_create.named_indexes_sqls.each do |sql|
        puts "NI: #{sql}"
        dbc_to.do(sql)
      end

      # CHECK indexes
      from_indexes = []
      sql= "SELECT xf$name, xe$name, xi$flags FROM x$index, X$File, X$Field
            WHERE xf$Id = xi$file AND xi$field = xe$Id
            AND xf$name = '#{table_name}' ORDER BY xe$name"
      stmt = dbc_from.run(sql)
      stmt.each do |row|
        from_indexes << row
      end
      stmt.drop

      to_indexes = []
      sql= "SELECT xf$name, xe$name, xi$flags FROM x$index, X$File, X$Field
            WHERE xf$Id = xi$file AND xi$field = xe$Id
            AND xf$name = '#{table_name}' ORDER BY xe$name"
      stmt = dbc_to.run(sql)
      stmt.each do |row|
        to_indexes << row
      end
      stmt.drop

      unless from_indexes == to_indexes
        p from_indexes
        puts "====="
        p to_indexes
        raise "Wrong indexes: #{table_name}"
      end

      # create temp_table in 'from' db
      tmp_table = "C#{table_name}"[0..19]
      dbc_from.do("DROP TABLE #{tmp_table}") if table_existed?("#{tmp_table}", dbc_from)

      tmp_sql_create = CompileCreate.new("#{tmp_table}",
                        "#{dirname_todb}\\#{table_file}",
                        columns, indexes, named_indexes)
      puts "#{tmp_table}" #{sql}"  #{sql_create.inspect}"
      dbc_from.do(tmp_sql_create.table_sql)
      # # create named indexes
      # tmp_sql_create.named_indexes_sqls.each do |sql|
      #   puts "NI: #{sql}"
      #   dbc_from.do(sql)
      # end

      # copy data by SQL-server
      # from table to temp_table
      dbc_from.do("INSERT INTO #{tmp_table} SELECT * FROM #{table_name}")

      #
      # copy all data. row by row.
      #copy_data_for(table_name, dbc_from, dbc_to) # very time consuming method

      # move data_file to the new db
      %x(move /Y #{tmp_dir}\\* #{bases_path}\\#{dirname_todb}\\)
      # remove table from Dictionary
      dbc_from.do("DROP TABLE #{tmp_table}")

    end # tables.each

    # hack for creating X$Proc and X$View tables
    dbc_to.do("CREATE PROCEDURE tmpProc(a INT(4)); BEGIN DECLARE f FLOAT(8); END")
    dbc_to.do("DROP PROCEDURE tmpProc")
    dbc_to.do("CREATE VIEW tmpView (ID) AS SELECT Xe$Id FROM X$Field")
    dbc_to.do("DROP VIEW tmpView")

   end # dbc_to
end # dbc_from

Dir.rmdir(tmp_dir)

# copy Views and Procs
%x(xcopy /Y #{bases_path}\\#{dirname_fromdb}\\PROC.DDF #{bases_path}\\#{dirname_todb}\\)
%x(xcopy /Y #{bases_path}\\#{dirname_fromdb}\\VIEW.DDF #{bases_path}\\#{dirname_todb}\\)

puts "\n All is Done !"
puts Time.now
