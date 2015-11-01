namespace Example 
{
    /**
     * Gegl Image Content for Clutter. We need only to display the output buffer here, do as little as possible. It should be possible to display rendered nodes at many surfaces without rendering them separately.
     */
    public class GeglContent : GLib.Object, Clutter.Content
    {
        private class RenderingThread : GLib.Object
        {
            public Gegl.Node        node;
            public Gegl.Buffer      buffer;
            public Gegl.Rectangle   rect;
            public GLib.SourceFunc  callback;
            public GLib.Cancellable cancellable;

            public RenderingThread (Gegl.Node       node)
                                    // Gegl.Rectangle  rect)
            {
                var rect = node.introspectable_get_bounding_box ();

                this.node        = node;
                this.rect        = rect;
                this.cancellable = new GLib.Cancellable ();

                this.buffer = new Gegl.Buffer.introspectable_new ("R'G'B' u8",
                                                                  this.rect.x,
                                                                  this.rect.y,
                                                                  this.rect.width,
                                                                  this.rect.height);
            }

            public void cancel ()
            {
                this.cancellable.cancel ();

                this.cancelled ();
            }

            public bool on_idle ()
            {
                if (!this.cancellable.is_cancelled ()) {
                    this.completed ();
                }

                return false;
            }

            public void* run ()
            {
                this.node.blit_buffer (this.buffer, null);

                GLib.Idle.add (this.on_idle, GLib.Priority.HIGH_IDLE);

                return null;
            }

            public override void dispose ()
            {
                this.cancel ();

                base.dispose ();
            }

            public signal void cancelled ();
            public signal void completed ();
        }

        private Gegl.Node _node;
        public Gegl.Node node {
            get {
                return this._node;
            }
            set {
                var node = value;

                if (this.node != null) {
                    this.node.invalidated.disconnect (this.on_node_invalidated);
                    this.node.computed.disconnect (this.on_node_computed);
                }

                if (node != null) {
                    node.invalidated.connect (this.on_node_invalidated);
                    node.computed.connect (this.on_node_computed);
                }

                this._node = node;

                this.invalidate_node ();
            }
        }

        private Cogl.Texture texture;
        private RenderingThread thread;

        public GeglContent (Gegl.Node? node)
        {
            this.node = node;
        }

        /**
         * Retrieves the natural size of the this, if any.
         */
        public bool get_preferred_size (out float width, out float height)
        {
            if (this.texture == null)
            {
                width = 0.0f;
                height = 0.0f;

                return false;
            }

            width = this.texture.get_width ();
            height = this.texture.get_height ();

            return true;
        }

        /**
         * Invalidates a Content.
         */
        public void invalidate ()
        {
        }

        private void invalidate_node ()
        {
            // TODO: only process the node if attached

            if (this.node != null)
            {
                var box = this.node.introspectable_get_bounding_box ();

                this.node.invalidated (box);
            }
        }

        /**
         *
         */
        public new void paint_content (Clutter.Actor     actor,
                                       Clutter.PaintNode node)
        {
            if (this.texture == null) {
                return;
            }

            var color = Clutter.Color.from_string ("#FFFFFF");
            var child_node = new Clutter.TextureNode (this.texture,
                                                      color,
                                                      Clutter.ScalingFilter.LINEAR,
                                                      Clutter.ScalingFilter.TRILINEAR);
            child_node.add_rectangle (actor.get_content_box ());
            child_node.set_name ("Gegl Content");

            node.add_child (child_node);
        }

        public void update_texture (Gegl.Buffer buffer)
        {
            Cogl.Texture texture = null;
            var rect             = buffer.get_extent ();

            Example.cogl_texture_from_buffer (ref texture, buffer, rect, 1.0);

            if (texture != null) {
                message ("cogl_texture %ux%u is set", texture.get_width (), texture.get_height ());

                this.texture = texture;

                this.invalidate ();
            }
            else {
                message ("cogl_texture_set_data_from_buffer() failed");
            }
        }

        private void on_node_invalidated (Gegl.Node      node,
                                          Gegl.Rectangle rectangle)
        {
            message ("node invalidated: %d, %d %dx%d", rectangle.x, rectangle.y, rectangle.width, rectangle.height);

            // TODO: check if invalidated area is visible, if it is then update the region

            // var rect = node.introspectable_get_bounding_box ();

            if (this.thread != null) {
                this.thread.cancel ();
            }

            this.thread = new RenderingThread (node);
            this.thread.completed.connect ((thread) => {
                this.update_texture (thread.buffer);

                this.thread = null;
            });

            try {
                Thread.create<void*> (this.thread.run, false);
            }
            catch (GLib.ThreadError error) {
                stderr.printf ("Thread error: %s\n", error.message);
            }
        }

        private void on_node_computed (Gegl.Node node, Gegl.Rectangle rectangle)
        {
            message ("node computed: %d, %d %dx%d", rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }
    }
}
