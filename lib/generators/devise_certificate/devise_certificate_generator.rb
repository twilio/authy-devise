module DeviseCertificate
  module Generators
    class DeviseCertigicateGenerator < Rails::Generators::NamedBase

      namespace "devise_centeficate"

      desc "Add :certificate_authenticatable directive in the given model, plus accessors. Also generate migration for ActiveRecord"

      def inject_devise_certificate_content
        path = File.join("app","models","#{file_path}.rb")
        if File.exists?(path) &&
          !File.read(path).include?("certificate_authenticatable")
          inject_into_file(path,
                           "certificate_authenticatable, :",
                           :after => "devise :")
        end

        if File.exists?(path) &&
          !File.read(path).include?(":certificate_id")
          inject_into_file(path,
                           ":certificate_id, :last_sign_in_with_certificate, ",
                           :after => "attr_accessible ") 
        end
      end

      hook_for :orm

    end
  end
end
