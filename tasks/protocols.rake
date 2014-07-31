namespace :parsing do
  namespace :protocols do
    desc 'Parsing protocols from zakupki.gov.ru'
    task :zakupki, :protocols_count do |t, args|
      args.with_defaults(:protocols_count => 100)
        protocol_link_template = ''
        tenders = Tender.where(source_id: '5339108d1d0aab8c0a000001', :external_work_type.gt => 0, :tender_group => '223').limit(args.protocols_count.to_i)

    end
  end
end