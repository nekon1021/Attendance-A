class CreateOrverworks < ActiveRecord::Migration[5.1]
  def change
    create_table :orverworks do |t|
      t.references :user, null: false
      t.date :worked_on, null: false
      t.datetime :finished_at, null: false
      t.text :note, null: false
      t.references :superior, null: false, foreign_key: { to_table: :users }
      t.datetime :approved_at, null: true
      t.datetime :applied_at, null: false

      t.timestamps
    end
  end
end
