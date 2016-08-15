module DeviseAuthy
  module Mapping
    private
    def default_controllers(options)
      options[:controllers] ||= {}
      options[:controllers][:passwords] ||= "devise_authy/passwords"
      super
    end
  end
end
