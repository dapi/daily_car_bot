module TelegramHelpers
  private

  def multiline(*args)
    args.flatten.map(&:to_s).join("\n")
  end

  def code(text)
    multiline '```', text, '```'
  end
end
