defmodule Goodreads.OpensearchClient do
  @opensearch_url "http://opensearch-node1:9200"  # Use the Docker Compose service name and port

  @doc """
  Indexes a document in OpenSearch.
  """
  def index_document(index, id, document) do
    url = "#{@opensearch_url}/#{index}/_doc/#{id}"
    body = Jason.encode!(document)

    IO.inspect(document, label: "Document being indexed")

    case HTTPoison.post(url, body, [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        IO.puts("Document created successfully.")
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("Document updated successfully.")
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to index document.")
        IO.inspect(status_code, label: "Error Status Code")
        IO.inspect(body, label: "Error Response Body")
        {:error, %{status_code: status_code, body: body}}

      {:error, reason} ->
        IO.puts("Error in HTTP request.")
        IO.inspect(reason, label: "Request Error")
        {:error, reason}
    end
  end

  @doc """
  Deletes a document from OpenSearch.
  """
  def delete_document(index, id) do
    url = "#{@opensearch_url}/#{index}/_doc/#{id}"

    HTTPoison.delete(url)
    |> handle_response()
  end

  @doc """
  Searches for documents in OpenSearch.
  """
  def search(index, query) do
    url = "#{@opensearch_url}/#{index}/_search"

    body = Jason.encode!(query)

    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    IO.puts("Successful response from OpenSearch.")
    IO.inspect(body, label: "Response from OpenSearch")
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    IO.puts("Failed request to OpenSearch.")
    IO.inspect(status_code, label: "Error Status Code")
    IO.inspect(body, label: "Error Response Body")
    {:error, %{status_code: status_code, body: body}}
  end

  defp handle_response({:error, reason}) do
    IO.puts("Error in HTTP request.")
    IO.inspect(reason, label: "Request Error")
    {:error, reason}
  end
end
