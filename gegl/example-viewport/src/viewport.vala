namespace Example
{
    public class Viewport : Clutter.Actor
    {
        private static bool transform_to_adjustment_value (GLib.Binding   binding,
                                                           GLib.Value     source_value,
                                                           ref GLib.Value target_value)
        {
            var value = - source_value.get_float ();

            target_value.set_double ((double) value);

            return true;
        }

        private static bool transform_from_adjustment_value (GLib.Binding   binding,
                                                             GLib.Value     source_value,
                                                             ref GLib.Value target_value)
        {
            var value = - source_value.get_double ();

            target_value.set_float ((float) value);

            return true;
        }

        public Clutter.ScrollMode scroll_mode {
            get {
                return this.scroll_actor.scroll_mode;
            }
            set {
                this.scroll_actor.scroll_mode = value;
            }
        }

        private Gtk.Adjustment      hadjustment;
        private Gtk.Adjustment      vadjustment;
        private Clutter.Actor       hscrollbar;
        private Clutter.Actor       vscrollbar;
        private Clutter.Actor       resize_grip;
        private Example.ScrollActor scroll_actor;

        construct
        {
            this.clip_to_allocation = true;

            this.scroll_actor = new Example.ScrollActor ();

            this.hadjustment = new Gtk.Adjustment (0.0, 0.0, 0.0, 5.0, 10.0, 0.0);
            this.vadjustment = new Gtk.Adjustment (0.0, 0.0, 0.0, 5.0, 10.0, 0.0);

            var vscrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, this.vadjustment);
            this.vscrollbar = new GtkClutter.Actor.with_contents (vscrollbar);

            var hscrollbar = new Gtk.Scrollbar (Gtk.Orientation.HORIZONTAL, this.hadjustment);
            this.hscrollbar = new GtkClutter.Actor.with_contents (hscrollbar);

            this.resize_grip = new Clutter.Actor ();
            this.resize_grip.set_background_color (Clutter.Color.from_pixel (0x333333FF));

//            this.child_set_property (this.vscrollbar, "internal", true);
//            this.child_set_property (this.hscrollbar, "internal", true);
//            this.child_set_property (this.resize_grip, "internal", true);

            this.vscrollbar.set_data<bool> ("internal", true);
            this.hscrollbar.set_data<bool> ("internal", true);
            this.resize_grip.set_data<bool> ("internal", true);

            base.add_child (this.scroll_actor);
            base.add_child (this.vscrollbar);
            base.add_child (this.hscrollbar);
            base.add_child (this.resize_grip);

            this.allocation_changed.connect (this.on_allocation_changed);

            this.scroll_actor.actor_added.connect (this.on_scroll_actor_actor_added);
            this.scroll_actor.actor_removed.connect (this.on_scroll_actor_actor_removed);

            this.scroll_actor.notify["scroll-mode"].connect(this.on_scroll_mode_notify);

            this.scroll_actor.bind_property ("scroll-x",
                                             this.hadjustment,
                                             "value",
                                             GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE,
                                             transform_to_adjustment_value,
                                             transform_from_adjustment_value);

            this.scroll_actor.bind_property ("scroll-y",
                                             this.vadjustment,
                                             "value",
                                             GLib.BindingFlags.BIDIRECTIONAL | GLib.BindingFlags.SYNC_CREATE,
                                             transform_to_adjustment_value,
                                             transform_from_adjustment_value);
        }

        private void on_scroll_mode_notify ()
        {
            var scroll_mode = this.scroll_mode;

            this.vscrollbar.visible = Clutter.ScrollMode.VERTICALLY in scroll_mode;
            this.hscrollbar.visible = Clutter.ScrollMode.HORIZONTALLY in scroll_mode;
            this.resize_grip.visible = this.vscrollbar.visible || this.hscrollbar.visible;

            this.notify_property ("scroll-mode");

            this.queue_relayout ();
        }

        public override void allocate (Clutter.ActorBox        box,
                                       Clutter.AllocationFlags flags)
        {
            var height                = box.get_height ();
            var width                 = box.get_width ();
            var vscrollbar_min_width  = 0.0f;
            var vscrollbar_width      = 0.0f;
            var hscrollbar_min_height = 0.0f;
            var hscrollbar_height     = 0.0f;

            var child_box = Clutter.ActorBox () {
                x1 = 0.0f,
                y1 = 0.0f,
                x2 = width,
                y2 = height
            };

            if (this.vscrollbar.visible)
            {
                this.vscrollbar.get_preferred_width (height, out vscrollbar_min_width, out vscrollbar_width);

                child_box.x2 = float.max (width - vscrollbar_width, 0.0f);
            }

            if (this.hscrollbar.visible)
            {
                this.hscrollbar.get_preferred_height (width, out hscrollbar_min_height, out hscrollbar_height);

                child_box.y2 = float.max (height - hscrollbar_height, 0.0f);
            }

            if (this.vscrollbar.visible)
            {
                var vscrollbar_box = Clutter.ActorBox () {
                    x1 = child_box.x2,
                    y1 = child_box.y1,
                    x2 = width,
                    y2 = child_box.y2
                };

                this.vscrollbar.allocate (vscrollbar_box, flags);
            }

            if (this.hscrollbar.visible)
            {
                var hscrollbar_box = Clutter.ActorBox () {
                    x1 = child_box.x1,
                    y1 = child_box.y2,
                    x2 = child_box.x2,
                    y2 = height
                };

                this.hscrollbar.allocate (hscrollbar_box, flags);
            }

            var resize_grip_box = Clutter.ActorBox () {
                x1 = child_box.x2,
                y1 = child_box.y2,
                x2 = width,
                y2 = height
            };
            this.resize_grip.allocate (resize_grip_box, flags);

            var iter = Clutter.ActorIter ();
            iter.init (this);

            Clutter.Actor? child = null;

            while (iter.next (out child))
            {
//                if (child.visible && !this.child_get_property (child, "internal"))
                if (child.visible && !child.get_data<bool> ("internal"))
                {
                    child.allocate (child_box, flags);
                }
            }

            base.allocate (box, flags);
        }

        public new void add_child (Clutter.Actor child)
        {
            this.scroll_actor.add_child (child);
        }

        private void on_scroll_actor_actor_added (Clutter.Actor actor)
        {
            actor.allocation_changed.connect (this.on_child_allocation_changed);
        }

        private void on_scroll_actor_actor_removed (Clutter.Actor actor)
        {
            actor.allocation_changed.disconnect (this.on_child_allocation_changed);
        }

        private void scroll_changed ()
        {
            var box          = this.scroll_actor.allocation;
            var child_box    = this.scroll_actor.first_child.allocation;

            // TODO: iter all children and get true child box extents

            var width        = box.get_width ();
            var height       = box.get_height ();
            var child_width  = child_box.get_width ();
            var child_height = child_box.get_height ();

            var scroll_mode  = this.scroll_mode;

            if (Clutter.ScrollMode.VERTICALLY in scroll_mode) {
                this.vadjustment.configure (double.max (this.vadjustment.value,
                                                        height - child_height),  /* value */
                                            0.0,                                 /* lower */
                                            child_height,                        /* upper */
                                            this.vadjustment.step_increment,     /* step_increment */
                                            this.vadjustment.page_increment,     /* page_increment */
                                            height);                             /* page_size */
            }
            else {
                this.vadjustment.configure (0.0,
                                            0.0,
                                            0.0,
                                            this.vadjustment.step_increment,
                                            this.vadjustment.page_increment,
                                            0.0);
            }

            if (Clutter.ScrollMode.HORIZONTALLY in scroll_mode) {
                this.hadjustment.configure (double.max (this.hadjustment.value,
                                                        width - child_width),    /* value */
                                            0.0,                                 /* lower */
                                            child_width,                         /* upper */
                                            this.hadjustment.step_increment,     /* step_increment */
                                            this.hadjustment.page_increment,     /* page_increment */
                                            width);                              /* page_size */
            }
            else {
                this.hadjustment.configure (0.0,
                                            0.0,
                                            0.0,
                                            this.hadjustment.step_increment,
                                            this.hadjustment.page_increment,
                                            0.0);
            }
        }

        private void on_allocation_changed (Clutter.ActorBox        box,
                                            Clutter.AllocationFlags flags)
        {
            this.scroll_changed ();
        }

        private void on_child_allocation_changed (Clutter.ActorBox        box,
                                                  Clutter.AllocationFlags flags)
        {
            this.scroll_changed ();
        }
    }
}
