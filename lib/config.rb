require 'yaml'

module PortfolioPoweredByBehance
  class Config
    def initialize config_path
      @defaults = {
      }
      @redis_defaults = {
        'prefix' => 'portfolio:',
        'db' => 1,
      }
      @rendering_defaults = {
        'css_prefix' => '.behance-project'
      }

      @config = @defaults.update YAML.load_file config_path
      @config['redis'] ||= {}
      @config['redis'] = @redis_defaults.update @config['redis']
      @config['rendering'] ||= {}
      @config['rendering'] = @rendering_defaults.update @config['rendering']
    end

    def [](key)
      @config[key]
    end
  end
end # module PortfolioPoweredByBehance
