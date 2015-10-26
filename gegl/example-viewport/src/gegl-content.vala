namespace Example 
{
    /**
     * Gegl Image Content for Clutter. We need only to display the output buffer here, do as little as possible. It should be possible to display rendered nodes at many surfaces without rendering them separately.
     */
    public class GeglContent : GLib.Object, Clutter.Content
    {
        private Gegl.Node _node;
        public Gegl.Node node {
            get {
                return this._node;
            }
            set {
                var node = value;

                if (node != null) {
                    node.invalidated.connect (this.on_node_invalidated);
                    node.computed.connect (this.on_node_computed);
                }

                this._node = node;

                this.invalidate ();
            }
        }

        private Cogl.Texture texture;
        private Gegl.Processor processor;

        public GeglContent (Gegl.Node? node)
        {
            this.node = node;
        }

        /**
         * Retrieves the natural size of the this, if any.
         */
        public bool get_preferred_size (out float width, out float height)
        {
            if (this.texture == null) {
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
            // TODO: only process the node if attached

            if (this.node != null) {
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

            // TODO: Make it async

            var box = node.introspectable_get_bounding_box ();
            var buffer = new Gegl.Buffer.introspectable_new ("R'G'B' u8", box.x, box.y, box.width, box.height);

            node.blit_buffer (buffer, box);

            this.update_texture (buffer);
        }

        private void on_node_computed (Gegl.Node node, Gegl.Rectangle rectangle)
        {
            message ("node computed: %d, %d %dx%d", rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }

        //private bool process_idle ()
        //    // GTask *task = G_TASK (user_data);
        //    // PhotosBaseItem *self;
        //    // GCancellable *cancellable;

        //    // cancellable = g_task_get_cancellable (task);

        //    if (g_cancellable_is_cancelled (cancellable)) {
        //        goto done;
        //    }

        //    var progress = 0.0;  // there is also this.processor.progress, 

        //    if (this.processor.work (out progress))
        //    {
        //        message ("progress = %g", progress);

        //        return GLib.Source.CONTINUE;
        //    }

        //    message ("progress = %g", progress);

        //    // g_task_return_pointer (task, NULL, NULL);

        //    return GLib.Source.REMOVE;
        //}
    }
}
