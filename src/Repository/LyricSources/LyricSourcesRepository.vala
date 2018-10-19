public class LyricSources.Repository : Lyrics.IRepository, Object {
    string dbus_name;
    string dbus_path;
    LyricSources.Downloader? downloader;

    public Repository (string _dbus_name, string _dbus_path) {
        dbus_name = _dbus_name;
        dbus_path = _dbus_path;

        load_connection ();
    }

    void load_connection () {
        downloader = Bus.get_proxy_sync (BusType.SESSION, dbus_name, dbus_path);
    }

    public Gee.Collection<Lyrics.ILyricFile> find (Lyrics.Metasong song) {
        if (downloader == null) {
            load_connection ();
        }

        var metadata = new HashTable <string, Variant> (null, null);
        metadata["artist"] = song.artist;
        metadata["title"] = song.title;
        metadata["album"] = song.album;

        var loop = new MainLoop ();
        var ticket = downloader.search (metadata);
        var collection = new Gee.ArrayList <Lyrics.ILyricFile> ();

        downloader.search_complete.connect ((id, b, results) => {
            if (ticket == id) {
                print (@"ID $id B $b\n");

                foreach (var result in results) {
                    collection.add (new LyricsSources.File (downloader, result));
                }
                loop.quit ();
            }
        });

        loop.run ();
        return collection;
    }
}