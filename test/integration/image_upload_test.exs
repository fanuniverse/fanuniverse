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

  defmodule FixtureServer do
    def init(opts),
      do: opts

    def call(conn, _opts),
      do: Plug.Conn.send_resp(conn, 200, File.read!("test/fixtures/vidalia.png"))
  end

  defmacro assert_fixture_processing(test_pid, upload_id) do
    quote bind_quoted: [test_pid: test_pid, upload_id: upload_id] do
      GenServer.cast(Dispatcher.Image, {:set_callback, fn(id) ->
        assert id == upload_id

        updated_record = Repo.get!(Image, id)

        assert updated_record.width == 564
        assert updated_record.height == 720
        assert updated_record.phash != ""
        assert updated_record.ext == "png"
        assert updated_record.processed

        assert File.exists?("priv/images/#{id}/thumbnail.png")
        assert File.exists?("priv/images/#{id}/preview.png")

        File.rm_rf!("priv/images/#{id}")

        send test_pid, :testing_finished
      end})

      receive do
        :testing_finished -> :ok
      after
        2_000 -> flunk "test callback has not been invoked."
      end
    end
  end

  test "creates a new image and performs background processing", %{session: session} do
    session = session |> post("/images", %{"image" => %{
      "image" => @plug_upload, "source" => "source.url",
      "tags" => "(artist) msillzie, (fandom) steven universe, vidalia"
    }})

    "/images/" <> upload_id = redirected_to(session)
    assert_fixture_processing(self(), upload_id)
  end

  test "displays image preview if there are submission errors", %{session: session} do
    GenServer.cast(Dispatcher.Image, {:set_callback, fn(_id) ->
      flunk "the callback shouldn't be invoked"
    end})

    session = session |> post("/images", %{"image" => %{
      "image" => @plug_upload, "source" => "",
      "tags" => "(artist) msillzie, (fandom) steven universe, vidalia"
    }})

    cache_root = Application.get_env(:fanuniverse, :cache_url_root) <> "/"
    cache_string = session.assigns.image_cache
    assert cache_root <> cache_string == session.assigns.image_preview_url
    assert [source: {"can't be blank", _}] = session.assigns.changeset.errors
  end

  test "creates a new image from a remote file", %{session: session} do
    {:ok, _} = Plug.Adapters.Cowboy.http(FixtureServer, [], port: 8279)

    session = session |> post("/images", %{"image" => %{
      "remote_image" => "localhost:8279/image", "source" => "source.url",
      "tags" => "(artist) msillzie, (fandom) steven universe, vidalia"
    }})

    "/images/" <> upload_id = redirected_to(session)
    assert_fixture_processing(self(), upload_id)
  end
end
