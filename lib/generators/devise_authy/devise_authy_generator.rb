module DeviseAuthy
	module Generators
		class DeviseAuthyGenerator < Rails::Generators::NamedBase

			namespace "devise_authy"

			desc "Add :authy_authenticatable directive in the given model, plus accessors. Also generate migration for ActiveRecord"

			def inject_devise_authy_content
				path = File.join("app","models","#{file_path}.rb")
				inject_into_file(path, "authy_authenticatable, :", :after => "devise :") if File.exists?(path)
				inject_into_file(path, ":authy_id, :last_sign_in_with_authy", :after => "attr_accessible :") if File.exists?(path)
			end

			hook_for :orm

		end
	end
end