# ここではControllerのsuperの役割を果たすコードを書く

require 'erb'
require 'yaml'
require 'uri'
require 'securerandom'

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

class FormBuilder
  def label(name_symbol, options = {}, &block)
"labellll"
  end

  def email_field(name_symbol, options = {}, &block)
"email"
  end

  def password_field(name_symbol, options = {}, &block)
"password"
  end

  def check_box(name_symbol, options = {}, &block)
"chjeck!!"
  end

  def submit(name_symbol, options = {}, &block)
"submit"
  end
end

class ActionController::Base
  # ここでメソッドの呼び出しのためのメソッドなどを書く

  # 本当はこれも動的に読み込む
  include ApplicationHelper

  def initialize
    @views_root_path = "../../rails_tutorial/sample_app/app/views/" # ToDo: 本当はどっかに書いておく
    @cookies         = Cookies.new # 本当はもらってくる
    @provided_values = {}
  end

  def session
    {}
  end

  def provide(name_symbol, content)
    @provided_values[name_symbol&.to_sym] = content
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
    "<A href='#{URI.encode(url)}'>#{title}</A>"
  end

  def image_tag(url, options = {})
    "<img>"
  end

  def form_for(target_symbol, options = {}, &form_block)
    "<form>" + form_block.call(FormBuilder.new) + "</form>"
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
      controller_name       = self.class.name.gsub(/Controller$/, '').underscore
      method_name           = method_symbol.to_s
      target_filename       = "#{controller_name}/#{method_name}.html.erb"
      current_rendered      = _read_and_render_erb(@views_root_path + target_filename)
      @provided_values[nil] = current_rendered
      _render_layout_and_yield
    else
      fail "未実装"
    end
  end

  # ToDo: 動いているがこのへんごちゃついているのでリファクタする

  def render(target_name)
    @render_state = '' # ToDo: その後の処理内容を記録する
    if target_name.include? "/"
      _read_and_render_erb(File.dirname(target_name) + "/_" + File.basename(target_name) + ".html.erb")
    else
      # 同じディレクトリ内なのでファイル名から即参照できる
    end
  end

  def redirect_to(target)
    @render_state = '' # ToDo: その後の処理内容を記録する
  end

  def _render_layout_and_yield
    # このブロック内全体で、ディレクトリの起点を変更しておく
    Dir.chdir @views_root_path do
      # レイアウトファイル読み込んだりする
      _read_and_render_erb 'layouts/application.html.erb' do |key_symbol|
        @provided_values[key_symbol&.to_sym] || '' # ToDO: なければ空白でいいのか
      end
    end
  end

  def _read_and_render_erb(path, &block)
    File.open(path, "r") do |f|
      _render_erb(f.read, &block)
    end
  end

  def _render_erb(source)
    prefix       = "v"
    regex_do     = /<%=(.*?\bdo\b.*?)%>/
    regex_end    = /<%\s+?end\s+?%>/
    var_names    = []
    random_value = SecureRandom.hex(16)
    while (m = source.match regex_do) != nil
      id       = SecureRandom.hex(16)
      var_name = prefix + id
      var_names << var_name
      source = source[0...(m.begin 0)] + "<% #{var_name} =#{source[(m.begin 1)...(m.end 1)]}%>" + source[(m.end 0)..source.size]
    end
    while (m = source.match regex_end) != nil
      var_name = var_names.pop
      source   = source[0...(m.begin 0)] + "<% #{random_value} %><%= #{var_name} %>" + source[(m.end 0)..source.size]
    end
    source.gsub!(/<% #{random_value} %>/, '<% end %>')
    erb = ERB.new(source)
    erb.result(binding)
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end