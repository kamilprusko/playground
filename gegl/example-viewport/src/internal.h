#ifndef __EXAMPLE_PRIVATE_H__
#define __EXAMPLE_PRIVATE_H__

#include <glib.h>
#include <gegl-0.3/gegl.h>
#include <cogl/cogl.h>

G_BEGIN_DECLS

gboolean example_cogl_texture_from_buffer (CoglTexture         **texture,
                                           GeglBuffer           *buffer,
                                           const GeglRectangle  *rect,
                                           gdouble               scale);

G_END_DECLS

#endif /* __EXAMPLE_PRIVATE_H__ */
