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

  def intake_photo_alt(repair, position, total)
    "Intake photo #{position} of #{total}: #{repair.bike.make} #{repair.bike.model}, repair ##{repair.id}"
  end

  def intake_thumbnail(repair)
    width, height = Repair::THUMBNAIL_SIZE
    photo = repair.saved_intake_photos.first

    if photo
      image_tag photo.variant(:thumb),
        alt: intake_photo_alt(repair, 1, repair.saved_intake_photos.size),
        width: width, height: height, class: "d-block"
    else
      tag.div(tag.i(class: "bi bi-image"), class: "d-flex align-items-center justify-content-center bg-body-secondary text-secondary",
        style: "width: #{width}px; height: #{height}px;", role: "img", aria: { label: "No intake photos" })
    end
  end

  def diagnosis_excerpt(repair)
    repair.diagnosis.to_plain_text.squish.truncate(60)
  end

  def status_choices
    Repair.statuses.keys.map { |status| [status.humanize, status] }
  end
end
