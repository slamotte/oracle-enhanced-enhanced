module ActiveRecord
  module ConnectionAdapters
    module OracleEnhancedAdapter

      # Maximum length of an Oracle VARCHAR2 field
      VARCHAR2_MAX_LENGTH = 4000

      # Indicate whether to use varchar2(length) for TEXT columns or clob (default).
      # Pass true or false to select varchar2 or clob, respectively. Optionally pass in the desired varchar2 length.
      def set_text_storage_representation(use_varchar2, length = VARCHAR2_MAX_LENGTH)
        NATIVE_DATABASE_TYPES[:text] = use_varchar2 ? {:name => 'VARCHAR2', :limit => length} : {:name => 'CLOB'}
      end

      # Create helper methods to check what storage representation is in effect
      # e.g. text_is_clob?, text_is_varchar2?
      %w(clob varchar2).each do |format|
        define_method "text_is_#{format}?" do
          NATIVE_DATABASE_TYPES[:text][:name].downcase == format
        end
      end

      # Convert an existing CLOB field into a VARCHAR2
      def convert_clob_to_varchar2(table_name, column_name, varchar2_length = VARCHAR2_MAX_LENGTH, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, "varchar2#{varchar2_length}", temp_column_name
      end

      # Convert an existing VARCHAR2 field into a CLOB
      def convert_varchar2_to_clob(table_name, column_name, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, 'clob', temp_column_name
      end

      private

      def convert_text_column_storage_type(table_name, column_name, to_type, temp_column_name)
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
        cmds.split('\n').each{|cmd| @connection.execute cmd}
      end

    end
  end
end
