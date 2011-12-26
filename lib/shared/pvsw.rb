# 2.98 120 update
#RealizColumns = "ID, TransType, aDate, aTime, Smena, DishID, DivID, CliID, PosID, WrkID, Quant, Amount, Discount, PayForm, DocNumber, OutDoor, Black, Nds, RealAttribute, EkkaNo, EkkaCheckNo, DocUID"

require "odbc_utf8"

class Pvsw

  class << self
   attr_writer :odbc_alias

   def odbc_alias
     @odbc_alias ||= "D2Main.NET"
   end
  end

  def self.do_sql_no_result(sql)
    ODBC::connect(odbc_alias) do |dbc|
      Pvsw.new(dbc).run_simple(sql)
    end
  end

  def self.do_sql_single_result(sql)
    ODBC::connect(odbc_alias) do |dbc|
      Pvsw.new(dbc).run_single_result(sql)
    end
  end

  def self.do_sql_multiple_results(sql, &block)
    ODBC::connect(odbc_alias) do |dbc|
      stmt = dbc.run(sql)
        yield stmt
      stmt.drop
    end
  end

  def self.do_some_sqls_no_result(*sqls)
    ODBC::connect(odbc_alias) do |dbc|
      pvsw = Pvsw.new(dbc)
      sqls.each do |sql|
        pvsw.run_simple(sql)
      end
    end
  end

  def initialize(dbc)
    @dbc = dbc
  end

  def run_simple(sql)
    p sql
    @dbc.do(sql)
  end

  def run_single_result(sql)
    res = nil
    @dbc.run(sql) do |stmt|
      res = stmt.first.first if stmt && stmt.first
      stmt.drop
    end
    res
  end

  # def run_multiple_results(sql, &block)
  #   res = nil
  #   @dbc.run(sql) do |stmt|
  #     stmt.each
  #     stmt.drop
  #   end
  # end

  def table_exist?(table_name)
    res = run_single_result("SELECT COUNT(*) FROM X$File
          WHERE Xf$Name = '#{table_name}'")
    res == 1
  end

end