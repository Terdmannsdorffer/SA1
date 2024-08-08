defmodule GoodreadsWeb.BookHTML do
  use GoodreadsWeb, :html
  import Phoenix.HTML
  import Phoenix.HTML.Form
  embed_templates "book_html/*"

  @doc """
  Renders a book form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def book_form(assigns)
end
