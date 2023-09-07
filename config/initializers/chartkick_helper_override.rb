Chartkick::Helper.module_eval do
  private

  # don't break out options since need to merge with default options
  def chartkick_chart(klass, data_source, **options)
    options = Chartkick::Utils.deep_merge(Chartkick.options, options)

    @chartkick_chart_id ||= 0
    element_id = options.delete(:id) || "chart-#{@chartkick_chart_id += 1}"

    height = (options.delete(:height) || "300px").to_s
    width = (options.delete(:width) || "100%").to_s

    # html vars
    html_vars = {
      id: element_id,
      height: height,
      width: width,
      # don't delete loading option since it needs to be passed to JS
      loading: options[:loading] || "Loading..."
    }

    %i[height width].each do |k|
      # limit to alphanumeric and % for simplicity
      # this prevents things like calc() but safety is the priority
      # dot does not need escaped in square brackets
      raise ArgumentError, "Invalid #{k}" unless /\A[a-zA-Z0-9%.]*\z/.match?(html_vars[k])
    end

    html_vars.each_key do |k|
      # escape all variables
      # we already limit height and width above, but escape for safety as fail-safe
      # to prevent XSS injection in worse-case scenario
      html_vars[k] = ERB::Util.html_escape(html_vars[k])
    end

    # js vars
    js_vars = {
      type: klass,
      id: element_id,
      data: data_source.respond_to?(:chart_json) ? data_source.chart_json : data_source.to_json,
      options: options.to_json
    }

    html = content_tag(:div, id: html_vars[:id],
      style: "height: #{html_vars[:height]}; width: #{html_vars[:width]}; line-height: #{html_vars[:height]}; text-align: center; color: #999; font-size: 14px; font-family: 'Lucida Grande', 'Lucida Sans Unicode', Verdana, Arial, Helvetica, sans-serif;",

      "data-controller": "chartkick",
      "data-chartkick-target": "chart",
      "data-chartkick-type-value": js_vars[:type],
      "data-chartkick-data-value": js_vars[:data],
      "data-chartkick-options-value": js_vars[:options]) do
      html_vars[:loading]
    end

    html.respond_to?(:html_safe) ? html.html_safe : html
  end
end
