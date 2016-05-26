require 'erb'
module Codebreaker_rack
  class Page
    FILE_EXTENSION = '.html.erb'
    attr_reader :template, :layout, :page

    def initialize(template, context = {})
      @template = template
      @layout, @page = parse(template)
      context.each { |var,value| instance_variable_set("@#{var}", value)}
    end

    def render
      render_layout {render_body}
    end

    alias to_str render
    alias to_s render

    def render_layout
      file = File.read(file_path('layouts/'+ layout))
      ERB.new(file).result(binding)
    end

    def render_body
      file = File.read(file_path(template))
      ERB.new(file).result(binding)
    end

    def file_path(file)
      File.expand_path("views/" + file + FILE_EXTENSION)
    end

    private
    def parse(file)
      matches = file.match(/([^\/]+)\/(.*)/)
      matches[1..2] unless matches.nil?
    end
  end
end
