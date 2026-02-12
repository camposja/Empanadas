class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.string :channel, null: false
      t.text :body, null: false
      t.string :status, default: "pending", null: false
      t.string :provider_message_id
      t.datetime :sent_at
      t.datetime :delivered_at
      t.text :error_text

      t.timestamps
    end
    
    add_index :messages, :status
    add_index :messages, :sent_at
  end
end
