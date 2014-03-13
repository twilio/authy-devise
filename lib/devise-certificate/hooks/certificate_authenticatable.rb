Warden::Manager.after_authentication do |user, auth, options|
  if user.respond_to?(:with_certificate_authentication?)
    if auth.session(options[:scope])[:with_certificate_authentication] = user.with_certificate_authentication?(auth.request)
      auth.session(options[:scope])[:id] = user.id
    end
  end
end
