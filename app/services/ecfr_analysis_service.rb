class EcfrAnalysisService
  def self.agency_metrics
    new.agency_metrics
  end

  def agency_metrics
    Section.group(:agency)
           .select(
             'agency',
             'COUNT(*) as section_count',
             'SUM(word_count) as total_words',
             'AVG(word_count) as avg_words_per_section',
             'MIN(word_count) as min_words',
             'MAX(word_count) as max_words',
             'SUM(LENGTH(text)) as total_chars'
           )
           .map { |result| build_agency_metrics(result) }
  end

  def self.title_metrics
    new.title_metrics
  end

  def title_metrics
    Section.group(:title_number)
           .select(
             'title_number',
             'COUNT(*) as section_count',
             'SUM(word_count) as total_words',
             'AVG(word_count) as avg_words_per_section',
             'COUNT(DISTINCT agency) as agency_count'
           )
           .map { |result| build_title_metrics(result) }
  end

  private

  def build_agency_metrics(result)
    {
      agency: result.agency,
      section_count: result.section_count,
      total_words: result.total_words,
      avg_words_per_section: result.avg_words_per_section.round(2),
      min_words: result.min_words,
      max_words: result.max_words,
      total_chars: result.total_chars,
      complexity_score: calculate_complexity_score(
        result.section_count,
        result.total_words,
        result.total_chars
      )
    }
  end

  def build_title_metrics(result)
    {
      title_number: result.title_number,
      section_count: result.section_count,
      total_words: result.total_words,
      avg_words_per_section: result.avg_words_per_section.round(2),
      agency_count: result.agency_count,
      regulatory_density: calculate_regulatory_density(
        result.section_count,
        result.total_words,
        result.agency_count
      )
    }
  end

  def calculate_complexity_score(section_count, total_words, total_chars)
    weights = { sections: 0.3, words: 0.4, chars: 0.3 }
    score = weights[:sections] * normalize(section_count) +
            weights[:words] * normalize(total_words) +
            weights[:chars] * normalize(total_chars)
    score * 100
  end

  def calculate_regulatory_density(section_count, total_words, agency_count)
    weights = { sections: 0.4, words: 0.4, agencies: 0.2 }
    score = weights[:sections] * normalize(section_count) +
            weights[:words] * normalize(total_words) +
            weights[:agencies] * normalize(agency_count, 1)
    score * 100
  end

  def normalize(value, min = nil)
    min ||= Section.minimum(:word_count)
    max = Section.maximum(:word_count)
    return 0 if max == min
    (value - min).to_f / (max - min)
  end
end 