module StoriesHelper
  def markdown(input)
    markdown = RDiscount.new(input)
    return Sanitize.clean(markdown.to_html, Sanitize::Config::BASIC)
  end
end
