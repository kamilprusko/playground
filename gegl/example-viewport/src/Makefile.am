bin_PROGRAMS = example

example_DEPENDENCIES = \
	$(abs_top_builddir)/vapi/gegl-0.3.vapi

example_SOURCES = \
	clutter-gegl-actor.vala \
	clutter-gegl-content.vala \
	internal.c \
	internal.vapi \
	main.vala \
	pan-action.vala \
	scroll-actor.vala \
	stack-layout.vala \
	window.vala \
	viewport.vala

example_CFLAGS = \
	$(EXAMPLE_CFLAGS)

example_VALAFLAGS = \
	--target-glib $(GLIB_REQUIRED) \
	--vapidir=$(abs_top_builddir)/vapi \
	--pkg gobject-2.0 \
	--pkg gegl-0.3 \
	--pkg gtk+-3.0 \
	--pkg clutter-1.0 \
	--pkg clutter-gtk-1.0 \
	--pkg cogl-1.0

example_LDADD = \
	$(EXAMPLE_LIBS)

-include $(top_srcdir)/git.mk
