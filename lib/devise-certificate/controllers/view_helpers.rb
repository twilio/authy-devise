module DeviseCertificate
  module Views
    module Helpers

      def certificate_request_sms_link
        link_to(
          I18n.t('request_sms', {:scope => 'devise'}),
          url_for([resource_name, :request_sms]),
          :id => "certificate-request-sms-link",
          :method => :post,
          :remote => true
        )
      end

      def verify_certificate_form(&block)
        form_tag([resource_name, :verify_certificate], :id => 'devise_certificate', :class => 'certificate-form', :method => :post) do
          buffer = hidden_field_tag(:"#{resource_name}_id", @resource.id)
          buffer << capture(&block)
        end
      end

      def enable_certificate_form(&block)
        form_tag([resource_name, :enable_certificate], :class => 'certificate-form', :method => :post) do
          capture(&block)
        end
      end

      def verify_certificate_installation_form(&block)
        form_tag([resource_name, :verify_certificate_installation], :class => 'certificate-form', :method => :post) do
          capture(&block)
        end
      end
    end
  end
end

