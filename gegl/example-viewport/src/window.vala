namespace Example
{
    public class Window : Gtk.Window
    {
        public GLib.File _file;
        public GLib.File file {
            get {
                return this._file;
            }
            set {
                this._file = value;

                if (this._file != null) {
                    var pipeline = new Gegl.Node ();
                    pipeline.set_property ("dont-cache", true);

                    var source = pipeline.create_child ("gegl:load");
                    source.set_property ("path", this._file.get_path ());

                    this.content.node = source;  // TODO: Pass processed buffer rather than whole node
                                                 // TODO: How to get last child from the pipeline?
                }
            }
        }

        private Example.GeglContent content;
        private GtkClutter.Embed    embed;

        construct
        {
            this.setup ();
        }

        private void setup ()
        {
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
            this.content = new Example.GeglContent (null);

            var stage = this.embed.get_stage ();
            stage.set_background_color (Clutter.Color.from_pixel (0x222222FF));
            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR,
                                               Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            stage.set_content (this.content);

            this.add (this.embed);
        }

        private void on_open_button_clicked ()
        {
            var file_chooser = new Gtk.FileChooserDialog (
                    "Select image", this, Gtk.FileChooserAction.OPEN,
                    "_Cancel",
                    Gtk.ResponseType.CANCEL,
                    "_Open",
                    Gtk.ResponseType.ACCEPT);

            file_chooser.set_modal (true);
            file_chooser.set_transient_for (this);

            var file_filter = new Gtk.FileFilter ();
            file_filter.add_mime_type ("image/jpeg");
            file_filter.add_mime_type ("image/png");
            file_chooser.set_filter (file_filter);

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
                this.file = file_chooser.get_file ();
            }

            file_chooser.close ();
        }

        public override void dispose ()
        {
            this.content = null;

            base.dispose ();
        }
    }
}
