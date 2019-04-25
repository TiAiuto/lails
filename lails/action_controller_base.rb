require 'erb'
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
  def initialize(controller, target_name)
    @controller  = controller
    @target_name = target_name
  end

  def label(name_symbol, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('label', options.merge({ for: _generate_name(name_symbol) })))
    if block_given?
      @controller.instance_exec &block
    else
      @controller._erbout(name_symbol.to_s.capitalize)
    end
    @controller._erbout('</label>')
  end

  def _generate_name(name)
    "#{@target_name}[#{name}]"
  end

  def email_field(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'email', name: _generate_name(name_symbol), id: _generate_name(name_symbol) })))
  end

  def password_field(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'password', name: _generate_name(name_symbol), id: _generate_name(name_symbol) })))
  end

  def check_box(name_symbol, options = {})
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'checkbox', name: _generate_name(name_symbol), id: _generate_name(name_symbol) })))
  end

  def submit(value, options = {}, &block)
    @controller._erbout(HTMLTagBuilder.build('input', options.merge({ type: 'submit', value: value })))
  end
end

module HTMLTagBuilder
  def self.build(tag_name, options = {})
    tag = "<#{tag_name} "
    options.each do |key, value|
      tag += "#{key}='#{value}' " # 仮実装
    end
    tag += ">"
    tag
  end
end

class Flash
  include Enumerable

  def initialize
    @values_to_save = [] # 描画等の実行後Sessionに保存する
    @values_saved   = [] # 前回から引き継いだもの
  end

  def now
    # .nowが呼ばれた場合は専用のオブジェクトを返す
    # なければ作る
    unless @_now_hash
      @_now_hash = {} # ここは今回しか表示しないので保存されない
    end
    @_now_hash
  end

  def []=(key, val)
    @values_to_save << [key, val]
  end

  def [](key)
    @values_to_save.find { |item| item[0] == key } & [1]
  end

  def each(&block)
    (@values_saved + @values_to_save + @_now_hash.to_a).to_h.each &block
  end
end

class ActionController::Base
  # ToDo: 本当はこれも動的に読み込む
  include ApplicationHelper
  attr_accessor :cookies, :params, :session, :flash

  class << self
    ### コールバック登録ここから
    def before_action(method_symbol, only = [])

    end
    ### コールバック登録ここまで
  end

  def initialize
    @_views_root_path = "#{APP_ROOT}app/views/" # ToDo: 本当はどっかに書いておく
    @cookies          = Cookies.new # ToDo: 本当はリクエストから変換する
    @session          = {}
    @params           = {}
    @flash            = Flash.new
    @_provided_values = {} # provide, yield で参照するためのデータ
  end

  ### HTMLタグ等定義ここから

  def content_tag(tag_name, content, options = {})
    (HTMLTagBuilder.build tag_name, options) + content + "</#{tag_name}>"
  end

  def link_to(title, url, options = {})
    content_tag('a', title, options.merge(href: url))
  end

  def image_tag(url, options = {})
    HTMLTagBuilder.build('img', options.merge({ src: "/assets/img/#{url}" }))
  end

  def form_for(target, options = {}, &form_block)
    if target.instance_of? Symbol
      _erbout(HTMLTagBuilder.build('form', options.merge(method: :post, action: options[:url])))
      self.instance_exec FormBuilder.new(self, target.to_s), &form_block
      _erbout('</form>')
    else
      fail "未実装"
    end
  end

  def csrf_meta_tags
    '' # ToDo: これから定義する（必要なら）
  end

  def stylesheet_link_tag(path, options = {})
    "<link href='/assets/css/#{COMPILED_CSS_FILENAME}' rel='stylesheet'>"
  end

  def javascript_include_tag(path, options = {})
    '' # チュートリアルの内容ならいらないかも
  end

  ### HTMLタグ等定義ここまで

  ### その他メソッドここから

  def debug(target)
    content_tag 'pre', target.to_yaml, class: 'debug_dump'
  end

  ### その他メソッドここまで

  # コントローラの処理の実行を請け負う
  # 実行結果の使い道は呼び出した側に任せる
  def _invoke(method_symbol)
    # メソッド内での処理結果を覚えておくためのへんすう
    # `render` や `redirect_to` が呼びだされたとき、この変数の値が変化する
    # `nil` のままの場合、特に何も呼び出されていない
    @_method_result = nil
    # viewファイルの探索の基準となるフォルダ
    controller_name    = self.class.name.gsub(/Controller$/, '').underscore
    @_current_base_dir = "#{controller_name}/" # なおさなかんよかん
    # 要求されたメソッドを呼び出す
    self.send(method_symbol)
    if @_method_result == nil
      method_name = method_symbol.to_s
      # コントローラ・メソッドに対応するViewを探して描画する
      target_erb_filename = "#{@_current_base_dir}#{method_name}.html.erb"
      current_rendered    = _read_and_render_erb(@_views_root_path + target_erb_filename)
      provide(nil, current_rendered) # layout内で `yield` が呼ばれたときに返す値を登録する
      # layoutの描画を実行する
      { type: :to_render, content: _render_layout_and_yield }
    elsif @_method_result[:type] == :to_render
      provide(nil, @_method_result[:content]) # layout内で `yield` が呼ばれたときに返す値を登録する
      # layoutの描画を実行する
      { type: :to_render, content: _render_layout_and_yield }
    else
      @_method_result
    end
  end

  ### コントローラ側の描画要求・リダイレクト要求ここから

  def provide(name_symbol, content)
    @_provided_values[name_symbol] = content
  end

  def render(target_name)
    if target_name.include? "/"
      _read_and_render_erb(File.dirname(target_name) + "/_" + File.basename(target_name) + ".html.erb")
    else
      # conteroller内でrenderが呼ばれた場合
      # 同じディレクトリ内なのでファイル名から即参照できる
      content         = _read_and_render_erb("#{@_views_root_path}#{@_current_base_dir}#{target_name.to_s}.html.erb")
      @_method_result = { type: :to_render, content: content }
    end
  end

  def redirect_to(target)
    @_method_result = { type: :to_redirect, target: target }
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