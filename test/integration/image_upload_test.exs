defmodule Fanuniverse.ImageUploadIntegrationTest do
  use Fanuniverse.Web.ConnCase

  import Ecto.Query

  alias Fanuniverse.Repo
  alias Fanuniverse.Image
  alias Fanuniverse.Report

  @fixture "test/fixtures/vidalia.png"
  @tmp_dir "/tmp/plug-1497"
  @tmp_path "/tmp/plug-1497/multipart-random"
  @tmp_path_2 "/tmp/plug-1497/multipart-upload-2"

  setup_all do
    File.mkdir(@tmp_dir)

    File.rename("priv/images", "priv/_images")
    File.rename("priv/cache", "priv/_cache")
    File.mkdir("priv/images")
    File.mkdir("priv/cache")

    on_exit fn ->
      File.rm(@tmp_path)
      File.rm(@tmp_path_2)

      File.rm_rf("priv/images")
      File.rm_rf("priv/cache")
      File.rename("priv/_images", "priv/images")
      File.rename("priv/_cache", "priv/cache")
    end
  end

  setup do
    File.cp!(@fixture, @tmp_path)

    {:ok, %{session: test_user_session()}}
  end

  defmodule FixtureServer do
    def init(opts),
      do: opts

    def call(conn, _opts),
      do: Plug.Conn.send_resp(conn, 200, File.read!("test/fixtures/vidalia.png"))
  end

  def plug_upload(path),
    do: %Plug.Upload{content_type: "image/png", filename: "file.png", path: path}

  defmacro assert_fixture_processing(test_pid, upload_id) do
    quote bind_quoted: [test_pid: test_pid, upload_id: upload_id] do
      GenServer.cast(Dispatcher.Vidalia, {:set_callback, fn(id) ->
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
      "image" => plug_upload(@tmp_path), "source" => "source.url",
      "tags" => "artist: msillzie, fandom: steven universe, vidalia"
    }})

    "/images/" <> upload_id = redirected_to(session)
    assert_fixture_processing(self(), upload_id)
  end

  test "displays image preview if there are submission errors", %{session: session} do
    GenServer.cast(Dispatcher.Vidalia, {:set_callback, fn(_id) ->
      flunk "the callback shouldn't be invoked"
    end})

    session = session |> post("/images", %{"image" => %{
      "image" => plug_upload(@tmp_path), "source" => "",
      "tags" => "artist: msillzie, fandom: steven universe, vidalia"
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
      "tags" => "artist: msillzie, fandom: steven universe, vidalia"
    }})

    "/images/" <> upload_id = redirected_to(session)
    assert_fixture_processing(self(), upload_id)
  end

  # This test uploads the thumbnail of an already existent image
  # and ensures the system reports it as a duplicate.
  test "detects duplicate uploads and reports them", %{session: session} do
    parent_pid = self()

    upload_duplicate = fn(original_id) ->
      File.cp("priv/images/#{original_id}/thumbnail.png", @tmp_path_2)

      session |> post("/images", %{"image" => %{
        "image" => plug_upload(@tmp_path_2), "source" => "source.url",
        "tags" => "artist: msillzie, fandom: steven universe, vidalia"
      }})
    end

    check_for_duplicate_report = fn(original_id, duplicate_id) ->
      assert %Report{} = Repo.one(
        from r in Report,
        where: r.image_id == ^duplicate_id and
          r.body == ^"This image might be a duplicate of ##{original_id}.")
    end

    GenServer.cast(Dispatcher.Vidalia, {:set_callback, fn(original_id) ->
      GenServer.cast(Dispatcher.Vidalia, {:set_callback, fn(duplicate_id) ->
        GenServer.cast(Dispatcher.Vidalia, {:set_callback, fn(_) -> :ok end})

        check_for_duplicate_report.(original_id, duplicate_id)

        send parent_pid, :testing_finished
      end})

      upload_duplicate.(original_id)
    end})

    session |> post("/images", %{"image" => %{
      "image" => plug_upload(@tmp_path), "source" => "source.url",
      "tags" => "artist: msillzie, fandom: steven universe, vidalia"
    }})

    receive do
      :testing_finished -> :ok
    after
      2_000 -> flunk "test callback has not been invoked."
    end
  end
end
