namespace :db do

  desc "Synch mongodb; defaults: host_from: '10.0.105.15:27017', host_to: '127.0.0.1:27017', db_name: 'crawler'"
  task :mongodb_synch, :host_from, :host_to, :db_name do |t, args|
    require 'fileutils'
    args.with_defaults(host_from: '10.0.105.15:27017', host_to: '127.0.0.1:27017', db_name: 'crawler')

    dumps_path = '/var/backups/tender-crawler/mongodb/updater/'
    dump_name_template = 'mongodb_crawler_'
    FileUtils.mkdir_p(dumps_path)

    dump_name = dump_name_template + Time.now.getutc.to_i.to_s
    full_dump_path = dumps_path + dump_name
    FileUtils.mkdir_p(full_dump_path)

    print "FROM: [#{args.host_from}]\nTO: [#{args.host_to}]\nDB: [#{args.db_name}]\n Enter 'yes' to continue: "
    abort 'Exit' unless %w(yes Yes y Y).include?(STDIN.gets.chomp)

    puts "\n\n################ Download dump ################\n\n"
    system("mongodump --host #{args.host_from} --db #{args.db_name} --out #{full_dump_path}")

    Mongoid::Config.purge!

    puts "\n\n################ Update database ################\n\n"
    system("mongorestore --host #{args.host_to} #{full_dump_path}")

    puts "\n\n################ Delete old dumps ################\n\n"
    Dir.chdir(dumps_path)
    dumps_for_remove = Dir.glob("#{dump_name_template}*").reject { |file|  file == dump_name }
    FileUtils.rm_rf(dumps_for_remove)
  end

end
