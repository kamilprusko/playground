namespace ClutterGegl
{
    /**
     * A wrapper for GeglContent to render content at optimal scale.
     */
    public class Actor : Clutter.Actor
    {
        public Gegl.Node node {
            get {
                var content = this.content as ClutterGegl.Content;

                return content.node;
            }
            set {
                var node = value as Gegl.Node;

                var content = new ClutterGegl.Content ();
                content.size_changed.connect (this.on_content_size_changed);
                content.node = node;

                this.set_content (content as Clutter.Content);

                this.on_content_size_changed ();
            }
        }

        public Actor.with_node (Gegl.Node node)
        {
            this.node = node;
        }

        construct
        {
            // TODO: Clutter.ScalingFilter.TRILINEAR not available anymore?
            this.set_content_scaling_filters (Clutter.ScalingFilter.LINEAR,
                                              Clutter.ScalingFilter.LINEAR);
            this.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            this.set_request_mode (Clutter.RequestMode.CONTENT_SIZE);
        }

        private void on_content_size_changed ()
        {
            base.queue_relayout ();
        }
    }
}
