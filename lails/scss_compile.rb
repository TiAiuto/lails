
require '../lails/config'
require '../lails/rails'

require 'fileutils'
require 'sassc'
require 'jquery-rails'


def compile(file)
  path = APP_ROOT + 'app/assets/stylesheets'
  FileUtils.rm_rf('.sass-cache', secure: true)
  engine = SassC::Engine.new(
    %Q{@import "#{path}/#{file}"},
    syntax: :scss, load_paths: ["#{BOOTSTRAP_SASS_ROOT}assets/stylesheets/"]
  )
  FileUtils.mkdir_p("tmp/#{File.dirname(file)}")
  File.open("tmp/#{file}.css", 'w') { |f|
    f.write engine.render
  }
end

compile SCSS_FILENAME
