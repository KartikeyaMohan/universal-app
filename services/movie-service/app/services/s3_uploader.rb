class S3Uploader
  def initialize
    @client = Aws::S3::Resource.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY"],
      secret_access_key: ENV["AWS_SECRET_KEY"]
    )
    @bucket = ENV["AWS_BUCKET"]
  end

  def upload(file:, key:)
    object = @client.bucket(@bucket).object(key)
    object.upload_file(file.tempfile, content_type: file.content_type)
    key
  end

  def delete(key)
    @client.bucket(@bucket).object(key).delete
  end

  def url(key:)
    @client.bucket(@bucket).object(key).public_url
  end

  def presigned_url(key:, expires_in: 3600)
    signer = Aws::S3::Presigner.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
    signer.presigned_url(:get_object,
      bucket: ENV["AWS_BUCKET"],
      key: key,
      expires_in: expires_in
    )
  end
end