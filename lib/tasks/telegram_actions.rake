namespace :telegram do
  task :actions => :environment do
    controller = TelegramWebhooksController
    actions = controller.public_instance_methods.map do |method|
      details = controller.instance_method(method)
      details.owner == controller ? details : nil
    end.compact

    actions.each do |action|
      comment = action.comment
      comment = comment.gsub(/\#/,'–') if comment.present?
      name = action.name
      next unless name.to_s.end_with? '!'
      puts "/#{action.name} #{comment}"
    end
  end
end
