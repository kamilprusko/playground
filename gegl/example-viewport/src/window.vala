namespace Example
{
    public class Window : Gtk.Window
    {
        public Clutter.Color background_color { get; set; }

        private GtkClutter.Embed embed;
        private Gegl.Node        pipeline;
        private Gegl.Node        display_node;

        construct {
            this.setup ();
        }

        private void on_buffer_changed ()
        {
            message ("buffer changed");
        }

        private void setup_pipeline ()
        {
            var pipeline = new Gegl.Node ();
            pipeline.set_property ("dont-cache", true);

            var source = pipeline.create_child ("gegl:load");
            source.set_property ("path", "data/color-checker.png");

            var sink = pipeline.create_child ("gegl:buffer-sink");
            source.link (sink);

            // this.display_node = pipeline.get_output_proxy ("output");
            this.display_node = sink;

            this.pipeline = pipeline;
        }

        private void setup ()
        {
            this.setup_pipeline ();

            this.display_node.process ();  // FIXME TODO: process the node by scheduling a task, mere .process () is a blocking operation

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
            // TODO: There may be many display nodes (in theory) so we should pass the
            var image = new Example.GeglImage (this.display_node);

            var stage = this.embed.get_stage ();
            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR,
                                               Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            stage.set_content (image);

            // signals and bindings
            this.bind_property ("background-color", stage, "color", BindingFlags.SYNC_CREATE);

            this.add (this.embed);
        }

        public override void dispose ()
        {
            this.pipeline = null;

            base.dispose ();
        }
    }
}
