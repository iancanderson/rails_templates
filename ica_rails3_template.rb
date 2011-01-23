# ICA RAILS 3 TEMPLATE 01
# By Ian C. Anderson
# Inspired by RailsWizard's output

# example to apply other sub-templates:
# apply "http://gist.github.com/XXXXXX.txt"

# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
  g.stylesheets false
  g.template_engine :haml
  g.test_framework :rspec, :fixture_replacement => :factory_girl
  g.fixture_replacement :factory_girl, :dir => "test/factories"
end
RUBY

def say_recipe(name); say "\033[36m" + "recipe".rjust(10) + "\033[0m" + "    Running #{name} recipe..." end
def say_wizard(text); say "\033[36m" + "wizard".rjust(10) + "\033[0m" + "    #{text}" end

@after_blocks = []
def after_bundler(&block); @after_blocks << block; end

# >---------------------------------[ RSpec ]---------------------------------<

# Use RSpec for unit testing for this Rails app.
say_recipe 'RSpec'

after_bundler do
  generate 'rspec:install'
end

# >--------------------------------[ jQuery ]---------------------------------<

# Adds the latest jQuery and Rails UJS helpers for jQuery.
say_recipe 'jQuery'

inside "public/javascripts" do
  get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "rails.js"
  get "http://code.jquery.com/jquery-1.4.4.js", "jquery/jquery.js"
end

application do
  "\n    config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails)\n"
end

gsub_file "config/application.rb", /# JavaScript.*\n/, ""
gsub_file "config/application.rb", /# config\.action_view\.javascript.*\n/, ""

# >--------------------------------[ Devise ]---------------------------------<

# Utilize Devise for authentication
say_recipe 'Devise'

after_bundler do
  generate 'devise:install'      
  generate 'devise user'
end

inject_into_file "config/environments/development.rb", :after => "  config.action_dispatch.best_standards_support = :builtin\n" do
  "\n# For Devise\n
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

# >---------------------------------[ Gems ]----------------------------------<

say_wizard 'Creating Gemfile'

# Just append the Gemfile so we can generate nicer-looking code by using
# blocks for environment grouping.
append_file 'Gemfile' do <<-END

gem 'will_paginate', '3.0.pre2'
gem "haml", "~> 3.0.21"
gem "devise", '~> 1.1'
gem "cancan", '~> 1.4'

group :test do
  gem "factory_girl_rails", '1.0'
  gem "redgreen"
  gem 'rspec', '2.3.0'
  gem 'webrat', '0.7.1'
  gem 'spork', '0.8.4'
end

group :development do
  gem "nifty-generators"
  gem "rails3-generators"
  gem "haml-rails"
  gem 'rspec-rails', '2.3.0'
  gem 'annotate-models', '1.0.4'
  gem 'faker', '0.3.1'
end
END
end

# >--------------------------------[ Misc. ]---------------------------------<

# Delete unnecessary files
say_wizard("Removing unnecessary files")
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| b.call}

# >-----------------------------[     Git     ]-------------------------------<

# Set up git repository
  git :init

# Add and commit to git
  git :add => ".", :commit => "-am 'initial commit'"

# >-----------------------------[    Heroku   ]-------------------------------<

# Heroku
if yes?("Do you want to deploy to Heroku?")
  run "heroku create"
  git :push => "heroku master"
end
