ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table :states do |t|
    t.string :name, :abbreviation
  end

  create_table :cities do |t|
    t.belongs_to :state
    t.string :name
  end

  create_table :currencies do |t|
    t.string :name, :code
  end
end
