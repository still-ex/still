if Mix.env() == :dev do
  defmodule Still.Site.Github do
    @contributors [
      "gabrielpoca",
      "frm"
    ]

    def contributors do
      @contributors
      |> Enum.map(fn username ->
        {:ok, {_, _, body}} =
          :httpc.request(
            :get,
            {"https://api.github.com/users/#{username}",
             [
               {'Accept', 'application/vnd.github.v3+json'},
               {'User-Agent',
                'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0'}
             ]},
            [],
            []
          )

        Jason.decode!(body)
      end)
      |> Enum.map(fn user ->
        %{
          username: "@#{user["login"]}",
          url: user["html_url"],
          avatar_url: user["avatar_url"]
        }
      end)
    end
  end
end
