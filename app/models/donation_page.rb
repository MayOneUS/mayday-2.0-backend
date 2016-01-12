class DonationPage < ActiveRecord::Base
  belongs_to :person, required: true
  has_many :actions, dependent: :nullify

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :visible_user_name, presence: true
  validates :photo_url, presence: true
  validates :intro_text, presence: true

  before_save :downcase_slug

  def self.by_funds_raised
    joins(:actions).
      select('
        donation_pages.id,
        donation_pages.slug,
        donation_pages.visible_user_name,
        sum(actions.donation_amount_in_cents) as funds_raised_in_cents,
        count(actions.donation_amount_in_cents) as donations_count
      ').
      group('donation_pages.id, donation_pages.slug, donation_pages.visible_user_name').
      order('funds_raised_in_cents desc')
  end

  def to_param
    slug
  end

  private

  def downcase_slug
    self.slug.downcase!
  end
end
