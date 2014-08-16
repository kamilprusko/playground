
using GLib;


public class Example.Project : Gom.Resource
{
    public int id { get; set; }
    public string name { get; set; }

    static construct {
        set_table ("projects");
        set_primary_key ("id");
    }

    public Project (string name)
    {
        this.name = name;
    }
}


namespace Example.Utils
{
    private string get_file_contents (File file,
                                      Cancellable? cancellable = null)
                                      throws Error
    {
        var data_input_stream = new GLib.DataInputStream (file.read ());
        var file_contents = data_input_stream.read_until ("",
                                                          null,
                                                          cancellable);
        return file_contents;
    }
}


public class Example.Application : GLib.Application
{
    private Gom.Repository repository;

    private const uint REPOSITORY_VERSION = 1;


    public Application () {
        GLib.Object (application_id: "org.example.application",
                     flags: ApplicationFlags.FLAGS_NONE);
    }

    public override void activate ()
    {
        try {
            // var filter_args = new GLib.Array<GLib.Value?> ();
            // var filter = new Gom.Filter.sql ("id > 0",
            //                                  filter_args);
            var value1 = Value (typeof (string));
            value1.set_string ("Pomodoro");
            var filter = new Gom.Filter.eq (typeof (Example.Project),
                                            "name",
                                            value1);

            var project = this.repository.find_one_sync (
                                       typeof (Example.Project),
                                       filter) as Example.Project;

            GLib.message ("Project #%d, \"%s\"", project.id, project.name);
        }
        catch (GLib.Error error) {
            GLib.warning ("Could not find project: %s", error.message);
        }
    }

    public override void startup ()
    {
        this.hold ();

        base.startup ();

        this.setup_repository ();

        this.release ();
    }

    public override void shutdown ()
    {
        this.destroy_repository ();

        base.shutdown ();
    }

    private static bool migrate_repository (Gom.Repository repository,
                                            Gom.Adapter    adapter,
                                            uint           version)
                                            throws GLib.Error
    {
        var file = File.new_for_uri ("resource:///org/example" +
                                     "/database/migration-" +
                                     version.to_string() +
                                     ".sql");
        var query = Utils.get_file_contents (file);

        GLib.debug ("Migrating database to version %u", version);

        /* Gom.Adapter.execute_sql is limited just to one query,
         * so we need to use Sqlite API directly
         */
        unowned Sqlite.Database database = adapter.get_handle ();
        var error_message = (string) null;

        if (database.exec (query, null, out error_message) != Sqlite.OK) {
            throw new Gom.Error.COMMAND_SQLITE (error_message);
        }

        return true;
    }

    private void setup_repository ()
    {
        this.hold ();
        this.mark_busy ();

        /* Open database handle */
        var adapter = new Gom.Adapter ();
        var uri = File.new_for_path ("example.db").get_uri ();

        try {
            adapter.open_sync (uri);
            GLib.debug ("Opened database '%s'", uri);
        }
        catch (GLib.Error error) {
            GLib.error ("Failed to open database '%s': %s",
                        uri,
                        error.message);
        }

        /* Migrate database if needed */
        this.repository = new Gom.Repository (adapter);

        try {
            this.repository.migrate_sync (Application.REPOSITORY_VERSION,
                                          Application.migrate_repository);
        }
        catch (GLib.Error error) {
            GLib.error ("Failed to migrate database: %s", error.message);
        }

        this.unmark_busy ();
        this.release ();

        /*
        this.repository.migrate_async.begin (Application.REPOSITORY_VERSION,
                                             Application.migrate_repository,
                                             (obj, res) => {
            try {
                this.repository.migrate_async.end (res);
            }
            catch (GLib.Error error) {
                GLib.error ("Failed to migrate database: %s",
                               error.message);
            }

            this.unmark_busy ();
            this.release ();
        });
        */
    }

    private void destroy_repository ()
    {
        if (this.repository != null)
        {
            try {
                this.repository.adapter.close_sync ();
            }
            catch (GLib.Error error) {
                GLib.error ("Failed to close adapter: %s",
                            error.message);
            }

            this.repository = null;
        }
    }
}


public int main (string[] args)
{
    var application = new Example.Application ();
    var status = application.run (args);
    return status;
}
