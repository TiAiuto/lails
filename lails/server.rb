require '../lails/rails'

require '../rails_tutorial/sample_app/app/helpers/application_helper'

require '../lails/active_record_base'
require '../lails/action_controller_base'

require '../rails_tutorial/sample_app/app/models/application_record'
require '../rails_tutorial/sample_app/app/models/user'

# 本当はここで入れるんじゃない
require '../rails_tutorial/sample_app/app/helpers/sessions_helper'

require '../rails_tutorial/sample_app/app/controllers/application_controller'
require '../rails_tutorial/sample_app/app/controllers/users_controller'
require '../rails_tutorial/sample_app/app/controllers/static_pages_controller'
require '../rails_tutorial/sample_app/app/controllers/sessions_controller'

require '../rails_tutorial/sample_app/config/routes'

require 'webrick'
require 'yaml'

# Railsプロジェクトのルート
APP_ROOT = '../rails_tutorial/sample_app/'
# コンパイル済みのSCSSファイルのファイル名
COMPILED_CSS_FILENAME = 'custom.scss.css'

# Railsの中で help_path などのヘルパーを定義しているのでincludeしておく
include Rails

srv = WEBrick::HTTPServer.new(
  {
    DocumentRoot: './',
    BindAddress:  '0.0.0.0',
    Port:         '8080',
  }
)

# webrickのqueryをRailsのparamsの形式に変換する
def convert_query_to_params(query)
  params = {}
  query.each do |raw_key, value|
    current_obj = params
    key_names   = raw_key
                    .split("[").map { |item| item.gsub(/]/, "") }
    key_names.each.with_index do |key_s, index|
      key = key_s.to_sym
      if index == key_names.size - 1
        # 最後のときは代入する
        current_obj[key] = value
      else
        # それ以外のときは下に潜る
        unless current_obj[key]
          current_obj[key] = {}
        end
        current_obj = current_obj[key]
      end
    end
  end
  params
end

srv.mount_proc '/' do |req, res|
  # コールバックの中で処理を中止したい場合ここに飛ぶ
  # ToDo: トランザクションの中止
  catch :abort do
    path   = req.path.gsub(/\.\./, '') # 脆弱性になるので排除する
    method = req.request_method

    # path, methodを使って、登録済みのルーティングから検索する
    puts "route検索 #{path} #{method}"
    # ToDo: :idなど対応できるよう直す
    route = Rails._find_route(path, method)
    if route
      puts "routeヒット #{route}"
      # 登録されているルーティングから情報を検索する
      action = route[:action]
      # コントローラのクラスを取得する
      controller = Object.const_get(action[:controller_name].to_sym).new
      params     = convert_query_to_params(req.query)
      puts "パラメータ：#{params}"
      controller.params = params
      # コントローラ側のメソッドを呼び出し、結果を取得する
      result = controller._invoke(action[:controller_method_name].to_sym)
      if result[:type] == :rendered
        res.body = result[:content]
      else
        fail "実行結果の返却方法が未実装"
      end
    else
      # 登録済みのルーティングから見つからない場合に静的リソースのリクエストの可能性を疑う
      if path.match /^\/assets\//
        unless method == "GET"
          fail "リソースはGET専用"
        end
        begin
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
          next
        rescue Errno::ENOENT, Errno::EACCES # ファイルが存在しない、または権限がない
          # 404
        end
      else
        # 404
      end
      puts '404'
      res.status = 404
    end
  end
end

srv.start
