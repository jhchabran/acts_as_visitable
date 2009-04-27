ActiveRecord::Schema.define :version => 0 do
  create_table "users", :force => true do |t|
    t.string :login
  end
  
  create_table "foos", :force => true do |t|
    t.string :message
  end
  
  create_table "bars", :force => true do |t|
    t.integer :size
  end
  
  create_table "visits", :force => true do |t|
    t.string :visitable_type
    t.integer :visitable_id
    t.integer :visitor_id
    t.datetime :visited_at, :default => Time.now
  end
end