module LayoutsHelper
  def nav_item_selected?(url)
    url_part = url.include?("?") ? url.split("?").first : url
    path_part = request.path.include?("?") ? request.path.split("?").first : request.path
    url_part == path_part
  end

  def avatar_url(user, size)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end
end
