# Add access to reviews/ratings to the product model
Spree::Product.class_eval do
  has_many :reviews

  def stars
    avg_rating.try(:round) || 0
  end

  def recalculate_rating
    self[:reviews_count] = reviews.reload.count
    self[:avg_rating] = reviews_count.positive? ? review_average : 0
    save
  end
end
