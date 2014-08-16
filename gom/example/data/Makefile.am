resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --sourcedir=$(srcdir) --generate-dependencies $(srcdir)/example.gresource.xml)

EXTRA_DIST = \
	gnome-pomodoro.gresource.xml \
	$(resource_files)
