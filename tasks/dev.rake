# Rake file for dev/test rake tasks
namespace :dev do
  desc "Clear tendetrs from cities and regions"
  task :clear_tenders_from_cities_and_regions do
    Tender.all.each do |t|
      t.region_code = nil
      t.city_code = nil
      t.save
    end
  end

  task :console do
    byebug
  end

  task :dirty_liar do
    tenders = Tender.where(:external_db_id.gte => 1, :region_code.ne => nil, :created_at.lt => '2014-12-04 00:00:00').sort(created_at: -1).limit(2000).to_a
    progress_bar = ProgressBar.create(
        title: 'Processing tenders',
        format: '%a %B %p%% %t %c/%C',
        starting_at: 0,
        total: tenders.count
    )
    tmp = []
    tenders.each do |t|
      t.created_at = DateTime.parse('2014-12-04 10:00:00')
      t.save
      progress_bar.increment
      t.reload
      tmp << t.created_at
    end
    puts tmp
  end

  desc "Fix errors"
  task :fix_error do
    tenders = Tender.where(:group=>'bankrupt')
    progress_bar = ProgressBar.create(
        title: 'Processing tenders',
        format: '%a %B %p%% %t %c/%C',
        starting_at: 0,
        total: tenders.count
    )
    tmp = []
    tenders.each do |t|
      t.published_at = t.created_at
      t.save
      progress_bar.increment
      t.reload
      tmp << t.published_at
    end
    puts tmp
  end

  desc "Reparse damaged tenders"
  task :reparse_damage do

    cartridge={
        :fz44 => BSON::ObjectId.from_string('537b09fe1d0aabca46000001'),
        :fz223 => BSON::ObjectId.from_string('5382f8f890c043e7a5000003')
    }

    tenders = Tender.where(:source_id=>BSON::ObjectId.from_string('5339108d1d0aab8c0a000001'),
                           :start_price.lte=>100,
                           :id_by_source.exists=>true)
    progress_bar = ProgressBar.create(
        title: 'Processing tenders',
        format: '%a %B %p%% %t %c/%C',
        starting_at: 0,
        total: tenders.count
    )
    to_reparse = {
        fz44:[],
        fz223:[]
    }
    tenders.each do |t|
      to_reparse[:fz44].push(t.id_by_source) if t.group.to_s=='44'
      to_reparse[:fz223].push(t.id_by_source) if t.group.to_s=='223'
      progress_bar.increment
    end

    puts 'Sending to reparse'
    to_reparse[:fz44].each_slice(10) do |ids|
      Resque.enqueue(ReapSourceIdsForceJob, cartridge[:fz44], ids)
    end

    to_reparse[:fz223].each_slice(10) do |ids|
      Resque.enqueue(ReapSourceIdsForceJob, cartridge[:fz223], ids)
    end

    ap to_reparse
  end
end
