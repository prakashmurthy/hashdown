require 'spec_helper'

describe Hashdown do
  describe 'cache' do
    describe 'in a Rails project' do
      before { Object.const_set('Rails', double(cache: :rails_cache, env: 'development')) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'delegates to Rails.cache if available' do
        expect(Hashdown.cache).to eq Rails.cache
      end

      it 'incorporates the environment in the cache key' do
        expect(Hashdown.cache_key(:finder, 'MyModel', 'some-value')).to match(/development/)
      end
    end

    it 'creates a new cache store if Rails.cache unavailable' do
      expect(Hashdown.cache.class).to eq ActiveSupport::Cache::MemoryStore
    end
  end
end
