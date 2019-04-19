# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'

module ActionController

end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  def initialize

  end

  def _invoke(method_symbol)
    # ここでメソッドの呼び出しをする
    result = self.send(method_symbol)
    _render_erb
  end

  def yield
    "kokoni今回の描画内容を入れる"
  end

  def _render_erb
    # puts self.class.name

    # レイアウトファイル読み込んだりする

    str = "hoge"
    erb = ERB.new("value = <%= str %>")
    erb.result(binding)
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end