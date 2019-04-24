# もらいもの
class String
  def camelize
    self.split("_").map { |w| w[0] = w[0].upcase; w }.join
  end

  def underscore
    self
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
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

class EnvConfig
  # とりあえずダミー
  def development?
    true
  end

  def test?
    false
  end
end

class Routes
  def extract_controller_info(path, options)
    to = options[:to]
    # ToDo: 名前空間などの実装は対応していない
    parts = []
    if to
      parts = to.split("#").reject { |item| item == '' }
    else
      parts = path.split("/").reject { |item| item == '' }
    end
    controller_name = parts[0].camelize
    { name: controller_name + 'Controller', method_name: parts[-1] }
  end

  def get(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'get', extract_controller_info(path, options))
  end

  def root(path, options = {})
    _define_path_helper('root', '/')
    Rails._register_route('/', 'get', extract_controller_info(path, options.merge(to: path)))
  end

  def post(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'post', extract_controller_info(path, options))
  end

  def delete(path, options = {})
    _define_path_helper(path, path)
    Rails._register_route(path, 'delete', extract_controller_info(path, options))
  end

  def resources(path, options = {})
    _define_path_helper(path, path)
  end

  def _define_path_helper(path, url)
    method_name = (path.to_s).split("/").reject { |item| item == "" }.join("_") + "_path"
    puts "#{method_name} 自動登録"
    # 本当にこの実装でいいのか調べる
    Rails.define_method method_name.to_s do
      url
    end
  end

  # ここで登録処理をする
  def draw(&block)
    self.instance_eval &block
  end
end

# ここもダミー
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

    def _register_route(path, method, controller_info)
      if path[0] != '/'
        path = '/' + path # ToDo: 仮対応
      end
      route = { path: path, method: method, controller_info: controller_info }
      puts "route割り当て登録 #{route}"
      @routes << route
    end

    def _find_route(path, method)
      @routes.find { |item| item[:path] == path && item[:method].downcase == method.downcase }
    end
  end
end

class Rails::Engine

end
