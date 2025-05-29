class Section < ApplicationRecord
  belongs_to :ecfr_title, foreign_key: 'title_number', primary_key: 'number'
  belongs_to :part
  belongs_to :subpart, optional: true
  
  validates :agency, presence: true
  validates :part, presence: true
  validates :section, presence: true
  validates :text, presence: true
  validates :checksum, presence: true, uniqueness: true
  
  before_validation :generate_checksum
  
  def citation
    "#{title_number} CFR #{part.identifier}.#{section}"
  end
  
  def self.find_by_citation(citation)
    # Parse citation like "1 CFR 1.1"
    if citation =~ /(\d+)\s+CFR\s+(\d+)\.(\d+)/
      title_number = $1.to_i
      part = $2
      section = $3
      find_by(title_number: title_number, part: part, section: section)
    end
  end
  
  private
  
  def generate_checksum
    self.checksum = Digest::MD5.hexdigest("#{title_number}-#{part}-#{section}-#{text}")
  end
end
