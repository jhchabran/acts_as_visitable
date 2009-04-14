ActiveRecord::Schema.define :version => 0 do
  create_table "users", :force => true do |t|
    t.integer :user_id
    t.string :login
  end
  
  create_table "foos", :force => true do |t|
    t.integer :foo_id
    t.string :message
  end
  
  create_table "sights", :force => true do |t|
    t.integer :sigh_id
    t.string :sightable_type
    t.integer :sightable_id
    t.integer :viewer_id
    t.datetime :seen_at, :default => Time.now
  end
end