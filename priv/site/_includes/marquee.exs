---
text: "Tonight on display: still (featuring elixir)"
---

use Temple

temple do
  div class: "marquee" do
    div class: "content" do
      for _ <- 1..5 do
        span do
          @text
        end
      end
    end
  end
end
