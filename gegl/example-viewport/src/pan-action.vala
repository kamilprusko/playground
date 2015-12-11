namespace Example
{
    public enum PanState {
        INACTIVE = 0,
        PANNING = 1
    }

    /**
     * Action for mapping / scrolling contents of the ScrollActor
     */
    public class PanAction : Clutter.Action
    {
        public PanState state { get; set; }
        private bool motion_events_enabled;

        private unowned Clutter.Stage stage;
        private Clutter.InputDevice   device;
        private Clutter.EventSequence sequence;
        private ulong                 button_press_id;
        private ulong                 touch_begin_id;
        private ulong                 capture_id;

        private float                 initial_x;
        private float                 initial_y;
        private float                 press_x;
        private float                 press_y;
        private float                 last_motion_x;
        private float                 last_motion_y;

        private void emit_drag_begin (Clutter.Actor      actor,
                                      Clutter.Event      event)
        {
            if (this.stage != null)
            {
                this.stage.set_motion_events_enabled (false);
            }

            this.gesture_begin (actor);
        }

        private void emit_drag_motion (Clutter.Actor actor,
                                       Clutter.Event event)
        {
            var motion_x = 0.0f;
            var motion_y = 0.0f;

            event.get_coords (out this.last_motion_x, out this.last_motion_y);

            actor.transform_stage_point (this.last_motion_x,
                                         this.last_motion_y,
                                         out motion_x,
                                         out motion_y);

            this.gesture_progress (actor);
        }

        private void emit_drag_end (Clutter.Actor  actor,
                                    Clutter.Event? event)
        {
            /* ::drag-end may result in the destruction of the actor, which in turn
             * will lead to the removal and finalization of the action, so we need
             * to keep the action alive for the entire emission sequence
             */
            this.@ref ();

            /* if we have an event, update our own state, otherwise we'll
            * just use the currently stored state when emitting the ::drag-end
            * signal
            */
            if (event != null)
            {
                event.get_coords (out this.last_motion_x, out this.last_motion_y);
            }

            this.gesture_end (actor);

            if (this.stage != null)
            {
                /* disconnect the capture */
                if (this.capture_id != 0)
                {
                    this.stage.disconnect (this.capture_id);
                    this.capture_id = 0;
                }

                this.stage.set_motion_events_enabled (this.motion_events_enabled);
            }

            this.sequence = null;

            this.unref ();
        }

        private bool on_captured_event (Clutter.Actor stage,
                                        Clutter.Event event)
        {
            var actor = this.actor;

            if (this.state != PanState.PANNING)
                return false; // CLUTTER_EVENT_PROPAGATE;

            if (event.get_device () != this.device ||
                event.get_event_sequence () != this.sequence)
            {
                return false; // CLUTTER_EVENT_PROPAGATE;
            }

            switch (event.type)
            {
                case Clutter.EventType.TOUCH_UPDATE:
                    this.emit_drag_motion (actor, event);
                    break;

                case Clutter.EventType.MOTION:
                    var mods = event.get_state ();

                    /* we might miss a button-release event in case of grabs,
                     * so we need to check whether the button is still down
                     * during a motion event
                     */
                    if (Clutter.ModifierType.BUTTON1_MASK in mods ||
                        Clutter.ModifierType.BUTTON2_MASK in mods)
                    {
                        this.emit_drag_motion (actor, event);
                    }
                    else {
                        this.emit_drag_end (actor, event);
                    }
                    break;

                case Clutter.EventType.TOUCH_END:
                case Clutter.EventType.TOUCH_CANCEL:
                    this.emit_drag_end (actor, event);
                    break;

                case Clutter.EventType.BUTTON_RELEASE:
                    if (this.state == PanState.PANNING)
                        this.emit_drag_end (actor, event);
                    break;

                case Clutter.EventType.ENTER:
                case Clutter.EventType.LEAVE:
                    if (this.state == PanState.PANNING)
                        return true;  // CLUTTER_EVENT_STOP;
                    break;

                default:
                    break;
            }

            return false;  // CLUTTER_EVENT_PROPAGATE;
        }

        private bool on_touch_event (Clutter.Actor actor,
                                     Clutter.Event event)
        {
            if (!this.enabled)
                return false;  // CLUTTER_EVENT_PROPAGATE

            /* dragging is only performed using the primary button */
            switch (event.type)
            {
                case Clutter.EventType.BUTTON_PRESS:
                    if (this.sequence != null)
                        return false;  // CLUTTER_EVENT_PROPAGATE

                    if (!(event.get_button () == 1 ||
                          event.get_button () == 2))  // CLUTTER_BUTTON_PRIMARY
                    {
                        return false;  // CLUTTER_EVENT_PROPAGATE
                    }

                    break;

                case Clutter.EventType.TOUCH_BEGIN:
                    if (this.sequence != null)
                        return false;  // CLUTTER_EVENT_PROPAGATE
                    this.sequence = event.get_event_sequence ();
                    break;

                default:
                    return false;  // CLUTTER_EVENT_PROPAGATE
            }

            if (this.stage == null)
                this.stage = actor.get_stage ();

            event.get_coords (out this.press_x, out this.press_y);

            this.device = event.get_device ();

            this.last_motion_x = this.press_x;
            this.last_motion_y = this.press_y;

            this.motion_events_enabled = this.stage.get_motion_events_enabled ();

            this.emit_drag_begin (actor, event);

            this.capture_id = this.stage.captured_event.connect (this.on_captured_event);

            return false;  // CLUTTER_EVENT_PROPAGATE
        }

        private bool on_button_press_event (Clutter.Actor       actor,
                                            Clutter.ButtonEvent event)
        {
            var base_event = Clutter.get_current_event ();

            return on_touch_event (actor, base_event);
        }

        public override void set_actor (Clutter.Actor? actor)
        {
            // FIXME: what if actor changes during panning

            if (this.button_press_id != 0)
            {
                var old_actor = this.actor;

                if (old_actor != null)
                {
                    old_actor.disconnect (this.button_press_id);
                    old_actor.disconnect (this.touch_begin_id);
                }

                this.button_press_id = 0;
                this.touch_begin_id = 0;
            }

            if (this.capture_id != 0)
            {
                if (this.stage != null)
                    this.stage.disconnect (this.capture_id);

                this.capture_id = 0;
                this.stage = null;
            }

            if (actor != null)
            {
                this.button_press_id = actor.button_press_event.connect (this.on_button_press_event);
                this.touch_begin_id = actor.touch_event.connect (this.on_touch_event);
            }

            base.set_actor (actor);
        }

        public override void dispose ()
        {
            /* if we're being disposed while a capture is still present, we
             * need to reset the state we are currently holding
             */

            if (this.sequence != null)
            {
                this.sequence = null;
            }

            if (this.capture_id != 0)
            {
                this.gesture_cancel (this.actor);

                this.stage.set_motion_events_enabled (this.motion_events_enabled);

                if (this.stage != null)
                    this.stage.disconnect (this.capture_id);

                this.capture_id = 0;
                this.stage = null;
            }

            if (this.button_press_id != 0)
            {
                if (this.actor != null)
                {
                    this.actor.disconnect (this.button_press_id);
                    this.actor.disconnect (this.touch_begin_id);
                }

                this.button_press_id = 0;
                this.touch_begin_id = 0;
            }

            base.dispose ();
        }

        /**
         * get_press_coords:
         * @action: a #ClutterDragAction
         * @press_x: (out): return location for the press event's X coordinate
         * @press_y: (out): return location for the press event's Y coordinate
         *
         * Retrieves the coordinates, in stage space, of the press event
         * that started the dragging
         */
        public void get_press_coords (out float press_x,
                                      out float press_y)
        {
            press_x = this.press_x;
            press_y = this.press_y;
        }

        /**
         * get_motion_coords:
         * @motion_x: (out): return location for the latest motion
         *   event's X coordinate
         * @motion_y: (out): return location for the latest motion
         *   event's Y coordinate
         *
         * Retrieves the coordinates, in stage space, of the latest motion
         * event during the dragging
         */
        public void get_motion_coords (out float motion_x,
                                       out float motion_y)
        {
            motion_x = this.last_motion_x;
            motion_y = this.last_motion_y;
        }

        private bool pan (Clutter.Actor actor)
        {
            var motion_x = 0.0f;
            var motion_y = 0.0f;

            this.get_motion_coords (out motion_x, out motion_y);

            var scroll_actor = actor as Example.ScrollActor;
            var scroll_x = 0.0f;
            var scroll_y = 0.0f;

            if (Clutter.ScrollMode.HORIZONTALLY in scroll_actor.scroll_mode)
            {
                scroll_x = this.initial_x + Math.floorf (motion_x - this.press_x);
                scroll_x = scroll_x.clamp (actor.width - scroll_actor.first_child.width, 0.0f);
            }

            if (Clutter.ScrollMode.VERTICALLY in scroll_actor.scroll_mode)
            {
                scroll_y = (this.initial_y + Math.floorf (motion_y - this.press_y));
                scroll_y = scroll_y.clamp (actor.height - scroll_actor.first_child.height, 0.0f);
            }

            if (scroll_actor.scroll_x != scroll_x) {
                scroll_actor.scroll_x = scroll_x;
            }

            if (scroll_actor.scroll_y != scroll_y) {
                scroll_actor.scroll_y = scroll_y;
            }

            return true;
        }

//        private bool gesture_prepare (Clutter.Actor actor)
//        {
//            return true;
//        }

        private bool gesture_begin (Clutter.Actor actor)
        {
            this.state = PanState.PANNING;

            var scroll_actor = actor as Example.ScrollActor;
            this.initial_x = scroll_actor.scroll_x;
            this.initial_y = scroll_actor.scroll_y;

            this.get_press_coords (out this.press_x, out this.press_y);

            return true;
        }

        private bool gesture_progress (Clutter.Actor actor)
        {
            this.pan (actor);

            return true;
        }

        private void gesture_cancel (Clutter.Actor actor)
        {
            this.state = PanState.INACTIVE;
        }

        private void gesture_end (Clutter.Actor actor)
        {
            this.state = PanState.INACTIVE;
        }
    }
}
