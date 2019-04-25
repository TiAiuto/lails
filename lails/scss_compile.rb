
# Railsプロジェクトのルート
APP_ROOT = '../rails_tutorial/sample_app/'

# bootstrap.scssなどがあるフォルダ
BOOTSTRAP_SASS_ROOT = '/Users/ayuto.takasaki/.rbenv/versions/2.5.1/lib/ruby/gems/2.5.0/gems/bootstrap-sass-3.3.7/'

# アプリケーション固有のSCSSのファイル名（アセットパイプラインの処理は再現しないため、 `application.css` は無視する）
SCSS_FILENAME = 'custom.scss'

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
  FileUtils.mkdir_p("compiled/#{File.dirname(file)}")
  File.open("compiled/#{file}.css", 'w') { |f|
    f.write engine.render
  }
end

compile SCSS_FILENAME
