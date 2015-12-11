namespace Example
{
    /**
     * Unlike Clutter.ScrollActor here scroll_mode is set automatically 
     */
    public class ScrollActor : Clutter.ScrollActor
    {
        private struct ChildMeta
        {
            public unowned Clutter.Actor actor;
            public Clutter.ActorBox      allocation;
            public float                 min_width;
            public float                 min_height;
            public float                 width;
            public float                 height;
        }

        public float scroll_x { get; set; }
        public float scroll_y { get; set; }

        construct {
            this.reactive = true;

            var child_transform = (Clutter.Matrix) Cogl.Matrix.identity ();

            this.set_child_transform (child_transform);

            this.notify["scroll-x"].connect(this.update_child_transform);
            this.notify["scroll-y"].connect(this.update_child_transform);

            var pan_action = new Example.PanAction ();
            this.add_action_with_name ("pan", pan_action);
        }

        private void update_child_transform ()
        {
            var child_transform = (Clutter.Matrix) Cogl.Matrix.identity ();

            child_transform.translate (this._scroll_x, this._scroll_y, 0.0f);

            this.set_child_transform (child_transform);
        }

        public override void allocate (Clutter.ActorBox        box,
                                       Clutter.AllocationFlags flags)
        {
            var x               = 0.0f;
            var y               = 0.0f;
            var height          = 0.0f;
            var width           = 0.0f;
            var children_width  = 0.0f;
            var children_height = 0.0f;
            var scroll_mode     = Clutter.ScrollMode.NONE;

            Clutter.Actor?        child            = null;
            Clutter.ActorBox?     child_allocation = null;
            GLib.List<ChildMeta?> child_meta_list  = new GLib.List<ChildMeta?> ();

            box.get_origin (out x, out y);
            box.get_size (out width, out height);

            var iter = Clutter.ActorIter ();
            iter.init (this);

            while (iter.next (out child))
            {
                var child_meta = ChildMeta () {
                    actor      = child,
                    allocation = Clutter.ActorBox (),
                    width      = 0.0f,
                    height     = 0.0f,
                    min_width  = 0.0f,
                    min_height = 0.0f
                };

                child.get_preferred_size (out child_meta.min_width,
                                          out child_meta.min_height,
                                          out child_meta.width,
                                          out child_meta.height);

                child_meta.allocation.x2 = child_meta.width;
                child_meta.allocation.y2 = child_meta.height;

                if (children_width < child_meta.width) {
                    children_width = child_meta.width;
                }

                if (children_height < child_meta.height) {
                    children_height = child_meta.height;
                }

                child_meta_list.prepend (child_meta);
            }

            if (children_width > width) {
                scroll_mode |= Clutter.ScrollMode.HORIZONTALLY;
            }

            if (children_height > height) {
                scroll_mode |= Clutter.ScrollMode.VERTICALLY;
            }

            if (this.scroll_mode != scroll_mode) {
                this.scroll_mode = scroll_mode;
            }

            foreach (var child_meta in child_meta_list)
            {
                child = child_meta.actor;

                if (!(Clutter.ScrollMode.HORIZONTALLY in scroll_mode))
                {
                    child_meta.allocation.x1 = Math.floorf ((width - child_meta.width) * get_actor_align_factor (child.x_align) + x);
                    child_meta.allocation.x2 = child_meta.allocation.x1 + (child.x_align == Clutter.ActorAlign.FILL ? width : child_meta.width);
                }

                if (!(Clutter.ScrollMode.VERTICALLY in scroll_mode))
                {
                    child_meta.allocation.y1 = Math.floorf ((height - child_meta.height) * get_actor_align_factor (child.y_align) + y);
                    child_meta.allocation.y2 = child_meta.allocation.y1 + (child.y_align == Clutter.ActorAlign.FILL ? height : child_meta.height);
                }

                child.allocate (child_meta.allocation, flags);
            }

            base.allocate (box, flags);
        }
    }

    private static float get_actor_align_factor (Clutter.ActorAlign align)
    {
        switch (align)
        {
            case Clutter.ActorAlign.CENTER:
                return 0.5f;

            case Clutter.ActorAlign.END:
                return 1.0f;

            case Clutter.ActorAlign.START:
            case Clutter.ActorAlign.FILL:
                return 0.0f;
        }

        return 0.0f;
    }
}
