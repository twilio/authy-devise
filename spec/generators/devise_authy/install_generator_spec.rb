# frozen_string_literal: true
require "generators/devise_authy/install_generator"

RSpec.describe DeviseAuthy::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  after(:all) do
    prepare_destination
  end

  def prepare_app
    FileUtils.mkdir_p(File.join(destination_root, "config", "initializers"))
    File.open(File.join(destination_root, "config", "initializers", "devise.rb"), "w") do |file|
      file << "Devise.setup do |config|\n\nend"
    end
  end

  def prepare_html_layout
    FileUtils.mkdir_p(File.join(destination_root, "app", "views", "layouts"))
    File.open(File.join(destination_root, "app", "views", "layouts", "application.html.erb"), "w") do |file|
      file << "<html><head><title>Application</title></head><body></body></html>"
    end
  end

  describe "with no arguments" do
    before(:all) do
      prepare_destination
      prepare_app
      prepare_html_layout
      run_generator
    end

    it "copies across the locale file" do
      expect(destination_root).to have_structure {
        directory "config" do
          directory "locales" do
            file "devise.authy.en.yml" do
              contains "Two factor authentication was enabled"
            end
          end
        end
      }
    end

    it "injects devise config" do
      devise_config = File.read(File.join(destination_root, "config", "initializers", "devise.rb"))
      expect(devise_config).to match("Devise Authy Authentication Extension")
      expect(devise_config).to match("# config.authy_remember_device = 1.month")
      expect(devise_config).to match("# config.authy_enable_onetouch = false")
      expect(devise_config).to match("# config.authy_enable_qr_code = false")
    end

    it "creates an authy initializer" do
      expect(destination_root).to have_structure {
        directory "config" do
          directory "initializers" do
            file "authy.rb" do
              contains "Authy.api_key = ENV[\"AUTHY_API_KEY\"]\n"
              contains "Authy.api_uri = \"https://api.authy.com/\""
            end
          end
        end
      }
    end

    it "copies over the HTML views" do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "views" do
            directory "devise" do
              directory "devise_authy" do
                file "enable_authy.html.erb"
                file "verify_authy_installation.html.erb"
                file "verify_authy.html.erb"
              end
            end
          end
        end
      }
    end

    it "copies over the CSS and JS assets" do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "assets" do
            directory "stylesheets" do
              file "devise_authy.css"
            end
            directory "javascripts" do
              file "devise_authy.js"
            end
          end
        end
      }
    end

    it "injects JS and CSS into the head of the application layout" do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "views" do
            directory "layouts" do
              file "application.html.erb" do
                contains "<%=javascript_include_tag \"https://www.authy.com/form.authy.min.js\" %>"
                contains "<%=stylesheet_link_tag \"https://www.authy.com/form.authy.min.css\" %>"
              end
            end
          end
        end
      }
    end
  end

  describe "with haml views" do
    before(:all) do
      prepare_destination
      prepare_app
      prepare_html_layout
      run_generator %w(--haml)
    end

    it "copies over the HAML views" do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "views" do
            directory "devise" do
              directory "devise_authy" do
                file "enable_authy.html.haml"
                file "verify_authy_installation.html.haml"
                file "verify_authy.html.haml"
              end
            end
          end
        end
      }
    end
  end

  describe "with sass" do
    before(:all) do
      prepare_destination
      prepare_app
      prepare_html_layout
      run_generator %w(--sass)
    end

    it "copies over SASS and JS assets" do
      expect(destination_root).to have_structure {
        directory "app" do
          directory "assets" do
            directory "stylesheets" do
              file "devise_authy.sass"
            end
            directory "javascripts" do
              file "devise_authy.js"
            end
          end
        end
      }
    end
  end
end