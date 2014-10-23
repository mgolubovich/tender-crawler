=begin

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "scroll"
Dir.glob('./storages/*.storage.rb').each { |file| require file }
Dir.glob('./transports/*.transport.rb').each { |file| require file }

file_logger = Scroll.new :file, :info
console_logger = Scroll.new :console, :info

puts "INFO LOGGER"

for i in 0..60
	data = []
	data.push (0...8).map { (65 + rand(26)).chr }.join
	data.push (0...8).map { (65 + rand(26)).chr }.join
	data.push (0...8).map { (65 + rand(26)).chr }.join

	file_logger.log(data)
	console_logger.log(data)

	sleep 1
end

file_logger = Scroll.new :file, :debug
console_logger = Scroll.new :console, :debug

puts "DEBUG LOGGER"

for i in 0..60
	data = []
	data.push (0...8).map { (65 + rand(26)).chr }.join
	data.push (0...8).map { (65 + rand(26)).chr }.join
	data.push (0...8).map { (65 + rand(26)).chr }.join

	file_logger.log(data)
	console_logger.log(data)

	sleep 1
end
=end