class CreateBlogsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :blogs do |b|
      b.string :title
      b.string :content
      b.integer :likes
      b.integer :user_id
    end
  end
end
