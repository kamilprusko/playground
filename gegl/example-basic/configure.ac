AC_INIT([example],[0.0])
AM_INIT_AUTOMAKE

AM_PROG_VALAC([0.24])
AM_PROG_CC_C_O

dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

GLIB_REQUIRED=2.0.0
GOBJ_REQUIRED=2.0.0
INTROSPECTION_REQUIRED=0.10.1

PKG_CHECK_MODULES(EXAMPLE, [
  glib-2.0 >= $GLIB_REQUIRED
  gobject-2.0 >= $GOBJ_REQUIRED
  gegl-0.3
  json-glib-1.0
])

GOBJECT_INTROSPECTION_REQUIRE($INTROSPECTION_REQUIRED)
AC_SUBST(INTROSPECTION_REQUIRED)

INTROSPECTION_GIRDIR=`$PKG_CONFIG \
--define-variable="prefix=${prefix}" \
--define-variable="datarootdir=${datarootdir}" \
--define-variable="datadir=${datadir}" \
--variable=girdir gobject-introspection-1.0`

INTROSPECTION_TYPELIBDIR=`$PKG_CONFIG \
--define-variable="prefix=${prefix}" \
--define-variable="libdir=${libdir}" \
--variable=typelibdir gobject-introspection-1.0`

VAPIGEN_CHECK

AC_SUBST([GLIB_REQUIRED])

dnl ###########################################################################
dnl Files to generate
dnl ###########################################################################

AC_CONFIG_FILES([
Makefile
src/Makefile
vapi/Makefile
])
AC_OUTPUT
