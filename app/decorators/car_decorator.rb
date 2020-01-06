class CarDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper

  delegate_all

  def model
    object.model
  end

  def current_mileage
    humanized_mileage object.current_mileage
  end

  def next_maintenance_mileage
    humanized_mileage object.next_maintenance_mileage
  end

  def next_maintenance_mileage_distance
    humanized_mileage object.next_maintenance_mileage_distance
  end

  def maintenance_mileage
    humanized_mileage object.maintenance_mileage
  end

  def insurance_end_date
    return '???' if object.insurance_end_date.nil?
    I18n.l(object.insurance_end_date, format: :human).squish
  end

  def insurance_end_distance
    return '???' if object.insurance_end_date.nil?
    distance = Time.zone.today - object.insurance_end_date

    text = distance_of_time_in_words Time.zone.today, object.insurance_end_date
    if distance > 0
      "ПРОСРОЧЕНО #{text}"
    else
      "закончится через #{text}"
    end
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  private

  def humanized_mileage(mileage)
    return '???' if mileage.nil?
    mileage.to_s + ' км.'
  end
end
