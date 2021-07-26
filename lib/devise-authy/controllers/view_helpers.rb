module DeviseAuthy
  module Views
    module Helpers
      def authy_request_phone_call_link(opts = {})
        title = opts.delete(:title) do
          I18n.t('request_phone_call', scope: 'devise')
        end
        opts = {
          :id => "authy-request-phone-call-link",
          :method => :post,
          :remote => true
        }.merge(opts)

        link_to(
          title,
          url_for([resource_name.to_s.to_sym, :request_phone_call]),
          opts
        )
      end

      def authy_request_sms_link(opts = {})
        title = opts.delete(:title) do
          I18n.t('request_sms', scope: 'devise')
        end
        opts = {
          :id => "authy-request-sms-link",
          :method => :post,
          :remote => true
        }.merge(opts)

        link_to(
          title,
          url_for([resource_name.to_s.to_sym, :request_sms]),
          opts
        )
      end

      def verify_authy_form(opts = {}, &block)
        opts = default_opts.merge(:id => 'devise_authy').merge(opts)
        form_tag([resource_name.to_s.to_sym, :verify_authy], opts) do
          buffer = hidden_field_tag(:"#{resource_name}_id", @resource.id)
          buffer << capture(&block)
        end
      end

      def enable_authy_form(opts = {}, &block)
        opts = default_opts.merge(opts)
        form_tag([resource_name.to_s.to_sym, :enable_authy], opts) do
          capture(&block)
        end
      end

      def verify_authy_installation_form(opts = {}, &block)
        opts = default_opts.merge(opts)
        form_tag([resource_name.to_s.to_sym, :verify_authy_installation], opts) do
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
