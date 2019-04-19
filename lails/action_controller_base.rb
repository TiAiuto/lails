# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'

# 動的に
require '../../rails_tutorial/sample_app/app/helpers/application_helper'
require '../lails/rails'
require 'yaml'

module ActionController
end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  # 本当はこれも動的に読み込む
  include ApplicationHelper

  def initialize

  end

  def flash
    [] # ToDo: 実装
  end

  def params
    {} # ToDo: 実装
  end

  def debug(target)
    target.to_yaml
  end

  def render(target_name)

  end

  def _invoke(method_symbol)
    # ここでメソッドの呼び出しをする
    result = self.send(method_symbol)
    _render_erb
  end

  def _render_layout
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

  def _render_erb
    # puts self.class.name

    # レイアウトファイル読み込んだりする
    _render_layout { "current file" }
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end