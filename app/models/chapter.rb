class Chapter < ApplicationRecord
  belongs_to :ecfr_title
  has_many :parts, -> { order(:position) }
  
  validates :identifier, presence: true
  validates :label, presence: true
  validates :position, presence: true
  
  def full_identifier
    "#{ecfr_title.number}-#{identifier}"
  end
end
