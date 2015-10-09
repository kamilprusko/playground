
BUILT_SOURCES = \
    gegl-0.3.vapi

CLEANFILES = \
    $(BUILT_SOURCES)

gegl-0.3.vapi: $(INTROSPECTION_GIRDIR)/Gegl-0.3.gir Gegl-0.3.metadata
	$(AM_V_GEN) $(VAPIGEN) --library gegl-0.3 --pkg gio-2.0 --metadatadir=$(srcdir) $<

# Gegl-0.3.metadata

dist-hook:
	cd $(distdir) && rm -f $(CLEANFILES)

-include $(top_srcdir)/git.mk
