class Example : GLib.Object
{
    public static int main (string[] args)
    {
        string[] args_copy = args;

        Gegl.init (ref args_copy);

        var ptn = new Gegl.Node ();

        // Disable caching on all child nodes
        ptn.set_property ("dont-cache", true);

        // Create our background buffer. A gegl:color node would
        // make more sense, we just use a buffer here as an example.
        var background_buffer = new Gegl.Buffer.introspectable_new ("RGBA float", 246, -10, 276, 276);
        var white = new Gegl.Color ("#FFF");
        background_buffer.set_color (background_buffer.get_extent(), white);

        var src = ptn.create_child ("gegl:load");
        src.set_property ("path", "data/surfer.png");

        var crop = ptn.create_child ("gegl:crop");
        crop.set_property ("x", 256);
        crop.set_property ("y", 0);
        crop.set_property ("width", 256);
        crop.set_property ("height", 256);

        var buffer_src = ptn.create_child ("gegl:buffer-source");
        buffer_src.set_property ("buffer", background_buffer);

        var over = ptn.create_child ("gegl:over");

        var dst = ptn.create_child ("gegl:save");
        dst.set_property ("path", "cropped.png");

        // The parent node is only for reference tracking, we need to
        // connect the node's pads to actualy pass data between them.
        buffer_src.connect_to ("output", over, "input");
        src.connect_to ("output", crop, "input");
        crop.connect_to ("output", over, "aux");
        over.connect_to ("output", dst, "input");

        // Will create "cropped.png" in the current directory
        dst.process ();

        Gegl.exit ();

        return 0;
    }
}
