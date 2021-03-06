dnl***************************************************************************
dnl Copyright (c) 1998 Free Software Foundation, Inc.                        *
dnl                                                                          *
dnl Permission is hereby granted, free of charge, to any person obtaining a  *
dnl copy of this software and associated documentation files (the            *
dnl "Software"), to deal in the Software without restriction, including      *
dnl without limitation the rights to use, copy, modify, merge, publish,      *
dnl distribute, distribute with modifications, sublicense, and/or sell       *
dnl copies of the Software, and to permit persons to whom the Software is    *
dnl furnished to do so, subject to the following conditions:                 *
dnl                                                                          *
dnl The above copyright notice and this permission notice shall be included  *
dnl in all copies or substantial portions of the Software.                   *
dnl                                                                          *
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  *
dnl OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               *
dnl MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   *
dnl IN NO EVENT SHALL THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,   *
dnl DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR    *
dnl OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    *
dnl THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               *
dnl                                                                          *
dnl Except as contained in this notice, the name(s) of the above copyright   *
dnl holders shall not be used in advertising or otherwise to promote the     *
dnl sale, use or other dealings in this Software without prior written       *
dnl authorization.                                                           *
dnl***************************************************************************
dnl
dnl Author: Thomas E. Dickey <dickey@clark.net> 1996,1997,1998
dnl
dnl $Id: aclocal.m4,v 1.121 1998/02/11 12:13:40 tom Exp $
dnl Macros used in NCURSES auto-configuration script.
dnl
dnl ---------------------------------------------------------------------------
dnl ---------------------------------------------------------------------------
dnl Construct the list of include-options for the C programs in the Ada95
dnl binding.
AC_DEFUN([CF_ADA_INCLUDE_DIRS],
[
ACPPFLAGS="$ACPPFLAGS -I. -I../../include"
if test "$srcdir" != "."; then
	ACPPFLAGS="$ACPPFLAGS -I\$(srcdir)/../../include"
fi
if test -z "$GCC"; then
	ACPPFLAGS="$ACPPFLAGS -I\$(includedir)"
elif test "$includedir" != "/usr/include"; then
	if test "$includedir" = '${prefix}/include' ; then
		if test $prefix != /usr ; then
			ACPPFLAGS="$ACPPFLAGS -I\$(includedir)"
		fi
	else
		ACPPFLAGS="$ACPPFLAGS -I\$(includedir)"
	fi
fi
AC_SUBST(ACPPFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl Test if 'bool' is a builtin type in the configured C++ compiler.  Some
dnl older compilers (e.g., gcc 2.5.8) don't support 'bool' directly; gcc
dnl 2.6.3 does, in anticipation of the ANSI C++ standard.
dnl
dnl Treat the configuration-variable specially here, since we're directly
dnl substituting its value (i.e., 1/0).
AC_DEFUN([CF_BOOL_DECL],
[
AC_MSG_CHECKING([for builtin c++ bool type])
AC_CACHE_VAL(cf_cv_builtin_bool,[
	AC_TRY_COMPILE([],[bool x = false],
		[cf_cv_builtin_bool=1],
		[cf_cv_builtin_bool=0])
	])
if test $cf_cv_builtin_bool = 1
then	AC_MSG_RESULT(yes)
else	AC_MSG_RESULT(no)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Test for the size of 'bool' in the configured C++ compiler (e.g., a type).
dnl Don't bother looking for bool.h, since it's been deprecated.
AC_DEFUN([CF_BOOL_SIZE],
[
AC_MSG_CHECKING([for size of c++ bool])
AC_CACHE_VAL(cf_cv_type_of_bool,[
	rm -f cf_test.out
	AC_TRY_RUN([
#include <stdlib.h>
#include <stdio.h>
#if HAVE_BUILTIN_H
#include <builtin.h>
#endif
main()
{
	FILE *fp = fopen("cf_test.out", "w");
	if (fp != 0) {
		bool x = true;
		if ((-x) >= 0)
			fputs("unsigned ", fp);
		if (sizeof(x) == sizeof(int))       fputs("int",  fp);
		else if (sizeof(x) == sizeof(char)) fputs("char", fp);
		else if (sizeof(x) == sizeof(short))fputs("short",fp);
		else if (sizeof(x) == sizeof(long)) fputs("long", fp);
		fclose(fp);
	}
	exit(0);
}
		],
		[cf_cv_type_of_bool=`cat cf_test.out`],
		[cf_cv_type_of_bool=unknown],
		[cf_cv_type_of_bool=unknown])
	])
	rm -f cf_test.out
AC_MSG_RESULT($cf_cv_type_of_bool)
if test "$cf_cv_type_of_bool" = unknown ; then
	AC_MSG_WARN(Assuming unsigned for type of bool)
	cf_cv_type_of_bool=unsigned
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Determine the default configuration into which we'll install ncurses.  This
dnl can be overridden by the user's command-line options.  There's two items to
dnl look for:
dnl	1. the prefix (e.g., /usr)
dnl	2. the header files (e.g., /usr/include/ncurses)
dnl We'll look for a previous installation of ncurses and use the same defaults.
dnl
dnl We don't use AC_PREFIX_DEFAULT, because it gets evaluated too soon, and
dnl we don't use AC_PREFIX_PROGRAM, because we cannot distinguish ncurses's
dnl programs from a vendor's.
AC_DEFUN([CF_CFG_DEFAULTS],
[
AC_MSG_CHECKING(for prefix)
if test "x$prefix" = "xNONE" ; then
	case "$cf_cv_system_name" in
		# non-vendor systems don't have a conflict
	openbsd*|netbsd*|freebsd*|linux*)
		prefix=/usr
		;;
	*)	prefix=$ac_default_prefix
		;;
	esac
fi
AC_MSG_RESULT($prefix)

if test "x$prefix" = "xNONE" ; then
AC_MSG_CHECKING(for default include-directory)
test -n "$verbose" && echo 1>&AC_FD_MSG
for cf_symbol in \
	$includedir \
	$includedir/ncurses \
	$prefix/include \
	$prefix/include/ncurses \
	/usr/local/include \
	/usr/local/include/ncurses \
	/usr/include \
	/usr/include/ncurses
do
	cf_dir=`eval echo $cf_symbol`
	if test -f $cf_dir/curses.h ; then
	if ( fgrep NCURSES_VERSION $cf_dir/curses.h 2>&1 >/dev/null ) ; then
		includedir="$cf_symbol"
		test -n "$verbose"  && echo $ac_n "	found " 1>&AC_FD_MSG
		break
	fi
	fi
	test -n "$verbose"  && echo "	tested $cf_dir" 1>&AC_FD_MSG
done
AC_MSG_RESULT($includedir)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Check for data that is usually declared in <stdio.h> or <errno.h>
dnl $1 = the name to check
AC_DEFUN([CF_CHECK_ERRNO],
[
AC_MSG_CHECKING([declaration of $1])
AC_CACHE_VAL(cf_cv_dcl_$1,[
    AC_TRY_COMPILE([
#include <stdio.h>
#include <sys/types.h>
#include <errno.h> ],
    [long x = (long) $1],
    [eval 'cf_cv_dcl_'$1'=yes'],
    [eval 'cf_cv_dcl_'$1'=no]')])
eval 'cf_result=$cf_cv_dcl_'$1
AC_MSG_RESULT($cf_result)

# It's possible (for near-UNIX clones) that the data doesn't exist
AC_CACHE_VAL(cf_cv_have_$1,[
if test $cf_result = no ; then
    eval 'cf_result=DECL_'$1
    CF_UPPER(cf_result,$cf_result)
    AC_DEFINE_UNQUOTED($cf_result)
    AC_MSG_CHECKING([existence of $1])
        AC_TRY_LINK([
#undef $1
extern long $1;
],
            [$1 = 2],
            [eval 'cf_cv_have_'$1'=yes'],
            [eval 'cf_cv_have_'$1'=no'])
        eval 'cf_result=$cf_cv_have_'$1
        AC_MSG_RESULT($cf_result)
else
    eval 'cf_cv_have_'$1'=yes'
fi
])
eval 'cf_result=HAVE_'$1
CF_UPPER(cf_result,$cf_result)
eval 'test $cf_cv_have_'$1' = yes && AC_DEFINE_UNQUOTED($cf_result)'
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if the terminal-capability database functions are available.  If not,
dnl ncurses has a much-reduced version.
AC_DEFUN([CF_CGETENT],[
AC_MSG_CHECKING(for terminal-capability database functions)
AC_CACHE_VAL(cf_cv_cgetent,[
AC_TRY_LINK([
#include <stdlib.h>],[
	char temp[128];
	char *buf = temp;
	char *db_array = temp;
	cgetent(&buf, /* int *, */ &db_array, "vt100");
	cgetcap(buf, "tc", '=');
	cgetmatch(buf, "tc");
	],
	[cf_cv_cgetent=yes],
	[cf_cv_cgetent=no])
])
AC_MSG_RESULT($cf_cv_cgetent)
test $cf_cv_cgetent = yes && AC_DEFINE(HAVE_BSD_CGETENT)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if we're accidentally using a cache from a different machine.
dnl Derive the system name, as a check for reusing the autoconf cache.
dnl
dnl If we've packaged config.guess and config.sub, run that (since it does a
dnl better job than uname). 
AC_DEFUN([CF_CHECK_CACHE],
[
if test -f $srcdir/config.guess ; then
	AC_CANONICAL_HOST
	system_name="$host_os"
else
	system_name="`(uname -s -r) 2>/dev/null`"
	if test -z "$system_name" ; then
		system_name="`(hostname) 2>/dev/null`"
	fi
fi
test -n "$system_name" && AC_DEFINE_UNQUOTED(SYSTEM_NAME,"$system_name")
AC_CACHE_VAL(cf_cv_system_name,[cf_cv_system_name="$system_name"])

test -z "$system_name" && system_name="$cf_cv_system_name"
test -n "$cf_cv_system_name" && AC_MSG_RESULT("Configuring for $cf_cv_system_name")

if test ".$system_name" != ".$cf_cv_system_name" ; then
	AC_MSG_RESULT(Cached system name ($system_name) does not agree with actual ($cf_cv_system_name))
	AC_ERROR("Please remove config.cache and try again.")
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl If we're trying to use g++, test if libg++ is installed (a rather common
dnl problem :-).  If we have the compiler but no library, we'll be able to
dnl configure, but won't be able to build the c++ demo program.
AC_DEFUN([CF_CXX_LIBRARY],
[
cf_cxx_library=unknown
if test $ac_cv_prog_gxx = yes; then
	AC_MSG_CHECKING([for libg++])
	cf_save="$LIBS"
	LIBS="$LIBS -lg++ -lm"
	AC_TRY_LINK([
#include <builtin.h>
	],
	[float foo=abs(1.0)],
	[cf_cxx_library=yes
	 CXXLIBS="$CXXLIBS -lg++ -lm"],
	[cf_cxx_library=no])
	LIBS="$cf_save"
	AC_MSG_RESULT($cf_cxx_library)
fi
])dnl
dnl ---------------------------------------------------------------------------
AC_DEFUN([CF_DIRS_TO_MAKE],
[
DIRS_TO_MAKE="lib"
for cf_item in $cf_list_models
do
	CF_OBJ_SUBDIR($cf_item,cf_subdir)
	DIRS_TO_MAKE="$DIRS_TO_MAKE $cf_subdir"
done
for cf_dir in $DIRS_TO_MAKE
do
	test ! -d $cf_dir && mkdir $cf_dir
done
AC_SUBST(DIRS_TO_MAKE)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if 'errno' is declared in <errno.h>
AC_DEFUN([CF_ERRNO],
[
CF_CHECK_ERRNO(errno)
])dnl
dnl ---------------------------------------------------------------------------
dnl Test for availability of useful gcc __attribute__ directives to quiet
dnl compiler warnings.  Though useful, not all are supported -- and contrary
dnl to documentation, unrecognized directives cause older compilers to barf.
AC_DEFUN([CF_GCC_ATTRIBUTES],
[
if test -n "$GCC"
then
cat > conftest.i <<EOF
#ifndef GCC_PRINTF
#define GCC_PRINTF 0
#endif
#ifndef GCC_SCANF
#define GCC_SCANF 0
#endif
#ifndef GCC_NORETURN
#define GCC_NORETURN /* nothing */
#endif
#ifndef GCC_UNUSED
#define GCC_UNUSED /* nothing */
#endif
EOF
if test -n "$GCC"
then
	AC_CHECKING([for gcc __attribute__ directives])
	changequote(,)dnl
cat > conftest.$ac_ext <<EOF
#line __oline__ "configure"
#include "confdefs.h"
#include "conftest.h"
#include "conftest.i"
#if	GCC_PRINTF
#define GCC_PRINTFLIKE(fmt,var) __attribute__((format(printf,fmt,var)))
#else
#define GCC_PRINTFLIKE(fmt,var) /*nothing*/
#endif
#if	GCC_SCANF
#define GCC_SCANFLIKE(fmt,var)  __attribute__((format(scanf,fmt,var)))
#else
#define GCC_SCANFLIKE(fmt,var)  /*nothing*/
#endif
extern void wow(char *,...) GCC_SCANFLIKE(1,2);
extern void oops(char *,...) GCC_PRINTFLIKE(1,2) GCC_NORETURN;
extern void foo(void) GCC_NORETURN;
int main(int argc GCC_UNUSED, char *argv[] GCC_UNUSED) { return 0; }
EOF
	changequote([,])dnl
	for cf_attribute in scanf printf unused noreturn
	do
		CF_UPPER(CF_ATTRIBUTE,$cf_attribute)
		cf_directive="__attribute__(($cf_attribute))"
		echo "checking for gcc $cf_directive" 1>&AC_FD_CC
		case $cf_attribute in
		scanf|printf)
		cat >conftest.h <<EOF
#define GCC_$CF_ATTRIBUTE 1
EOF
			;;
		*)
		cat >conftest.h <<EOF
#define GCC_$CF_ATTRIBUTE $cf_directive
EOF
			;;
		esac
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... $cf_attribute)
			cat conftest.h >>confdefs.h
#		else
#			sed -e 's/__attr.*/\/*nothing*\//' conftest.h >>confdefs.h
		fi
	done
else
	fgrep define conftest.i >>confdefs.h
fi
rm -rf conftest*
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if the compiler supports useful warning options.  There's a few that
dnl we don't use, simply because they're too noisy:
dnl
dnl	-Wconversion (useful in older versions of gcc, but not in gcc 2.7.x)
dnl	-Wredundant-decls (system headers make this too noisy)
dnl	-Wtraditional (combines too many unrelated messages, only a few useful)
dnl	-Wwrite-strings (too noisy, but should review occasionally)
dnl	-pedantic
dnl
AC_DEFUN([CF_GCC_WARNINGS],
[
if test -n "$GCC"
then
	changequote(,)dnl
	cat > conftest.$ac_ext <<EOF
#line __oline__ "configure"
int main(int argc, char *argv[]) { return argv[argc-1] == 0; }
EOF
	changequote([,])dnl
	AC_CHECKING([for gcc warning options])
	cf_save_CFLAGS="$CFLAGS"
	EXTRA_CFLAGS="-W -Wall"
	cf_warn_CONST=""
	test "$with_ext_const" = yes && cf_warn_CONST="Wwrite-strings"
	for cf_opt in \
		Wbad-function-cast \
		Wcast-align \
		Wcast-qual \
		Winline \
		Wmissing-declarations \
		Wmissing-prototypes \
		Wnested-externs \
		Wpointer-arith \
		Wshadow \
		Wstrict-prototypes $cf_warn_CONST
	do
		CFLAGS="$cf_save_CFLAGS $EXTRA_CFLAGS -$cf_opt"
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... -$cf_opt)
			EXTRA_CFLAGS="$EXTRA_CFLAGS -$cf_opt"
			test "$cf_opt" = Wcast-qual && EXTRA_CFLAGS="$EXTRA_CFLAGS -DXTSTRINGDEFINES"
		fi
	done
	rm -f conftest*
	CFLAGS="$cf_save_CFLAGS"
fi
AC_SUBST(EXTRA_CFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl Verify Version of GNAT.
AC_DEFUN([CF_GNAT_VERSION],
[
changequote(<<, >>)dnl
cf_cv_gnat_version=`$cf_ada_make -v 2>&1 | grep '[0-9].[0-9][0-9]*' |\
  sed -e 's/[^0-9 \.]//g' | $AWK '{print $<<1>>;}'`
case $cf_cv_gnat_version in
  3.[1-9]*|[4-9].*)
    ac_cv_prog_gnat_correct=yes
    ;;
  *) echo Unsupported GNAT version $cf_cv_gnat_version. Required is 3.10 or better. Disabling Ada95 binding.
     ac_cv_prog_gnat_correct=no
     ;;
esac
case $cf_cv_gnat_version in
  3.1*|[4-9].*)
      cf_compile_generics=generics
      ;;
  *)  cf_compile_generics=
      ;;
esac
changequote([, ])dnl
])
dnl ---------------------------------------------------------------------------
dnl Insert text into the help-message, for readability, from AC_ARG_WITH.
AC_DEFUN([CF_HELP_MESSAGE],
[AC_DIVERT_HELP([$1])dnl
])dnl
dnl ---------------------------------------------------------------------------
dnl Construct the list of include-options according to whether we're building
dnl in the source directory or using '--srcdir=DIR' option.  If we're building
dnl with gcc, don't append the includedir if it happens to be /usr/include,
dnl since that usually breaks gcc's shadow-includes.
AC_DEFUN([CF_INCLUDE_DIRS],
[
CPPFLAGS="$CPPFLAGS -I. -I../include"
if test "$srcdir" != "."; then
	CPPFLAGS="$CPPFLAGS -I\$(srcdir)/../include"
fi
if test -z "$GCC"; then
	CPPFLAGS="$CPPFLAGS -I\$(includedir)"
elif test "$includedir" != "/usr/include"; then
	if test "$includedir" = '${prefix}/include' ; then
		if test $prefix != /usr ; then
			CPPFLAGS="$CPPFLAGS -I\$(includedir)"
		fi
	else
		CPPFLAGS="$CPPFLAGS -I\$(includedir)"
	fi
fi
AC_SUBST(CPPFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if we have either a function or macro for 'isascii()'.
AC_DEFUN([CF_ISASCII],
[
AC_MSG_CHECKING(for isascii)
AC_CACHE_VAL(cf_cv_have_isascii,[
	AC_TRY_LINK([#include <ctype.h>],[int x = isascii(' ')],
	[cf_cv_have_isascii=yes],
	[cf_cv_have_isascii=no])
])dnl
AC_MSG_RESULT($cf_cv_have_isascii)
test $cf_cv_have_isascii = yes && AC_DEFINE(HAVE_ISASCII)
])dnl
dnl ---------------------------------------------------------------------------
dnl Append definitions and rules for the given models to the subdirectory
dnl Makefiles, and the recursion rule for the top-level Makefile.  If the
dnl subdirectory is a library-source directory, modify the LIBRARIES list in
dnl the corresponding makefile to list the models that we'll generate.
dnl
dnl For shared libraries, make a list of symbolic links to construct when
dnl generating each library.  The convention used for Linux is the simplest
dnl one:
dnl	lib<name>.so	->
dnl	lib<name>.so.<major>	->
dnl	lib<name>.so.<maj>.<minor>
AC_DEFUN([CF_LIB_RULES],
[
CF_LIB_PREFIX(cf_prefix)
AC_REQUIRE([CF_SUBST_NCURSES_VERSION])
for cf_dir in $SRC_SUBDIRS
do
	if test -f $srcdir/$cf_dir/modules; then

		cf_libs_to_make=
		for cf_item in $CF_LIST_MODELS
		do
			CF_LIB_SUFFIX($cf_item,cf_suffix)
			cf_libs_to_make="$cf_libs_to_make ../lib/${cf_prefix}${cf_dir}${cf_suffix}"
		done

		if test $cf_dir = ncurses ; then
			case "$LIB_SUBSETS" in
			termlib+*) #(vi
				;;
			*) #(vi
				cf_item=`echo $cf_libs_to_make |sed -e s/$LIB_NAME/$TINFO_NAME/g`
				cf_libs_to_make="$cf_libs_to_make $cf_item"
				;;
			esac
		fi

		sed -e "s@\@LIBS_TO_MAKE\@@$cf_libs_to_make@" \
			$cf_dir/Makefile >$cf_dir/Makefile.out
		mv $cf_dir/Makefile.out $cf_dir/Makefile

		$AWK -f $srcdir/mk-0th.awk \
			name=$cf_dir \
			$srcdir/$cf_dir/modules >>$cf_dir/Makefile

		for cf_item in $CF_LIST_MODELS
		do
			echo 'Appending rules for '$cf_item' model ('$cf_dir')'
			CF_UPPER(CF_ITEM,$cf_item)
			CF_LIB_SUFFIX($cf_item,cf_suffix)
			CF_OBJ_SUBDIR($cf_item,cf_subdir)

			# These dependencies really are for development, not
			# builds, but they are useful in porting, too.
			cf_depend="../include/ncurses_cfg.h"
			if test "$srcdir" = "."; then
				cf_reldir="."
			else
				cf_reldir="\$(srcdir)"
			fi

			if test -f $srcdir/$cf_dir/$cf_dir.priv.h; then
				cf_depend="$cf_depend $cf_reldir/$cf_dir.priv.h"
			elif test -f $srcdir/$cf_dir/curses.priv.h; then
				cf_depend="$cf_depend $cf_reldir/curses.priv.h"
			fi

			for cf_subset in $LIB_SUBSETS
			do
			$AWK -f $srcdir/mk-1st.awk \
				name=$cf_dir \
				MODEL=$CF_ITEM \
				model=$cf_subdir \
				prefix=$cf_prefix \
				suffix=$cf_suffix \
				subset=$cf_subset \
				DoLinks=$cf_cv_do_symlinks \
				rmSoLocs=$cf_cv_rm_so_locs \
				ldconfig="$LDCONFIG" \
				overwrite=$WITH_OVERWRITE \
				depend="$cf_depend" \
				target="$target" \
				$srcdir/$cf_dir/modules >>$cf_dir/Makefile
			test $cf_dir = ncurses && WITH_OVERWRITE=no
			$AWK -f $srcdir/mk-2nd.awk \
				name=$cf_dir \
				MODEL=$CF_ITEM \
				model=$cf_subdir \
				subset=$cf_subset \
				srcdir=$srcdir \
				echo=$WITH_ECHO \
				$srcdir/$cf_dir/modules >>$cf_dir/Makefile
			done
		done
	fi

	echo '	cd '$cf_dir' && $(MAKE) $(CF_MFLAGS) [$]@' >>Makefile
done

for cf_dir in $SRC_SUBDIRS
do
	if test -f $cf_dir/Makefile ; then
		case "$cf_dir" in
		Ada95) #(vi
			echo 'install.libs \' >> Makefile
			echo 'uninstall.libs ::' >> Makefile
			echo '	cd '$cf_dir' && $(MAKE) $(CF_MFLAGS) [$]@' >> Makefile
			;;
		esac
	fi

	if test -f $srcdir/$cf_dir/modules; then
		echo >> Makefile
		if test -f $srcdir/$cf_dir/headers; then
cat >> Makefile <<CF_EOF
install.includes \\
uninstall.includes \\
CF_EOF
		fi
if test "$cf_dir" != "c++" ; then
echo 'lint \' >> Makefile
fi
cat >> Makefile <<CF_EOF
lintlib \\
install.libs \\
uninstall.libs \\
install.$cf_dir \\
uninstall.$cf_dir ::
	cd $cf_dir && \$(MAKE) \$(CF_MFLAGS) \[$]@
CF_EOF
	elif test -f $srcdir/$cf_dir/headers; then
cat >> Makefile <<CF_EOF

install.libs \\
uninstall.libs \\
install.includes \\
uninstall.includes ::
	cd $cf_dir && \$(MAKE) \$(CF_MFLAGS) \[$]@
CF_EOF
fi
done

cat >> Makefile <<CF_EOF

install.data ::
	cd misc && \$(MAKE) \$(CF_MFLAGS) \[$]@

install.man ::
	cd man && \$(MAKE) \$(CF_MFLAGS) \[$]@

distclean ::
	rm -f config.cache config.log config.status Makefile include/ncurses_cfg.h
	rm -f headers.sh headers.sed
	rm -rf \$(DIRS_TO_MAKE)
CF_EOF

dnl If we're installing into a subdirectory of /usr/include, etc., we should
dnl prepend the subdirectory's name to the "#include" paths.  It won't hurt
dnl anything, and will make it more standardized.  It's awkward to decide this
dnl at configuration because of quoting, so we'll simply make all headers
dnl installed via a script that can do the right thing.

rm -f headers.sed headers.sh

dnl ( generating this script makes the makefiles a little tidier :-)
echo creating headers.sh
cat >headers.sh <<CF_EOF
#! /bin/sh
# This shell script is generated by the 'configure' script.  It is invoked in a
# subdirectory of the build tree.  It generates a sed-script in the parent
# directory that is used to adjust includes for header files that reside in a
# subdirectory of /usr/include, etc.
PRG=""
while test \[$]# != 3
do
PRG="\$PRG \[$]1"; shift
done
DST=\[$]1
REF=\[$]2
SRC=\[$]3
echo installing \$SRC in \$DST
case \$DST in
/*/include/*)
	TMP=\${TMPDIR-/tmp}/\`basename \$SRC\`
	if test ! -f ../headers.sed ; then
		END=\`basename \$DST\`
		for i in \`cat \$REF/../*/headers |fgrep -v "#"\`
		do
			NAME=\`basename \$i\`
			echo "s/<\$NAME>/<\$END\/\$NAME>/" >> ../headers.sed
		done
	fi
	rm -f \$TMP
	sed -f ../headers.sed \$SRC > \$TMP
	eval \$PRG \$TMP \$DST
	rm -f \$TMP
	;;
*)
	eval \$PRG \$SRC \$DST
	;;
esac
CF_EOF

chmod 0755 headers.sh

for cf_dir in $SRC_SUBDIRS
do
	if test -f $srcdir/$cf_dir/headers; then
	cat >>$cf_dir/Makefile <<CF_EOF
\$(INSTALL_PREFIX)\$(includedir) :
	\$(srcdir)/../mkinstalldirs \[$]@

install \\
install.libs \\
install.includes :: \$(INSTALL_PREFIX)\$(includedir) \\
CF_EOF
		j=""
		for i in `cat $srcdir/$cf_dir/headers |fgrep -v "#"`
		do
			test -n "$j" && echo "		$j \\" >>$cf_dir/Makefile
			j=$i
		done
		echo "		$j" >>$cf_dir/Makefile
		for i in `cat $srcdir/$cf_dir/headers |fgrep -v "#"`
		do
			echo "	@ (cd \$(INSTALL_PREFIX)\$(includedir) && rm -f `basename $i`) ; ../headers.sh \$(INSTALL_DATA) \$(INSTALL_PREFIX)\$(includedir) \$(srcdir) $i" >>$cf_dir/Makefile
			test $i = curses.h && echo "	@ (cd \$(INSTALL_PREFIX)\$(includedir) && rm -f ncurses.h && \$(LN_S) curses.h ncurses.h)" >>$cf_dir/Makefile
		done

	cat >>$cf_dir/Makefile <<CF_EOF

uninstall \\
uninstall.libs \\
uninstall.includes ::
CF_EOF
		for i in `cat $srcdir/$cf_dir/headers |fgrep -v "#"`
		do
			i=`basename $i`
			echo "	-@ (cd \$(INSTALL_PREFIX)\$(includedir) && rm -f $i)" >>$cf_dir/Makefile
			test $i = curses.h && echo "	-@ (cd \$(INSTALL_PREFIX)\$(includedir) && rm -f ncurses.h)" >>$cf_dir/Makefile
		done
	fi
done

])dnl
dnl ---------------------------------------------------------------------------
dnl Compute the library-prefix for the given host system
dnl $1 = variable to set
AC_DEFUN([CF_LIB_PREFIX],
[
	case $cf_cv_system_name in
	os2)	$1=''     ;;
	*)	$1='lib'  ;;
	esac
])dnl
dnl ---------------------------------------------------------------------------
dnl Compute the library-suffix from the given model name
dnl $1 = model name
dnl $2 = variable to set
AC_DEFUN([CF_LIB_SUFFIX],
[
	AC_REQUIRE([CF_SUBST_NCURSES_VERSION])
	case $1 in
	normal)  $2='.a'   ;;
	debug)   $2='_g.a' ;;
	profile) $2='_p.a' ;;
	shared)
		case $cf_cv_system_name in
		openbsd*|netbsd*|freebsd*)
			$2='.so.$(REL_VERSION)' ;;
		hpux*)	$2='.sl'  ;;
		*)	$2='.so'  ;;
		esac
	esac
])dnl
dnl ---------------------------------------------------------------------------
dnl Compute the string to append to -library from the given model name
AC_DEFUN([CF_LIB_TYPE],
[
	case $1 in
	normal)  $2=''   ;;
	debug)   $2='_g' ;;
	profile) $2='_p' ;;
	shared)  $2=''   ;;
	esac
])dnl
dnl ---------------------------------------------------------------------------
dnl Some systems have a non-ANSI linker that doesn't pull in modules that have
dnl only data (i.e., no functions), for example NeXT.  On those systems we'll
dnl have to provide wrappers for global tables to ensure they're linked
dnl properly.
AC_DEFUN([CF_LINK_DATAONLY],
[
AC_MSG_CHECKING([if data-only library module links])
AC_CACHE_VAL(cf_cv_link_dataonly,[
	rm -f conftest.a
	changequote(,)dnl
	cat >conftest.$ac_ext <<EOF
#line __oline__ "configure"
int	testdata[3] = { 123, 456, 789 };
EOF
	changequote([,])dnl
	if AC_TRY_EVAL(ac_compile) ; then
		mv conftest.o data.o && \
		( $AR $AR_OPTS conftest.a data.o ) 2>&5 1>/dev/null
	fi
	rm -f conftest.$ac_ext data.o
	changequote(,)dnl
	cat >conftest.$ac_ext <<EOF
#line __oline__ "configure"
int	testfunc()
{
#if defined(NeXT)
	exit(1);	/* I'm told this linker is broken */
#else
	extern int testdata[3];
	return testdata[0] == 123
	   &&  testdata[1] == 456
	   &&  testdata[2] == 789;
#endif
}
EOF
	changequote([,])dnl
	if AC_TRY_EVAL(ac_compile); then
		mv conftest.o func.o && \
		( $AR $AR_OPTS conftest.a func.o ) 2>&5 1>/dev/null
	fi
	rm -f conftest.$ac_ext func.o
	( eval $ac_cv_prog_RANLIB conftest.a ) 2>&5 >/dev/null
	cf_saveLIBS="$LIBS"
	LIBS="conftest.a $LIBS"
	AC_TRY_RUN([
	int main()
	{
		extern int testfunc();
		exit (!testfunc());
	}
	],
	[cf_cv_link_dataonly=yes],
	[cf_cv_link_dataonly=no],
	[cf_cv_link_dataonly=unknown])
	LIBS="$cf_saveLIBS"
	])
AC_MSG_RESULT($cf_cv_link_dataonly)
test $cf_cv_link_dataonly = no && AC_DEFINE(BROKEN_LINKER)
])dnl
dnl ---------------------------------------------------------------------------
dnl Some 'make' programs support $(MAKEFLAGS), some $(MFLAGS), to pass 'make'
dnl options to lower-levels.  It's very useful for "make -n" -- if we have it.
dnl (GNU 'make' does both :-)
AC_DEFUN([CF_MAKEFLAGS],
[
AC_MSG_CHECKING([for makeflags variable])
AC_CACHE_VAL(cf_cv_makeflags,[
	cf_cv_makeflags=''
	for cf_option in '$(MFLAGS)' '-$(MAKEFLAGS)'
	do
		cat >cf_makeflags.tmp <<CF_EOF
all :
	echo '.$cf_option'
CF_EOF
		set cf_result=`${MAKE-make} -f cf_makeflags.tmp 2>/dev/null`
		if test "$cf_result" != "."
		then
			cf_cv_makeflags=$cf_option
			break
		fi
	done
	rm -f cf_makeflags.tmp])
AC_MSG_RESULT($cf_cv_makeflags)
AC_SUBST(cf_cv_makeflags)
])dnl
dnl ---------------------------------------------------------------------------
dnl Try to determine if the man-pages on the system are compressed, and if
dnl so, what format is used.  Use this information to construct a script that
dnl will install man-pages.
AC_DEFUN([CF_MAN_PAGES],
[AC_MSG_CHECKING(format of man-pages)
  if test -z "$MANPATH" ; then
    MANPATH="/usr/man:/usr/share/man"
  fi
  # look for the 'date' man-page (it's most likely to be installed!)
  IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS="${IFS}:"
  cf_form=unknown
  for cf_dir in $MANPATH; do
    test -z "$cf_dir" && cf_dir=/usr/man
    cf_rename=""
    cf_format=no
changequote({{,}})dnl
    for cf_name in $cf_dir/*/date.[01]* $cf_dir/*/date
changequote([,])dnl
    do
       cf_test=`echo $cf_name | sed -e 's/*//'`
       if test "x$cf_test" = "x$cf_name" ; then
	  case "$cf_name" in
	  *.gz) cf_form=gzip;     cf_name=`basename $cf_name .gz`;;
	  *.Z)  cf_form=compress; cf_name=`basename $cf_name .Z`;;
	  *.0)	cf_form=BSDI; cf_format=yes;;
	  *)    cf_form=cat;;
	  esac
	  break
       fi
    done
    if test "$cf_form" != "unknown" ; then
       break
    fi
  done
  IFS="$ac_save_ifs"
  if test "$prefix" = "NONE" ; then
     cf_prefix="$ac_default_prefix"
  else
     cf_prefix="$prefix"
  fi

  # Debian 'man' program?
  test -f /etc/debian_version && \
  cf_rename=`cd $srcdir && pwd`/man/man_db.renames

  test ! -d man && mkdir man

  # Construct a sed-script to perform renaming within man-pages
  if test -n "$cf_rename" ; then
    $srcdir/man/make_sed.sh $cf_rename >man/edit_man.sed
  fi
  if test $cf_format = yes ; then
    cf_subdir='$mandir/cat'
  else
    cf_subdir='$mandir/man'
  fi

cat >man/edit_man.sh <<CF_EOF
changequote({{,}})dnl
#! /bin/sh
# this script is generated by the configure-script
prefix="$cf_prefix"
datadir="$datadir"
MKDIRS="`cd $srcdir && pwd`/mkinstalldirs"
INSTALL="$INSTALL"
INSTALL_DATA="$INSTALL_DATA"
TMP=\${TMPDIR-/tmp}/man\$\$
trap "rm -f \$TMP" 0 1 2 5 15

verb=\{{$}}1
shift

mandir=\{{$}}1
shift

for i in \{{$}}*
do
case \$i in
*.[0-9]*)
	section=\`expr "\$i" : '.*\\.\\([0-9]\\)[xm]*'\`;
	if test \$verb = installing ; then
	if test ! -d $cf_subdir\${section} ; then
		\$MKDIRS $cf_subdir\$section
	fi
	fi
	source=\`basename \$i\`
CF_EOF
if test -z "$cf_rename" ; then
cat >>man/edit_man.sh <<CF_EOF
	target=$cf_subdir\${section}/\$source
	sed -e "s,@DATADIR@,\$datadir," < \$i >\$TMP
CF_EOF
else
cat >>man/edit_man.sh <<CF_EOF
	target=\`grep "^\$source" $cf_rename | $AWK '{print \{{$}}2}'\`
	if test -z "\$target" ; then
		echo '? missing rename for '\$source
		target="\$source"
	fi
	target="$cf_subdir\$section/\$target"
	test \$verb = installing && sed -e "s,@DATADIR@,\$datadir," < \$i | sed -f edit_man.sed >\$TMP
CF_EOF
fi
if test \$verb = installing ; then
if test $cf_format = yes ; then
cat >>man/edit_man.sh <<CF_EOF
	nroff -man \$TMP >\$TMP.out
	mv \$TMP.out \$TMP
CF_EOF
fi
fi
case "$cf_form" in
compress)
cat >>man/edit_man.sh <<CF_EOF
	if test \$verb = installing ; then
	if ( compress -f \$TMP )
	then
		mv \$TMP.Z \$TMP
	fi
	fi
	target="\$target.Z"
CF_EOF
  ;;
gzip)
cat >>man/edit_man.sh <<CF_EOF
	if test \$verb = installing ; then
	if ( gzip -f \$TMP )
	then
		mv \$TMP.gz \$TMP
	fi
	fi
	target="\$target.gz"
CF_EOF
  ;;
BSDI)
cat >>man/edit_man.sh <<CF_EOF
	# BSDI installs only .0 suffixes in the cat directories
	target="\`echo \$target|sed -e 's/\.[1-9]\+.\?/.0/'\`"
CF_EOF
  ;;
esac
cat >>man/edit_man.sh <<CF_EOF
	echo \$verb \$target
	if test \$verb = installing ; then
		\$INSTALL_DATA \$TMP \$target
	else
		rm -f \$target
	fi
	;;
esac
done 
CF_EOF
changequote([,])dnl
chmod 755 man/edit_man.sh
AC_MSG_RESULT($cf_form)
])dnl
dnl ---------------------------------------------------------------------------
dnl Compute the object-directory name from the given model name
AC_DEFUN([CF_OBJ_SUBDIR],
[
	case $1 in
	normal)  $2='objects' ;;
	debug)   $2='obj_g' ;;
	profile) $2='obj_p' ;;
	shared)  $2='obj_s' ;;
	esac
])dnl
dnl ---------------------------------------------------------------------------
dnl Within AC_OUTPUT, check if the given file differs from the target, and
dnl update it if so.  Otherwise, remove the generated file.
dnl
dnl Parameters:
dnl $1 = input, which configure has done substitutions upon
dnl $2 = target file
dnl
AC_DEFUN([CF_OUTPUT_IF_CHANGED],[
if ( cmp -s $1 $2 2>/dev/null )
then
	echo "$2 is unchanged"
	rm -f $1
else
	echo "creating $2"
	rm -f $2
	mv $1 $2
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Force $INSTALL to be an absolute-path.  Otherwise, edit_man.sh and the
dnl misc/tabset install won't work properly.  Usually this happens only when
dnl using the fallback mkinstalldirs script
AC_DEFUN([CF_PROG_INSTALL],
[AC_PROG_INSTALL
case $INSTALL in
/*)
  ;;
*)
changequote({{,}})dnl
  cf_dir=`echo $INSTALL|sed -e 's%/[^/]*$%%'`
  test -z "$cf_dir" && cf_dir=.
changequote([,])dnl
  INSTALL=`cd $cf_dir && pwd`/`echo $INSTALL | sed -e 's:^.*/::'`
  ;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl Attempt to determine if we've got one of the flavors of regular-expression
dnl code that we can support.
AC_DEFUN([CF_REGEX],
[
AC_MSG_CHECKING([for regular-expression headers])
AC_CACHE_VAL(cf_cv_regex,[
AC_TRY_LINK([#include <sys/types.h>
#include <regex.h>],[
	regex_t *p;
	int x = regcomp(p, "", 0);
	int y = regexec(p, "", 0, 0, 0);
	regfree(p);
	],[cf_cv_regex="regex.h"],[
	AC_TRY_LINK([#include <regexp.h>],[
		char *p = compile("", "", "", 0);
		int x = step("", "");
	],[cf_cv_regex="regexp.h"],[
		cf_save_LIBS="$LIBS"
		LIBS="-lgen $LIBS"
		AC_TRY_LINK([#include <regexpr.h>],[
			char *p = compile("", "", "");
			int x = step("", "");
		],[cf_cv_regex="regexpr.h"],[LIBS="$cf_save_LIBS"])])])
])
AC_MSG_RESULT($cf_cv_regex)
case $cf_cv_regex in
	regex.h)   AC_DEFINE(HAVE_REGEX_H_FUNCS) ;;
	regexp.h)  AC_DEFINE(HAVE_REGEXP_H_FUNCS) ;;
	regexpr.h) AC_DEFINE(HAVE_REGEXPR_H_FUNCS) ;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl This bypasses the normal autoconf process because we're generating an
dnl arbitrary number of NEED_xxxx definitions with the CF_HAVE_FUNCS macro. 
dnl Rather than populate an aclocal.h file with all of those definitions, we do
dnl it here.
dnl
dnl Parameters:
dnl $1 = input, which configure has done substitutions upon (will delete)
dnl $2 = target file
dnl $3 = preamble, if any (a 'here' document)
dnl $4 = trailer, if any (a 'here' document)
dnl
AC_DEFUN([CF_SED_CONFIG_H],[
cf_config_h=conf$$
rm -f $cf_config_h
## PREAMBLE
ifelse($3,,[
echo '/* generated by configure-script */' >$cf_config_h
],[cat >$cf_config_h <<CF_EOF
$3[]dnl
CF_EOF])
## DEFINITIONS
if test -n "$ac_cv_path_TD_CONFIG" ; then
	$ac_cv_path_TD_CONFIG $1 |egrep -v '^#' >$cf_config_h
	$ac_cv_path_TD_CONFIG $1 |egrep '^#' | sort >>$cf_config_h
else
grep -v '^ -D' $1 >>$cf_config_h
changequote(,)dnl
sed	-e '/^ -D/!d' \
	-e '/^# /d' \
	-e 's/ -D/\
#define /g' \
	-e 's/\(#define [A-Za-z_][A-Za-z0-9_]*\)=/\1	/g' \
	-e 's@\\@@g' \
	$1 | sort >>$cf_config_h
changequote([,])dnl
fi
## TRAILER
ifelse($4,,,
[cat >>$cf_config_h <<CF_EOF
$4[]dnl
CF_EOF])
CF_OUTPUT_IF_CHANGED($cf_config_h,$2)
rm -f $1 $cf_config_h
])dnl
dnl ---------------------------------------------------------------------------
dnl Attempt to determine the appropriate CC/LD options for creating a shared
dnl library.
dnl
dnl Note: $(LOCAL_LDFLAGS) is used to link executables that will run within the 
dnl build-tree, i.e., by making use of the libraries that are compiled in ../lib
dnl We avoid compiling-in a ../lib path for the shared library since that can
dnl lead to unexpected results at runtime.
dnl $(LOCAL_LDFLAGS2) has the same intention but assumes that the shared libraries
dnl are compiled in ../../lib
dnl
dnl The variable 'cf_cv_do_symlinks' is used to control whether we configure
dnl to install symbolic links to the rel/abi versions of shared libraries.
dnl
dnl Some loaders leave 'so_locations' lying around.  It's nice to clean up.
AC_DEFUN([CF_SHARED_OPTS],
[
	AC_REQUIRE([CF_SUBST_NCURSES_VERSION])
 	LOCAL_LDFLAGS=
 	LOCAL_LDFLAGS2=
	LD_SHARED_OPTS=
	INSTALL_LIB="-m 644"

	cf_cv_do_symlinks=no
	cf_cv_rm_so_locs=no

	case $cf_cv_system_name in
	hpux*)
		# (tested with gcc 2.7.2 -- I don't have c89)
		if test "${CC}" = "gcc"; then
			CC_SHARED_OPTS='-fPIC'
			LD_SHARED_OPTS='-Xlinker +b -Xlinker $(libdir)'
		else
			CC_SHARED_OPTS='+Z'
			LD_SHARED_OPTS='+b $(libdir)'
		fi
		MK_SHARED_LIB='$(LD) -b -o $[@]'
		# HP-UX shared libraries must be executable, and should be
		# readonly to exploit a quirk in the memory manager.
		INSTALL_LIB="-m 555"
		;;
	irix*)
		# tested with IRIX 5.2 and 'cc'.
		if test "${CC}" = "gcc"; then
			CC_SHARED_OPTS='-fPIC'
		else
			CC_SHARED_OPTS='-KPIC'
		fi
		MK_SHARED_LIB='$(LD) -shared -rdata_shared -soname `basename $[@]` -o $[@]'
		cf_cv_rm_so_locs=yes
		;;
	linux*)
		# tested with Linux 2.0.29 and gcc 2.7.2 (ELF)
		CC_SHARED_OPTS='-fPIC'
 		MK_SHARED_LIB='gcc -o $[@].$(REL_VERSION) -L../lib -L\$(libdir) -shared -Wl,-soname,`basename $[@].$(ABI_VERSION)`,-stats,$(SHLIB_LIST)-lc'
		test $cf_cv_ld_rpath = yes && cf_ld_rpath_opt="-Wl,-rpath,"
		if test $DFT_LWR_MODEL = "shared" ; then
 			LOCAL_LDFLAGS='-Wl,-rpath,../lib'
 			LOCAL_LDFLAGS2='-Wl,-rpath,../../lib'
		fi
		cf_cv_do_symlinks=yes
		;;
	openbsd*|netbsd*|freebsd*)
		CC_SHARED_OPTS='-fpic -DPIC'
		MK_SHARED_LIB='$(LD) -Bshareable -o $[@]'
		;;
	osf*|mls+*)
		# tested with OSF/1 V3.2 and 'cc'
		# tested with OSF/1 V3.2 and gcc 2.6.3 (but the c++ demo didn't
		# link with shared libs).
		CC_SHARED_OPTS=''
 		MK_SHARED_LIB='$(LD) -o $[@].$(REL_VERSION) -set_version $(ABI_VERSION):$(REL_VERSION) -expect_unresolved "*" -shared -soname `basename $[@].$(ABI_VERSION)`'
		test $cf_cv_ld_rpath = yes && cf_ld_rpath_opt="-rpath"
		case $host_os in
		osf4*)
 			MK_SHARED_LIB="${MK_SHARED_LIB} -msym"
			;;
		esac
		if test $DFT_LWR_MODEL = "shared" ; then
 			LOCAL_LDFLAGS='-Wl,-rpath,../lib'
 			LOCAL_LDFLAGS2='-Wl,-rpath,../../lib'
		fi
		cf_cv_do_symlinks=yes
		cf_cv_rm_so_locs=yes
		;;
	sunos4*)
		# tested with SunOS 4.1.1 and gcc 2.7.0
		if test $ac_cv_prog_gcc = yes; then
			CC_SHARED_OPTS='-fpic'
		else
			CC_SHARED_OPTS='-KPIC'
		fi
		MK_SHARED_LIB='$(LD) -assert pure-text -o $[@].$(REL_VERSION)'
		cf_cv_do_symlinks=yes
		;;
	solaris2*)
		# tested with SunOS 5.5.1 (solaris 2.5.1) and gcc 2.7.2
		if test $ac_cv_prog_gcc = yes; then
			CC_SHARED_OPTS='-fpic'
		else
			CC_SHARED_OPTS='-KPIC'
		fi
		MK_SHARED_LIB='$(LD) -dy -G -h `basename $[@].$(ABI_VERSION)` -o $[@].$(REL_VERSION)'
		if test $cf_cv_ld_rpath = yes ; then
			cf_ld_rpath_opt="-R"
			EXTRA_LDFLAGS="-R ../lib:\$(libdir) $EXTRA_LDFLAGS"
		fi
		cf_cv_do_symlinks=yes
		;;
	unix_sv*)
		# tested with UnixWare 1.1.2
		CC_SHARED_OPTS='-KPIC'
		MK_SHARED_LIB='$(LD) -d y -G -o $[@]'
		;;
	*)
		CC_SHARED_OPTS='unknown'
		MK_SHARED_LIB='echo unknown'
		;;
	esac

	if test -n "$cf_ld_rpath_opt" ; then
		AC_MSG_CHECKING(if we need a space after rpath option)
		cf_save_LIBS="$LIBS"
		LIBS="$LIBS ${cf_ld_rpath_opt}/usr/lib"
		AC_TRY_LINK(, , cf_rpath_space=no, cf_rpath_space=yes)
		LIBS="$cf_save_LIBS"
		AC_MSG_RESULT($cf_rpath_space)
		test $cf_rpath_space = yes && cf_ld_rpath_opt="$cf_ld_rpath_opt "
		MK_SHARED_LIB="$MK_SHARED_LIB $cf_ld_rpath_opt\$(libdir)"
	fi

	AC_SUBST(CC_SHARED_OPTS)
	AC_SUBST(LD_SHARED_OPTS)
	AC_SUBST(MK_SHARED_LIB)
	AC_SUBST(EXTRA_LDFLAGS)
	AC_SUBST(LOCAL_LDFLAGS)
	AC_SUBST(LOCAL_LDFLAGS2)
	AC_SUBST(INSTALL_LIB)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check for definitions & structures needed for window size-changing
dnl FIXME: check that this works with "snake" (HP-UX 10.x)
AC_DEFUN([CF_SIZECHANGE],
[
AC_MSG_CHECKING([declaration of size-change])
AC_CACHE_VAL(cf_cv_sizechange,[
    cf_cv_sizechange=unknown
    cf_save_CFLAGS="$CFLAGS"

for cf_opts in "" "NEED_PTEM_H"
do

    CFLAGS="$cf_save_CFLAGS"
    test -n "$cf_opts" && CFLAGS="$CFLAGS -D$cf_opts"
    AC_TRY_COMPILE([#include <sys/types.h>
#if HAVE_TERMIOS_H
#include <termios.h>
#else
#if HAVE_TERMIO_H
#include <termio.h>
#endif
#endif
#if NEED_PTEM_H
/* This is a workaround for SCO:  they neglected to define struct winsize in
 * termios.h -- it's only in termio.h and ptem.h
 */
#include        <sys/stream.h>
#include        <sys/ptem.h>
#endif
#if !defined(sun) || !defined(HAVE_TERMIOS_H)
#include <sys/ioctl.h>
#endif
],[
#ifdef TIOCGSIZE
	struct ttysize win;	/* FIXME: what system is this? */
	int y = win.ts_lines;
	int x = win.ts_cols;
#else
#ifdef TIOCGWINSZ
	struct winsize win;
	int y = win.ws_row;
	int x = win.ws_col;
#else
	no TIOCGSIZE or TIOCGWINSZ
#endif /* TIOCGWINSZ */
#endif /* TIOCGSIZE */
	],
	[cf_cv_sizechange=yes],
	[cf_cv_sizechange=no])

	CFLAGS="$cf_save_CFLAGS"
	if test "$cf_cv_sizechange" = yes ; then
		echo "size-change succeeded ($cf_opts)" >&AC_FD_CC
		test -n "$cf_opts" && AC_DEFINE_UNQUOTED($cf_opts)
		break
	fi
done
	])
AC_MSG_RESULT($cf_cv_sizechange)
test $cf_cv_sizechange != no && AC_DEFINE(HAVE_SIZECHANGE)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check for datatype 'speed_t', which is normally declared via either
dnl sys/types.h or termios.h
AC_DEFUN([CF_SPEED_TYPE],
[
AC_MSG_CHECKING([for speed_t])
AC_CACHE_VAL(cf_cv_type_speed_t,[
	AC_TRY_COMPILE([
#include <sys/types.h>
#if HAVE_TERMIOS_H
#include <termios.h>
#endif],
	[speed_t x = 0],
	[cf_cv_type_speed_t=yes],
	[cf_cv_type_speed_t=no])
	])
AC_MSG_RESULT($cf_cv_type_speed_t)
test $cf_cv_type_speed_t != yes && AC_DEFINE(speed_t,unsigned)
])dnl
dnl ---------------------------------------------------------------------------
dnl For each parameter, test if the source-directory exists, and if it contains
dnl a 'modules' file.  If so, add to the list $cf_cv_src_modules which we'll
dnl use in CF_LIB_RULES.
dnl
dnl This uses the configured value to make the lists SRC_SUBDIRS and
dnl SUB_MAKEFILES which are used in the makefile-generation scheme.
AC_DEFUN([CF_SRC_MODULES],
[
AC_MSG_CHECKING(for src modules)

# dependencies and linker-arguments for test-programs
TEST_DEPS="${LIB_PREFIX}${LIB_NAME}${DFT_DEP_SUFFIX} $TEST_DEPS"
TEST_ARGS="-l${LIB_NAME}${DFT_ARG_SUFFIX} $TEST_ARGS"

# dependencies and linker-arguments for utility-programs
PROG_ARGS="$TEST_ARGS"

cf_cv_src_modules=
for cf_dir in $1
do
	if test -f $srcdir/$cf_dir/modules; then

		# We may/may not have tack in the distribution, though the
		# makefile is.
		if test $cf_dir = tack ; then
			if test ! -f $srcdir/${cf_dir}/${cf_dir}.h; then
				continue
			fi
		fi

		if test -z "$cf_cv_src_modules"; then
			cf_cv_src_modules=$cf_dir
		else
			cf_cv_src_modules="$cf_cv_src_modules $cf_dir"
		fi

		# Make the ncurses_cfg.h file record the library interface files as
		# well.  These are header files that are the same name as their
		# directory.  Ncurses is the only library that does not follow
		# that pattern.
		if test $cf_dir = tack ; then
			continue
		elif test -f $srcdir/${cf_dir}/${cf_dir}.h; then
			CF_UPPER(cf_have_include,$cf_dir)
			AC_DEFINE_UNQUOTED(HAVE_${cf_have_include}_H)
			AC_DEFINE_UNQUOTED(HAVE_LIB${cf_have_include})
			TEST_DEPS="${LIB_PREFIX}${cf_dir}${DFT_DEP_SUFFIX} $TEST_DEPS"
			TEST_ARGS="-l${cf_dir}${DFT_ARG_SUFFIX} $TEST_ARGS"
		fi
	fi
done
AC_MSG_RESULT($cf_cv_src_modules)
TEST_ARGS="-L${LIB_DIR} -L\$(libdir) $TEST_ARGS"
AC_SUBST(TEST_DEPS)
AC_SUBST(TEST_ARGS)

PROG_ARGS="-L${LIB_DIR} -L\$(libdir) $PROG_ARGS"
AC_SUBST(PROG_ARGS)

SRC_SUBDIRS="man include"
for cf_dir in $cf_cv_src_modules
do
	SRC_SUBDIRS="$SRC_SUBDIRS $cf_dir"
done
SRC_SUBDIRS="$SRC_SUBDIRS misc test"
test $cf_cxx_library != no && SRC_SUBDIRS="$SRC_SUBDIRS c++"

ADA_SUBDIRS=
if test "$ac_cv_prog_gnat_correct" = yes && test -d $srcdir/Ada95; then
   SRC_SUBDIRS="$SRC_SUBDIRS Ada95"
   ADA_SUBDIRS="gen ada_include samples"
fi

SUB_MAKEFILES=
for cf_dir in $SRC_SUBDIRS
do
	SUB_MAKEFILES="$SUB_MAKEFILES $cf_dir/Makefile"
done

if test -n "$ADA_SUBDIRS"; then
   for cf_dir in $ADA_SUBDIRS
   do	
      SUB_MAKEFILES="$SUB_MAKEFILES Ada95/$cf_dir/Makefile"
   done
   AC_SUBST(ADA_SUBDIRS)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl	Remove "-g" option from the compiler options
AC_DEFUN([CF_STRIP_G_OPT],
[$1=`echo ${$1} | sed -e 's/-g //' -e 's/-g$//'`])dnl
dnl ---------------------------------------------------------------------------
dnl Check if we need _POSIX_SOURCE defined to use struct sigaction.  We'll only
dnl do this if we've found the sigaction function.
dnl
dnl If needed, define SVR4_ACTION.
AC_DEFUN([CF_STRUCT_SIGACTION],[
if test $ac_cv_func_sigaction = yes; then
AC_MSG_CHECKING(whether sigaction needs _POSIX_SOURCE)
AC_TRY_COMPILE([
#include <sys/types.h>
#include <signal.h>],
	[struct sigaction act],
	[sigact_bad=no],
	[
AC_TRY_COMPILE([
#define _POSIX_SOURCE
#include <sys/types.h>
#include <signal.h>],
	[struct sigaction act],
	[sigact_bad=yes
	 AC_DEFINE(SVR4_ACTION)],
	 [sigact_bad=unknown])])
AC_MSG_RESULT($sigact_bad)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl Some machines require _POSIX_SOURCE to completely define struct termios.
dnl If so, define SVR4_TERMIO
AC_DEFUN([CF_STRUCT_TERMIOS],[
if test $ac_cv_header_termios_h = yes ; then
	case "$CFLAGS" in
	*-D_POSIX_SOURCE*)
		termios_bad=dunno ;;
	*)	termios_bad=maybe ;;
	esac
	if test $termios_bad = maybe ; then
	AC_MSG_CHECKING(whether termios.h needs _POSIX_SOURCE)
	AC_TRY_COMPILE([#include <termios.h>],
		[struct termios foo; int x = foo.c_iflag],
		termios_bad=no, [
		AC_TRY_COMPILE([
#define _POSIX_SOURCE
#include <termios.h>],
			[struct termios foo; int x = foo.c_iflag],
			termios_bad=unknown,
			termios_bad=yes AC_DEFINE(SVR4_TERMIO))
			])
	AC_MSG_RESULT($termios_bad)
	fi
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl	Shorthand macro for substituting things that the user may override
dnl	with an environment variable.
dnl
dnl	$1 = long/descriptive name
dnl	$2 = environment variable
dnl	$3 = default value
AC_DEFUN([CF_SUBST],
[AC_CACHE_VAL(cf_cv_subst_$2,[
AC_MSG_CHECKING(for $1 (symbol $2))
test -z "[$]$2" && $2=$3
AC_MSG_RESULT([$]$2)
AC_SUBST($2)
cf_cv_subst_$2=[$]$2])
$2=${cf_cv_subst_$2}
])dnl
dnl ---------------------------------------------------------------------------
dnl Get the version-number for use in shared-library naming, etc.
AC_DEFUN([CF_SUBST_NCURSES_VERSION],
[
changequote(,)dnl
NCURSES_MAJOR="`egrep '^NCURSES_MAJOR[ 	]*=' $srcdir/dist.mk | sed -e 's/^[^0-9]*//'`"
NCURSES_MINOR="`egrep '^NCURSES_MINOR[ 	]*=' $srcdir/dist.mk | sed -e 's/^[^0-9]*//'`"
NCURSES_PATCH="`egrep '^NCURSES_PATCH[ 	]*=' $srcdir/dist.mk | sed -e 's/^[^0-9]*//'`"
changequote([,])dnl
cf_cv_abi_version=${NCURSES_MAJOR}
cf_cv_rel_version=${NCURSES_MAJOR}.${NCURSES_MINOR}
dnl Show the computed version, for logging
AC_MSG_RESULT(Configuring NCURSES $cf_cv_rel_version ABI $cf_cv_abi_version (`date`))
dnl We need these values in the generated headers
AC_SUBST(NCURSES_MAJOR)
AC_SUBST(NCURSES_MINOR)
AC_SUBST(NCURSES_PATCH)
dnl We need these values in the generated makefiles
AC_SUBST(cf_cv_rel_version)
AC_SUBST(cf_cv_abi_version)
AC_SUBST(cf_cv_builtin_bool)
AC_SUBST(cf_cv_type_of_bool)
])dnl
dnl ---------------------------------------------------------------------------
dnl Check if we can include <sys/time.h> with <sys/select.h>; this breaks on
dnl older SCO configurations.
AC_DEFUN([CF_SYS_TIME_SELECT],
[
AC_MSG_CHECKING(if sys/time.h works with sys/select.h)
AC_CACHE_VAL(cf_cv_sys_time_select,[
AC_TRY_COMPILE([
#include <sys/types.h>
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#if HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif
],[],[cf_cv_sys_time_select=yes],
     [cf_cv_sys_time_select=no])
     ])
AC_MSG_RESULT($cf_cv_sys_time_select)
test $cf_cv_sys_time_select = yes && AC_DEFINE(HAVE_SYS_TIME_SELECT)
])dnl
dnl ---------------------------------------------------------------------------
dnl Determine the type we should use for chtype (and attr_t, which is treated
dnl as the same thing).  We want around 32 bits, so on most machines want a
dnl long, but on newer 64-bit machines, probably want an int.  If we're using
dnl wide characters, we have to have a type compatible with that, as well.
AC_DEFUN([CF_TYPEOF_CHTYPE],
[
AC_REQUIRE([CF_UNSIGNED_LITERALS])
AC_MSG_CHECKING([for type of chtype])
AC_CACHE_VAL(cf_cv_typeof_chtype,[
		AC_TRY_RUN([
#if USE_WIDEC_SUPPORT
#include <stddef.h>	/* we want wchar_t */
#define WANT_BITS 39
#else
#define WANT_BITS 31
#endif
#include <stdio.h>
int main()
{
	FILE *fp = fopen("cf_test.out", "w");
	if (fp != 0) {
		char *result = "long";
#if USE_WIDEC_SUPPORT
		/*
		 * If wchar_t is smaller than a long, it must be an int or a
		 * short.  We prefer not to use a short anyway.
		 */
		if (sizeof(unsigned long) > sizeof(wchar_t))
			result = "int";
#endif
		if (sizeof(unsigned long) > sizeof(unsigned int)) {
			int n;
			unsigned int x;
			for (n = 0; n < WANT_BITS; n++) {
				unsigned int y = (x >> n);
				if (y != 1 || x == 0) {
					x = 0;
					break;
				}
			}
			/*
			 * If x is nonzero, an int is big enough for the bits
			 * that we want.
			 */
			result = (x != 0) ? "int" : "long";
		}
		fputs(result, fp);
		fclose(fp);
	}
	exit(0);
}
		],
		[cf_cv_typeof_chtype=`cat cf_test.out`],
		[cf_cv_typeof_chtype=long],
		[cf_cv_typeof_chtype=long])
		rm -f cf_test.out
	])
AC_MSG_RESULT($cf_cv_typeof_chtype)

AC_SUBST(cf_cv_typeof_chtype)
AC_DEFINE_UNQUOTED(TYPEOF_CHTYPE,$cf_cv_typeof_chtype)

cf_cv_1UL="1"
test "$cf_cv_unsigned_literals" = yes && cf_cv_1UL="${cf_cv_1UL}U"
test "$cf_cv_typeof_chtype"    = long && cf_cv_1UL="${cf_cv_1UL}L"
AC_SUBST(cf_cv_1UL)

])dnl
dnl ---------------------------------------------------------------------------
dnl
AC_DEFUN([CF_TYPE_SIGACTION],
[
AC_MSG_CHECKING([for type sigaction_t])
AC_CACHE_VAL(cf_cv_type_sigaction,[
	AC_TRY_COMPILE([
#include <signal.h>],
		[sigaction_t x],
		[cf_cv_type_sigaction=yes],
		[cf_cv_type_sigaction=no])])
AC_MSG_RESULT($cf_cv_type_sigaction)
test $cf_cv_type_sigaction = yes && AC_DEFINE(HAVE_TYPE_SIGACTION)
])dnl
dnl ---------------------------------------------------------------------------
dnl Test if the compiler supports 'U' and 'L' suffixes.  Only old compilers
dnl won't, but they're still there.
AC_DEFUN([CF_UNSIGNED_LITERALS],
[
AC_MSG_CHECKING([if unsigned literals are legal])
AC_CACHE_VAL(cf_cv_unsigned_literals,[
	AC_TRY_COMPILE([],[long x = 1L + 1UL + 1U + 1],
		[cf_cv_unsigned_literals=yes],
		[cf_cv_unsigned_literals=no])
	])
AC_MSG_RESULT($cf_cv_unsigned_literals)
])dnl
dnl ---------------------------------------------------------------------------
dnl Make an uppercase version of a variable
dnl $1=uppercase($2)
AC_DEFUN([CF_UPPER],
[
changequote(,)dnl
$1=`echo $2 | tr '[a-z]' '[A-Z]'`
changequote([,])dnl
])dnl
dnl ---------------------------------------------------------------------------
dnl Compute the shift-mask that we'll use for wide-character indices.  We use
dnl all but the index portion of chtype for storing attributes.
AC_DEFUN([CF_WIDEC_SHIFT],
[
AC_REQUIRE([CF_TYPEOF_CHTYPE])
AC_MSG_CHECKING([for number of bits in chtype])
AC_CACHE_VAL(cf_cv_shift_limit,[
	AC_TRY_RUN([
#include <stdio.h>
int main()
{
	FILE *fp = fopen("cf_test.out", "w");
	if (fp != 0) {
		int n;
		unsigned TYPEOF_CHTYPE x = 1L;
		for (n = 0; ; n++) {
			unsigned long y = (x >> n);
			if (y != 1 || x == 0)
				break;
			x <<= 1;
		}
		fprintf(fp, "%d", n);
		fclose(fp);
	}
	exit(0);
}
		],
		[cf_cv_shift_limit=`cat cf_test.out`],
		[cf_cv_shift_limit=32],
		[cf_cv_shift_limit=32])
		rm -f cf_test.out
	])
AC_MSG_RESULT($cf_cv_shift_limit)
AC_SUBST(cf_cv_shift_limit)

AC_MSG_CHECKING([for width of character-index])
AC_CACHE_VAL(cf_cv_widec_shift,[
if test ".$with_widec" = ".yes" ; then
	cf_attrs_width=39
	if ( expr $cf_cv_shift_limit \> $cf_attrs_width >/dev/null )
	then
		cf_cv_widec_shift=`expr 16 + $cf_cv_shift_limit - $cf_attrs_width`
	else
		cf_cv_widec_shift=16
	fi
else
	cf_cv_widec_shift=8
fi
])
AC_MSG_RESULT($cf_cv_widec_shift)
AC_SUBST(cf_cv_widec_shift)
])dnl
dnl ---------------------------------------------------------------------------
dnl Wrapper for AC_ARG_WITH to ensure that user supplies a pathname, not just
dnl defaulting to yes/no.
dnl
dnl $1 = option name
dnl $2 = help-text
dnl $3 = environment variable to set
dnl $4 = default value, shown in the help-message, must be a constant
dnl $5 = default value, if it's an expression & cannot be in the help-message
dnl
AC_DEFUN([CF_WITH_PATH],
[AC_ARG_WITH($1,[$2 ](default: ifelse($4,,empty,$4)),,
ifelse($4,,[withval="${$3}"],[withval="${$3-ifelse($5,,$4,$5)}"]))dnl
case ".$withval" in #(vi
./*) #(vi
  ;;
.\[$]{*prefix}*) #(vi
  eval withval="$withval"
  case ".$withval" in #(vi
  .NONE/*)
    withval=`echo $withval | sed -e s@NONE@$ac_default_prefix@`
    ;;
  esac
  ;; #(vi
.NONE/*)
  withval=`echo $withval | sed -e s@NONE@$ac_default_prefix@`
  ;;
*)
  AC_ERROR(expected a pathname for $1)
  ;;
esac
eval $3="$withval"
AC_SUBST($3)dnl
])dnl
