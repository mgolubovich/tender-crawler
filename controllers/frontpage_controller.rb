# FrontPage controller
class FrontPageController < ApplicationController
  get '/' do
    base_stats
    haml :index
  end

  def base_stats
    @stats = {}
    @stats[:source_count] = Statistics.first.global_sources_count
    @stats[:tenders_count] = Statistics.first.global_tenders_count
  end
end
