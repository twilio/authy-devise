# frozen_string_literal: true

module DeviseAuthy
  module Generators
    class DeviseAuthyGenerator < Rails::Generators::NamedBase

      namespace "devise_authy"

      desc "Add :authy_authenticatable directive in the given model, plus accessors. Also generate migration for ActiveRecord"

      def inject_devise_authy_content
        path = File.join(destination_root, "app","models","#{file_path}.rb")
        if File.exists?(path) &&
          !File.read(path).include?("authy_authenticatable")
          inject_into_file(path,
                           "authy_authenticatable, :",
                           :after => "devise :")
        end

        if File.exists?(path) &&
          !File.read(path).include?(":authy_id")
          inject_into_file(path,
                           ":authy_id, :last_sign_in_with_authy, ",
                           :after => "attr_accessible ")
        end
      end

      hook_for :orm

    end
  end
end
