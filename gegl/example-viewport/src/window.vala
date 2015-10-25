namespace Example
{
    public class Window : Gtk.Window
    {
        public Clutter.Color background_color { get; set; }

        private GtkClutter.Embed embed;
        private Gegl.Node        pipeline;
        private Gegl.Node        display_node;

        construct
        {
            this.setup ();
        }

        private void setup_pipeline ()
        {
            var pipeline = new Gegl.Node ();
            pipeline.set_property ("dont-cache", true);

            var source = pipeline.create_child ("gegl:load");
            source.set_property ("path", "data/color-checker.png");

            this.display_node = source;
            this.pipeline = pipeline;
        }

        private void setup ()
        {
            this.setup_pipeline ();

            // properties
            this.background_color = Clutter.Color.from_pixel (0x222222FF);

            // widgets
            var header_bar = new Gtk.HeaderBar ();
            header_bar.title = "GEGL Viewport";
            header_bar.show_close_button = true;
            header_bar.show_all ();
            this.set_titlebar (header_bar);

            var open_button = new Gtk.Button.from_stock (Gtk.Stock.OPEN);
            open_button.show_all ();
            header_bar.pack_start (open_button);

            open_button.clicked.connect (this.on_open_button_clicked);

            this.embed = new GtkClutter.Embed ();
            this.embed.add_events (Gdk.EventMask.FOCUS_CHANGE_MASK |
                                   Gdk.EventMask.BUTTON_PRESS_MASK |
                                   Gdk.EventMask.BUTTON_RELEASE_MASK |
                                   Gdk.EventMask.KEY_PRESS_MASK |
                                   Gdk.EventMask.KEY_RELEASE_MASK |
                                   Gdk.EventMask.SCROLL_MASK);
            this.embed.has_focus = true;
            this.embed.show ();

            // stage contents
            var content = new Example.GeglContent (this.display_node);

            var stage = this.embed.get_stage ();
            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR,
                                               Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            stage.set_content (content);

            // signals and bindings
            this.bind_property ("background-color", stage, "color", BindingFlags.SYNC_CREATE);

            this.add (this.embed);

            this.display_node.invalidated (this.display_node.introspectable_get_bounding_box ());
        }

        private void on_open_button_clicked ()
        {
            // FileChooserDialog
            var file_chooser = new Gtk.FileChooserDialog (
                    "Select image", this, Gtk.FileChooserAction.OPEN,
                    "_Cancel",
                    Gtk.ResponseType.CANCEL,
                    "_Open",
                    Gtk.ResponseType.ACCEPT);

            var file_filter = new Gtk.FileFilter ();
            file_filter.add_mime_type ("image/jpeg");
            file_filter.add_mime_type ("image/png");
            file_chooser.set_filter (file_filter);

            file_chooser.set_modal (true);
            file_chooser.set_transient_for (this);

            var preview_area = new Gtk.Image ();
            file_chooser.set_preview_widget (preview_area);
            file_chooser.update_preview.connect (() => {
                var file = GLib.File.new_for_uri (file_chooser.get_preview_uri ());

                if (file.is_native ()) {
                    try {
                        var pixbuf = new Gdk.Pixbuf.from_file_at_scale (file.get_path (),
                                                                        150,
                                                                        150,
                                                                        true);
                        preview_area.set_from_pixbuf (pixbuf);
                        preview_area.show ();
                    }
                    catch (Error error) {
                        preview_area.hide ();
                    }
                }
                else {
                    preview_area.hide ();
                }
            });

            if (file_chooser.run () == Gtk.ResponseType.ACCEPT)
            {
                var uris = file_chooser.get_uris ();
                stdout.printf ("Selection:\n");

                foreach (unowned string uri in uris) {
                    stdout.printf (" %s\n", uri);
                }
            }

            file_chooser.close ();
        }

        public override void dispose ()
        {
            this.pipeline = null;

            base.dispose ();
        }
    }
}
