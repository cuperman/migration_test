class Person < ActiveRecord::Base
  attr_accessible :age, :name

  def touch!
    self.touched = true
    self.save
  end
end
