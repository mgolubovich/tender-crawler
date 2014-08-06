# Some cool functionality like address-like quieries
# for Hash
# Query example
# some_hash.at('root.section.subsection.folder.book')
# equals
# some_hash[:root][:section][:subsection][:folder][:book]
class Hash
  def at(path, symbolize = true)
    this = self
    path.split('.').each do |key|
      key = key.to_sym if symbolize
      this = this[key]
      break unless this
    end

    this
  end
end
