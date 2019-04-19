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

  def _render_erb
    # puts self.class.name

    # レイアウトファイル読み込んだりする

    Dir.chdir "../../rails_tutorial/sample_app/app/views/" do
      erb_body = ""
      File.open("layouts/application.html.erb", "r") do |f|
        erb_body = f.read
      end
      puts erb_body

      erb = ERB.new(erb_body)
      erb.result(binding)
    end
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end