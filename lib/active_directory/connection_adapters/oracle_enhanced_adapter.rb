module ActiveRecord
  module ConnectionAdapters
    class OracleEnhancedAdapter

      # Set our new enhanced defaults
      set_enhanced_defaults

      # Maximum length of an Oracle VARCHAR2 field
      VARCHAR2_MAX_LENGTH = 4000

      # Indicate whether to use varchar2(length) for TEXT columns or clob (default).
      # Pass true or false to select varchar2 or clob, respectively. Optionally pass in the desired varchar2 length.
      def self.set_text_storage_representation(use_varchar2, length = VARCHAR2_MAX_LENGTH)
        NATIVE_DATABASE_TYPES[:text] = use_varchar2 ? {:name => 'VARCHAR2', :limit => length} : {:name => 'CLOB'}
      end

      # Create convenience methods to check what storage representation is in effect
      # e.g. text_is_clob?, text_is_varchar2?
      %w(clob varchar2).each do |format|
        (class << self; self; end).instance_eval do
          define_method "text_is_#{format}?" do
            NATIVE_DATABASE_TYPES[:text][:name].downcase == format
          end
        end
      end

      # Convert an existing CLOB field into a VARCHAR2. For use in migrations.
      def convert_clob_to_varchar2(table_name, column_name, varchar2_length = VARCHAR2_MAX_LENGTH, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, "varchar2#{varchar2_length}", temp_column_name
      end

      # Convert an existing VARCHAR2 field into a CLOB. For use in migrations.
      def convert_varchar2_to_clob(table_name, column_name, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, 'clob', temp_column_name
      end

      private

      # Enable our enhanced settings/defaults
      def set_enhanced_defaults
        # Use varchar2(4000) for TEXT fields
        set_text_storage_representation true

        # Cache columns because we don't need to hit the database to check metadata all the time
        self.cache_columns = true

        # Oracle's default sequence behavious doesn't appeal to us OCD freaks who prefer monotonically increasing sequences
        self.default_sequence_start_value = "1 NOCACHE ORDER"
      end

      # Convert a field from varchar2 to clob or vice versa
      def convert_text_column_storage_type(table_name, column_name, to_type, temp_column_name)
        # Inspired by http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1770086700346491686
        temp_col = temp_column_name || 'oee_temp_col'
        cmds = <<-SQL
          alter table #{table_name} add #{temp_col} #{to_type}
          update #{table_name} set #{temp_col} = #{column_name}
          update #{table_name} set #{column_name} = null
          alter table #{table_name} modify #{column_name} long
          alter table #{table_name} modify #{column_name} #{to_type}
          update #{table_name} set #{column_name} = #{temp_col}
          alter table #{table_name} drop column #{temp_col}
        SQL
        cmds.split('\n').each{|cmd| execute cmd}
      end
    end

  end
end
