namespace Example
{
    public class Window : Gtk.Window
    {
        public GtkClutter.Embed    embed;

        public Clutter.Color background_color { get; set; }

        construct {
            this.setup ();
        }

        private void setup ()
        {
            // properties
            this.background_color = Clutter.Color.from_pixel (0x222222FF);

            // widgets
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
            var stage = this.embed.get_stage ();
            var pixbuf = new Gdk.Pixbuf.from_file ("data/surfer.png");
            var image = new Clutter.Image ();
            image.set_data (pixbuf.get_pixels (),
                            pixbuf.get_has_alpha ()
                              ? Cogl.PixelFormat.RGBA_8888
                              : Cogl.PixelFormat.RGB_888,
                            pixbuf.get_width (),
                            pixbuf.get_height (),
                            pixbuf.get_rowstride ());

            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR,
                                               Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            stage.set_content (image);

            // TODO: Gegl texture 
            //var pipeline = new Gegl.Node ();
            //pipeline.set_property ("dont-cache", true);

            //var image = pipeline.create_child ("gegl:load");
            //image.set_property ("path", "data/surfer.png");

            //var texture = new Example.GeglTexture ();
            //texture.node = pipeline;

            //this.viewport = new Example.Viewport ();
            //this.viewport.add_child (texture);

            //var stage = this.embed.get_stage ();
            //stage.add_child (this.viewport);

            // signals and bindings
            this.bind_property ("background-color", stage, "color", BindingFlags.SYNC_CREATE);


            this.add (this.embed);
        }
    }
}
