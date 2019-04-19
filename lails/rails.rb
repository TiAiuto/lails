class EnvConfig
  # とりあえずダミー
  def development?
    true
  end
end

module Rails
  @config = EnvConfig.new

  def self.env
    @config
  end
end
