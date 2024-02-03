module PaginationHelper
  def custom_paginate_renderer(collection, options = {})
    content_tag(:nav, class: "pagination-controls") do
      previous_page_link(collection, options) + page_numbers(collection, options) + next_page_link(collection, options)
    end
  end

  private

  def link_to_previous_page(collection, options)
    unless collection.first_page?
      link_to "Previous", url_for(page: collection.prev_page), class: options[:previous_class] || "prev-page"
    end
  end

  def link_to_next_page(collection, options)
    unless collection.last_page?
      link_to 'Next', url_for(page: collection.next_page), class: options[:next_class] || "next-page"
    end
  end

  def page_numbers(collection, options)
    start_page = [collection.current_page - options[:page_range], 1].max
    end_page = [collection.current_page + options[:page_range], collection.total_pages].min

    (start_page..end_page).map do |page|
      link_to page, url_for(page: page), class: (page == collection.current_page ? options[:active_class] : options[:page_class])
    end.join.html_safe
  end
end
