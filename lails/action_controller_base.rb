# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'

module ActionController

end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  def _invoke(method_symbol)
    # ここでメソッドの呼び出しをする

    result = self.send(method_symbol)
    str = "hoge"
    erb = ERB.new("value = <%= str %>")
    puts erb.result(binding)
  end

  def _render_erb
    
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end