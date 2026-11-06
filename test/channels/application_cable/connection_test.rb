require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with a signed in user" do
    user = users(:regular)

    connect env: {"warden" => stub(user: user)}

    assert_equal user, connection.current_user
  end

  test "rejects connection without a signed in user" do
    assert_reject_connection { connect env: {"warden" => stub(user: nil)} }
  end

  test "rejects connection without warden" do
    assert_reject_connection { connect }
  end
end
