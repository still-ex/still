use Temple

temple do
  div class: "main" do
    div class: "content" do
      h1 class: "fancy-title" do
        div class: "visually-hidden" do
          "Still"
        end
      end

      div class: "logo-container" do
        responsive_image("_includes/logo.png", class: "logo", aria_hidden: true)
      end

      p class: "lead" do
        "A composable elixir static site builder"
      end

      div class: "info" do
        link(@env, "Docs", to: "https://hexdocs.pm/still", class: "cta")
        |> to_string()
        link(@env, "GitHub", to: "https://github.com/still-ex/still", class: "cta")
        |> to_string()
      end
    end
    include(@env, "_includes/marquee.exs")
    div class: "overlay"
    responsive_image("_includes/main.jpg", class: "cover", aria_hidden: true)
  end
end
