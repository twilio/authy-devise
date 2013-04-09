module DeviseAuthy
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseAuthy::Controllers::Helpers
    end
    ActiveSupport.on_load(:action_view) do
      include DeviseAuthy::Views::Helpers
    end
  end
end

