bin_PROGRAMS = example

example_DEPENDENCIES = \
    $(abs_top_builddir)/vapi/gegl-0.3.vapi

example_SOURCES = \
	main.vala

example_CFLAGS = \
	$(EXAMPLE_CFLAGS)

example_VALAFLAGS = \
	--target-glib $(GLIB_REQUIRED) \
	--vapidir=$(abs_top_builddir)/vapi \
    --pkg gobject-2.0 \
	--pkg gegl-0.3

example_LDADD = \
	$(EXAMPLE_LIBS)

