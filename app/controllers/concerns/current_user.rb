module CurrentUser

  private

  def current_user
    return unless from
    return @current_user if defined? @current_user
    @current_user = create_user
  end

  def create_user
    User.
      create_with(from.slice(*%w[first_name last_name]).merge telegram_username: from['username']).
      find_or_create_by(telegram_id: from['id'])
  end

  def current_car
    current_user.car
  end
end
