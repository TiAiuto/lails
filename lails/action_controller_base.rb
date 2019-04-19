# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'
require 'yaml'

module ActionController
end

class Cookies < Hash
  def signed
    {}
  end

  def permanent
    {}
  end
end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  # 本当はこれも動的に読み込む
  include ApplicationHelper

  # このへんは自動生成する

  def root_path
    ''
  end

  def help_path
    ''
  end

  def login_path
    ''
  end

  def about_path
    ''
  end

  def contact_path
    ''
  end

  def initialize
    @views_root_path = "../../rails_tutorial/sample_app/app/views/"
    @cookies = Cookies.new # 本当はもらってくる
  end

  def session
    {}
  end

  def cookies
    @cookies
  end

  def flash
    [] # ToDo: 実装
  end

  def params
    {} # ToDo: 実装
  end

  def link_to(title, url, options = {})
    "<A href='#{url}'>#{title}</A>"
  end

  def csrf_meta_tags

  end

  def stylesheet_link_tag(path, options = {})

  end

  def javascript_include_tag(path, options = {})

  end

  def debug(target)
    target.to_yaml
  end

  def _invoke(method_symbol)
    # ここでメソッドの呼び出しをする
    result = self.send(method_symbol)
    _render_erb
  end

  def render(target_name)
    if target_name.include? "/"
      _render_layout(File.dirname(target_name) + "/_" + File.basename(target_name) + ".html.erb")
    else

    end
  end

  def _render_layout(path)
    erb_body = ""
    File.open(path, "r") do |f|
      erb_body = f.read
    end
    puts erb_body

    erb = ERB.new(erb_body)
    erb.result(binding)
  end

  def _render_erb
    # このブロック内全体で、ディレクトリの起点を変更しておく
    Dir.chdir @views_root_path do
      # puts self.class.name

      # レイアウトファイル読み込んだりする
      _render_layout "layouts/application.html.erb" do
        "current file"
      end
    end
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end