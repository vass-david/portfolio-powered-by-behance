require_relative './config.rb'
require_relative './cache.rb'
require_relative './project.rb'

module PortfolioPoweredByBehance
  ROOT = File.expand_path '.'
  LIB_ROOT = File.dirname(__FILE__)
  CONFIG_PATH = File.join ROOT, 'config', 'behance.yml'
  VIEWS = File.join LIB_ROOT, 'views'

  class Portfolio
    def initialize
      @config = Config.new CONFIG_PATH

      @cache = Cache.new(
        user: @config['user'],
        client_id: @config['client_id'],
        host: @config['redis']['host'],
        port: @config['redis']['port'],
        db: @config['redis']['db'],
        prefix: @config['redis']['prefix'],
        debug: @config['debug'],
      )
    end

    attr_reader :cache

    def user
      @cache.get_user
    end

    def projects
      @cache.get_projects
    end

    def project_details(id)
      Project.new @cache.get_project_details(id), @config['rendering']
    end

    def do_all_the_stuff
      c = self.cache
      c.fetch_projects!
      c.fetch_all_project_details!
      c.save_projects!
      c.save_all_project_details!
    end

  end # class Portfolio

end # module PortfolioPoweredByBehance
