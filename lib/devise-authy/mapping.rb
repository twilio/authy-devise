module DeviseAuthy
  module Mapping
    def self.included(base)
      base.alias_method_chain :default_controllers, :authy_authenticatable
    end

    private
    def default_controllers_with_authy_authenticatable(options)
      options[:controllers] ||= {}
      options[:controllers][:passwords] ||= "devise_authy/passwords"
      default_controllers_without_authy_authenticatable(options)
    end
  end
end