class Part < ApplicationRecord
  belongs_to :chapter
  has_many :subparts, -> { order(:position) }
  has_many :sections, -> { order(:section) }
  
  validates :identifier, presence: true
  validates :label, presence: true
  validates :position, presence: true
  
  def full_identifier
    "#{chapter.ecfr_title.number}-#{identifier}"
  end
  
  def citation
    "#{chapter.ecfr_title.number} CFR #{identifier}"
  end
end 