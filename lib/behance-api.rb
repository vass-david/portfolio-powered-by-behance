require 'rest-client'
require 'json'

module PortfolioPoweredByBehance
  class API
    BEHANCE_ROOT_PATH = 'http://www.behance.net/v2/'

    def initialize(opts={})
      raise(ArgumentError, 'Client ID missing') \
        unless opts.include? :client_id

      @debug = opts[:debug]
      @client_id = opts[:client_id]

      log opts
    end

    def get(query, opts={})
      path = BEHANCE_ROOT_PATH + query
      opts.update client_id: @client_id

      log path: path

      JSON.parse RestClient.get path, params: opts
    end

    def user(user)
      get 'users/' + user
    end

    def userProjects(username, opts={})
      get 'users/' + username + '/projects', opts
    end

    def project(id)
      get 'projects/' + id.to_s
    end

    def projects(opts={})
      get 'projects', opts
    end


    private

    def log(opts)
      if @debug
        if opts.is_a? Hash
          opts.each {|k,v| p "#{k}: #{v}"}
        elsif opts.is_a? Array
          opts.each {|i| p i}
        elsif opts.is_a? String
          p opts
        end
      end
    end

  end # class BehanceAPI
end # module PortfolioPoweredByBehance
