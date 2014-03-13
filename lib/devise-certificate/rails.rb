module DeviseCertificate
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseCertificate::Controllers::Helpers
    end
    ActiveSupport.on_load(:action_view) do
      include DeviseCertificate::Views::Helpers
    end
  end
end

