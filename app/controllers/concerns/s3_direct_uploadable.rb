module S3DirectUploadable
  extend ActiveSupport::Concern

  included do
    before_action :set_s3_direct_post, only: [:index, :app_store_analytics]
  end

  private

  def set_s3_direct_post
    s3 = Aws::S3::Resource.new.bucket(ENV["S3_BUCKET"])
    @s3_direct_post = s3.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: "201")
  end
end
