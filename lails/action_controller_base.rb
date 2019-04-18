# ここではControllerのsuperの役割を果たすコードを書く

module ActionController

end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  def _invoke(method_name)

  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end