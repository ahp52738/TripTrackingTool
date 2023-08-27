class CreateTripVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_versions do |t|
      t.references :trip, null: false, foreign_key: true
      t.integer :version
      t.integer :owner_id
      t.integer :assignee_id
      t.integer :status

      t.timestamps
    end
  end
end

