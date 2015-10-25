namespace Example 
{
//    internal const Gegl.AbyssPolicy GEGL_ABYSS_NONE = 0;

    /**
     * Gegl Image Content for Clutter. We need only to display the output buffer here, do as little as possible. It should be possible to display rendered nodes at many surfaces without rendering them separately.
     */
    public class GeglImage : GLib.Object, Clutter.Content  // TODO: name it GeglContent or GeglDisplay? Allow to change node at runtime
    {
        private Gegl.Node _node;
        public Gegl.Node node {
            get {
                return this._node;
            }
            set {
                var node = value;

                node.invalidated.connect (this.on_node_invalidated);
                node.computed.connect (this.on_node_computed);

                this._node = node;
            }
        }

        private Cogl.Texture texture;
        private Gegl.Processor processor;

        // private uint idle_id;

        public GeglImage (Gegl.Node node)
        {
            this.node = node;

            // var buffer = new Gegl.Buffer.introspectable_new ("R'G'B' u8", 0, 0, 600, 455);
            // node.set_property ("buffer", buffer);

//            this.update_texture ();

            // this.idle_id = GLib.Idle.add (this.on_idle_timeout);
        }

        /**
         * Retrieves the natural size of the this, if any.
         */
        public bool get_preferred_size (out float width, out float height)
        {
            // var bounding_box = this.node.get_bounding_box ();

            // width = bounding_box.width;
            // height = bounding_box.height;

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
            // only process the node if attached

            this.node.process ();
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

//            var child_node = new Clutter.TextureNode (this.texture,
//                                                      color,
//                                                      Clutter.ScalingFilter.LINEAR,
//                                                      Clutter.ScalingFilter.TRILINEAR);  // Good for viewing and forbidding, can make a smooth zoom with that
            var child_node = new Clutter.TextureNode (this.texture,
                                                      color,
                                                      Clutter.ScalingFilter.LINEAR,
                                                      Clutter.ScalingFilter.NEAREST);  // Good for viewing and editing as long as zoom is at set at a strict level (x0.5 x2, x3)
            child_node.add_rectangle (actor.get_content_box ());
            child_node.set_name ("Gegl Content");

            node.add_child (child_node);
        }

//        /**
//         * This signal is emitted each time a Content implementation is assigned to a Actor.
//         */
//        public override signal void attached (Clutter.Actor actor)
//        {
//        }

//        /**
//         * This signal is emitted each time a Content implementation is removed from a Actor.
//         */
//        public override signal void detached (Clutter.Actor actor)
//        {
//        }

        private void update_texture (Gegl.Buffer buffer)
        {
//            Gegl.Buffer buffer = null;

//            var buffer_value = this.node.introspectable_get_property ("buffer");

//            if (buffer_value != null)
//            {
//                buffer = buffer_value as Gegl.Buffer;
//            }

//            if (buffer != null)
//            {
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
//            }
//            else
//            {
//                message ("Failed to get a buffer");
//            }
        }

        /** on_node_invalidated:
         * @node: The node that was invalidated.
         * @rectangle: The area that changed.
         */
        private void on_node_invalidated (Gegl.Node node, Gegl.Rectangle rectangle)
        {
            message ("node invalidated: %d, %d %dx%d", rectangle.x, rectangle.y, rectangle.width, rectangle.height);

            // check if invalidated area is visible, if it is then update the region

            // TODO: Make it async

//            node.process ();

            var box = node.introspectable_get_bounding_box ();
            var buffer = new Gegl.Buffer.introspectable_new ("R'G'B' u8", box.x, box.y, box.width, box.height);

            node.blit_buffer (buffer, box);

            this.update_texture (buffer);
        }

        private void on_node_computed (Gegl.Node node, Gegl.Rectangle rectangle)
        {
            message ("node computed: %d, %d %dx%d", rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }









//        public void render ()  // could to be async method?
//        {
//            this.processor.work ();

            // this.node.process ();

            // gegl:write-buffer
            // can write to existing buffer
            
            // public void blit_buffer (Gegl.Buffer? buffer, Gegl.Rectangle? roi);


//            var rect = 
//            var scale = 1.0;
//            var buffer = g_malloc (rect.width * rect.height * 4);

//            this.node.blit (this.node,
//                            scale,
//                            rect,
//                            babl_format ("R'G'B'A u8"),
//                            buffer,
//                            rect.width * 4,
//                            Gegl.BlitFlags.CACHE);

//            this.set_data (pixbuf.get_pixels (),
//                           pixbuf.get_has_alpha ()
//                             ? Cogl.PixelFormat.RGBA_8888
//                             : Cogl.PixelFormat.RGB_888,
//                           pixbuf.get_width (),
//                           pixbuf.get_height (),
//                           pixbuf.get_rowstride ());

//          /* XXX: should reuse a buffer allocation, to reduce alloc/free load */
//          buffer = g_malloc (rect->width * rect->height * 4);
//          gegl_node_blit (priv->node, priv->scale,
//                          rect,
//                          babl_format ("R'G'B'A u8"),
//                          buffer,
//                          rect->width * 4,
//                          GEGL_BLIT_CACHE);

//          clutter_texture_set_area_from_rgb_data (CLUTTER_TEXTURE (view),
//                                                  buffer,
//                                                  TRUE,
//                                                  rect->x, rect->y,
//                                                  rect->width, rect->height,
//                                                  rect->width * 4,  /* rowstride */
//                                                  4,                /* bpp   */
//                                                  0,                /* flags */
//                                                  NULL);            /* error */

//        }


//        private void grab_texture ()
//        {
//            var property_value = GLib.Value (typeof (Cogl.Texture));

//            this.node.get_property ("buffer", ref property_value);

//            var texture = property_value.get_object () as Cogl.Texture;

//            
//        }

//        private bool on_idle_timeout ()
//        {
////            var property_value = GLib.Value (typeof (Gegl.Buffer));

//            // this.node.get_property ("buffer", ref property_value);
//            // var property_value = this.node.introspectable_get_property ("buffer");

//            var buffer = this.node.introspectable_get_property ("buffer") as Gegl.Buffer;
//            // var buffer = property_value.get_object () as Gegl.Buffer;

//            if (buffer == null) {
//                return true;  // try again
//            }
//            else {
//                var rect = this.node.introspectable_get_bounding_box ();

//                this.buffer_data = buffer.introspectable_get (rect,
//                                                              1.0,  // scale
//                                                              "R'G'B' u8",  // format
//                                                              GEGL_ABYSS_NONE);
//                this.set_data (this.buffer_data,
//                               Cogl.PixelFormat.RGB_888,
//                               rect.width,
//                               rect.height,
//                               Gegl.AUTO_ROWSTRIDE
//                               );
//            }

//            return false;
//        }

/*
        private uint8[] buffer_data;

        private void update ()
        {
            var property_value = GLib.Value (typeof (Gegl.Buffer));

            this.node.get_property ("buffer", ref property_value);

            var buffer = property_value.get_object () as Gegl.Buffer;

            if (buffer == null) {
                message ("buffer is null");
            }
            else {
                //clutter_texture_set_area_from_rgb_data (CLUTTER_TEXTURE (view),
                //                                        buffer,
                //                                        TRUE,
                //                                        rect->x, rect->y,
                //                                        rect->width, rect->height,
                //                                        rect->width * 4,  // rowstride
                //                                        4,                // bpp
                //                                        0,                // flags
                //                                        NULL);            // error
                // babl_format ("R'G'B'A u8"),

                var rect = this.node.introspectable_get_bounding_box ();
                message ("Rect: (%d, %d) %d x %d", rect.x, rect.y, rect.width, rect.height);

                this.buffer_data = buffer.introspectable_get (rect,
                                                              1.0,  // scale
                                                              "R'G'B' u8",  // format
                                                              GEGL_ABYSS_NONE);
                this.set_data (this.buffer_data,
                               // buffer.get_has_alpha ()
                               // ? Cogl.PixelFormat.RGBA_8888,
                                 Cogl.PixelFormat.RGB_888,
                               rect.width,
                               rect.height,
                               Gegl.AUTO_ROWSTRIDE
                               );


    //            var pixbuf = new Gdk.Pixbuf.from_file ("data/surfer.png");
    //            this.set_data (pixbuf.get_pixels (),
    //                            pixbuf.get_has_alpha ()
    //                              ? Cogl.PixelFormat.RGBA_8888
    //                              : Cogl.PixelFormat.RGB_888,
    //                            pixbuf.get_width (),
    //                            pixbuf.get_height (),
    //                            pixbuf.get_rowstride ());
            }
        }
*/

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
