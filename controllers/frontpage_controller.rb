class FrontPageController < ApplicationController
  
  get '/' do
    @stats = Hash.new
    @stats[:source_count] = Source.active.count
    @stats[:tenders_count] = Tender.count
    haml :index
  end

end