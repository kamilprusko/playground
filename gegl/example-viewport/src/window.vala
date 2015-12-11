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

                if (this._file != null)
                {
                    var pipeline = new Gegl.Node ();
                    pipeline.set_property ("dont-cache", true);

                    var source = pipeline.create_child ("gegl:load");
                    source.set_property ("path", this._file.get_path ());

                    this.view.node = source; // TODO: How to get last child from the pipeline?
                }
            }
        }

        public bool _is_fullscreen;
        public bool is_fullscreen {
            get {
                return this._is_fullscreen;
            }
            set {
                if (value == this._is_fullscreen) {
                    return;
                }

                if (value) {
                    this.fullscreen ();
                }
                else {
                    this.unfullscreen ();
                }
            }
        }

        private ClutterGegl.Actor view;
        private Clutter.Actor overlay;
        private Example.Viewport  viewport;
        private GtkClutter.Embed  embed;

        private const Gtk.TargetEntry[] TARGET_ENTRIES = {
            { "text/uri-list", Gtk.TargetFlags.OTHER_APP, 0 }
        };

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

            var fullscreen_button = new Gtk.Button.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.BUTTON);
            fullscreen_button.show_all ();
            header_bar.pack_end (fullscreen_button);

            fullscreen_button.clicked.connect (() => {
                this.fullscreen ();
            });

            this.embed = new GtkClutter.Embed ();
            this.embed.add_events (Gdk.EventMask.FOCUS_CHANGE_MASK |
                                   Gdk.EventMask.BUTTON_PRESS_MASK |
                                   Gdk.EventMask.BUTTON_RELEASE_MASK |
                                   Gdk.EventMask.KEY_PRESS_MASK |
                                   Gdk.EventMask.KEY_RELEASE_MASK |
                                   Gdk.EventMask.SCROLL_MASK);
            this.embed.has_focus = true;
            this.embed.show ();

            this.embed.button_press_event.connect((event) => {
                if (event.type == Gdk.EventType.DOUBLE_BUTTON_PRESS)
                {
                    if (this.is_fullscreen) {
                        this.unfullscreen ();
                    }
                    else {
                        this.fullscreen ();
                    }

                    return true;
                }

                return false;
            });

            // stage contents

            var stage = this.embed.get_stage ();
            stage.set_background_color (Clutter.Color.from_pixel (0x222222FF));

            // contents

            this.view = new ClutterGegl.Actor ();
            this.view.set_background_color (Clutter.Color.from_pixel (0x000000FF));

            this.view.x_align = Clutter.ActorAlign.CENTER;
            this.view.y_align = Clutter.ActorAlign.CENTER;

            // overlay

            this.overlay = new Clutter.Actor ();

            var prev_button = new Clutter.Actor ();
            prev_button.set_background_color (Clutter.Color.get_static (Clutter.StaticColor.RED));
            prev_button.set_size (40.0f, 40.0f);
            prev_button.set_margin_left (12.0f);
            prev_button.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.X_AXIS, 0.0f));
            prev_button.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.Y_AXIS, 0.5f));

            var next_button = new Clutter.Actor ();
            next_button.set_background_color (Clutter.Color.get_static (Clutter.StaticColor.RED));
            next_button.set_size (40.0f, 40.0f);
            next_button.set_margin_right (12.0f);
            next_button.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.X_AXIS, 1.0f));
            next_button.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.Y_AXIS, 0.5f));

            var toolbar = new Clutter.Actor ();
            toolbar.set_background_color (Clutter.Color.get_static (Clutter.StaticColor.RED));
            toolbar.set_size (90.0f, 40.0f);
            toolbar.set_margin_bottom (12.0f);
            toolbar.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.X_AXIS, 0.5f));
            toolbar.add_constraint (new Clutter.AlignConstraint (this.overlay, Clutter.AlignAxis.Y_AXIS, 1.0f));

            this.overlay.add_child (prev_button);
            this.overlay.add_child (next_button);
            this.overlay.add_child (toolbar);

            this.viewport = new Example.Viewport ();
            this.viewport.set_name ("viewport");
            this.viewport.add_child (this.view);

            stage.layout_manager = new Example.StackLayout ();
            stage.add_child (this.viewport);
            // stage.add_child (this.overlay);

            // drag and drop
            Gtk.drag_dest_set (this,
                               Gtk.DestDefaults.ALL,
                               TARGET_ENTRIES,
                               Gdk.DragAction.COPY | Gdk.DragAction.LINK);

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

        public override bool key_press_event (Gdk.EventKey event)
        {
            switch (event.keyval)
            {
                case Gdk.Key.Escape:
                    this.unfullscreen ();
                    return true;

                case Gdk.Key.F11:
                    if (this.is_fullscreen) {
                        this.unfullscreen ();
                    }
                    else {
                        this.fullscreen ();
                    }

                    return true;
            }

            return base.key_press_event (event);
        }

        public override bool window_state_event (Gdk.EventWindowState event)
        {
            var result = base.window_state_event (event);

            this._is_fullscreen = Gdk.WindowState.FULLSCREEN in event.new_window_state;
            this.notify_property ("is_fullscreen");

            return result;
        }

        public override void drag_data_received (Gdk.DragContext   context,
                                                 int               x,
                                                 int               y,
                                                 Gtk.SelectionData data,
                                                 uint              info,
                                                 uint              time)
        {
            if (data.get_length () >= 0)
            {
                var action = context.get_selected_action ();
                var success = false;

                foreach (var uri in data.get_uris ())
                {
                    this.file = GLib.File.new_for_uri (uri);

                    success = true;

                    break;
                }

                // TODO
                // var pixbuf = data.get_pixbuf ();

                Gtk.drag_finish (context, success, false, time);  // TODO: handle DragAction.MOVE
            }
            else {
                Gtk.drag_finish (context, false, false, time);
            }
        }
    }
}
