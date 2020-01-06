module Wizard
  private

  def next_wizard_step wait = 2.seconds
    next_step = nil
    if current_car.model.blank?
      next_step = 'set_car'
    elsif current_car.insurance_end_date.blank?
      next_step = 'set_insurance_date'
    elsif current_car.current_mileage.blank?
      next_step = 'set_mileage'
    elsif current_car.next_maintenance_mileage.blank?
      next_step = 'set_next_maintenance'
    elsif current_car.maintenance_mileage.blank?
      next_step = 'set_maintenance_mileage'
    else
      if session[:last_wizard_step].present?
        later_message t('telegram_webhooks.questions_finished')
        session[:last_wizard_step] = nil
      end
      return
    end

    session[:last_wizard_step] = next_step
    save_context next_step + '!'
    later_message t("telegram_webhooks.#{next_step}.question"), wait
  end
end
