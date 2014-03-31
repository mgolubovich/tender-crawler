class FrontPageController < ApplicationController
  
  get '/' do
    get_base_stats
    haml :index
  end

  def get_base_stats
    @stats = Hash.new
    @stats[:source_count] = Source.active.count
    @stats[:tenders_count] = Tender.count
  end

end