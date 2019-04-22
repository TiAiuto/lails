# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'
require 'yaml'
require 'cgi'

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

  def initialize
    @views_root_path = "../../rails_tutorial/sample_app/app/views/" # ToDo: 本当はどっかに書いておく
    @cookies         = Cookies.new # 本当はもらってくる
  end

  def session
    {}
  end

  def provide(name_symbol, content)
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
    "<A href='#{CGI.escape(url)}'>#{title}</A>"
  end

  def csrf_meta_tags
    ''
  end

  def stylesheet_link_tag(path, options = {})
    ''
  end

  def javascript_include_tag(path, options = {})
    ''
  end

  def debug(target)
    target.to_yaml
  end

  def _invoke(method_symbol)
    @render_state = nil
    # ここでメソッドの呼び出しをする
    self.send(method_symbol)
    if @render_state == nil
      # 特に指示がなければ、コントローラ・メソッドに対応するViewを探して描画する
      controller_name  = self.class.name.gsub(/Controller$/, '').downcase
      method_name      = method_symbol.to_s
      target_filename  = "#{controller_name}/#{method_name}.html.erb"
      current_rendered = _read_and_render_layout(@views_root_path + target_filename)
      _read_and_render_erb current_rendered
    else
      fail "未実装"
    end
  end

  # ToDo: 動いているがこのへんごちゃついているのでリファクタする

  def render(target_name)
    @render_state = '' # ToDo: その後の処理内容を記録する
    if target_name.include? "/"
      _read_and_render_layout(File.dirname(target_name) + "/_" + File.basename(target_name) + ".html.erb")
    else
      # 同じディレクトリ内なのでファイル名から即参照できる
    end
  end

  def redirect_to(target)
    @render_state = '' # ToDo: その後の処理内容を記録する
  end

  def _read_and_render_layout(path, &block)
    File.open(path, "r") do |f|
      _render_erb(f.read, &block)
    end
  end

  def _render_erb(source)
    erb = ERB.new(source)
    erb.result(binding)
  end

  def _read_and_render_erb(current_rendered)
    # このブロック内全体で、ディレクトリの起点を変更しておく
    Dir.chdir @views_root_path do
      # レイアウトファイル読み込んだりする
      _read_and_render_layout "layouts/application.html.erb" do
        current_rendered
      end
    end
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end