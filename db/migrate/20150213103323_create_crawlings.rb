class CreateCrawlings < ActiveRecord::Migration
  def change
    create_table :crawlings do |t|
      t.string :statusCode
      t.string :link

      t.timestamps
    end
  end
end
