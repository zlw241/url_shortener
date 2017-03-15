class ShortenedUrl < ActiveRecord::Base

  validates :short_url, :long_url, :user_id, presence: true
  validates :short_url, uniqueness: true

  belongs_to(
    :submitter,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: "Visit",
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    through: :visits,
    source: :user
  )

  def self.random_code
    SecureRandom.urlsafe_base64(16)
  end

  def self.create!(user, long_url)
    raise ArgumentError unless user.is_a?(User)
    user_id = user.id
    short_url = ShortenedUrl.random_code
    until find_by(short_url: short_url).nil?
      short_url = ShortenedUrl.random_code
    end
    ShortenedUrl.new(short_url: short_url,
                     long_url: long_url,
                     user_id: user_id).save!
  end

  def all_visits
    Visit.where(shortened_url_id: id)

  end
  #
  def num_clicks
    all_visits.count
  end
  #
  def num_uniques
    # Visit.find_by_sql("SELECT * FROM visits WHERE shortened_url_id = id")
    all_visits.distinct.pluck(:user_id).count
  end


  def num_recent_uniques
  end


end
