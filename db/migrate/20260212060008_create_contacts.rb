class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :phone_number, null: false
      t.string :preferred_channel, default: "whatsapp"
      t.boolean :opt_in_status, default: false, null: false
      t.string :opt_in_source
      t.datetime :opt_in_timestamp
      t.boolean :do_not_contact, default: false, null: false
      t.datetime :unsubscribe_timestamp
      t.string :unsubscribe_reason
      t.text :notes
      t.string :tags
      t.datetime :last_contacted_at

      t.timestamps
    end
    
    add_index :contacts, :phone_number, unique: true
    add_index :contacts, :opt_in_status
    add_index :contacts, :do_not_contact
  end
end
