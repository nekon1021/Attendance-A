class ChangeCreateOverworksToCreateOverWorks < ActiveRecord::Migration[5.1]
  def change
    create_table :over_works do |t|
      t.references :user
      t.boolean :confirm, default: false, null: false, comment: "確認済みかどうか"
      t.string :destination, comment: "申請先の相手"

      t.timestamps
    end
  end
end
