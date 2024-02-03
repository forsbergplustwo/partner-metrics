module PaginationHelper
  def paginate(total_items, items_per_page, current_page, base_url)
    total_pages = (total_items.to_f / items_per_page).ceil
    pagination_html = '<ul class="pagination">'

    if current_page > 1
      pagination_html += '<li>' + link_to('Previous', "#{base_url}?page=#{current_page - 1}") + '</li>'
    end

    if current_page < total_pages
      pagination_html += '<li>' + link_to('Next', "#{base_url}?page=#{current_page + 1}") + '</li>'
    end

    pagination_html += "</ul>"
    pagination_html.html_safe
  end
end
