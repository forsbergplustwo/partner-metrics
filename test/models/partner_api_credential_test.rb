require "test_helper"

class PartnerApiCredentialTest < ActiveSupport::TestCase
  test "decrypts values encrypted under Rails 7.0 SHA-1 key derivation" do
    clear_token = "legacy-sha1-token"
    sha1_key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(
      ActiveRecord::Encryption.config.primary_key,
      key_generator: ActiveRecord::Encryption::KeyGenerator.new(hash_digest_class: OpenSSL::Digest::SHA1)
    )
    ciphertext = ActiveRecord::Encryption.encryptor.encrypt(clear_token, key_provider: sha1_key_provider)

    credential = partner_api_credentials(:one)
    connection = PartnerApiCredential.connection
    connection.execute(
      "UPDATE partner_api_credentials SET access_token = #{connection.quote(ciphertext)} WHERE id = #{credential.id.to_i}"
    )

    assert_equal clear_token, credential.reload.access_token
  end

  test "writes and reads values with the SHA-256 digest" do
    credential = partner_api_credentials(:one)
    credential.update_column(:access_token, "new-sha256-token")

    assert_equal "new-sha256-token", credential.reload.access_token
    assert_equal OpenSSL::Digest::SHA256, ActiveRecord::Encryption.config.hash_digest_class
  end
end
