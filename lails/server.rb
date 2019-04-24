require '../lails/rails'

require '../../rails_tutorial/sample_app/app/helpers/application_helper'

require '../lails/active_record_base'
require '../lails/action_controller_base'

require '../../rails_tutorial/sample_app/app/models/application_record'
require '../../rails_tutorial/sample_app/app/models/user'

# 本当はここで入れるんじゃない
require '../../rails_tutorial/sample_app/app/helpers/sessions_helper'

require '../../rails_tutorial/sample_app/app/controllers/application_controller'
require '../../rails_tutorial/sample_app/app/controllers/users_controller'
require '../../rails_tutorial/sample_app/app/controllers/static_pages_controller'
require '../../rails_tutorial/sample_app/app/controllers/sessions_controller'

require '../../rails_tutorial/sample_app/config/routes'

require 'webrick'

APP_ROOT = '../../rails_tutorial/sample_app/'
BOOTSTRAP_SASS_ROOT = '/Users/ayuto.takasaki/.rbenv/versions/2.5.1/lib/ruby/gems/2.5.0/gems/bootstrap-sass-3.3.7/'

### bootstrap-sass を使ってSCSSをコンパイルする

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
compile 'custom.scss'

### SCSSのコンパイルここまで

include Rails

def find_route(path, method)
  # ToDo: :idなど対応できるよう直す
  puts "route検索 #{path} #{method}"
  Rails._find_route(path, method)
end

srv = WEBrick::HTTPServer.new(
  {
    DocumentRoot: './',
    BindAddress:  '0.0.0.0',
    Port:         '8080',
  }
)


srv.mount_proc '/' do |req, res|
  catch :abort do
    path = req.path.gsub(/\.\./, '') # 脆弱性になるので排除する
    route = find_route(path, req.request_method)
    unless route
      if path.match /^\/assets\//
        if path.match /^\/assets\/css/
          puts 'CSSファイル送信'
          # リクエストされたCSSファイルを返す
          File.open("compiled/#{path.gsub(/^\/assets\/css/, '')}", "r") do |file|
            res.body = file.read
          end
        else
          puts 'リソース送信'
          res.body = File.binread("#{APP_ROOT}app/assets/images#{path.gsub(/^\/assets\/img/, '')}")
        end
      end
      next
    end
    puts "routeヒット #{route}"
    controller_info        = route[:controller_info]
    controller_name        = controller_info[:name]
    controller_method_name = controller_info[:method_name]
    # コントローラのクラスを取得する
    controller             = Object.const_get(controller_name.to_sym).new
    # コントローラ側のメソッドを呼び出し、描画内容を取得する
    res.body               = controller._invoke(controller_method_name.to_sym)
  end
end

srv.start
