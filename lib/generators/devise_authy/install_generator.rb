module DeviseAuthy
  module Generators
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      class_option :haml, :type => :boolean, :required => false, :default => false, :desc => "Generate views in Haml"
      class_option :sass, :type => :boolean, :required => false, :default => false, :desc => "Generate stylesheet in Sass"

      desc "Install the devise authy extension"

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise.authy.en.yml"
      end

      def copy_views
        if options.haml?
          copy_file '../../../app/views/devise/enable_authy.html.haml', 'app/views/devise/devise_authy/enable_authy.html.haml'
          copy_file '../../../app/views/devise/verify_authy.html.haml', 'app/views/devise/devise_authy/verify_authy.html.haml'
        else
          copy_file '../../../app/views/devise/enable_authy.html.erb', 'app/views/devise/devise_authy/enable_authy.html.erb'
          copy_file '../../../app/views/devise/verify_authy.html.erb', 'app/views/devise/devise_authy/verify_authy.html.erb'
        end
      end

      def copy_assets
        if options.sass?
          copy_file '../../../app/assets/stylesheets/devise_authy.sass', 'app/assets/stylesheets/devise_authy.sass'
        else
          copy_file '../../../app/assets/stylesheets/devise_authy.css', 'app/assets/stylesheets/devise_authy.css'
        end
      end
    end
  end
end
