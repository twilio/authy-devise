require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseAuthyGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_devise_migration
        migration_template "migration.rb", "db/migrate/devise_authy_add_to_#{table_name}.rb", migration_version: migration_version
      end

      private

      def versioned_migrations?
        Rails::VERSION::MAJOR >= 5
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if versioned_migrations?
      end
    end
  end
end
