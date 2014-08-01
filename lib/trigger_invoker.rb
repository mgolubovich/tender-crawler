# Trigger Invoker
# Invokes triggers before or after tender parsing
# Can be used for processing specific cases
class TriggerInvoker
  def self.invoke(t, data)
    if Object.const_defined?(t['class_name'])
      t_class = t['class_name'].constantize
      t['after'] ? t_class.invoke_after(data) : t_class.invoke_before(data)
    end
  end
end
