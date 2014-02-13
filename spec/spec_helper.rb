unless ENV['CI']
  require 'simplecov'
  
  SimpleCov.start do
    add_filter 'spec'
    add_filter '.bundle'
  end
end

require 'venice'
require 'rspec'
require 'webmock'

WebMock.allow_net_connect!