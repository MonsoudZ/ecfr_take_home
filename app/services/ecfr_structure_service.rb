require 'net/http'
require 'json'
require 'nokogiri'

class EcfrStructureService
  BASE_URL = 'https://www.ecfr.gov/api/versioner/v1'

  def self.import_title_structure(title_number)
    new.import_title_structure(title_number)
  end

  def import_title_structure(title_number)
    doc = fetch_title_xml(title_number)
    return unless doc

    ActiveRecord::Base.transaction do
      doc.css('DIV1').each do |chapter_node|
        chapter = create_chapter(title_number, chapter_node)
        chapter_node.css('DIV2').each do |part_node|
          part = create_part(chapter, part_node)
          process_sections(part, part_node, title_number)
        end
      end
    end
  end

  private

  def fetch_title_xml(title_number)
    titles_uri = URI("#{BASE_URL}/titles.json")
    titles_response = Net::HTTP.get_response(titles_uri)
    return nil unless titles_response.code == '200'
    
    titles_data = JSON.parse(titles_response.body)
    title_data = titles_data['titles'].find { |t| t['number'] == title_number }
    return nil unless title_data
    
    full_uri = URI("#{BASE_URL}/full/#{title_data['latest_issue_date']}/title-#{title_number}.xml")
    full_response = Net::HTTP.get_response(full_uri)
    return nil unless full_response.code == '200'
    
    Nokogiri::XML(full_response.body)
  end

  def create_chapter(title_number, node)
    Chapter.find_or_initialize_by(
      ecfr_title_id: title_number,
      identifier: node['N']
    ).tap do |chapter|
      chapter.assign_attributes(
        label: node.at_css('HEAD')&.text,
        position: node['N'].to_i
      )
      chapter.save!
    end
  end

  def create_part(chapter, node)
    Part.find_or_initialize_by(
      chapter_id: chapter.id,
      identifier: node['N']
    ).tap do |part|
      part.assign_attributes(
        label: node.at_css('HEAD')&.text,
        position: node['N'].to_i,
        agency: extract_agency(node)
      )
      part.save!
    end
  end

  def process_sections(part, part_node, title_number)
    # Process sections in subparts
    part_node.css('DIV3').each do |subpart_node|
      subpart = create_subpart(part, subpart_node)
      subpart_node.css('DIV8').each do |section_node|
        create_section(section_node, title_number, part, subpart)
      end
    end

    # Process sections directly under part
    part_node.css('DIV8').each do |section_node|
      create_section(section_node, title_number, part)
    end
  end

  def create_subpart(part, node)
    Subpart.find_or_initialize_by(
      part_id: part.id,
      identifier: node['N']
    ).tap do |subpart|
      subpart.assign_attributes(
        label: node.at_css('HEAD')&.text,
        position: node['N'].to_i
      )
      subpart.save!
    end
  end

  def create_section(node, title_number, part, subpart = nil)
    Section.find_or_initialize_by(
      title_number: title_number,
      part_id: part.id,
      section: node['N']
    ).tap do |section|
      section.assign_attributes(
        text: node.to_xml,
        word_count: count_words(node),
        agency: part.agency,
        subpart_id: subpart&.id
      )
      section.save!
    end
  end

  def extract_agency(node)
    if auth_node = node.at_css('AUTH')
      auth_node.text.strip
    elsif head_node = node.at_css('HEAD')
      heading = head_node.text.strip
      heading.include?('—') ? heading.split('—').last.strip : 'Unknown Agency'
    else
      'Unknown Agency'
    end
  end

  def count_words(node)
    node.text.split(/\s+/).count
  end
end 