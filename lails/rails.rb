class EnvConfig
  # とりあえずダミー
  def development?
    true
  end
end

class Routes
  def get(path, options = {})
    _define_path_helper(path, path)
  end

  def root(path, options = {})
    _define_path_helper('root', '/')
  end

  def post(path, options = {})
    _define_path_helper(path, path)
  end

  def delete(path, options = {})
    _define_path_helper(path, path)
  end

  def resources(path, options = {})
    _define_path_helper(path, path)
  end

  def _define_path_helper(path, url)
    method_name = (path.to_s).split("/").reject {|item| item == ""}.join("_") + "_path"
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

  @config = EnvConfig.new

  def self.env
    @config
  end

  class << self
    def application
      @rails_application
    end
  end
end
