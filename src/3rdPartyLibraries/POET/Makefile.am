include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

noinst_LTLIBRARIES = libpoet.la
libpoet_la_SOURCES = poet_AST.cpp codegen.cpp parse.cpp eval.cpp eval_ext.cpp evalOp.cpp driver.cpp tokenize.cpp timing.cpp AutoTuningInterface.cpp poet_yacc.c poet_lex.c

bin_PROGRAMS = pcg
pcg_SOURCES =   main.cpp 
pcg_LDADD = libpoet.la


EXTRA_DIST = ASTeval.h     error_config.h     poet_AST.h           poet_ASTvisitor.h  poet_SymbolTable.h  timing.h \
            ASTfactory.h  poet_ASTeval.h     poetAST.h            poet_config.h      poet_yacc.h         windows_includes.h \
	    ASTvisitor.h  poet_ASTfactory.h  poet_ASTinterface.h  poet_error.h       SymbolTable.h
             

files = $(EXTRA_DIST) $(pcg_SOURCES)

AM_YFLAGS=-d -v
AM_CPPFLAGS = -DPOET_LIB_DIR=\"$(abs_top_srcdir)/lib\" -DPOET_DEST_DIR=\"$(DESTDIR)/$(libdir)/\"
INCLUDES = -DPOET_VERSION="\"1.03.06\"" -I$(top_srcdir)/src/midend/programTransformation/loopProcessing/driver -I$(top_srcdir)/src/midend/programTransformation/loopProcessing/slicing -I$(top_srcdir)/src/midend/programTransformation/loopProcessing/computation -I$(top_srcdir)/src/midend/programTransformation/loopProcessing/depGraph -I$(top_srcdir)/src/midend/programTransformation/loopProcessing/depInfo -I$(top_srcdir)/src/midend/astUtil/astInterface -I$(top_srcdir)/src/midend/astUtil/astSupport -I$(top_srcdir)/src/midend/astUtil/symbolicVal -I$(top_srcdir)/src/util/support -I$(top_srcdir)/src/util/graphs -I$(top_srcdir)/src/frontend/SageIII

include  $(top_srcdir)/src/3rdPartyLibraries/POET/Make.inc
rosedir= $(rose_srcdir)/src/3rdPartyLibraries/POET
