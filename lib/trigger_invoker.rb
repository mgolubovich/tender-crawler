class TriggerInvoker

  def self.invoke(trigger,data)
    if Object.const_defined?(trigger["class_name"])
      trigger_class = trigger["class_name"].constantize
      data = trigger["after"] ? trigger_class.invoke_after(data) : trigger_class.invoke_before(data)
      data
    else
      puts 'Baaad'
    end
  end

end