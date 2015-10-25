public int main (string[] args)
{
    Gegl.init (ref args);

    if (GtkClutter.init (ref args) != Clutter.InitError.SUCCESS) {
        error ("Unable to initialize GtkClutter");
    }

    Gtk.init (ref args);

    var gtk_settings = Gtk.Settings.get_default ();
    gtk_settings.set ("gtk-application-prefer-dark-theme", true);

    // Gegl.load_module_directory ("./operations");
    // assert (Gegl.has_operation ("example:cogl-texture"));

    var window = new Example.Window ();
    window.title = "GEGL Viewport";
    window.window_position = Gtk.WindowPosition.CENTER;
    window.set_default_size (600, 400);
    window.destroy.connect (Gtk.main_quit);

    window.show_all ();

    Gtk.main ();

    Gegl.exit ();

    return 0;
}
