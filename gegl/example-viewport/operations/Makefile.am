ext_dir = $(libdir)/gegl-example-viewport

%.c.h: %.c $(top_srcdir)/tools/csourcetostring.py
	$(PYTHON) $(top_srcdir)/tools/csourcetostring.py $<

# start out with no ops, each if/endif block contains all the bits relevant
# for a specific dependency.
ops =

if HAVE_COGL
ops += cogl-texture.la
cogl_texture_la_SOURCES = cogl-texture.c
cogl_texture_la_CFLAGS = $(GEGL_OPERATION_CFLAGS) $(COGL_CFLAGS)
cogl_texture_la_LIBADD = $(GEGL_OPERATION_LIBS) $(COGL_LIBS)
cogl_texture_la_LDFLAGS = $(GEGL_OPERATION_LDFLAGS)

ops += cogl-texture-2d.la
cogl_texture_2d_la_SOURCES = cogl-texture-2d.c
cogl_texture_2d_la_CFLAGS = $(GEGL_OPERATION_CFLAGS) $(COGL_CFLAGS)
cogl_texture_2d_la_LIBADD = $(GEGL_OPERATION_LIBS) $(COGL_LIBS)
cogl_texture_2d_la_LDFLAGS = $(GEGL_OPERATION_LDFLAGS)
endif

BUILT_SOURCES = $(subst .c,.c.h,$(wildcard $(srcdir)/*.c))
EXTRA_DIST = $(BUILT_SOURCES)

opdir = $(libdir)/gegl-example-viewport
op_LTLIBRARIES = $(ops)

-include $(top_srcdir)/git.mk
