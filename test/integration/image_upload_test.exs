defmodule Fanuniverse.ImageUploadIntegrationTest do
  use Fanuniverse.Web.ConnCase

  alias Fanuniverse.Repo
  alias Fanuniverse.Image

  @fixture "test/fixtures/vidalia.png"
  @tmp_dir "/tmp/plug-1497"
  @tmp_path "/tmp/plug-1497/multipart-random"
  @plug_upload %Plug.Upload{
    content_type: "image/png", filename: "somefile.png", path: @tmp_path}

  setup do
    File.mkdir(@tmp_dir)
    :ok = File.cp(@fixture, @tmp_path)

    {:ok, %{session: test_user_session()}}
  end

  test "creates a new image and performs background processing", %{session: session} do
    test_process = self()

    session = session |> post("/images", %{"image" => %{
      "image" => @plug_upload, "source" => "source.url",
      "tags" => "(artist) msillzie, (fandom) steven universe, vidalia"
    }})

    "/images/" <> upload_id = redirected_to(session)

    GenServer.cast(Dispatcher.Image, {:set_callback, fn(id) ->
      assert id == upload_id

      updated_record = Repo.get!(Image, id)

      assert updated_record.width == 564
      assert updated_record.height == 720
      assert updated_record.phash != ""
      assert updated_record.ext == "png"
      assert updated_record.processed

      assert File.exists?("priv/vidalia/images/#{id}/thumbnail.png")
      assert File.exists?("priv/vidalia/images/#{id}/preview.png")

      File.rm_rf!("priv/vidalia/images/#{id}")

      send test_process, :testing_finished
    end})

    receive do
      :testing_finished -> :ok
    after
      2_000 ->
        flunk "test callback has not been invoked."
    end
  end

  test "displays image preview if there are submission errors", %{session: session} do
    GenServer.cast(Dispatcher.Image, {:set_callback, fn(_id) ->
      flunk "the callback shouldn't be invoked"
    end})

    session = session |> post("/images", %{"image" => %{
      "image" => @plug_upload, "source" => "",
      "tags" => "(artist) msillzie, (fandom) steven universe, vidalia"
    }})

    cache_root = Application.get_env(:fanuniverse, :image_cache_root) <> "/"
    cache_string = session.assigns.image_cache
    assert cache_root <> cache_string == session.assigns.image_preview_url
    assert [source: {"can't be blank", _}] = session.assigns.changeset.errors
  end
end
