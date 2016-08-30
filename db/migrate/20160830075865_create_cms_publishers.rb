class CreateCmsPublishers < ActiveRecord::Migration
  def change
    create_table :cms_publishers do |t|
      t.references :publishable, index: true, polymorphic: true
      t.string     :state
      t.integer    :priority
      t.timestamps
    end
  end
end