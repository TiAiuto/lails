# ここではmodelのsuperの役割を果たすコードを書く

module ActiveRecord

end

class ActiveRecord::Base
  class << self
    attr_accessor :abstract_class

    @@validators = []

    # バリデーション方式を登録しておく

    def validates(target_symbol, options = {})
      @@validators << { target_symbol: target_symbol, options: options }
    end

    def has_secure_password
      # 何するんだろう？
    end

    def find(id)
      # 検索メソッドを呼び出す
    end

    def find_by(options)
      # 検索メソッドを呼び出す
    end

    @@hooks = []

    def before_save(&block)
      @@hooks << { type: :before_save, func: block }
    end
  end

  # ここで型情報を取得して、全てのキーの値を取得・格納可能にする

  def respond_to_missing(name, include_all)
    false # そのメソッドが使えるかどうか
  end

  def method_missing(method_symbol, *args, &block)
    "aaaaa"
  end

  def email
    "aaaa"
  end

  # 個別のインスタンスで使うメソッド

  def initialize(values = {})
    # ここで値のコピーを行う
  end

  def valid?

  end

  def save
    @@hooks.select { |item| item[:type] == :before_save }.each { |item| item[:func].call self }
    # ここで保存処理をする
  end

  def save!
    raise ActiveRecord::RecordInvalid unless save
  end

  def update_attribute(target_symbol, value)
  end
end

class ActiveRecord::RecordInvalid < StandardError
end