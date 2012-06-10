class Movie < ActiveRecord::Base
  def self.ratings
    @ratings = self.select('DISTINCT rating').map(&:rating)
  end
end
