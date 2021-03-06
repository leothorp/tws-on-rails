# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require "cancan/matchers"
require 'shoulda/matchers'
require 'factory_bot_rails'

#Coveralls Test Coverage
require 'coveralls'
Coveralls.wear!

load Rails.root + "db/seeds_test.rb"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Include FactoryBot in specs
  config.include FactoryBot::Syntax::Methods

  # Include devise test helpers in controller specs
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include IntegrationHelpers, :type => :feature

  #rspec-rails 3 will no longer automatically infer an example group's spec type
  #from the file location. You can explicitly opt-in to this feature using this
  #snippet:
  config.infer_spec_type_from_file_location!

  config.before(:all) { ActiveRecord::Base.skip_callbacks = true }
  config.before(:each) { ActionMailer::Base.deliveries.clear }

  config.after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

Shoulda::Matchers.configure do |config|
	config.integrate do |with|
		with.test_framework :rspec
		with.library :rails
	end
end
