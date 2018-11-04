class User < ActiveRecord::Base
  has_many :blogs
end

class Blog < ActiveRecord::Base
  belongs_to :user
end
