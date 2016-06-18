
module Madness

  # The base class for the sinatra server. 
  # Initialize what we can here, but since there are values that will 
  # become known only later, the #prepare method is provided.
  class ServerBase < Sinatra::Application
    helpers ServerHelper

    # Since we cannot use any config values in the main body of the class,
    # since they will be updated later, we need to set anything that relys 
    # on the config values just before running the server. 
    # The CommandLine class and the test suite should both call 
    # `Server.prepare` before calling Server.run!
    def self.prepare
      # Sass::Plugin.options[:template_location] = styles_path
      p styles_path
      Sass::Plugin.add_template_location styles_path
      Sass::Plugin.options[:css_location] = 'app/public/css'
      Slim::Engine.set_options pretty: true

      set :views, views_path
      set :bind, config.bind
      set :port, config.port      
      set :public_folder, File.expand_path('../../app/public', __dir__)

      use Sass::Plugin::Rack
      use Rack::TryStatic, :root => "#{config.path}/public/", :urls => %w[/]
    end

    def self.config
      Settings.instance
    end

    def self.views_path
      if config.views.is_a? Symbol
        File.expand_path("../../app/#{config.views}/views", __dir__)
      else
        File.expand_path(config.views, config.path)
      end
    end

    def self.styles_path
      if config.styles.is_a? Symbol
        "app/#{config.styles}/styles"
      else
        File.expand_path(config.styles, config.path)
      end
    end
  end

end