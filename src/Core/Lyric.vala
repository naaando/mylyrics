
public class Lyrics.Lyric : Object {
    private struct Metadata {
        string tag;
        string info;
    }

    private Metadata[] metadata = {};
    Gee.TreeMap<uint64?, string> lines = new Gee.TreeMap<uint64?, string> ();
    Gee.BidirMapIterator<uint64?, string> lrc_iterator;
    int offset = 0;

    public void add_metadata (string _tag, string _info) {
        metadata += Metadata () { tag = _tag, info = _info };
        if (_tag == "offset") {
            offset = int.parse (_info);
            message (@"Lyric offset: $offset");
        }
    }

    public void add_line (uint64 time, string text) {
        lines.set (time, text);
    }

    Gee.BidirMapIterator<uint64?, string> get_iterator () {
        if (lrc_iterator == null) {
            lrc_iterator = lines.bidir_map_iterator ();
            lrc_iterator.first ();
        }

        return lrc_iterator;
    }

    public string get_current_line (uint64 time_in_us) {
        while (get_iterator ().get_key () < time_in_us + offset) {
            if (!get_iterator ().has_next ()) {
                get_iterator ().first ();
                return "";
            }

            get_iterator ().next ();
        }

        return get_iterator ().get_value ().to_string ();
    }

    public string to_string () {
        var builder = new StringBuilder ();

        builder.append (@"Metadata:\n");
        foreach (var data in metadata) {
            builder.append (@"$(data.tag) = ");
            builder.append (@"$(data.info)\n");
        }

        builder.append (@"Lyric:\n");
        lines.foreach ((item) => {
            builder.append (@"$(item.key) : $(item.value)\n");
            return true;
        });

        return builder.str;
    }
}