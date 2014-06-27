class FrontPageController < ApplicationController

  get '/' do
    get_base_stats
    haml :index
  end

  def get_base_stats
    @stats = Hash.new
    @stats[:source_count] = Statistics.first.global_sources_count
    @stats[:tenders_count] = Statistics.first.global_tenders_count
  end
end
