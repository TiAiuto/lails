# もらいもの
class String
  # キャメルケースに変換する
  def camelize
    self.split("_").map { |w| w[0] = w[0].upcase; w }.join
  end

  # スネークケースに変換する
  def underscore
    self
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end

  def pluralize
    self + "s" # 仮実装
  end
end

# もらいもの
class Class
  def subclasses
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == self}
  end
end

class Object
  def empty?
    self == ''
  end

  def blank?
    self.nil? || self.empty?
  end

  def present?
    !self.blank?
  end
end

class Hash
  def symbolize_keys
    self.map { |k, v| [k.to_sym, v] }.to_h
  end
end

# 勝手に定義したクラス
class EnvConfig
  # ダミー
  def development?
    true
  end

  def test?
    false
  end
end

class Routes
  # `get 'sessions/new' `, `get '/help', to: 'static_pages#help'`
  # のそれぞれの形式のルーティングから、コントローラ名とメソッド名を抽出する
  def _extract_controller_action(path, options)
    # ToDo: 名前空間などの実装は対応していない
    to    = options[:to]
    parts =
      if to
        to.split("#").reject { |item| item == '' }
      else
        path.split("/").reject { |item| item == '' }
      end
    { controller_name: "#{parts[0].camelize}Controller", controller_method_name: parts[-1] }
  end

  # コントローラ名、メソッド名から、`help_path` のようにヘルパーを生成していく
  def _define_path_helper(path, url)
    # 本当にこの実装でいいのかはわからない
    # ToDo: 正しく変換されないページがあったら直す
    method_name = (path.to_s).split("/").reject { |item| item == "" }.join("_") + "_path"
    puts "#{method_name} 自動登録"
    Rails._register_path_helper method_name.to_s, url
  end

  def get(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'get', _extract_controller_action(path, options))
  end

  def root(path, options = {})
    _define_path_helper('root', '/')
    Rails._register_route('/', 'get', _extract_controller_action(path, options.merge(to: path)))
  end

  def post(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'post', _extract_controller_action(path, options))
  end

  def delete(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'delete', _extract_controller_action(path, options))
  end

  def resources(path, options = {})
    # ToDo: 実装
    _define_path_helper(path, path)
  end

  # ここで登録処理をする（ `routes.rb` を読み込んだら自動で登録される）
  def draw(&block)
    self.instance_eval &block
  end
end

# ダミー
class RailsApplication
  attr_reader :routes

  def initialize
    @routes = Routes.new
  end
end

module Rails
  @rails_application = RailsApplication.new
  @config            = EnvConfig.new
  @routes            = []

  def self.env
    @config
  end

  class << self
    def application
      @rails_application
    end

    def _register_route(path, method, action)
      if path[0] != '/'
        path = '/' + path # ToDo: 仮対応
      end
      route = { path: path, method: method, action: action }
      puts "route割り当て登録 #{route}"
      @routes << route
    end

    def _find_route(path, method)
      @routes.find { |item| item[:path] == path && item[:method].downcase == method.downcase }
    end

    def _register_path_helper(name, url)
      define_method name do
        url
      end
    end
  end
end

# bootstrap-sass でこれがないとエラーになる
class Rails::Engine
end
