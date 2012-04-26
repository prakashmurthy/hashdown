module Hashdown
  def self.cache
    @cache ||= rails_cache || local_cache
  end

  def self.cache=(value)
    @cache = value
  end

  def self.force_cache_miss?
    Rails.env.test? if defined?(Rails)
  end

  def self.cache_key(source, class_name, token=nil)
    ['hashdown', class_name, source, token].compact.join('-')
  end

  def self.uncache(source, class_name, token)
    cache.delete(cache_key(source, class_name, token))
  end

  class Config
    def initialize(hash={})
      @data = hash
    end

    def method_missing(method_id, *args)
      if method_id.to_s =~ /^(\w*)=$/
        @data[$1.to_sym] = args.first
      elsif method_id.to_s =~ /^(\w*)\?$/
        @data.has_key?($1.to_sym)
      else
        if @data.has_key?(method_id)
          @data[method_id]
        else
          super
        end
      end
    end
  end

  private

  def self.rails_cache
    Rails.cache if defined?(Rails)
  end

  def self.local_cache
    ActiveSupport::Cache::MemoryStore.new
  end
end