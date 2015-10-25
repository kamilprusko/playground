#include "config.h"
#include <glib/gi18n-lib.h>


#ifdef GEGL_PROPERTIES

property_pointer (texture,
                  _("Cogl texture"),
                  _("Texture where to store the image."))

#else

#define GEGL_OP_SINK
#define GEGL_OP_C_SOURCE cogl-texture.c

#include <gegl-0.3/gegl-op.h>
#include <cogl/cogl.h>


static gboolean
process (GeglOperation       *operation,
         GeglBuffer          *input,
         const GeglRectangle *result,
         gint                 level)
{
    GeglProperties   *o            = GEGL_PROPERTIES (operation);
    const Babl       *input_format;
    const Babl       *data_format;
    gint              bps;
    gint              row_stride;
    gint              n_components;
    guchar           *data;
    CoglPixelFormat   cogl_pixel_format;

    g_object_get (input, "format", &input_format, NULL);

    /* cogl doesnt support anything more than 8bit bps */
    bps          = 8;
    n_components = babl_format_get_n_components (input_format);

    switch (n_components)
    {
        case 1:
            data_format = babl_format ("Y'");
            cogl_pixel_format = COGL_PIXEL_FORMAT_G_8;
            break;

        default:
            if (babl_format_has_alpha (input_format)) {
                data_format = babl_format_new (babl_model ("R'G'B'A"),
                                    babl_type ("u8"),
                                    babl_component ("B'"),
                                    babl_component ("G'"),
                                    babl_component ("R'"),
                                    babl_component ("A"),
                                    NULL);
                cogl_pixel_format = COGL_PIXEL_FORMAT_BGRA_8888;
                n_components = 4;
            }
            else {
                data_format = babl_format_new (babl_model ("R'G'B'"),
                                    babl_type ("u8"),
                                    babl_component ("B'"),
                                    babl_component ("G'"),
                                    babl_component ("R'"),
                                    NULL);
                cogl_pixel_format = COGL_PIXEL_FORMAT_BGR_888;
                n_components = 3;
            }

            break;
    }

    row_stride = result->width * n_components * bps/8;

    data = g_malloc (result->height * row_stride);
    gegl_buffer_get (input,
                     result,  /* rect */
                     1.0,     /* scale */
                     data_format,
                     data,
                     GEGL_AUTO_ROWSTRIDE,
                     GEGL_ABYSS_NONE);

    if (data)
    {
        if (o->texture == NULL)
        {
            CoglTextureFlags flags = COGL_TEXTURE_NONE;

            if (result->width >= 512 && result->height >= 512) {
                flags |= COGL_TEXTURE_NO_ATLAS;
            }

            o->texture = cogl_texture_new_from_data (result->width,
                                                     result->height,
                                                     flags,
                                                     cogl_pixel_format,
                                                     COGL_PIXEL_FORMAT_ANY,
                                                     row_stride,
                                                     data);
        }
        else
        {
            gboolean success;

            success = cogl_texture_set_region (COGL_TEXTURE (o->texture),
                                               0, 0,
                                               result->x, result->y,
                                               result->width, result->height,
                                               result->width, result->height,
                                               cogl_pixel_format,
                                               row_stride,
                                               data);

            if (!success)
            {
                cogl_object_unref (o->texture);
                o->texture = NULL;
            }
        }
    }
    else
    {
        g_warning (G_STRLOC ": inexistant data, unable to create CoglTexture.");
    }

    return TRUE;
}

static void
finalize (GObject *object)
{
    GeglProperties *o = GEGL_PROPERTIES (object);

    if (o->texture)
    {
        g_object_unref (o->texture);
        o->texture = NULL;
    }

    G_OBJECT_CLASS (gegl_op_parent_class)->finalize (object);
}

static void
gegl_op_class_init (GeglOpClass *klass)
{
    GObjectClass           *object_class;
    GeglOperationClass     *operation_class;
    GeglOperationSinkClass *sink_class;

    object_class    = G_OBJECT_CLASS (klass);
    operation_class = GEGL_OPERATION_CLASS (klass);
    sink_class      = GEGL_OPERATION_SINK_CLASS (klass);

    object_class->finalize = finalize;

    sink_class->process = process;
    sink_class->needs_full = TRUE;

    gegl_operation_class_set_keys (operation_class,
        "name",         "example:cogl-texture",
        "title",        _("Cogl Texture"),
        "categories",   "display",
        "description",
            _("Node preperaing content for display with clutter."),
            NULL);
}
#endif
