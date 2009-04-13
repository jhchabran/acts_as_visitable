ActiveRecord::Schema.define :version => 0 do
  create_table "users", :force => true do |t|
    t.integer :user_id
    t.string :login
  end
  
  create_table "foos", :force => true do |t|
    t.integer :foo_id
    t.string :message
  end
end