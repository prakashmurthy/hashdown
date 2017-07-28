require 'spec_helper'

describe Hashdown::Finder do
  describe 'bracket lookup' do
    it 'is added to enabled models' do
      expect(State).to respond_to(:[])
    end

    it 'finds a record by a string key value' do
      expect(State['CA'].name).to eq 'California'
    end

    it 'finds a record by a symbol key value' do
      expect(State[:CO].name).to eq 'Colorado'
    end

    it 'adds uniqueness validation to key attribute' do
      expect(State.where(abbreviation: 'CO').count).to eq 1
      expect(State.new(abbreviation: 'CO')).not_to be_valid
    end
  end

  describe 'missing/invalid key' do
    it 'raises record not found exception' do
      expect(lambda { State[:HI] }).to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows setting a default to avoid exception' do
      expect(lambda { expect(StateDefaultNil[:HI]).to be_nil }).not_to raise_error
    end
  end

  describe 'cache layer' do
    let(:florida) { State.new(abbreviation: 'FL', name: 'Florida') }

    it 'caches found records' do
      scope = double(first: florida)
      expect(State).to receive(:where).once.and_return(scope)

      2.times { expect(State[:FL].name).to eq 'Florida' }
    end

    describe 'in test environment' do
      before { Object.const_set('Rails', double(env: double(test?: true), cache: ActiveSupport::Cache::MemoryStore.new)) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'forces cache miss' do
        scope = double(first: florida)
        expect(State).to receive(:where).twice.and_return(scope)

        2.times { expect(State[:FL].name).to eq 'Florida' }
      end
    end

    it 'clears the cache on save' do
      scope = double(first: florida)
      expect(State).to receive(:where).twice.and_return(scope)

      State[:FL].save
      State[:FL]
    end

    it 'clears the cache on destroy' do
      scope = double(first: florida)
      expect(State).to receive(:where).twice.and_return(scope)

      State[:FL].destroy
      State[:FL]
    end
  end
end
