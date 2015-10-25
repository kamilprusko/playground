#include "config.h"
#include "internal.h"


gboolean
example_cogl_texture_from_buffer (CoglTexture         **texture,
                                  GeglBuffer           *buffer,
                                  const GeglRectangle  *rect,
                                  gdouble               scale)
{
    const Babl       *buffer_format;
    const Babl       *data_format;
    guchar           *data;
    gint              bps;
    gint              row_stride;
    gint              n_components;
    CoglPixelFormat   cogl_pixel_format;

    g_object_get (buffer, "format", &buffer_format, NULL);

    /* cogl doesnt support anything more than 8bit bps */
    bps          = 8;
    n_components = babl_format_get_n_components (buffer_format);

    switch (n_components)
    {
        case 1:
            data_format = babl_format ("Y'");
            cogl_pixel_format = COGL_PIXEL_FORMAT_G_8;
            break;

        default:
            if (babl_format_has_alpha (buffer_format)) {
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

    row_stride = rect->width * n_components * bps / 8;

    data = g_malloc (rect->height * row_stride);
    gegl_buffer_get (buffer,
                     rect,
                     scale,
                     data_format,
                     data,
                     GEGL_AUTO_ROWSTRIDE,
                     GEGL_ABYSS_NONE);

    gboolean success;

    if (data)
    {
        if (*texture == NULL)
        {
            CoglTextureFlags flags = COGL_TEXTURE_NONE;

            if (rect->width >= 512 && rect->height >= 512) {
                flags |= COGL_TEXTURE_NO_ATLAS;
            }

            *texture = cogl_texture_new_from_data (rect->width,
                                                   rect->height,
                                                   flags,
                                                   cogl_pixel_format,
                                                   COGL_PIXEL_FORMAT_ANY,
                                                   row_stride,
                                                   data);
            success = TRUE;
        }
        else
        {
            success = cogl_texture_set_region (COGL_TEXTURE (*texture),
                                               0, 0,
                                               rect->x, rect->y,
                                               rect->width, rect->height,
                                               rect->width, rect->height,
                                               cogl_pixel_format,
                                               row_stride,
                                               data);
        }
    }
    else
    {
        g_warning (G_STRLOC ": inexistant data, unable to create CoglTexture.");

        success = FALSE;
    }

    return success;
}
