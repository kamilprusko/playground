namespace Example
{
    public class StackLayout : Clutter.LayoutManager
    {
        public override void get_preferred_width (Clutter.Container container,
                                                  float             for_height,
                                                  out float         min_width,
                                                  out float         natural_width)
        {
            min_width     = 0.0f;
            natural_width = 0.0f;
        }

        public override void get_preferred_height (Clutter.Container container,
                                                   float             for_width,
                                                   out float         min_height,
                                                   out float         natural_height)
        {
            min_height     = 0.0f;
            natural_height = 0.0f;
        }

        public override void allocate (Clutter.Container       container,
                                       Clutter.ActorBox        allocation,
                                       Clutter.AllocationFlags flags)
        {
            var actor = container as Clutter.Actor;
            var iter  = Clutter.ActorIter ();

            iter.init (actor);

            Clutter.Actor? child = null;

            while (iter.next (out child))
            {
                child.allocate (allocation, flags);
            }
        }
    }
}
