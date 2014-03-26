class Crawler < Sinatra::Base

  get '/' do
    haml :index
  end

  get '/sources' do
    haml :sources
  end

  get '/tenders' do
    haml :tenders
  end

end