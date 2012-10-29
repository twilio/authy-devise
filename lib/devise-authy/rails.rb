module DeviseAuthy
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseAuthy::Controllers::Helpers
    end
  end
end
