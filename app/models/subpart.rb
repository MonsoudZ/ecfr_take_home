class Subpart < ApplicationRecord
  belongs_to :part
  has_many :sections, -> { order(:section) }
  
  validates :identifier, presence: true
  validates :label, presence: true
  validates :position, presence: true
  
  def full_identifier
    "#{part.chapter.ecfr_title.number}-#{part.identifier}-#{identifier}"
  end
end 