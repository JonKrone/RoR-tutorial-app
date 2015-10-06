module ApplicationHelper
  
  # Returns a standard, full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "OOLWs: Our Own Little Worlds"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end