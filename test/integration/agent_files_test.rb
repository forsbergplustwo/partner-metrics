require "test_helper"

class AgentFilesTest < ActionDispatch::IntegrationTest
  test "serves agents.md at llms.txt and llms-full.txt without authentication" do
    agents_md = Rails.public_path.join("agents.md").read

    ["/llms.txt", "/llms-full.txt"].each do |path|
      get path
      assert_response :success
      assert_equal "text/plain; charset=utf-8", response.headers["content-type"]
      assert_equal agents_md, response.body
    end
  end
end
