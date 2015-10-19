ext_dir = $(libdir)/gegl-example-viewport

%.c.h: %.c $(top_srcdir)/tools/csourcetostring.py
	$(PYTHON) $(top_srcdir)/tools/csourcetostring.py $<

# start out with no ops, each if/endif block contains all the bits relevant
# for a specific dependency.
ops =

#if HAVE_CLUTTER
ops += clutter-image.la
clutter_image_la_SOURCES = clutter-image.c
clutter_image_la_CFLAGS = $(GEGL_OPERATION_CFLAGS) $(CLUTTER_CFLAGS)
clutter_image_la_LIBADD = $(GEGL_OPERATION_LIBS) $(CLUTTER_LIBS)
clutter_image_la_LDFLAGS = $(GEGL_OPERATION_LDFLAGS)
#endif

BUILT_SOURCES = $(subst .c,.c.h,$(wildcard $(srcdir)/*.c))
EXTRA_DIST = $(BUILT_SOURCES)

opdir = $(libdir)/gegl-example-viewport
op_LTLIBRARIES = $(ops)

-include $(top_srcdir)/git.mk
