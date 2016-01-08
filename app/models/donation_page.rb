class DonationPage < ActiveRecord::Base
  belongs_to :person, required: true
  has_many :actions, dependent: :nullify

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :visible_user_name, presence: true
  validates :photo_url, presence: true
  validates :intro_text, presence: true

  before_save :downcase_slug

  def rank
    1
  end

  def funds_raised_in_cents
    1200
  end

  def to_param
    slug
  end

  private

  def downcase_slug
    self.slug.downcase!
  end
end
