bin_PROGRAMS = \
    example

BUILT_SOURCES = \
    resources.c

example_SOURCES = \
    main.vala \
    resources.c

example_VALAFLAGS = \
    --vapidir=$(abs_top_srcdir) \
    --vapidir=$(abs_top_srcdir)/vapi \
    --vapidir=$(abs_top_builddir)/vapi \
    --pkg gobject-2.0 \
    --pkg gio-2.0 \
    --pkg gom-1.0 \
    --pkg sqlite3

example_CPPFLAGS = \
    $(EXAMPLE_CFLAGS) \
    -I$(abs_top_srcdir)

example_LDADD = \
    $(EXAMPLE_LIBS)


resources.c: $(top_srcdir)/data/example.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data/ $(top_srcdir)/data/example.gresource.xml)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data/ --generate-source $<


CLEANFILES = \
    $(BUILT_SOURCES) \
    $(example_SOURCES:.vala=.c) \
    example \
    example_vala.stamp
