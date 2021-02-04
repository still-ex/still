if Mix.env() == :dev do
  defmodule Still.Site.Github do
    @rate_limited_stargazers 418
    @rate_limited_username "@ratelimited"
    @rate_limited_url "https://picsum.photos/400"

    def stars do
      {:ok, {_, _, body}} =
        :httpc.request(
          :get,
          {"https://api.github.com/repos/still-ex/still",
           [
             {'Accept', 'application/vnd.github.v3+json'},
             {'User-Agent',
              'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0'}
           ]},
          [],
          []
        )

      body
      |> Jason.decode!()
      |> Map.get("stargazers_count", @rate_limited_stargazers)
    end

    def contributors do
      {:ok, {_, _, body}} =
        :httpc.request(
          :get,
          {"https://api.github.com/repos/still-ex/still/contributors",
           [
             {'Accept', 'application/vnd.github.v3+json'},
             {'User-Agent',
              'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0'}
           ]},
          [],
          []
        )

      body
      |> Jason.decode!()
      |> Enum.map(fn
        %{"login" => _} = user ->
          %{
            username: "@#{user["login"]}",
            url: user["html_url"],
            avatar_url: user["avatar_url"]
          }

        _error ->
          %{
            username: @rate_limited_username,
            url: @rate_limited_url,
            avatar_url: @rate_limited_url
          }
      end)
    end
  end
end
