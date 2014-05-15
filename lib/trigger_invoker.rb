class TriggerInvoker

  def self.invoke(trigger,tender)
    if Object.const_defined?(trigger["class_name"])
      trigger_class = trigger["class_name"].constantize
      tender = trigger_class.invoke(tender)
      tender
    else
      puts 'Baaad'
    end
  end

end