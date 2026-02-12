class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.text :message_template, null: false
      t.string :segment_tags
      t.datetime :scheduled_for
      t.string :status, default: "draft", null: false
      t.integer :sent_count, default: 0
      t.integer :failed_count, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :campaigns, :status
    add_index :campaigns, :scheduled_for
  end
end
