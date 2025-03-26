class ThemeFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    super method, options
  end

  def image_field(method, options = {})
    file_field method, options
  end
end
