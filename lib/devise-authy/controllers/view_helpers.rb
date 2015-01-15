module DeviseAuthy
  module Views
    module Helpers
      def authy_request_phone_call_link
        link_to(
          I18n.t('request_phone_call', { :scope => 'devise' }),
          url_for([resource_name, :request_phone_call]),
          :id => "authy-request-phone-call-link",
          :method => :post,
          :remote => true
        )
      end

      def authy_request_sms_link
        link_to(
          I18n.t('request_sms', {:scope => 'devise'}),
          url_for([resource_name, :request_sms]),
          :id => "authy-request-sms-link",
          :method => :post,
          :remote => true
        )
      end

      def verify_authy_form(opts={}, &block)
        opts = default_opts.merge(:id => 'devise_authy').merge(opts)
        form_tag([resource_name, :verify_authy], opts) do
          buffer = hidden_field_tag(:"#{resource_name}_id", @resource.id)
          buffer << capture(&block)
        end
      end

      def enable_authy_form(opts={}, &block)
        opts = default_opts.merge(opts)
        form_tag([resource_name, :enable_authy], opts) do
          capture(&block)
        end
      end

      def verify_authy_installation_form(opts={}, &block)
        opts = default_opts.merge(opts)
        form_tag([resource_name, :verify_authy_installation], opts) do
          capture(&block)
        end
      end

      private

      def default_opts
        { :class => 'authy-form', :method => :post }
      end
    end
  end
end

