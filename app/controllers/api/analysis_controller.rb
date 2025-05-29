module Api
  class AnalysisController < ApplicationController
    def agency_metrics
      metrics = EcfrAnalysisService.agency_metrics
      render json: {
        metrics: metrics,
        summary: {
          total_agencies: metrics.length,
          total_sections: metrics.sum { |m| m[:section_count] },
          total_words: metrics.sum { |m| m[:total_words] },
          avg_complexity: metrics.sum { |m| m[:complexity_score] } / metrics.length
        }
      }
    end

    def title_metrics
      metrics = EcfrAnalysisService.title_metrics
      render json: {
        metrics: metrics,
        summary: {
          total_titles: metrics.length,
          total_sections: metrics.sum { |m| m[:section_count] },
          total_words: metrics.sum { |m| m[:total_words] },
          avg_density: metrics.sum { |m| m[:regulatory_density] } / metrics.length
        }
      }
    end
  end
end 