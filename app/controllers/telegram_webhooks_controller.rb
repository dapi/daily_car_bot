# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  use_session!

  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors
  include LaterMessage
  include StoreMessage
  include Wizard

  def message(message)
    stored_message = store_message message
    respond_with :message, text: t('.response', stored_message: stored_message)
  end

  def start!(*)
    next_wizard_step 5.seconds
    respond_with :message, text: t('.response', user: current_user), parse_mode: :Markdown
  end

  def info!(*)
    if current_car.present?
      respond_with :message, text: t('.success', car: CarDecorator.decorate(current_car)), parse_mode: :Markdown
    else
      respond_with :message, text: t('.empty'), parse_mode: :Markdown
    end
  end

  def reset!(arg = nil, *)
    if arg == 'force'
      current_user.destroy!
      session.destroy
      respond_with :message, text: t('.success'), parse_mode: :Markdown
    else
      respond_with :message, text: t('.no_arg', arg: 'force'), parse_mode: :Markdown
    end
  end

  def set_maintenance_mileage!(mileage, *)
    current_car.update! maintenance_mileage: mileage
    next_wizard_step
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_next_maintenance!(mileage, *)
    current_car.update! next_maintenance_mileage: mileage
    next_wizard_step
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_mileage!(mileage, *)
    mileage = mileage.to_f
    current_user.messages.create!(
      value: mileage,
      kind: :mileage,
      telegram_message_id: telegram_message_id,
      telegram_date: telegram_date
    )
    current_car.update! current_mileage: mileage
    next_wizard_step
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_insurance_date!(date, *)
    current_car.update! insurance_end_date: date == '0' ? nil : Date.parse(date)
    next_wizard_step
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_number!(number = nil, *)
    current_car.update! number: number == '0' ? nil : number
    next_wizard_step
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_car!(mark = nil, model = nil, year = nil, *)
    if model.present? && mark.present? && year.present?
      if current_car.present?
        current_car.update model: model, mark: mark, year: year
      else
        current_user.create_car! model: model, mark: mark, year: year
      end

      next_wizard_step
      respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
    else
      save_context :set_car!
      respond_with :message, text: t('.wrong'), parse_mode: :Markdown
    end
  end
end
