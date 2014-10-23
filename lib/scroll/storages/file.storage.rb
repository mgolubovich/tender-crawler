class FileStorage
	def initialize (filename)
		path = "file_storage/" + filename
		@file = File.open(path, "a")
	end

	def save(data)
		@file.write(data)
		@file.flush
	end 
end