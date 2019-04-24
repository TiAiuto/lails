require 'erb'
require 'yaml'
require 'uri'

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

  def email_field(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'email' })))
  end

  def password_field(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'password' })))
  end

  def check_box(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'checkbox' })))
  end

  def submit(value, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'submit', value: value })))
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
  # ToDo: 本当はこれも動的に読み込む
  include ApplicationHelper

  class << self
    ### コールバック登録ここから
    def before_action(method_symbol, only = [])

    end
    ### コールバック登録ここまで
  end

  def initialize
    @_views_root_path = "#{APP_ROOT}app/views/" # ToDo: 本当はどっかに書いておく
    @_cookies         = Cookies.new # ToDo: 本当はリクエストから変換する
    @_provided_values = {} # provide, yield で参照するためのデータ
  end

  ### 各リクエスト・描画で使う値ここから

  def flash
    [] # ToDo: 実装
  end

  def params
    {} # ToDo: 実装
  end

  def cookies
    @_cookies
  end

  def session
    {}
  end

  def provide(name_symbol, content)
    @_provided_values[name_symbol] = content
  end

  ### 値ここまで

  ### HTMLタグ等定義ここから

  def link_to(title, url, options = {})
    HTMLTagBuilder.build('a', options.merge(href: url)) + title + "</a>"
  end

  def image_tag(url, options = {})
    HTMLTagBuilder.build('img', options.merge({ src: "/assets/img/#{url}" }))
  end

  def form_for(target_symbol, options = {}, &form_block)
    _erbout('<form>')
    self.instance_exec FormBuilder.new(self), &form_block
    _erbout('</form>')
  end

  def csrf_meta_tags
    '' # ToDo: これから定義する（必要なら）
  end

  def stylesheet_link_tag(path, options = {})
    '<link href="/assets/css/custom.scss.css" rel="stylesheet">'
  end

  def javascript_include_tag(path, options = {})
    '' # ToDo: これから定義する（必要なら）
  end

  ### HTMLタグ等定義ここまで

  ### その他メソッドここから

  def debug(target)
    "<pre class='debug_dump'>#{target.to_yaml}</pre>"
  end

  ### その他メソッドここまで

  # コントローラの処理の実行を請け負う
  # 実行結果の使い道は呼び出した側に任せる
  def _invoke(method_symbol)
    # メソッド内での処理結果を覚えておくためのへんすう
    # `render` や `redirect_to` が呼びだされたとき、この変数の値が変化する
    # `nil` のままの場合、特に何も呼び出されていない
    @_render_state = nil
    # 要求されたメソッドを呼び出す
    self.send(method_symbol)
    # @_render_state にはメソッドの実行結果が入っている
    if @_render_state == nil
      # コントローラ・メソッドに対応するViewを探して描画する
      controller_name     = self.class.name.gsub(/Controller$/, '').underscore
      method_name         = method_symbol.to_s
      target_erb_filename = "#{controller_name}/#{method_name}.html.erb"
      current_rendered    = _read_and_render_erb(@_views_root_path + target_erb_filename)
      provide(nil, current_rendered) # layout内で `yield` が呼ばれたときに返す値を登録する
      # layoutの描画を実行する
      { type: :rendered, content: _render_layout_and_yield }
    else
      @_render_state
    end
  end

  ### コントローラ側の描画要求・リダイレクト要求ここから

  def render(target_name)
    # ToDo: メソッドの実行結果として描画する場合
    if target_name.include? "/"
      _read_and_render_erb(File.dirname(target_name) + "/_" + File.basename(target_name) + ".html.erb")
    else
      # ToDo: 実装
      # 同じディレクトリ内なのでファイル名から即参照できる
      fail "見実装"
    end
  end

  def redirect_to(target)
    @_render_state = { type: :to_redirect, target: :target }
  end

  ### 描画要求・リダイレクト要求ここまで

  ### erbの描画関連ここから

  # layout の描画を実行する
  # `yield` の実行時に `provide` で登録した値が返るように、ブロックを渡す
  def _render_layout_and_yield
    # このブロック内全体で、ディレクトリの起点を `views` に変更しておく
    Dir.chdir @_views_root_path do
      # layout の読み込みを実行する
      _read_and_render_erb 'layouts/application.html.erb' do |key_symbol|
        @_provided_values[key_symbol&.to_sym] || ''
      end
    end
  end

  # 指定したファイル名のerbファイルを読み込み、描画結果を返す
  def _read_and_render_erb(path, &block)
    File.open(path, "r") do |f|
      _render_erb(f.read, &block)
    end
  end

  # コントローラ側から任意の文字列を描画したいときに使うメソッド
  def _erbout(str)
    # @_erbout_proc はerbの内部で定義する
    @_erbout_proc.call(str)
  end

  # 個別のerbの描画（変換）を行う
  def _render_erb(source)
    # `<%= [].each do |item| %><%end %>` のような書き方は本当はerbの規約違反なので直す
    # <% [].each do |item| %><%end %> は書いてもOK
    source.gsub!(/<%=(.*?\bdo\b.*?)%>/, "<%\\1%>")
    erb = ERB.new('<% @_erbout_proc = Proc.new do |it| _erbout += it end  %>' + source)
    erb.result(binding)
  end

  ### erbの描画ここまで
end