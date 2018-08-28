require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseAuthyGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_devise_migration
        migration_template "migration.rb", "db/migrate/devise_authy_add_to_#{table_name}.rb", migration_version: migration_version
      end

      private

      def rails5?
        Rails.version.start_with? '5'
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if rails5?
      end
    end
  end
end
