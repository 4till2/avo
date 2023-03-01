class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :status
      t.references :orderable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
