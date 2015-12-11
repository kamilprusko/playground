AC_PREREQ([2.69])
AC_INIT([example],[0.0])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11 foreign])

m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

LT_INIT([disable-static])
PKG_PROG_PKG_CONFIG([0.22])
GOBJECT_INTROSPECTION_REQUIRE([1.36.0])
VAPIGEN_CHECK

GETTEXT_PACKAGE=AC_PACKAGE_NAME


dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

GLIB_REQUIRED=2.0.0
GOBJ_REQUIRED=2.0.0
GTK_REQUIRED=3.16.0
CLUTTER_REQUIRED=1.20.0
CLUTTER_GTK_REQUIRED=1.6.0
GEGL_REQUIRED=0.3.0
BABL_REQUIRED=0.1
COGL_REQUIRED=1.20
INTROSPECTION_REQUIRED=0.10.1

PKG_CHECK_MODULES(EXAMPLE, [
    glib-2.0 >= $GLIB_REQUIRED
    gobject-2.0 >= $GOBJ_REQUIRED
    gegl-0.3 >= $GEGL_REQUIRED
    babl >= $BABL_REQUIRED
    json-glib-1.0
    gtk+-3.0 >= $GTK_REQUIRED
    clutter-1.0 >= $CLUTTER_REQUIRED
    clutter-gtk-1.0 >= $CLUTTER_GTK_REQUIRED
    cogl-1.0 >= $COGL_REQUIRED
])

EXAMPLE_LIBS="$EXAMPLE_LIBS -lm"

INTROSPECTION_GIRDIR=`$PKG_CONFIG \
--define-variable="prefix=${prefix}" \
--define-variable="datarootdir=${datarootdir}" \
--define-variable="datadir=${datadir}" \
--variable=girdir gobject-introspection-1.0`

INTROSPECTION_TYPELIBDIR=`$PKG_CONFIG \
--define-variable="prefix=${prefix}" \
--define-variable="libdir=${libdir}" \
--variable=typelibdir gobject-introspection-1.0`

AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_VALAC([0.24])

# GEGL_VARIADIC_MACROS

PKG_CHECK_MODULES(GEGL_OPERATION,
    glib-2.0 >= $GLIB_REQUIRED
    gobject-2.0 >= $GOBJ_REQUIRED
    gthread-2.0 >= $GLIB_REQUIRED
    babl >= $BABL_REQUIRED
    gegl-0.3 >= $GEGL_REQUIRED)

GEGL_OPERATION_CFLAGS="$GEGL_OPERATION_CFLAGS -I$(top_srcdir) -I$(top_builddir) --include config.h"
GEGL_OPERATION_LIBS="$GEGL_OPERATION_LIBS -lm"
GEGL_OPERATION_LDFLAGS="-module -avoid-version -export-dynamic"


#################
# Check for Python (optional, used for introspection unittests)
#################
AM_PATH_PYTHON([2.7.0],, [:])
AM_CONDITIONAL([HAVE_PYTHON], [test "$PYTHON" != :])


#################
# Check for Clutter
#################

PKG_CHECK_MODULES(COGL,
    cogl-1.0 >= $COGL_REQUIRED,
    have_clutter="yes",
    have_clutter="no  (Cogl not found)")

AM_CONDITIONAL([HAVE_COGL], test "$have_cogl" = "yes")


# Some variables to pass to Makefiles
AC_SUBST([GLIB_REQUIRED])
AC_SUBST([INTROSPECTION_REQUIRED])

AC_SUBST([GETTEXT_PACKAGE])
AC_SUBST([GEGL_OPERATION_CFLAGS])
AC_SUBST([GEGL_OPERATION_LIBS])
AC_SUBST([GEGL_OPERATION_LDFLAGS])


# Some constants to pass to config.h
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], "$GETTEXT_PACKAGE",
                   [The name of the gettext domain])


dnl ###########################################################################
dnl Files to generate
dnl ###########################################################################

AC_CONFIG_FILES([
    Makefile
    src/Makefile
    operations/Makefile
    vapi/Makefile
])
AC_OUTPUT
