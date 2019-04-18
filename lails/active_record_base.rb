# ここではmodelのsuperの役割を果たすコードを書く

module ActiveRecord

end

class ActiveRecord::Base
  class << self
    attr_accessor :abstract_class

    def validates(target_symbol, options = {})

    end

    def has_secure_password
    end

    def find(id)
    end

    def find_by(options)
    end

    def before_save
    end
  end

  # ここで型情報を取得して、全てのキーの値を取得・格納可能にする

  self.define_method :name do |value|
  end

  self.define_method :name= do |value|
  end

  # 個別のインスタンスで使うメソッド
  def valid?

  end

  def save

  end

  def save!
    raise ActiveRecord::RecordInvalid unless save
  end

  def update_attribute(target_symbol, value)
  end
end

class ActiveRecord::RecordInvalid < StandardError
end