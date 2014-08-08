namespace :parsing do
  namespace :protocols do
    desc 'Parsing protocols from zakupki.gov.ru'
    task :zakupki, :protocols_count, :proxy_url, :proxy_port do |t, args|
      args.with_defaults(protocols_count: 100,
        proxy_url: nil,
        proxy_port: nil)

      tenders = Tender
                      .where(:source_id => '5339108d1d0aab8c0a000001')
                      .where(:external_work_type.gt => 0)
                      .where(:start_at.gte => '2014-01-01 00:00:00')
                      .where(:id_by_source.ne => nil)
                      .order_by(:start_at => :asc)
                      .limit(args.protocols_count.to_i)

      tenders.each do |t|
        data = ZakupkiProtocolParser.new(t.id_by_source || t.code_by_source).parse
        protocol = t.protocols.count > 0 ? t.protocols.first : t.protocols.new
        protocol.update_attributes!(:data => data)
      end
    end
  end
end