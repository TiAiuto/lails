# ここではmodelのsuperの役割を果たすコードを書く

module ActiveRecord

end

class ActiveRecord::Base
  # ここにvalidatesやfind_byなどの処理を書く

  def validates(target_symbol, options = {})

  end

  def find(id)
  end

  def find_by(options)
  end

  def save

  end

  def save!
    raise ActiveRecord::RecordInvalid unless save
  end

  def update_attribute(target_symbol, value)
  end

  def has_secure_password
  end
end

class ActiveRecord::RecordInvalid < StandardError
end