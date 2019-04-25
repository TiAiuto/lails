module ActiveRecord
end

class ActiveRecord::Base
  class << self
    attr_accessor :abstract_class

    ### バリデーション関連ここから

    @@validators = []

    # バリデーション方式を登録しておく

    def validates(target_symbol, options = {})
      @@validators << { target_symbol: target_symbol, options: options }
    end

    ### バリデーション関連ここまで

    ### DB操作関連ここから

    def find(id)
      # 検索メソッドを呼び出す
    end

    def find_by(options)
      # 検索メソッドを呼び出す
    end

    ### DB操作関連ここまで

    ### コールバック関連ここから

    @@hooks = []

    def before_save(&block)
      @@hooks << { type: :before_save, func: block }
    end

    ### コールバック関連ここまで

    ### その他ここから

    def has_secure_password
      # 何するんだろう？
    end

    ### その他ここまで
  end

  # 個別のインスタンスで使うメソッド

  def initialize(params = {})

  end

  ### バリデーション関連ここから

  def valid?

  end

  ### バリデーション関連ここまで

  ### DB操作ここから

  def save
    @@hooks.select { |item| item[:type] == :before_save }.each do |item|
      self.instance_eval &item[:func]
    end
    # ここで保存処理をする
  end

  def save!
    raise ActiveRecord::RecordInvalid unless save
  end

  def update_attribute(target_symbol, value)
  end

  ### DB操作ここまで
end

# 保存に失敗した場合の例外
class ActiveRecord::RecordInvalid < StandardError
end