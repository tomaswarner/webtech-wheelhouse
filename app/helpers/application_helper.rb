module ApplicationHelper
  FLASH_COLORS = { "notice" => "success", "alert" => "danger" }.freeze

  def flash_color(type)
    FLASH_COLORS.fetch(type.to_s, "info")
  end

  def field_messages(form, attribute)
    name = attribute.to_s
    keys = [name]
    keys << name.delete_suffix("_id") if name.end_with?("_id")
    keys.flat_map { |key| form.object.errors.full_messages_for(key.to_sym) }
  end

  def field_class(form, attribute, base = "form-control")
    field_messages(form, attribute).any? ? "#{base} is-invalid" : base
  end

  def field_feedback(form, attribute)
    messages = field_messages(form, attribute)
    return if messages.empty?

    tag.div(safe_join(messages, tag.br), class: "invalid-feedback")
  end

  def status_choices
    Repair.statuses.keys.map { |status| [status.humanize, status] }
  end
end
