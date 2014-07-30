namespace :parsing do
  namespace :protocols do
    desc 'Parsing protocols from zakupki.gov.ru'
    task :zakupki, :protocols_count do |t, args|
      args.with_defaults(:protocols_count => 100)
      
    end
  end
end