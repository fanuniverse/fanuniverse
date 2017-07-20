defmodule Fanuniverse.Factory do
  use ExMachina.Ecto, repo: Fanuniverse.Repo

  def image_factory do
    %Fanuniverse.Image{
      tags: "artist: someone, fandom: steven universe, pearl, amethyst, opal",
      source: "https://someone.tumblr.com/awesome-post"
    }
  end
end
