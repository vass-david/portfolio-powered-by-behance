require 'redis'
require 'json'
require 'open-uri'
require 'fileutils'

require_relative './behance-api.rb'

module PortfolioPoweredByBehance
  class Cache
    attr_reader :projects, :project_details, :user, :username

    def initialize(opts={})
      @redis = Redis.new(
        host: opts[:host],
        port: opts[:port],
        db: opts[:db]
      )
      @prefix = opts[:prefix]
      @images = opts[:images]

      @behance = API.new client_id: opts[:client_id]

      raise(ArgumentError, 'Username or user id missing') \
        unless opts.include? :user
      @username = opts[:user]

      @project_details = {}
    end

    def get
      get_user
      get_projects
      get_all_project_details
    end

    def get_user
      user = @redis.get(@prefix + 'user')
      unless user.nil? or user.empty?
        @user = JSON.parse(user) unless user.nil? or user.empty?
      else
        fetch_user! && save_user!
        @user
      end
    end

    def get_projects
      projects = @redis.hgetall @prefix + 'projects'

      unless projects.nil? or projects.empty?
        @projects = projects.map {|k,v| JSON.parse(v)}
      else
        fetch_projects! && save_projects!
        @projects
      end
    end

    def get_project_details(id)
      detail = @redis.get project_details_key(id)

      unless detail.nil? or detail.empty?
        @project_details[id] = JSON.parse(detail)
      else
        fetch_project_details!(id) && save_project_details!(id)
        @project_details[id]
      end
    end

    def get_all_project_details
      if @projects.nil? or @projects.empty?
        get_projects
      end

      ids = @projects.map {|p| p['id'] }

      @redis.pipelined do
        ids.each do |id|
          get_project_details(id)
        end
      end
    end

    def fetch
      fetch_user!
      fetch_projects!
      fetch_project_details!
    end

    def fetch_user!
      @user = @behance.user @username
    end

    def fetch_projects!
      @projects = []
      page_n = 0
      begin
        page_n += 1
        page = @behance.userProjects(@username, page: page_n)['projects']
        @projects += page
      end while !page.empty?

      return @projects
    end

    def fetch_project_details!(id)
      @project_details[id] = @behance.project(id)['project']
    end

    def fetch_all_project_details!
      @projects.each do |p|
        fetch_project_details! p['id']
      end
    end

    def save_user!
      flush_user!

      @redis.set key('user'), @user.to_json
    end

    def save_projects!
      flush_projects!
      projects = []
      @projects.each do |p|
        projects << [p['id'], p.to_json]
      end

      @redis.hmset key('projects'), *projects.flatten
    end

    def save_project_details!(id)
      if @images
        download_project_images!(id)
      end
      @redis.set project_details_key(id), @project_details[id].to_json
    end

    def save_all_project_details!
      @redis.pipelined do
        @project_details.each do |id, p|
          save_project_details!(id)
        end
      end
    end

    def download_project_images!(id)
      project = @project_details[id]

      @images['covers'].each do |size|
        project['covers_local'] ||= {}
        project['covers_local'][size.to_s] = download_image(
          image_path("#{id}/covers", "#{size}-#{project['covers'][size.to_s].split('/').last}"),
          project['covers'][size.to_s]
        )
      end if @images.include? 'covers'

      if @images['content'] != false
        background = project['styles']['background']
        project['styles']['background']['image']['local_url'] = download_image(
          image_path(
            "#{id}/content", "background-#{background['image']['url'].split('/').last}"
          ), background['image']['url']
        ) if background.include? 'image'

        project['modules'].map! do |m|
          m['local_src'] = download_image(
            image_path("#{id}/content", "background-#{m['src'].split('/').last}"),
            m['src']
          ) if m['type'] == 'image'

          m
        end
      end

      @project_details[id] = project
    end

    private

    def download_image(filepath, image_url)
      dir = File.dirname(filepath)
      FileUtils::mkdir_p dir unless File.directory?(dir)
      open filepath, 'wb' do |file|
        file << open(image_url).read
      end

      "/#{Pathname.new(filepath).relative_path_from(
        Pathname.new(File.join ROOT, 'public'))}"
    end

    def image_path(dir, filename)
      File.join(ROOT, @images['dir'], dir, filename)
    end

    def project_details_key(id)
      "#{@prefix}project:#{id}:details"
    end

    def key(name)
      @prefix ? "#{@prefix}#{name}" : name
    end

    def flush_projects!
      ids = @redis.hkeys(key('projects')).map { |id| project_details_key(id) }
      unless ids.nil? or ids.empty?
        @redis.pipelined do
          @redis.del *ids
          @redis.del key('projects')
        end
      end
    end

    def flush_user!
      @redis.del 'user'
    end

  end # class BehanceCache
end # module PortfolioPoweredByBehance
