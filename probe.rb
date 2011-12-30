require_relative 'lib/shared/pvsw'

ODBC::connect(Pvsw.odbc_alias) do |dbc|


  pvsw = Pvsw.new dbc
  p pvsw.get_json_data_for('frTables', 1)


end
