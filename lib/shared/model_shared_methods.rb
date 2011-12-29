module Shared
  module ModelSharedMethods
    def clear!
      repository(:default).adapter.select("DELETE FROM #{storage_name}")
      #repository(:default).adapter.select("UPDATE sqlite_sequence SET seq = 0 WHERE name = '#{storage_name}'")
      repository(:default).adapter.select("DELETE FROM sqlite_sequence WHERE name = '#{storage_name}'")
    end
  end
end
