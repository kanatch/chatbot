class ChangeNameChatdata < ActiveRecord::Migration[6.1]
  def change
    rename_table :chatdata, :chatdatas
  end
end
