require 'pry'
module Codebreaker_rack
  module Render
    FILE_EXTENSION = '.html.erb'
    DEFAULT_LAYOUT = 'app'
    DEFAULT_FILE = 'index'

    def render_layout(layout, &block)
      file = File.read(file_path('layouts/'+ layout))
      ERB.new(file).result(binding, &block)
    end

    def render_body(file, context, &block)
      file = File.read(file_path(file))
      ERB.new(file).result(context, &block)
    end

    def render(file = 'app/index',context = nil, &block)
      matches = file.match(/([^\/]+)\//)
      layout = matches.nil? ? Render::DEFAULT_LAYOUT : matches[1]
      file = [layout, file].join('/') if matches.nil?
      render_layout(layout) do
        render_body(file, context, &block)
      end
    end

    def file_path(file)
      File.expand_path("views/" + file + FILE_EXTENSION)
    end
  end
end