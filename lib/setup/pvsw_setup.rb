require_relative "../shared/pvsw"
require_relative "../../config"

#Pvsw.odbc_alias = FILIAL_ALIAS

class PvswSetup < Pvsw

  def initialize(dbc)
    super
  end

  def drop_triggers
    return unless table_exist? 'X$Trigger'
    @tables_to_watch.each do |tbl|
      drop_triggers_for tbl
    end
  end

  def run_setup_clientdb
    drop_triggers

    setup_table_for_changes

    setup_triggers
  end

  def run_setup_testdb
    #drop_triggers

    setup_table_for_changes
    setup_test_tables
    #setup_triggers

    puts "Ok."
  end

  private
    def setup_table_for_changes
      run_simple("DROP TABLE urDataCh") if table_exist? 'urDataCh'
      #File.delete("urDataCh.mkd") if File.exists?("urDataCh.mkd")

      sql = "
      CREATE TABLE urDataCh USING 'urDataCh.mkd'
      (
        ID AUTOINC(4),
        tblOper ZSTRING(31),
        rowWithID INT(4)
      )
      WITH INDEX
      (
        ID UNIQUE,
        tblOper
      )"
      run_simple sql
    end

    def setup_test_tables
      run_simple("DROP TABLE tableOne") if table_exist? 'tableOne'
      run_simple("DROP TABLE tableTwo") if table_exist? 'tableTwo'

      run_simple "
      CREATE TABLE tableOne USING 'tableOne.mkd'
      (
        ID          AUTOINC(4),
        string_prm  ZSTRING(31),
        integer_prm INT(4),
        short_prm   INT(2),
        float_prm   FLOAT(8),
        date_prm    DATE(4),
        time_prm    TIME(4),
        bool_prm    LOGICAL(1)
      )
      WITH INDEX
      (
        ID UNIQUE
      )"

      run_simple "
      CREATE TABLE tableTwo USING 'tableTwo.mkd'
      (
        ID          AUTOINC(4),
        string_prm  ZSTRING(31),
        integer_prm INT(4),
        date_prm    DATE(4)
      )
      WITH INDEX
      (
        ID UNIQUE
      )"
    end

    def setup_triggers
      @tables_to_watch.each do |tbl|
        print "\n* "
        setup_triggers_for tbl
        print " #{tbl}"
      end
    end

    def drop_trigger(trigger_name)
      puts "x #{trigger_name}"
      run_simple("DROP TRIGGER #{trigger_name}")
    end

    def trigger_exists?(trigger_name)
      res = run_single_result("
      SELECT COUNT(*) FROM X$Trigger WHERE Xt$Name = '#{trigger_name}'")
      res == 1
    end

    def trigger_name(table, suffix)
      "UR#{table[0..23]}#{suffix}"
    end

    def drop_triggers_for(table)
      %w(Ins Upd Del).each do |suffix|
        trigger = trigger_name(table, suffix)
        drop_trigger trigger if trigger_exists? trigger
      end
    end

    def setup_triggers_for(table)
      create_insert_trigger table
      print "+"
      %w(Upd Del).each do |suffix|
        create_trigger(table, suffix)
      end
      print "u-"
    end

    def create_insert_trigger(table)
      sql = "
CREATE TRIGGER #{trigger_name(table, 'Ins')}
AFTER INSERT ON #{table}
REFERENCING NEW AS REF
FOR EACH ROW

BEGIN
  DECLARE fNextID INT (4);
  DECLARE c1 CURSOR FOR
    SELECT MAX(#{id_columns[table]}) + 1 FROM #{table};

  IF (REF.#{id_columns[table]} = 0) THEN
   OPEN c1;
   FETCH_LOOP:
   LOOP
    FETCH NEXT FROM c1 INTO fNextID;
    LEAVE FETCH_LOOP;
   END LOOP;
   CLOSE c1;
  ELSE
   SET fNextID = REF.#{id_columns[table]};
  END IF;

  INSERT INTO urDataCh (tblOper, rowWithID) VALUES('#{table} I', fNextID);
END"
      #File.write('sql.txt', sql)
      run_simple sql
    end

    def create_trigger(table, suffix)
      trigger_type, char_type = case suffix
      when 'Upd'
        ['UPDATE', 'U']
      when 'Del'
        ['DELETE', 'D']
      end

      sql = "
CREATE TRIGGER #{trigger_name(table, suffix)}
AFTER #{trigger_type} ON #{table}
REFERENCING OLD AS REF
FOR EACH ROW
INSERT INTO urDataCh (tblOper, rowWithID)
VALUES('#{table} #{char_type}', REF.#{id_columns[table]})"
      #File.write('sql.txt', sql)
      run_simple sql
    end

end

def print_help_message
  puts "Usage:"
  puts "#{$0} server or client or test or drop :)"
end

def setup_client_side_db
  ODBC::connect(FILIAL_ALIAS) do |dbc|
    PvswSetup.new(dbc).run_setup_clientdb
  end
end

def setup_testdb
  ODBC::connect("TestDB.NET") do |dbc|
    PvswSetup.new(dbc).run_setup_testdb
  end
end

def setup_drop_triggers
  ODBC::connect(FILIAL_ALIAS) do |dbc|
    PvswSetup.new(dbc).drop_triggers
  end
end

case ARGV[0]
when 'test'
  setup_testdb
when 'server'
  setup_server_side_db
when 'client'
  setup_client_side_db
when 'drop'
  setup_drop_triggers
else
  print_help_message
end

