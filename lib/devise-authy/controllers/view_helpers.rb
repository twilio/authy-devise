module DeviseAuthy
  module Views
    module Helpers
      
      def authy_request_sms_link
        link_to(
          I18n.t('request_sms', {:scope => 'devise'}),
          url_for([resource_name, :request_sms]),
          :id => "authy-request-sms-link",
          :method => :post,
          :remote => true
        )
      end
    end
  end
end

