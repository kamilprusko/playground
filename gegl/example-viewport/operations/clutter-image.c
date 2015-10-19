#include "config.h"
#include <glib/gi18n-lib.h>


#ifdef GEGL_PROPERTIES

property_string (window_title, _("Window title"), "window_title")
    description (_("Title to be given to output window"))
property_string (icon_title, _("Icon title"), "icon_title")
    description (_("Icon to be used for output window"))
#else

#define GEGL_OP_SINK
#define GEGL_OP_C_SOURCE clutter-image.c

#include <gegl-0.3/gegl-op.h>
#include <clutter/clutter.h>

/*
typedef struct {
  SDL_Surface *screen;
  gint         width;
  gint         height;
} SDLState;
*/

static gboolean
process (GeglOperation       *operation,
         GeglBuffer          *input,
         const GeglRectangle *result,
         gint                 level)
{
  GeglProperties   *o = GEGL_PROPERTIES (operation);
//  SDLState     *state = NULL;

//  if(!o->user_data)
//      o->user_data = g_new0 (SDLState, 1);
//  state = o->user_data;

/*
  if (!state->screen ||
       state->width  != result->width ||
       state->height != result->height)
    {
      state->screen = SDL_SetVideoMode (result->width, result->height, 32, SDL_SWSURFACE);
      if (!state->screen)
        {
          fprintf (stderr, "Unable to set SDL mode: %s\n",
                   SDL_GetError ());
          return -1;
        }

      state->width  = result->width ;
      state->height = result->height;
    }
*/

  /*
   * There seems to be a valid faster path to the SDL desired display format
   * in B'G'R'A, perhaps babl should have been able to figure this out ito?
   *
   */
/*  gegl_buffer_get (input,*/
/*       NULL,*/
/*       1.0,*/
/*       babl_format_new (babl_model ("R'G'B'A"),*/
/*                        babl_type ("u8"),*/
/*                        babl_component ("B'"),*/
/*                        babl_component ("G'"),*/
/*                        babl_component ("R'"),*/
/*                        babl_component ("A"),*/
/*                        NULL),*/
/*       state->screen->pixels, GEGL_AUTO_ROWSTRIDE,*/
/*       GEGL_ABYSS_NONE);*/

  return  TRUE;
}

static void
finalize (GObject *object)
{
  GeglProperties *o = GEGL_PROPERTIES (object);

  if (o->user_data)
    {
      g_free (o->user_data);
      o->user_data = NULL;
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
    "name",         "example:clutter-image",
    "title",        _("Clutter Image"),
    "categories",   "display",
    "description",
        _("Node preperaing content for display with clutter."),
        NULL);
}
#endif
