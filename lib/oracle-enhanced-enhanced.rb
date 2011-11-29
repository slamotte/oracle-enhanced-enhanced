require 'active_record/base'

module ActiveRecord
  module ConnectionAdapters
    class OracleEnhancedAdapter

      # Maximum length of an Oracle VARCHAR2 field
      VARCHAR2_MAX_LENGTH = 4000

      # Length of an Oracle primary key field
      PRIMARY_KEY_LENGTH = 12

      # Indicate whether to use varchar2(length) for TEXT columns or clob (default).
      # Pass true or false to select varchar2 or clob, respectively. Optionally pass in the desired varchar2 length.
      def self.set_text_storage_representation(use_varchar2, length = VARCHAR2_MAX_LENGTH)
        NATIVE_DATABASE_TYPES[:text] = use_varchar2 ? {:name => 'VARCHAR2', :limit => length} : {:name => 'CLOB'}
      end

      # Create convenience methods to check what text storage representation is in effect
      # e.g. text_is_clob?, text_is_varchar2?
      %w(clob varchar2).each do |format|
        (class << self; self; end).instance_eval do
          define_method "text_is_#{format}?" do
            NATIVE_DATABASE_TYPES[:text][:name].downcase == format
          end
        end
      end

      # Enable our enhanced settings/defaults
      def self.set_enhanced_defaults
        # Use sane length for PK fields
        NATIVE_DATABASE_TYPES[:primary_key] = "NUMBER(#{PRIMARY_KEY_LENGTH}) NOT NULL PRIMARY KEY"

        # Use varchar2(4000) for TEXT fields
        set_text_storage_representation true

        # Cache columns because we don't need to hit the database to check metadata all the time.
        # This requires that you restart your server when devleoping if your models change.
        #TODO: should we disable this for development?
        self.cache_columns = true

        # Oracle's default sequence behavious doesn't appeal to us OCD freaks who prefer monotonically increasing sequences
        self.default_sequence_start_value = "1 NOCACHE ORDER"
      end

      # Enable the enhanced defaults
      set_enhanced_defaults
    end

    module SchemaStatements
      # Convert an existing CLOB field into a VARCHAR2. For use in migrations.
      def convert_clob_to_varchar2(table_name, column_name, varchar2_length = ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter::VARCHAR2_MAX_LENGTH, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, "varchar2(#{varchar2_length})", temp_column_name
      end

      # Convert an existing VARCHAR2 field into a CLOB. For use in migrations.
      def convert_varchar2_to_clob(table_name, column_name, temp_column_name = nil)
        convert_text_column_storage_type table_name, column_name, 'clob', temp_column_name
      end

      private

      # Convert a field from varchar2 to clob or vice versa
      def convert_text_column_storage_type(table_name, column_name, to_type, temp_column_name)
        quoted_table_name = quote_table_name(table_name)
        orig_col = quote_column_name(column_name)
        temp_col = quote_column_name(temp_column_name || 'oee_temp_col')
        cmds = <<-SQL
          alter table #{quoted_table_name} add #{temp_col} #{to_type}
          update #{quoted_table_name} set #{temp_col} = #{orig_col}
          alter table #{quoted_table_name} drop column #{orig_col}
          alter table #{quoted_table_name} rename column #{temp_col} to #{orig_col}
        SQL
        cmds.split("\n").map(&:strip).each{|cmd| execute cmd}

        # Also process any history table
        convert_text_column_storage_type(history_table_name(table_name), column_name, to_type, temp_column_name) if history_table_exists?(table_name)
      end
    end

  end
end
