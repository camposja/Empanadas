class AddCampaignTypeFieldsToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :campaign_type, :string, default: "one_off", null: false
    add_column :campaigns, :active, :boolean, default: true, null: false
    add_column :campaigns, :recurring_interval_days, :integer
    add_column :campaigns, :starts_on, :date
    add_column :campaigns, :ends_on, :date
    add_column :campaigns, :last_sent_at, :datetime
  end
end
