module DeviseCertificate
  module Generators
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      class_option :haml, :type => :boolean, :required => false, :default => false, :desc => "Generate views in Haml"
      class_option :sass, :type => :boolean, :required => false, :default => false, :desc => "Generate stylesheet in Sass"

      desc "Install the devise certificate extension"

      def add_configs
        inject_into_file "config/initializers/devise.rb", "\n" +
        "  # ==> Devise Certificate Authentication Extension\n" +
        "  # How long should the user's device be remembered for.\n" +
        "  # config.certificate_remember_device = 1.month\n\n", :before => /^end[\r\n]*$/
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise.certificate.en.yml"
      end

      def copy_views
        if options.haml?
          copy_file '../../../app/views/devise/enable_certificate.html.haml', 'app/views/devise/devise_certificate/enable_certificate.html.haml'
          copy_file '../../../app/views/devise/verify_certificate.html.haml', 'app/views/devise/devise_certificate/verify_certificate.html.haml'
          copy_file '../../../app/views/devise/verify_certificate_installation.html.haml', 'app/views/devise/devise_certificate/verify_certificate_installation.html.haml'
        else
          copy_file '../../../app/views/devise/enable_certificate.html.erb', 'app/views/devise/devise_certificate/enable_certificate.html.erb'
          copy_file '../../../app/views/devise/verify_certificate.html.erb', 'app/views/devise/devise_certificate/verify_certificate.html.erb'
          copy_file '../../../app/views/devise/verify_certificate_installation.html.erb', 'app/views/devise/devise_certificate/verify_certificate_installation.html.erb'
        end
      end

      def copy_assets
        if options.sass?
          copy_file '../../../app/assets/stylesheets/devise_certificate.sass', 'app/assets/stylesheets/devise_certificate.sass'
        else
          copy_file '../../../app/assets/stylesheets/devise_certificate.css', 'app/assets/stylesheets/devise_certificate.css'
        end
        copy_file '../../../app/assets/javascripts/devise_certificate.js', 'app/assets/javascripts/devise_certificate.js'
      end

      def inject_assets_in_layout
        {
          :haml => {
            :before => %r{%body\s*$},
            :content => %@
    =javascript_include_tag "https://www.certificate.com/form.certificate.min.js"
    =stylesheet_link_tag "https://www.certificate.com/form.certificate.min.css"
    =javascript_include_tag "devise_certificate.js"
@
          },
          :erb => {
            :before => %r{\s*</\s*head\s*>\s*},
            :content => %@
  <%=javascript_include_tag "https://www.certificate.com/form.certificate.min.js" %>
  <%=stylesheet_link_tag "https://www.certificate.com/form.certificate.min.css" %>
  <%=javascript_include_tag "devise_certificate.js" %>
@
          }
        }.each do |extension, opts|
          file_path = "app/views/layouts/application.html.#{extension}"
          if File.exists?(file_path) && !File.read(file_path).include?("devise_certificate.js")
            inject_into_file(file_path, opts.delete(:content), opts)
          end
        end
      end
    end
  end
end
