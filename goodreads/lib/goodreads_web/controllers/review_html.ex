defmodule GoodreadsWeb.ReviewHTML do
  use GoodreadsWeb, :html

  embed_templates "review_html/*"

  @doc """
  Renders a review form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def review_form(assigns)
end
