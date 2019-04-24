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
  def initialize(controller)
    @controller = controller
  end

  def label(name_symbol, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('label', options))
    if block_given?
      @controller.instance_exec &block
    else
      @controller._erbout(name_symbol.to_s.capitalize)
    end
    @controller._erbout('</label>')
  end

  def email_field(name_symbol, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({type: 'email'})))
  end

  def password_field(name_symbol, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({type: 'password'})))
  end

  def check_box(name_symbol, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({type: 'checkbox'})))
  end

  def submit(value, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({type: 'submit', value: value})))
  end
end

module HTMLTagBuilder
  def self.build(tag_name, options = {})
    tag = "<#{tag_name} "
    options.each do |key, value|
      tag += "#{key}='#{value}'" # 仮実装
    end
    tag += ">"
    tag
  end
end

class ActionController::Base
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
    HTMLTagBuilder.build('a', options.merge(href: url)) + title + "</a>"
  end

  def image_tag(url, options = {})
    HTMLTagBuilder.build('img', options.merge({src: "/assets/img/#{url}"}))
  end

  def csrf_meta_tags
    ''
  end

  def stylesheet_link_tag(path, options = {})
    '<link href="/assets/css/custom.scss.css" rel="stylesheet">'
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

  def form_for(target_symbol, options = {}, &form_block)
    _erbout('<form>')
    self.instance_exec FormBuilder.new(self), &form_block
    _erbout('</form>')
  end

  def _erbout(str)
    @_erbout_proc.call(str)
  end

  def _render_erb(source)
    source.gsub!(/<%=(.*?\bdo\b.*?)%>/, "<%\\1%>")
    erb = ERB.new('<% @_erbout_proc = Proc.new do |it| _erbout += it end  %>' + source)
    erb.result(binding)
  end

  class << self
    def before_action(method_symbol, only = [])

    end
  end
end