# lib/goodreads/uploads/image_uploader.ex
defmodule Goodreads.Uploads.ImageUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  # Define where to store files
  @storage :local

  def storage_dir(version, {_file, scope}) do
    case Application.get_env(:goodreads, :reverse_proxy) do
      true -> "/static/uploads/#{scope}/#{version}/"
      false -> "/uploads/#{scope}/#{version}/"
    end
  end

  # Define any transformations or validations here
end
