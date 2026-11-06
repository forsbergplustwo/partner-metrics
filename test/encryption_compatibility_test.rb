require "test_helper"

class EncryptionCompatibilityTest < ActiveSupport::TestCase
  test "verifies Marshal-serialized messages written before json_allow_marshal" do
    secret = Rails.application.key_generator.generate_key("active_record/signed_id")
    old_verifier = ActiveSupport::MessageVerifier.new(secret, serializer: Marshal)
    token = old_verifier.generate(users(:regular).id)

    current_verifier = ActiveSupport::MessageVerifier.new(secret)
    assert_equal users(:regular).id, current_verifier.verify(token)
  end

  test "decrypts JSON cookies derived with the SHA-256 key generator" do
    secret = Rails.application.key_generator.generate_key(
      Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt,
      ActiveSupport::MessageEncryptor.key_len
    )
    encryptor = ActiveSupport::MessageEncryptor.new(
      secret,
      cipher: "aes-256-gcm",
      serializer: ActiveSupport::Messages::SerializerWithFallback[:json]
    )
    payload = {"session_id" => "keep-me", "warden.user.user.key" => [[users(:regular).id], "salt"]}

    assert_equal payload, encryptor.decrypt_and_verify(encryptor.encrypt_and_sign(payload))
    assert_equal OpenSSL::Digest::SHA256, Rails.application.config.active_support.key_generator_hash_digest_class
    assert_equal :json, Rails.application.config.action_dispatch.cookies_serializer
    assert_equal :json_allow_marshal, Rails.application.config.active_support.message_serializer
  end
end
