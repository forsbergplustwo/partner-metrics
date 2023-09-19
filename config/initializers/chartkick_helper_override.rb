module Chartkick
  module Helper
    # TODO: THIS IS A HACK to make turbo frames play nicely with charts
    #  ONLY KEEP UNTIL THE FOLLOWING BUG IS FIXED: https://github.com/ankane/chartkick/issues/608
    #  IT CAN BE SAFELY DELETED WHEN THAT BUG IS FIXED

    private

    def chartkick_chart(klass, data_source, **options)
      options = Chartkick::Utils.deep_merge(Chartkick.options, options)

      @chartkick_chart_id ||= 0
      element_id = options.delete(:id) || "chart-#{@chartkick_chart_id += 1}"

      height = (options.delete(:height) || "300px").to_s
      width = (options.delete(:width) || "100%").to_s
      defer = !!options.delete(:defer)

      # content_for: nil must override default
      content_for = options.key?(:content_for) ? options.delete(:content_for) : Chartkick.content_for

      nonce = options.fetch(:nonce, true)
      options.delete(:nonce)
      if nonce == true
        # Secure Headers also defines content_security_policy_nonce but it takes an argument
        # Rails 5.2 overrides this method, but earlier versions do not
        nonce = if respond_to?(:content_security_policy_nonce) && begin
          content_security_policy_nonce
        rescue
          nil
        end
          # Rails 5.2+
          content_security_policy_nonce
        elsif respond_to?(:content_security_policy_script_nonce)
          # Secure Headers
          content_security_policy_script_nonce
        end
      end
      nonce_html = nonce ? " nonce=\"#{ERB::Util.html_escape(nonce)}\"" : nil

      # html vars
      html_vars = {
        id: element_id,
        height: height,
        width: width,
        # don't delete loading option since it needs to be passed to JS
        loading: options[:loading] || "Loading..."
      }

      [:height, :width].each do |k|
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

      html = (options.delete(:html) || %(<div id="%{id}" style="height: %{height}; width: %{width}; text-align: center; color: #999; line-height: %{height}; font-size: 14px; font-family: 'Lucida Grande', 'Lucida Sans Unicode', Verdana, Arial, Helvetica, sans-serif;">%{loading}</div>)) % html_vars

      # js vars
      js_vars = {
        type: klass.to_json,
        id: element_id.to_json,
        data: data_source.respond_to?(:chart_json) ? data_source.chart_json : data_source.to_json,
        options: options.to_json
      }
      js_vars.each_key do |k|
        js_vars[k] = Chartkick::Utils.json_escape(js_vars[k])
      end
      createjs = "new Chartkick[%{type}](%{id}, %{data}, %{options});" % js_vars

      warn "[chartkick] The defer option is no longer needed and can be removed" if defer

      # Turbolinks preview restores the DOM except for painted <canvas>
      # since it uses cloneNode(true) - https://developer.mozilla.org/en-US/docs/Web/API/Node/
      #
      # don't rerun JS on preview to prevent
      # 1. animation
      # 2. loading data from URL
      js = <<~JS
        <script#{nonce_html}>
          (function() {
            if (document.documentElement.hasAttribute("data-turbolinks-preview")) return;
            if (document.documentElement.hasAttribute("data-turbo-preview")) return;

            var createChart = function() { #{createjs} };
            if ("Chartkick" in window) {
              window.addEventListener("turbo:load", createChart, {once: true});
            } else {
              window.addEventListener("chartkick:load", createChart, true);
            }
          })();
        </script>
      JS

      if content_for
        content_for(content_for) { js.respond_to?(:html_safe) ? js.html_safe : js }
      else
        html += "\n#{js}"
      end

      html.respond_to?(:html_safe) ? html.html_safe : html
    end
  end
end
