module DeviseAuthy
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseAuthy::Controllers::Helpers
    end
    ActiveSupport.on_load(:action_view) do
      include DeviseAuthy::Views::Helpers
    end

    # extend mapping with after_initialize because it's not reloaded
    config.after_initialize do
      Devise::Mapping.send :include, DeviseAuthy::Mapping
    end
  end
end

