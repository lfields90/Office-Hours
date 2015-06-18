require 'rspec'
require 'capybara/rspec'

require_relative '../server.rb'

set :environment, :test

Capybara.app = Sinatra::Application
