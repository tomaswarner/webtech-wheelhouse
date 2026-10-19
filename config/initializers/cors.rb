# The price list is read by the personal page, which is served from another
# origin. Only reading is opened, and only for the two origins the page lives on.
# The routes that need the token are not opened to any origin.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://tomaswarner.github.io", "http://localhost:5500"

    resource %r{\A/api/v1/services(/[^/]+)?\z}, headers: :any, methods: [:get, :options]
  end
end
