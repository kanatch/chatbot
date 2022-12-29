class CreateChatdata < ActiveRecord::Migration[6.1]
  def change
    create_table :chatdata do |t|
      t.string :keyword
      t.string :replytext
      t.timestamps null: false
    end
  end
end