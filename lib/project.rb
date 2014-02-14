# encoding: utf-8

require 'slim'

module PortfolioPoweredByBehance
  class Project
    def initialize(data, opts={})
      data.each do |k, v|
        instance_variable_set('@'+k, v)
        Project.class_eval{attr_reader k.to_sym}
      end

      @opts = opts
      @stylesheet = parse_style
      @markup = Slim::Template.new(
        File.join(VIEWS, 'project.slim')
      ).render(self, {project: self})
    end

    attr_reader :stylesheet, :markup

    private

    def parse_style
      project_class = ''
      content_class = ''
      module_class = ''
      text_styles = ''

      @styles['background'].each do |k, v|
        case k
        when 'image'
          project_class += "background-image: url(#{v['url']});"
          project_class += "background-repeat: #{v['repeat']};"
          project_class += "background-position: #{v['position']};"
        when 'color'
          project_class += "background-color: ##{v};"
        end
      end

      # behance illogical names
      params = {
        'top_margin' => 'margin-top',
        'bottom_margin' => 'margin-bottom',
      }
      
      @styles['spacing']['project'].each {|k, v| content_class += "#{params[k]}: #{v}px;"}
      @styles['spacing']['modules'].each {|k, v| module_class += "#{params[k]}: #{v}px;"}

      # behance aliases
      tags = {
        'title'     => 'h2',
        'subtitle'  => 'h3',
        'paragraph' => 'p',
        'caption'   => '.caption',
        'link'      => 'a',
      }

      @styles['text'].each do |k, v|
        params = ''
        v.each {|k, v| params += "#{k.sub('_','-')}: #{v};" }
        text_styles += "#{@opts['css_prefix']} .content .module #{tags[k]} {#{params}} "
      end

      p = @styles['text']['paragraph']
      project_class += "font-family:#{p['font_family']};"
      project_class += "font-size:#{p['font_size']};"
      project_class += "font-weight:#{p['font_weight']};"
      project_class += "font-style:#{p['font_style']};"
      project_class += "line-height:#{p['line_height']};"
      project_class += "color:#{p['color']};"

      "#{@opts['css_prefix']} .content-wrapper {#{project_class}} #{@opts['css_prefix']} .content-wrapper .content {#{content_class}} #{@opts['css_prefix']} .content-wrapper .content .module {#{module_class}} #{text_styles}"
    end # def parse_style

  end # class Project
end # module PortfolioPoweredByBehance
