namespace :parsing do
  namespace :protocols do
    desc 'Parsing protocols from zakupki.gov.ru'
    task :zakupki, :protocols_count, :proxy_url, :proxy_port do |t, args|
      args.with_defaults(protocols_count: 100,
                         proxy_url: nil,
                         proxy_port: nil)

      tenders = Tender
                    .where(:source_id => '5339108d1d0aab8c0a000001')
                    .where(:id_by_source.ne => nil)
                    .where(:start_at.lte => Time.now.utc)
                    .where(:has_winner.ne => true)
                    .order_by(:start_at => :asc)
                    .limit(args.protocols_count.to_i)

      ap tenders.count

      tenders.each do |t|
        data = ZakupkiProtocolParser.new(t.id_by_source, t.cartridge).parse
        #protocol = t.protocols.count > 0 ? t.protocols.first : t.protocols.new

        unless data.nil?
          data.each do |inn, is_winner|
            protocol_record = Protocol.find_or_create_by(tender_id: t._id, inn: inn)
            protocol_record.update_attributes!(is_winner: is_winner, tender_data: t.as_document)
            t.update_attributes!(has_winner: true) if is_winner
          end

        end

      end
    end

    desc 'Parsing full zakupki.gov.ru'
    task :zakupki_full do

      tenders = Tender
                    .where(:source_id => '5339108d1d0aab8c0a000001')
                    .where(:id_by_source.ne => nil)
                    .where(:start_at.lte => Time.now.utc)
                    .where(:has_winner.ne => true)

      ap tenders.count

      tenders.each do |t|
        data = ZakupkiProtocolParser.new(t.id_by_source, t.cartridge).parse
        #protocol = t.protocols.count > 0 ? t.protocols.first : t.protocols.new

        unless data.nil?
          data.each do |inn, is_winner|
            protocol_record = Protocol.find_or_create_by(tender_id: t._id, inn: inn)
            protocol_record.update_attributes!(is_winner: is_winner, tender_data: t.as_document)
            t.update_attributes!(has_winner: true) if is_winner
          end

        end

      end
    end
  end
end