AC_INIT([example],
        [1.0])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_MAINTAINER_MODE

# enable nice build output if available
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

PKG_PROG_PKG_CONFIG([0.22])
GOBJECT_INTROSPECTION_REQUIRE([1.36.0])


# Checks for pkg-config packages.
GLIB_REQUIRED=2.36.0
GOM_REQUIRED=0.2

PKG_CHECK_MODULES(EXAMPLE, [
    glib-2.0 >= $GLIB_REQUIRED
    gio-2.0 >= $GLIB_REQUIRED
    gthread-2.0 >= $GLIB_REQUIRED
    gom-1.0 >= $GOM_REQUIRED
    sqlite3
])


# Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_AWK
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

AM_PROG_VALAC([0.26])
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

VAPIGEN_CHECK

# Checks for libraries.
AC_CHECK_LIB(m, floor)


# Checks for header files.
AC_CHECK_HEADERS([malloc.h float.h stdlib.h string.h])


# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T


# Checks for library functions.
AC_CHECK_FUNCS([atexit floor memchr memset mallopt])


AC_CONFIG_FILES([
    Makefile
    vapi/Makefile
    src/Makefile
    data/Makefile
])

AC_OUTPUT
