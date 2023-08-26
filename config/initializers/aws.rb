Aws.config.update({
  region: ENV.fetch("AWS_REGION", "us-east-1"),
  credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
})
