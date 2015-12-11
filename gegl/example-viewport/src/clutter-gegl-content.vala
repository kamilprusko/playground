namespace ClutterGegl
{
    private const bool USE_THREADED_RENDERING = false;

    private class RenderingThread : GLib.Object
    {
        public Gegl.Node        node;
        public Gegl.Buffer      buffer;
        public Gegl.Rectangle   rect;
        public GLib.Cancellable cancellable;

        public RenderingThread (Gegl.Node node)
        {
            this.node        = node;
            this.rect        = node.introspectable_get_bounding_box ();
            this.cancellable = new GLib.Cancellable ();
        }

        public void cancel ()
        {
            this.cancellable.cancel ();
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
            this.buffer = new Gegl.Buffer.introspectable_new ("R'G'B' u8",
                                                              this.rect.x,
                                                              this.rect.y,
                                                              this.rect.width,
                                                              this.rect.height);

            this.node.blit_buffer (this.buffer, null);

            GLib.Idle.add (this.on_idle, GLib.Priority.HIGH_IDLE);

            return null;
        }

        public signal void completed ();

        public override void dispose ()
        {
            this.cancel ();

            base.dispose ();
        }
    }

    /**
     * Gegl Image Content for Clutter. We need only to display the output buffer here, do as little as possible. It should be possible to display rendered nodes at many surfaces without rendering them separately.
     *
     * TODO: could be merged into ClutterGegl.Actor by overriding paint_node method,
     *       in theory Content should be able to be shared between actors, but as actors may have different visible
     *       areas it is pointless
     */
    public class Content : GLib.Object, Clutter.Content
    {
        private Gegl.Node _node;
        public Gegl.Node node {
            get {
                return this._node;
            }
            set {
                if (this._node != null) {
                    this._node.invalidated.disconnect (this.on_node_invalidated);
                    this._node.computed.disconnect (this.on_node_computed);
                }

                this._node = value;

                if (this._node != null) {
                    this._node.invalidated.connect (this.on_node_invalidated);
                    this._node.computed.connect (this.on_node_computed);

                    this.invalidate_node ();
                }
            }
        }

        private Cogl.Texture texture;
        private RenderingThread thread;

        /**
         * Retrieves the natural size of the this, if any.
         */
        public bool get_preferred_size (out float width,
                                        out float height)
        {
            if (this.node != null)
            {
                var rect = this.node.introspectable_get_bounding_box ();

                width  = (float) rect.width;
                height = (float) rect.height;

                return true;
            }
            else {
                width  = 0.0f;
                height = 0.0f;

                return false;
            }
        }

        /**
         * This function should be called by Content implementations when they change the way a the content
         * should be painted regardless of the actor state.
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

        public new void paint_content (Clutter.Actor     actor,
                                       Clutter.PaintNode root)
        {
            if (this.texture != null)
            {
                var color      = Clutter.Color.get_static (Clutter.StaticColor.WHITE);
                var min_filter = Clutter.ScalingFilter.NEAREST;
                var mag_filter = Clutter.ScalingFilter.NEAREST;

                actor.get_content_scaling_filters (out min_filter,
                                                   out mag_filter);

                var node = new Clutter.TextureNode (this.texture,  // TODO: store texture data in actor
                                                    color,
                                                    min_filter,
                                                    mag_filter);
                node.add_rectangle (actor.get_content_box ());
                node.set_name ("Gegl Content");

                root.add_child (node);
            }
            else {
                // displayed when first rendering
                var color = Clutter.Color.get_static (Clutter.StaticColor.BLACK);
                var node  = new Clutter.ColorNode (color);
                node.add_rectangle (actor.get_content_box ());
                node.set_name ("Gegl Content");

                root.add_child (node);
            }
        }

        private void update_texture (Gegl.Buffer buffer)
        {
            Cogl.Texture texture = null;
            var rect             = buffer.get_extent ();

            Example.cogl_texture_from_buffer (ref texture, buffer, rect, 1.0);

            if (texture != null)
            {
                this.texture = texture;

                this.invalidate ();
            }
            else {
                stderr.printf ("cogl_texture_set_data_from_buffer() failed");
            }
        }

        private void on_node_invalidated (Gegl.Node      node,
                                          Gegl.Rectangle rectangle)
        {
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

            if (USE_THREADED_RENDERING) {
                try {
                    Thread.create<void*> (this.thread.run, false);
                }
                catch (GLib.ThreadError error) {
                    stderr.printf ("Thread error: %s\n", error.message);
                }
            }
            else {
                thread.run ();
            }

            this.size_changed ();
        }

        private void on_node_computed (Gegl.Node node, Gegl.Rectangle rectangle)
        {
        }

        public signal void size_changed ();

        public override void dispose ()
        {
            if (this._node != null) {
                this._node.invalidated.disconnect (this.on_node_invalidated);
                this._node.computed.disconnect (this.on_node_computed);
            }

            base.dispose ();
        }
    }
}
