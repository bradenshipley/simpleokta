require "simpleokta/version"
require "simpleokta/configuration"
require "faraday"

# @author Braden Shipley
module Simpleokta
  extend self
  attr_accessor :configuration

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Client
    require 'faraday'
    require 'json'
    require 'erb'
    include Apps
    include AuthServers
    include Groups
    include Constants
    include SystemLogs
    include Users

    attr_accessor :api_token, :base_api_url

    # Initialize using passed in config hash
    # @param config [Hash]
    def initialize(config)
      @api_token = config.api_token
      @base_api_url = config.base_api_url
    end

    # Setting initial connection with base_api_url from config
    def connection
      @conn ||= Faraday.new(@base_api_url)
    end

    # This method will add our api_token to each authorization header to keep our code D.R.Y
    # @param action [String] the HTTP verb we are sending our request with.
    #   IE: 'get', 'post', 'put', 'delete'
    # @param url [String] the URL to send the request to.
    # @param body [Hash] the request body, set to an empty hash by default.
    #   Each request may require a different body schema.
    def call_with_token(action, url, body={})
      connection.send(action) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Authorization'] = "SSWS #{@api_token}"
        req.body = body
      end
    end
  end
  class Error < StandardError; end
end
