class CompileCreate
  def initialize(table_name, table_file, columns, indexes, named_indexes)
    @table_name    = table_name
    @table_file    = table_file
    @columns       = columns
    @indexes       = indexes
    @named_indexes = named_indexes
  end

  # Create statement for table
  def table_sql
    sql = "CREATE TABLE #{@table_name} USING '#{@table_file}'
(
  #{columns_part.join(",\n  ")}
)
"
  indexes_part_cache = indexes_part
  sql << "WITH INDEX
(
  #{indexes_part_cache.join(",\n  ")}
)
" if indexes_part_cache.size > 0

  sql
  end

  # array of Create statements for named indexes
  def named_indexes_sqls
    sqls = []
    @indexes.each do |index|
      if named_index?(index[:flags])
        sqls << named_index_sql(named_index_name(index[:number]), index_field_and_flags(index[:field_name], index[:flags]))
      end
    end
    sqls
  end

  def named_index_sql(index_name, field_and_flags)
    "CREATE INDEX #{index_name} ON #{@table_name} (#{field_and_flags})"
  end

  def named_index_name(number)
    ni = @named_indexes.find {|ni| ni[:offset] == number}
    raise "Error with named index finding #{@table_name} #{@named_indexes}" if ni == nil
    ni[:index_name]
  end

  # like so:
  # RejectWorker INT(4),
  # Hide Logical(1)
  def columns_part
    rows = []
    @columns.each do |arr|
      column = arr.last
      rows << "#{column.name} #{type_to_s(column.type, column.length, column.name)}"
    end
    rows
  end

  # like so:
  # ID UNIQUE,
  # AccountID
  def indexes_part
    rows = []
    @indexes.each do |index|
      rows << index_field_and_flags(index[:field_name], index[:flags]) unless named_index?(index[:flags])
    end
    rows
  end

  # index = {field_name: flags: number: part:}
  def index_field_and_flags(field_name, flags)
    # NULL | CASE | MOD | DESC | ASC
    "#{field_name} #{index_modificators(flags)}"
  end

  def index_modificators(flags)
    res = []
    res << 'UNIQUE' if unique?(flags)
    res << 'MOD'    if modifiable?(flags)

    # just checkings for now, raising Not implemented
    alternate_collating?(flags)
    null_not_indexed?(flags)
    another_segment?(flags)
    case_insensitive?(flags)
    descending_collation?(flags)
    not_ext_type?(flags)

    res.join(' ')
  end

  def type_to_s(type, length, column_name)
    case type
    when 4
      'INT(4)'
    when 5
      'INT(2)'
    when 6
      'FLOAT(8)'
    when 1
      "CHAR(#{length})"
    when 12
      "ZSTRING(#{length})"
    when -7
      'LOGICAL(1)'
    when 91
      'DATE(4)'
    when 92
      'TIME(4)'
    when 93
      'TIMESTAMP'
    when -1
      "NOTE(#{length})"
    when -5
      'INT(8)' # only one field CardCode and its not in use
    else
      raise "Unknown Type: #{@table_name} #{column_name} #{type} #{length}"
    end
  end

  # indexes # offset = number for named_indexes
  # x$field - type=255 for named indexes
  # Index..
  # 1   # 0000_0001 - allows duplicates
  # 2   # 0000_0010 - is modifiable
  # 4   # 0000_0100 - Indicates an alternate collating sequence
  # 8   # 0000_1000 - Null values are not indexed
  # 16  # 0001_0000 - another segment is concatenated to this one in the index
  # 32  # 0010_0000 - is case-insensitive
  # 64  # 0100_0000 - is collated in descending order
  # 128 # 1000_0000 - is named index
  # 256 # 1_0000_0000 is a Btrieve extended key type
  def unique?(flags)
    (flags & 1) == 0
  end

  def modifiable?(flags)
    (flags & 2) == 2
  end

  def alternate_collating?(flags)
    raise "Not Implemented: alternate_collating" if (flags & 4) == 4
  end

  def null_not_indexed?(flags)
    raise "Not Implemented: null_not_indexed" if (flags & 8) == 8
  end

  def another_segment?(flags)
    raise "Not Implemented: another_segment" if (flags & 16) == 16
  end

  def case_insensitive?(flags)
    raise "Not Implemented: case_insensitive" if (flags & 32) == 32
  end

  def descending_collation?(flags)
    raise "Not Implemented: descending_collation" if (flags & 64) == 64
  end

  def named_index?(flags)
    (flags & 128) == 128
  end

  def not_ext_type?(flags)
    raise "Strange Index is not a special BTrieve type" if (flags & 256) == 0
  end
end
