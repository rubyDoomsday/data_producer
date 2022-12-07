class CreateDataSources < ActiveRecord::Migration[6.1]
  def change
    create_table :data_sources do |t|
      t.text :title
      t.text :source_type
      t.text :summary
      t.integer :status_code, default: 0

      t.timestamps
    end
  end
end
