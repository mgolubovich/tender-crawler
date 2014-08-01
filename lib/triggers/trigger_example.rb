# Example trigger
class ZakupkiTrigger
  def self.invoke_after(tender)
    tender.title = 'Trigger Working'
    tender
  end
end
