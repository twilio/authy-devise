module DeviseAuthy
  module Generators
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Install the devise authy extension"

      def add_configs
        inject_into_file "config/initializers/devise.rb", "\n  # ==> Devise Authy Authenticator Extension\n  # Configure extension for devise\n\n" +
        "  # Set api key of your application in Authy:\n" +
        "  # config.authy_api_key = 'your-authy-api-key'\n\n" +
        "\n", :before => /end[ |\n|]+\Z/
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise.authy.en.yml"
      end
    end
  end
end