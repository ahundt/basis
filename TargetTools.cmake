##############################################################################
# @file  TargetTools.cmake
# @brief Functions and macros to add executable and library targets.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_TARGETTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_TARGETTOOLS_INCLUDED TRUE)
endif ()


## @addtogroup CMakeUtilities
#  @{


# ============================================================================
# properties
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set properties on a target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
# set_target_properties()</a> command and extends its functionality.
# In particular, it maps the given target names to the corresponding target UIDs.
#
# @note Due to a bug in CMake (http://www.cmake.org/Bug/view.php?id=12303),
#       except of the first property given directly after the @c PROPERTIES keyword,
#       only properties listed in @c BASIS_PROPERTIES_ON_TARGETS can be set.
#
# @param [in] ARGN List of arguments. See
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
#                  set_target_properties()</a>.
#
# @returns Sets the specified properties on the given target.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties
#
# @ingroup CMakeAPI
function (basis_set_target_properties)
  # convert target names to UIDs
  set (TARGET_UIDS)
  list (LENGTH ARGN N)
  if (N EQUAL 0)
    message (FATAL_ERROR "basis_set_target_properties(): Missing arguments!")
  endif ()
  list (GET ARGN 0 ARG)
  while (NOT ARG MATCHES "^PROPERTIES$")
    basis_get_target_uid (TARGET_UID "${ARG}")
    list (APPEND TARGET_UIDS "${TARGET_UID}")
    list (REMOVE_AT ARGN 0)
    list (LENGTH ARGN N)
    if (N EQUAL 0)
      break ()
    else ()
      list (GET ARGN 0 ARG)
    endif ()
  endwhile ()
  if (NOT ARG MATCHES "^PROPERTIES$")
    message (FATAL_ERROR "Missing PROPERTIES argument!")
  elseif (NOT TARGET_UIDS)
    message (FATAL_ERROR "No target specified!")
  endif ()
  # remove PROPERTIES keyword
  list (REMOVE_AT ARGN 0)
  math (EXPR N "${N} - 1")
  # set targets properties
  #
  # Note: By iterating over the properties, the empty property values
  #       are correctly passed on to CMake's set_target_properties()
  #       command, while
  #       _set_target_properties(${TARGET_UIDS} PROPERTIES ${ARGN})
  #       (erroneously) discards the empty elements in ARGN.
  if (BASIS_DEBUG)
    message ("** basis_set_target_properties:")
    message ("**   Target(s):  ${TARGET_UIDS}")
    message ("**   Properties: [${ARGN}]")
  endif ()
  while (N GREATER 1)
    list (GET ARGN 0 PROPERTY)
    list (GET ARGN 1 VALUE)
    list (REMOVE_AT ARGN 0 1)
    list (LENGTH ARGN N)
    # The following loop is only required b/c CMake's ARGV and ARGN
    # lists do not support arguments which are themselves lists.
    # Therefore, we need a way to decide when the list of values for a
    # property is terminated. Hence, we only allow known properties
    # to be set, except for the first property where the name follows
    # directly after the PROPERTIES keyword.
    while (N GREATER 0)
      list (GET ARGN 0 ARG)
      if (ARG MATCHES "${BASIS_PROPERTIES_ON_TARGETS_REGEX}")
        break ()
      endif ()
      list (APPEND VALUE "${ARG}")
      list (REMOVE_AT ARGN 0)
      list (LENGTH ARGN N)
    endwhile ()
    if (BASIS_DEBUG)
      message ("**   -> ${PROPERTY} = [${VALUE}]")
    endif ()
    # check property name
    if (PROPERTY MATCHES "^$") # remember: STREQUAL is buggy and evil!
      message (FATAL_ERROR "Empty property name given!")
    endif ()
    # set target property
    _set_target_properties (${TARGET_UIDS} PROPERTIES ${PROPERTY} "${VALUE}")
  endwhile ()
  # make sure that every property had a corresponding value
  if (NOT N EQUAL 0)
    message (FATAL_ERROR "No value given for target property ${ARGN}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get value of property set on target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
# get_target_properties()</a> command and extends its functionality.
# In particular, it maps the given @p TARGET_NAME to the corresponding target UID.
#
# @param [out] VAR         Name of output variable.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  ARGN        Remaining arguments for
#                          <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_target_properties">
#                          get_target_properties()</a>.
#
# @returns Sets @p VAR to the value of the requested property.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_target_property
#
# @ingroup CMakeAPI
function (basis_get_target_property VAR TARGET_NAME)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
  get_target_property (VALUE "${TARGET_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# definitions
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add compile definitions.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions">
# add_definitions()</a> command.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions">
#                  add_definitions()</a>.
#
# @returns Adds the given definitions.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions
#
# @ingroup CMakeAPI
function (basis_add_definitions)
  add_definitions (${ARGN})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Remove previously added compile definitions.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definitions">
# remove_definitions()</a> command.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definitions">
#                  remove_definitions()</a>.
#
# @returns Removes the specified definitions.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definition
#
# @ingroup CMakeAPI
function (basis_remove_definitions)
  remove_definitions (${ARGN})
endfunction ()

# ============================================================================
# directories
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add directories to search path for include files.
#
# Overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
# include_directories()</a> command. This is required because the
# basis_include_directories() function is not used by other projects in their
# package use files. Therefore, this macro is an alias for
# basis_include_directories().
#
# @param [in] ARGN List of arguments for basis_include_directories().
#
# @returns Adds the given paths to the search path for include files.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories
macro (include_directories)
  basis_include_directories (${ARGN})
endmacro ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for include files.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
# include_directories()</a> command. Besides invoking CMake's internal command
# with the given arguments, it updates the @c PROJECT_INCLUDE_DIRECTORIES
# property on the current project (see basis_set_project_property()). This list
# contains a list of all include directories used by a project, regardless of
# the directory in which the basis_include_directories() function was used.
#
# @param ARGN List of arguments for
#             <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
#             include_directories()</a> command.
#
# @returns Nothing.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories
#
# @ingroup CMakeAPI
function (basis_include_directories)
  # CMake's include_directories ()
  _include_directories (${ARGN})

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "AFTER;BEFORE;SYSTEM" "" "" ${ARGN})

  # make relative paths absolute
  set (DIRS)
  foreach (P IN LISTS ARGN_UNPARSED_ARGUMENTS)
    get_filename_component (P "${P}" ABSOLUTE)
    list (APPEND DIRS "${P}")
  endforeach ()

  if (NOT DIRS)
    message (WARNING "basis_include_directories(): No directories given to add!")
  endif ()

  # append directories to "global" list of include directories
  basis_get_project_property (INCLUDE_DIRS PROPERTY PROJECT_INCLUDE_DIRS)
  if (BEFORE)
    list (INSERT INCLUDE_DIRS 0 ${DIRS})
  else ()
    list (APPEND INCLUDE_DIRS ${DIRS})
  endif ()
  if (INCLUDE_DIRS)
    list (REMOVE_DUPLICATES INCLUDE_DIRS)
  endif ()
  if (BASIS_DEBUG)
    message ("** basis_include_directories():")
    if (BEFORE)
      message ("**    Add before:  ${DIRS}")
    else ()
      message ("**    Add after:   ${DIRS}")
    endif ()
    if (BASIS_VERBOSE)
      message ("**    Directories: ${INCLUDE_DIRS}")
    endif ()
  endif ()
  basis_set_project_property (PROPERTY PROJECT_INCLUDE_DIRS ${INCLUDE_DIRS})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for libraries.
#
# Overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
# link_directories()</a> command. This is required because the
# basis_link_directories() function is not used by other projects in their
# package use files. Therefore, this macro is an alias for
# basis_link_directories().
#
# @param [in] ARGN List of arguments for basis_link_directories().
#
# @returns Adds the given paths to the search path for libraries.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
macro (link_directories)
  basis_link_directories (${ARGN})
endmacro ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for libraries.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
# link_directories()</a> command. Even though this function yet only invokes
# CMake's internal command, it should be used in BASIS projects to enable the
# extension of this command's functionality as part of BASIS if required.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
#                  link_directories()</a>.
#
# @returns Adds the given paths to the search path for libraries.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
#
# @ingroup CMakeAPI
function (basis_link_directories)
  # CMake's link_directories() command
  _link_directories (${ARGN})
endfunction ()

# ============================================================================
# dependencies
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add dependencies to build target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies">
# add_dependencies()</a> command and extends its functionality.
# In particular, it maps the given target names to the corresponding target UIDs.
#
# @param [in] ARGN Arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies">
#                  add_dependencies()</a>.
#
# @returns Adds the given dependencies of the specified build target.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies
#
# @ingroup CMakeAPI
function (basis_add_dependencies)
  set (ARGS)
  foreach (ARG ${ARGN})
    basis_get_target_uid (UID "${ARG}")
    if (TARGET "${UID}")
      list (APPEND ARGS "${UID}")
    else ()
      list (APPEND ARGS "${ARG}")
    endif ()
  endforeach ()
  add_dependencies (${ARGS})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add link dependencies to build target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:target_link_libraries">
# target_link_libraries()</a> command.
#
# The main reason for replacing this function is to treat libraries such as
# MEX-files which are supposed to be compiled into a MATLAB executable added
# by basis_add_executable() special. In this case, these libraries are added
# to the LINK_DEPENDS property of the given MATLAB Compiler target. Similarly,
# executable scripts and modules written in a scripting language may depend
# on other modules.
#
# Another reason is the mapping of build target names to fully-qualified
# build target names as used by BASIS (see basis_get_target_uid()).
#
# Example:
# @code
# basis_add_library (MyMEXFunc MEX myfunc.c)
# basis_add_executable (MyMATLABApp main.m)
# basis_target_link_libraries (MyMATLABApp MyMEXFunc OtherMEXFunc.mexa64)
# @endcode
#
# @param [in] TARGET_NAME Name of the target.
# @param [in] ARGN        Link libraries.
#
# @returns Adds link dependencies to the specified build target.
#          For custom targets, the given libraries are added to the
#          @c LINK_DEPENDS property of these targets, in particular.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:target_link_libraries
#
# @ingroup CMakeAPI
function (basis_target_link_libraries TARGET_NAME)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "basis_target_link_libraries(): Unknown target ${TARGET_UID}.")
  endif ()
  # get type of named target
  get_target_property (BASIS_TYPE ${TARGET_UID} BASIS_TYPE)
  # substitute non-fully qualified target names
  set (ARGS)
  foreach (ARG ${ARGN})
    basis_get_target_uid (UID "${ARG}")
    if (TARGET "${UID}")
      list (APPEND ARGS "${UID}")
    else ()
      list (APPEND ARGS "${ARG}")
    endif ()
  endforeach ()
  # custom BASIS targets with LINK_DEPENDS property
  if (BASIS_TYPE MATCHES "MCC|MEX|SCRIPT")
    get_target_property (DEPENDS ${TARGET_UID} LINK_DEPENDS)
    if (NOT DEPENDS)
      set (DEPENDS)
    endif ()
    # note that MCC does itself a dependency check and in case of scripts
    # the basis_get_target_link_libraries() function is used
    if (BASIS_TYPE MATCHES "MCC|SCRIPT")
      list (APPEND DEPENDS ${ARGS})
    # otherwise
    else ()
      list (APPEND DEPENDS ${ARGS})
      # pull implicit dependencies (e.g., ITK uses this)
      set (DEPENDENCY_ADDED 1)
      while (DEPENDENCY_ADDED)
        set (DEPENDENCY_ADDED 0)
        foreach (LIB IN LISTS DEPENDS)
          foreach (LIB_DEPEND IN LISTS ${LIB}_LIB_DEPENDS)
            if (NOT LIB_DEPEND MATCHES "^$|^general$")
              string (REGEX REPLACE "^-l" "" LIB_DEPEND "${LIB_DEPEND}")
              list (FIND DEPENDS ${LIB_DEPEND} IDX)
              if (IDX EQUAL -1)
                list (APPEND DEPENDS ${LIB_DEPEND})
                set (DEPENDENCY_ADDED 1)
              endif ()
            endif ()
          endforeach ()
        endforeach ()
      endwhile ()
    endif ()
    # update LINK_DEPENDS property
    _set_target_properties (${TARGET_UID} PROPERTIES LINK_DEPENDS "${DEPENDS}")
  # other
  else ()
    target_link_libraries (${TARGET_UID} ${ARGS})
  endif ()
endfunction ()

# ============================================================================
# add targets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add executable target.
#
# This is the main function to add an executable target to the build system,
# where an executable can be a binary file or a script written in a scripting
# language. In general we refer to any output file which is part of the software
# (i.e., excluding configuration files) and which can be executed
# (e.g., a binary file in the ELF format) or interpreted (e.g., a Python script)
# directly, as executable file. Natively, CMake supports only executables built
# from C/C++ source code files. This function extends CMake's capabilities
# by adding custom build commands for non-natively supported programming
# languages and further standardizes the build of executable targets.
# For example, by default, it is not necessary to specify installation rules
# separately as these are added by this function already (see below).
#
# @par Programming languages
# Besides adding usual executable targets build by the set <tt>C/CXX</tt>
# language compiler, this function inspects the list of source files given and
# detects whether this list contains sources which need to be build using a
# different compiler. In particular, it supports the following languages:
# @n
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>The default behavior, adding an executable target build from C/C++
#         source code. The target is added via CMake's add_executable() command.</td>
#   </tr>
#   <tr>
#     @tp <b>PYTHON</b>|<b>JYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Executables written in one of the named scripting languages are built by
#         configuring and/or copying the script files to the build tree and
#         installation tree, respectively. During the build step, certain strings
#         of the form \@VARIABLE\@ are substituted by the values set during the
#         configure step. How these CMake variables are set is specified by a
#         so-called script configuration, which itself is either a CMake script
#         file or a string of CMake code set as value of the @c COMPILE_DEFINITIONS
#         property of the executable target.</td>
#   </tr>
#   <tr>
#     @tp @b MATLAB @endtp
#     <td>Standalone application built from MATLAB sources using the
#         MATLAB Compiler (mcc). This language option is used when the list
#         of source files contains one or more *.m files. A custom target is
#         added which depends on custom command(s) that build the executable.</td>
#         @n@n
#         Attention: The *.m file with the entry point/main function of the
#                    executable has to be given before any other *.m file.
#   </tr>
# </table>
#
# @par Helper functions
# If the programming language of the input source files is not specified
# explicitly by providing the @p LANGUAGE argument, the extensions of the
# source files and if necessary the first line of script files are inspected
# by the basis_get_source_language() function. Once the programming language is
# known, this function invokes the proper subcommand which adds the respective
# build target. In particular, it calls basis_add_executable_target() for C++
# sources (.cxx), basis_add_mcc_target() for MATLAB scripts (.m), and
# basis_add_script() for all other source files.
#
# @note DO NOT use the mentioned subcommands directly. Always use
#       basis_add_executable() to add an executable target to your project.
#       Only refer to the documentation of the subcommands to learn about the
#       available options of the particular subcommand and considered target
#       properties.
#
# @par Output directories
# The built executable file is output to the @c BINARY_RUNTIME_DIR or
# @c BINARY_LIBEXEC_DIR if the @p LIBEXEC option is given.
# If this function is used within the @c PROJECT_TESTING_DIR, however,
# the built executable is output to the @c TESTING_RUNTIME_DIR or
# @c TESTING_LIBEXEC_DIR instead.
#
# @par Installation
# An install command for the added executable target is added by this function
# as well. The executable will be installed as part of the specified @p COMPONENT
# in the directory @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if the option
# @p LIBEXEC is given. Executable targets are exported by default such that they
# can be imported by other CMake-aware projects by including the CMake
# configuration file of this package (&lt;Package&gt;Config.cmake file).
# No installation rules are added, however, if this function is used within the
# @c PROJECT_TESTING_DIR or if "none" (case-insensitive) is given as
# @p DESTINATION. Test executables are further only exported as part of the
# build tree, but not the installation as they are by default not installed.
#
# @param [in] TARGET_NAME Name of the target. If an existing source file is given
#                         as first argument, it is added to the list of source files
#                         and the build target name is derived from the name of this file.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted, all other arguments are passed
#                         on to add_executable() or the respective custom
#                         commands used to add an executable build target.
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of component as part of which this executable will be installed
#         if the specified @c DESTINATION is not "none".
#         (default: @c BASIS_RUNTIME_COMPONENT)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory relative to @c INSTALL_PREFIX.
#         If "none" (case-insensitive) is given as argument, no default
#         installation rules are added for this executable target.
#         (default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR
#         if the @p LIBEXEC option is given)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Programming language in which source files are written (case-insensitive).
#         If not specified, the programming language is derived from the file name
#         extensions of the source files and, if applicable, the shebang directive
#         on the first line of the script file. If the programming language could
#         not be detected automatically, check the file name extensions of the
#         source files and whether no unrecognized additional arguments were given
#         or specify the programming language using this option.
#         (default: auto-detected)</td>
#   </tr>
#   <tr>
#     @tp @b LIBEXEC @endtp
#     <td>Specifies that the built executable is an auxiliary executable which
#         is only called by other executables. (default: @c FALSE)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this executable and hence
#         no link dependency on the BASIS utilities shall be added.
#         (default: @c NOT @c BASIS_UTILITIES)</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and required by this executable
#         and hence a link dependency on the BASIS utilities has to be added.
#         (default: @c BASIS_UTILITIES)</td>
#   </tr>
# </table>
#
# @returns Adds an executable build target. In case of an executable which is
#          not build from C++ source files, the function basis_finalize_targets()
#          has to be invoked to finalize the addition of the custom build target.
#          This is done at the end of the basis_project_impl() macro.
#
# @sa basis_add_executable_target()
# @sa basis_add_script()
# @sa basis_add_mcc_target()
#
# @ingroup CMakeAPI
function (basis_add_executable TARGET_NAME)
  # --------------------------------------------------------------------------
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "EXECUTABLE;LIBEXEC;NO_BASIS_UTILITIES;USE_BASIS_UTILITIES;EXPORT;NOEXPORT"
      "COMPONENT;DESTINATION;LANGUAGE"
      ""
    ${ARGN}
  )
  # derive target name from path if existing source path is given as first argument instead
  # and get list of library source files
  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (IS_DIRECTORY "${S}" AND NOT ARGN_UNPARSED_ARGUMENTS)
    set (SOURCES "${S}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  elseif (EXISTS "${S}" AND NOT IS_DIRECTORY "${S}" OR (NOT S MATCHES "\\.in$" AND EXISTS "${S}.in" AND NOT IS_DIRECTORY "${S}.in"))
    set (SOURCES "${S}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  else ()
    set (SOURCES)
  endif ()
  if (ARGN_UNPARSED_ARGUMENTS)
    list (APPEND SOURCES ${ARGN_UNPARSED_ARGUMENTS})
  endif ()
  # --------------------------------------------------------------------------
  # make target UID
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  # --------------------------------------------------------------------------
  # process globbing expressions to get complete list of source files
  basis_add_glob_target (${TARGET_UID} SOURCES ${SOURCES})
  # --------------------------------------------------------------------------
  # determine programming language
  if (NOT ARGN_LANGUAGE)
    basis_get_source_language (ARGN_LANGUAGE ${SOURCES})
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("Target ${TARGET_UID}: Given source code files:")
      foreach (SOURCE IN LISTS SOURCES)
        message ("  ${SOURCE}")
      endforeach ()
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "Target ${TARGET_UID}: Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "Target ${TARGET_UID}: Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      endif ()
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)
  # --------------------------------------------------------------------------
  # prepare arguments for subcommand
  foreach (ARG IN LISTS ARGN_UNPARSED_ARGUMENTS)
    list (REMOVE_ITEM ARGN "${ARG}")
  endforeach ()
  list (APPEND ARGN ${SOURCES})
  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE MATCHES "CXX")
    basis_add_executable_target (${TARGET_NAME} ${ARGN})
  # --------------------------------------------------------------------------
  # MATLAB
  elseif (ARGN_LANGUAGE MATCHES "MATLAB")
    if (ARGN_LIBEXEC)
      list (REMOVE_ITEM ARGN LIBEXEC)
      basis_add_mcc_target (${TARGET_NAME} LIBEXEC ${ARGN})
    else ()
      list (REMOVE_ITEM ARGN EXECUTABLE)
      basis_add_mcc_target (${TARGET_NAME} EXECUTABLE ${ARGN})
    endif ()
  # --------------------------------------------------------------------------
  # others
  else ()
    if (ARGN_LIBEXEC)
      list (REMOVE_ITEM ARGN LIBEXEC)
      basis_add_script (${TARGET_NAME} LIBEXEC ${ARGN})
    else ()
      list (REMOVE_ITEM ARGN EXECUTABLE)
      basis_add_script (${TARGET_NAME} EXECUTABLE ${ARGN})
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # re-glob source files before each build (if necessary)
  if (TARGET __${TARGET_UID})
    add_dependencies (${TARGET_UID} __${TARGET_UID})
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add library target.
#
# This is the main function to add a library target to the build system, where
# a library can be a binary archive, shared library, a MEX-file or module(s)
# written in a scripting language. In general we refer to any output file which
# is part of the software (i.e., excluding configuration files), but cannot be
# executed (e.g., a binary file in the ELF format) or interpreted
# (e.g., a Python module) directly, as library file. Natively, CMake supports only
# libraries built from C/C++ source code files. This function extends CMake's
# capabilities by adding custom build commands for non-natively supported
# programming languages and further standardizes the build of library targets.
# For example, by default, it is not necessary to specify installation rules
# separately as these are added by this function already (see below).
#
# @par Programming languages
# Besides adding usual library targets built from C/C++ source code files,
# this function can also add custom build targets for libraries implemented
# in other programming languages. It therefore tries to detect the programming
# language of the given source code files and delegates the addition of the
# build target to the proper helper functions. It in particular supports the
# following languages:
# @n
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>Source files written in C/C++ are by default built into either
#         @p STATIC, @p SHARED, or @p MODULE libraries. If the @p MEX option
#         is given, however, a MEX-file (a shared library) is build using
#         the MEX script instead of using the default C++ compiler directly.</td>
#   </tr>
#   <tr>
#     @tp <b>PYTHON</b>|<b>JYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Modules written in one of the named scripting languages are built similar
#         to executable scripts except that the file name extension is preserved
#         and no executable file permission is set on Unix. These modules are
#         intended for import/inclusion in other modules or executables written
#         in the particular scripting language only.</td>
#   </tr>
#   <tr>
#     @tp @b MATLAB @endtp
#     <td>Shared libraries built from MATLAB sources using the MATLAB Compiler (mcc).
#         This language option is used when the list of source files contains one or
#         more *.m files. A custom target is added which depends on custom command(s)
#         that build the library.</td>
#   </tr>
# </table>
#
# @par Helper functions
# If the programming language of the input source files is not specified
# explicitly by providing the @p LANGUAGE argument, the extensions of the
# source files are inspected using basis_get_source_language(). Once the
# programming language is known, this function invokes the proper subcommand.
# In particular, it calls basis_add_library_target() for C++ sources (.cxx)
# if the target is not a MEX-file target, basis_add_mex_file() for C++ sources
# if the @p MEX option is given, basis_add_mcc_target() for MATLAB scripts (.m),
# and basis_add_script_library() for all other source files.
#
# @note DO NOT use the mentioned subcommands directly. Always use
#       basis_add_library() to add a library target to your project. Only refer
#       to the documentation of the subcommands to learn about the available
#       options of the particular subcommand and the considered target properties.
#
# @par Output directories
# In case of modules written in a scripting language, the libraries are output to
# the <tt>BINARY_&lt;LANGUAGE&gt;_LIBRARY_DIR</tt> if defined. Otherwise,
# the built libraries are output to the @c BINARY_RUNTIME_DIR, @c BINARY_LIBRARY_DIR,
# and/or @c BINARY_ARCHIVE_DIR. If this command is used within the @c PROJECT_TESTING_DIR,
# however, the files are output to the corresponding directories in the testing tree,
# instead.
#
# @par Installation
# An installation rule for the added library target is added by this function
# if the destination is not "none" (case-insensitive). Runtime libraries are
# installed as part of the @p RUNTIME_COMPONENT to the @p RUNTIME_DESTINATION.
# Library components are installed as part of the @p LIBRARY_COMPONENT to the
# @p LIBRARY_DESTINATION. Library targets are further exported such that they
# can be imported by other CMake-aware projects by including the CMake
# configuration file of this package (&lt;Package&gt;Config.cmake file).
# If this function is used within the @c PROJECT_TESTING_DIR, however, no
# installation rules are added. Test library targets are further only exported
# as part of the build tree.
#
# @par Example
# @code
# basis_add_library (MyLib1 STATIC mylib.cxx)
# basis_add_library (MyLib2 STATIC mylib.cxx COMPONENT dev)
#
# basis_add_library (
#   MyLib3 SHARED mylib.cxx
#   RUNTIME_COMPONENT bin
#   LIBRARY_COMPONENT dev
# )
#
# basis_add_library (MyMex MEX mymex.cxx)
# basis_add_library (PythonModule MyModule.py.in)
# basis_add_library (ShellModule MODULE MyModule.sh.in)
# @endcode
#
# @param [in] TARGET_NAME Name of build target. If an existing file is given as
#                         argument, it is added to the list of source files and
#                         the target name is derived from the name of this file.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted. All unparsed arguments are
#                         treated as source files.
# @par
# <table border="0">
#   <tr>
#     @tp <b>STATIC</b>|<b>SHARED</b>|<b>MODULE</b>|<b>MEX</b> @endtp
#     <td>Type of the library. (default: @c SHARED for C++ libraries if
#         @c BUILD_SHARED_LIBS evaluates to true or @c STATIC otherwise,
#         @c SHARED for libraries build by MATLAB Compiler, and @c MODULE
#         in all other cases)</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of component as part of which this library will be installed
#         if the @c RUNTIME_DESTINATION or @c LIBRARY_DESTINATION is not "none".
#         Used only if @p RUNTIME_COMPONENT or @p LIBRARY_COMPONENT not specified.
#         (default: see @p RUNTIME_COMPONENT and @p LIBRARY_COMPONENT)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory for runtime and library component relative
#         to @c INSTALL_PREFIX. Used only if @p RUNTIME_DESTINATION or
#         @p LIBRARY_DESTINATION not specified. If "none" (case-insensitive)
#         is given as argument, no default installation rules are added.
#         (default: see @p RUNTIME_DESTINATION and @p LIBRARY_DESTINATION)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Programming language in which source files are written (case-insensitive).
#         If not specified, the programming language is derived from the file name
#         extensions of the source files and, if applicable, the shebang directive
#         on the first line of the script file. If the programming language could
#         not be detected automatically, check the file name extensions of the
#         source files and whether no unrecognized additional arguments were given
#         or specify the programming language using this option.
#         (default: auto-detected)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_COMPONENT name @endtp
#     <td>Name of component as part of which import/static library will be intalled
#         if @c LIBRARY_DESTINATION is not "none".
#         (default: @c COMPONENT if specified or @c BASIS_LIBRARY_COMPONENT otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_DESTINATION dir @endtp
#     <td>Installation directory of the library component relative to
#         @c INSTALL_PREFIX. If "none" (case-insensitive) is given as argument,
#         no installation rule for the library component is added.
#         (default: @c INSTALL_ARCHIVE_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_COMPONENT name @endtp
#     <td>Name of component as part of which runtime library will be installed
#         if @c RUNTIME_DESTINATION is not "none".
#         (default: @c COMPONENT if specified or @c BASIS_RUNTIME_COMPONENT otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_DESTINATION dir @endtp
#     <td>Installation directory of the runtime component relative to
#         @c INSTALL_PREFIX. If "none" (case-insensitive) is given as argument,
#         no installation rule for the runtime library is added.
#         (default: @c INSTALL_LIBRARY_DIR on Unix or @c INSTALL_RUNTIME_DIR Windows)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this executable and hence
#         no link dependency on the BASIS utilities shall be added.
#         (default: @c NOT @c BASIS_UTILITIES)</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and required by this executable
#         and hence a link dependency on the BASIS utilities has to be added.
#         (default: @c BASIS_UTILITIES)</td>
#   </tr>
# </table>
#
# @returns Adds a library build target. In case of a library not written in C++
#          or MEX-file targets, basis_finalize_targets() has to be invoked
#          to finalize the addition of the build target(s). This is done
#          at the end of the basis_project_impl() macro.
#
# @sa basis_add_library_target()
# @sa basis_add_script_library()
# @sa basis_add_mex_file()
# @sa basis_add_mcc_target()
#
# @ingroup CMakeAPI
function (basis_add_library TARGET_NAME)
  # --------------------------------------------------------------------------
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;MEX;USE_BASIS_UTILITIES;NO_BASIS_UTILITIES;EXPORT;NOEXPORT"
      "COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT;DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;LANGUAGE"
      ""
    ${ARGN}
  )
  # derive target name from path if existing source path is given as first argument instead
  # and get list of library source files
  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (IS_DIRECTORY "${S}" AND NOT ARGN_UNPARSED_ARGUMENTS)
    set (SOURCES "${S}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME)
  elseif (EXISTS "${S}" AND NOT IS_DIRECTORY "${S}" OR (NOT S MATCHES "\\.in$" AND EXISTS "${S}.in" AND NOT IS_DIRECTORY "${S}.in"))
    set (SOURCES "${S}")
    if (ARGN_MEX)
      basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
    else ()
      basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME)
    endif ()
  else ()
    set (SOURCES)
  endif ()
  if (ARGN_UNPARSED_ARGUMENTS)
    list (APPEND SOURCES ${ARGN_UNPARSED_ARGUMENTS})
  endif ()
  # --------------------------------------------------------------------------
  # make target UID
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  # --------------------------------------------------------------------------
  # process globbing expressions to get complete list of source files
  basis_add_glob_target (${TARGET_UID} SOURCES ${SOURCES})
  # --------------------------------------------------------------------------
  # determine programming language
  if (NOT ARGN_LANGUAGE)
    basis_get_source_language (ARGN_LANGUAGE ${SOURCES})
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("Target ${TARGET_UID}: Given source code files:")
      foreach (SOURCE IN LISTS SOURCES)
        message ("  ${SOURCE}")
      endforeach ()
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "Target ${TARGET_UID}: Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "Target ${TARGET_UID}: Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      endif ()
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)
  # --------------------------------------------------------------------------
  # prepare arguments for subcommand
  foreach (ARG IN LISTS ARGN_UNPARSED_ARGUMENTS)
    list (REMOVE_ITEM ARGN "${ARG}")
  endforeach ()
  list (APPEND ARGN ${SOURCES})
  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE MATCHES "CXX")
    # MEX-file
    if (ARGN_MEX)
      if (ARGN_STATIC)
        message (FATAL_ERROR "Target ${TARGET_UID}: Invalid library type! Only modules or shared libraries can be built by the MEX script.")
      endif ()
      list (REMOVE_ITEM ARGN MODULE)
      list (REMOVE_ITEM ARGN SHARED)
      list (REMOVE_ITEM ARGN MEX)
      basis_add_mex_file (${TARGET_NAME} ${ARGN})
    # library
    else ()
      basis_add_library_target (${TARGET_NAME} ${ARGN})
    endif ()
  # --------------------------------------------------------------------------
  # MATLAB
  elseif (ARGN_LANGUAGE MATCHES "MATLAB")
    if (ARGN_STATIC OR ARGN_MODULE OR ARGN_MEX)
      message (FATAL_ERROR "Target ${TARGET_UID}: Invalid library type! Only shared libraries can be built by the MATLAB Compiler.")
    endif ()
    list (REMOVE_ITEM ARGN SHARED)
    basis_add_mcc_target (${TARGET_NAME} SHARED ${ARGN})
  # --------------------------------------------------------------------------
  # other
  else ()
    if (ARGN_STATIC OR ARGN_SHARED OR ARGN_MEX)
      message (FATAL_ERROR "Target ${TARGET_UID}: Invalid library type! Only modules can be built from scripts.")
    endif ()
    list (REMOVE_ITEM ARGN MODULE)
    basis_add_script_library (${TARGET_NAME} ${ARGN})
  endif ()
  # --------------------------------------------------------------------------
  # re-glob source files before each build (if necessary)
  if (TARGET __${TARGET_UID})
    add_dependencies (${TARGET_UID} __${TARGET_UID})
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add single arbitrary or executable script.
#
# @note This function should not be used directly for executable scripts or
#       module libraries. Use basis_add_executable() or basis_add_library()
#       in such (most) cases instead.
#
# This function can be used to add a single arbitrary script file (i.e., any
# text file which is input to a program), such as a CTest script for example,
# to the build if neither basis_add_executable() nor basis_add_library() are
# appropriate choices. In all other cases, either basis_add_executable() or
# basis_add_library() should be used. Note that the script file is by default
# not considered to be an executable. Instead it is assumed that the program
# which interprets/processes the script must be executed explicitly with this
# script as argument. Only scripts built with the @p EXECUTABLE or @p LIBEXEC
# type option are treated as executable files, where in case of Unix a shebang
# directive implicitly states the program used by the shell to interpret the
# script and on Windows a Windows Command which imitates the behavior of Unix
# shells is generated by BASIS. Do not use these type options, however, but
# only use the default @p MODULE option. The basis_add_executable() function
# should be used instead to add an executable script. The basis_add_script()
# function shall only be used for none-executable arbitrary script files which
# cannot be built by basis_add_executable() or basis_add_library().
#
# If the script name ends in <tt>.in</tt>, the <tt>.in</tt> suffix is removed
# from the output name. Further, in case of executable scripts, the file name
# extension is removed from the output file name. Instead, a shebang directive
# is added on Unix to the built script. In order to enable the convenient
# execution of Python and Perl scripts also on Windows without requiring the
# user to setup a proper associate between the filename extension with the
# corresponding interpreter executable, a few lines of Batch code are added at
# the top and bottom of executable Python and Perl scripts. This Batch code
# invokes the configured interpreter with the script file and the given script
# arguments as command-line arguments. Note that both the original script source
# code and the Batch code are stored within the single file. The file name
# extension of such modified scripts is by default set to <tt>.cmd</tt>, the
# common extension for Windows NT Command Scripts. Scripts in other languages
# are not modified and the extension of the original scripts script file is
# preserved on Windows in this case. In case of non-executable scripts, the
# file name extension is kept in any case.
#
# Certain CMake variables within the source file are replaced during the
# built of the script. See the
# <a href="http://www.rad.upenn.edu/sbia/software/basis/scripttargets/>
# Build System Standard</a> for details.
# Note, however, that source files are only configured if the file name
# ends in the <tt>.in</tt> suffix.
#
# A custom CMake build target with the following properties is added by this
# function to the build system. These properties are used by basis_build_script()
# to generate a build script written in CMake code which is executed by a custom
# CMake command. Before the invokation of basis_build_script(), the target
# properties can be modified using basis_set_target_properties().
#
# @note Custom BASIS build targets are finalized by BASIS at the end of
#       basis_project_impl(), i.e., the end of the root CMake configuration file
#       of the (sub-)project.
#
# @par Properties on script targets
# <table border=0>
#   <tr>
#     @tp @b BASIS_TYPE @endtp
#     <td>Read-only property with value "SCRIPT_FILE" for arbitrary scripts,
#         "SCRIPT_EXECUTABLE" for executable scripts, and "SCRIPT_LIBEXEC" for
#          auxiliary executable scripts.
#          (default: see @p MODULE, @p EXECUTABLE, @p LIBEXEC options)</td>
#   </tr>
#   <tr>
#     @tp @b BASIS_UTILITIES @endtp
#     <td>Whether the BASIS utilities are used by this script. For the supported
#         scripting languages for which BASIS utilities are implemented, BASIS
#         will in most cases automatically detect whether these utilities are
#         used by a script or not. Otherwise, set this property manually or use
#         either the @p USE_BASIS_UTILITIES or the @p NO_BASIS_UTILITIES option
#         when adding the script target. (default: auto-detected or @c UNKNOWN)</td>
#   </tr>
#   <tr>
#     @tp @b BINARY_DIRECTORY @endtp
#     <td>Build tree directory of this target. (default: @c CMAKE_CURRENT_BINARY_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE @endtp
#     <td>Whether to compile the script if the programming language allows such
#         pre-compilation as in case of Python, for example. If @c TRUE, only the
#         compiled file is installed. (default: @c BASIS_COMPILE_SCRIPTS)</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE_DEFINITIONS @endtp
#     <td>CMake code which is evaluated after the inclusion of the default script
#         configuration files. This code can be used to set the replacement text of the
#         CMake variables ("@VAR@" patterns) used in the source file.
#         See <a href="http://www.rad.upenn.edu/sbia/software/basis/standard/scripttargets.html#script-configuration">
#         Build System Standard</a> for details. (default: "")</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT @endtp
#     <td>Name of component as part of which this script is installed if
#         @c INSTALL_DIRECTORY is not set to "none".
#         (default: see @p COMPONENT argument)</td>
#   </tr>
#   <tr>
#     @tp @b EXPORT @endtp
#     <td>Whether to export this build target in which case an import library
#         target is added to the custom exports file with the path to the
#         built/installed script set as @c IMPORT_LOCATION. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b INSTALL_DIRECTORY @endtp
#     <td>Installation directory of script file configured for use in installation tree
#         relative to @c INSTALL_PREFIX. Set to "none" (case-insensitive) to skip the
#         addition of an installation rule. (default: see @p DESTINATION argument)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE @endtp
#     <td>Read-only property of programming language of script file in uppercase letters.
#         (default: see @p LANGUAGE argument)</td>
#   </tr>
#   <tr>
#     @tp @b LINK_DEPENDS @endtp
#     <td>Paths or target names of script modules and libraries used by this script.
#         In case of an (auxiliary) executable script, the directories of these modules
#         are added to the search path for modules of the given programming language
#         if such search paths are supported by the language and BASIS knows how to set
#         these (as in case of Python/Jython, Perl, and MATLAB, in particular).
#         Moreover, for each listed build target a dependency is added between this
#         script target and the named build targets. Use basis_target_link_libraries()
#         to add additional link dependencies.
#         (default: BASIS utilities module if used or empty list otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_DIRECTORY @endtp
#     <td>Output directory for built script file configured for use in build tree.
#         (default: @c BINARY_LIBRARY_DIR for arbitrary scripts, @c BINARY_RUNTIME_DIR
#         for executable scripts, and @c BINARY_LIBEXEC_DIR for auxiliary executables)</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_NAME @endtp
#     <td>Name of built script file including file name extension (if any).
#         (default: basename of script file for arbitrary scripts, without extension
#         for executable scripts on Unix, and <tt>.cmd</tt> extension on Windows
#         in case of executable Python/Jython or Perl script)</td>
#   </tr>
#   <tr>
#     @tp @b SOURCE_DIRECTORY @endtp
#     <td>Source directory of this target. (default: @c CMAKE_CURRENT_SOURCE_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b SOURCES @endtp
#     <td>Read-only property which lists the source file of this script target.
#         Note that the first element in this list actually names a directory
#         in the build, the one where the build script for this target is located
#         instead of a source file and thus should be ignored. The second entry
#         corresponds to the source file of this script target.</td>
#   </tr>
# </table>
#
# @attention Properties documented as read-only must not be modified.
#
# @note If this function is used within the @c PROJECT_TESTING_DIR, the built
#       executable is output to the @c BINARY_TESTING_DIR directory tree instead.
#       Moreover, no installation rules are added. Test executables are further
#       not exported, regardless of the @c EXPORT property.
#
# @param [in] TARGET_NAME Name of build target. If an existing file is given as
#                         argument, it is added to the list of source files and
#                         the target name is derived from the name of this file.
# @param [in] ARGN        The remaining arguments are parsed and the following arguments
#                         recognized. All unparsed arguments are treated as source files,
#                         where in particular exactly one source file is required if the
#                         @p TARGET_NAME argument does not name an existing source file.
# @par
# <table border=0>
#   <tr>
#     @tp <b>MODULE</b>|<b>EXECUTABLE</b>|<b>LIBEXEC</b> @endtp
#     <td>Type of script to built, i.e., either arbitrary module script which
#         cannot be executed directly, an executable script with proper shebang
#         directive and execute permissions on Unix or Windows Command on Windows,
#         or an auxiliary executable. The type of the script mainly changes the
#         default values of the target properties such as the output and installation
#         directories. To add an (auxiliary) executable script, use
#         basis_add_executable(), however, instead of this function.
#         The @c EXECUTABLE and @c LIBEXEC options are only intended for
#         internal use by BASIS. (default: MODULE)</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of installation component as part of which this script is being
#         installed if the @c INSTALL_DIRECTORY property is not "none".
#         (default: @c BASIS_LIBRARY_COMPONENT for arbitrary scripts or
#         @c BASIS_RUNTIME_COMPONENT for executable scripts)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory for script file relative to @c INSTALL_PREFIX.
#         If an absolute path is given as argument, it is made relative to the
#         configured installation prefix.
#         (default: @c INSTALL_LIBRARY_DIR for arbitrary scripts,
#         @c INSTALL_RUNTIME_DIR for executable scripts, and @c INSTALL_LIBEXEC_DIR
#         for auxiliary executable scripts)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Programming language in which script file is written (case-insensitive).
#         If not specified, the programming language is derived from the file name
#         extension of the source file and the shebang directive on the first line
#         of the script if any. If the programming language could not be detected
#         automatically, the @c LANGUAGE property is set to @c UNKNOWN. Note that
#         for arbitrary script targets, the script file will still be built correctly
#         even if the scripting language was not recognized. The automatic detection
#         whether the BASIS utilities are used and required will fail, however.
#         In this case, specify the programming language using this option.
#         (default: auto-detected or @c UNKNOWN)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this script. If the
#         programming language of the script is known and BASIS utilities are
#         available for this language, BASIS will in most cases automatically
#         detect whether these utilities are used by a script or not. Use this
#         option to skip this check because the script does not make use of the
#         BASIS utilities.</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and thus required by this script.
#         If the programming language of the script is known and BASIS utilities are
#         available for this language, BASIS will in most cases automatically
#         detect whether these utilities are used by a script or not. Use this option
#         to skip this check because it is already known that the script makes use of
#         the BASIS utilities. Note that an error is raised if this option is given,
#         but no BASIS utilities are available for the programming language of this
#         script or if the programming language is unknown, respectively, not detected
#         correctly. In this case, consider the use of the @p LANGUAGE argument.</td>
#   </tr>
# </table>
#
# @returns Adds a custom CMake target with the documented properties. The actual custom
#          command to build the script is added by basis_build_script().
#
# @ingroup CMakeAPI
function (basis_add_script TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "MODULE;EXECUTABLE;LIBEXEC;NO_BASIS_UTILITIES;USE_BASIS_UTILITIES;EXPORT;NOEXPORT"
      "COMPONENT;DESTINATION;LANGUAGE"
      ""
    ${ARGN}
  )
  if (NOT ARGN_MODULE AND NOT ARGN_EXECUTABLE AND NOT ARGN_LIBEXEC)
    set (ARGN_MODULE TRUE)
  endif ()
  if (ARGN_MODULE)
    set (TYPE MODULE)
  else ()
    set (TYPE EXECUTABLE)
  endif ()
  string (TOLOWER "${TYPE}" type)
  # derive target name from file name if existing source file given as first argument
  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (EXISTS "${S}" AND NOT IS_DIRECTORY "${S}" OR (NOT S MATCHES "\\.in$" AND EXISTS "${S}.in" AND NOT IS_DIRECTORY "${S}.in"))
    set (SOURCES "${S}")
    if (ARGN_MODULE)
      basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME)
    else ()
      basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
    endif ()
  else ()
    set (SOURCES)
  endif ()
  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  if (BASIS_VERBOSE)
    message (STATUS "Adding ${type} script ${TARGET_UID}...")
  endif ()
  if (ARGN_MODULE AND TYPE MATCHES "EXECUTABLE")
    message (FATAL_ERROR "Target ${TARGET_UID}: MODULE and EXECUTABLE or LIBEXEC options are mutually exclusive!")
  endif ()
  # check/set parsed arguments
  basis_set_flag (ARGN EXPORT ${BASIS_EXPORT})
  if (ARGN_USE_BASIS_UTILITIES AND ARGN_NO_BASIS_UTILITIES)
    message (FATAL_ERROR "Options USE_BASIS_UTILITIES and NO_BASIS_UTILITIES are mutually exclusive!")
  endif ()
  list (LENGTH ARGN_UNPARSED_ARGUMENTS N)
  if (SOURCES)
    math (EXPR N "${N} + 1")
  endif ()
  if (N GREATER 1)
    if (NOT SOURCES)
      list (REMOVE_AT ARGN_UNPARSED_ARGUMENTS 0)
    endif ()
    message (FATAL_ERROR "Target ${TARGET_UID}: Too many or unrecognized arguments: ${ARGN_UNPARSED_ARGUMENTS}!\n"
                         " Only one script can be built by each script target.")
  elseif (NOT SOURCES)
    set (SOURCES "${ARGN_UNPARSED_ARGUMENTS}")
    get_filename_component (SOURCES "${SOURCES}" ABSOLUTE)
  endif ()
  if (NOT EXISTS "${SOURCES}" AND NOT SOURCES MATCHES "\\.in$" AND EXISTS "${SOURCES}.in")
    set (SOURCES "${SOURCES}.in")
  endif ()
  if (NOT EXISTS "${SOURCES}")
    string (REGEX REPLACE "\\.in$" "" SOURCES "${SOURCES}")
    message (FATAL_ERROR "Target ${TARGET_UID}: Source file ${SOURCES}[.in] does not exist!")
  endif ()
  # dump CMake variables for configuration of script
  set (BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_UID}.dir")
  basis_dump_variables ("${BUILD_DIR}/cache.cmake")
  # auto-detect programming language (may be as well UNKNOWN)
  if (ARGN_LANGUAGE)
    string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)
  else ()
    basis_get_source_language (ARGN_LANGUAGE ${SOURCES})
  endif ()
  # TEST flag
  basis_sanitize_for_regex (RE "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${RE}")
    set (TEST TRUE)
  else ()
    set (TEST FALSE)
  endif ()
  # default directory infix used below
  if (ARGN_MODULE)
    set (TYPE_INFIX "LIBRARY")
  elseif (ARGN_LIBEXEC)
    set (TYPE_INFIX "LIBEXEC")
  else ()
    set (TYPE_INFIX "RUNTIME")
  endif ()
  # output name
  string (REGEX REPLACE "\\.in$" "" SOURCE_NAME "${SOURCES}")
  if (ARGN_MODULE)
    get_filename_component (OUTPUT_NAME "${SOURCE_NAME}" NAME)
  else ()
    if (WIN32)
      if (ARGN_LANGUAGE MATCHES "[JP]YTHON|PERL")
        get_filename_component (OUTPUT_NAME "${SOURCE_NAME}" NAME_WE)
        set (OUTPUT_NAME "${OUTPUT_NAME}.cmd")
      else ()
        get_filename_component (OUTPUT_NAME "${SOURCE_NAME}" NAME)
      endif ()
    else ()
      get_filename_component (OUTPUT_NAME "${SOURCE_NAME}" NAME_WE)
    endif ()
  endif ()
  # output directory
  if (TEST)
    set (OUTPUT_DIRECTORY "${TESTING_${TYPE_INFIX}_DIR}")
  else ()
    set (OUTPUT_DIRECTORY "${BINARY_${TYPE_INFIX}_DIR}")
  endif ()
  # installation component
  if (NOT ARGN_COMPONENT)
    if (ARGN_MODULE)
      set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
    else ()
      set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()
  # installation directory
  if (ARGN_DESTINATION)
    if (ARGN_DESTINATION MATCHES "^[nN][oO][nN][eE]$")
      set (ARGN_DESTINATION)
    elseif (IS_ABSOLUTE "${ARGN_DESTINATION}")
      file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
    endif ()
  elseif (TEST)
    set (ARGN_DESTINATION) # do not install
  else ()
    set (ARGN_DESTINATION "${INSTALL_${TYPE_INFIX}_DIR}")
  endif ()
  # auto-detect use of BASIS utilities
  set (LINK_DEPENDS)
  if (ARGN_USE_BASIS_UTILITIES)
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "${ARGN_LANGUAGE}")
      message (FATAL_ERROR "Target ${TARGET_UID} requires the BASIS utilities for ${ARGN_LANGUAGE}"
                           " but BASIS was either build without the build of these utilities enabled"
                           " or no utilities for this programming language are implemented. Remove the"
                           " USE_BASIS_UTILITIES option if no BASIS utilities are used by the script"
                           " ${SOURCES} or specify the correct programming language if it was not"
                           " detected correctly.")
    endif ()
    set (USES_BASIS_UTILITIES TRUE)
  elseif (NOT ARGN_NO_BASIS_UTILITIES AND NOT ARGN_LANGUAGE MATCHES "UNKNOWN")
    basis_utilities_check (USES_BASIS_UTILITIES ${SOURCES} ${ARGN_LANGUAGE})
  else ()
    set (USES_BASIS_UTILITIES FALSE)
  endif ()
  if (USES_BASIS_UTILITIES)
    basis_set_project_property (PROPERTY PROJECT_USES_${ARGN_LANGUAGE}_UTILITIES TRUE)
    if (BASIS_DEBUG)
      message ("** Target ${TARGET_UID} uses the BASIS utilities for ${ARGN_LANGUAGE}.")
    endif ()
  endif ()
  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})
  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      LANGUAGE            ${ARGN_LANGUAGE}
      BASIS_TYPE          SCRIPT_${TYPE}
      BASIS_UTILITIES     ${USES_BASIS_UTILITIES}
      SOURCE_DIRECTORY    "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY    "${CMAKE_CURRENT_BINARY_DIR}"
      OUTPUT_DIRECTORY    "${OUTPUT_DIRECTORY}"
      INSTALL_DIRECTORY   "${ARGN_DESTINATION}"
      COMPONENT           "${ARGN_COMPONENT}"
      OUTPUT_NAME         "${OUTPUT_NAME}"
      COMPILE_DEFINITIONS ""
      LINK_DEPENDS        "${LINK_DEPENDS}"
      EXPORT              ${EXPORT}
      COMPILE             ${BASIS_COMPILE_SCRIPTS}
      TEST                ${TEST}
      LIBEXEC             ${ARGN_LIBEXEC}
  )
  # add target to list of targets
  basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")
  if (BASIS_VERBOSE)
    message (STATUS "Adding ${type} script ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ============================================================================
# internal helpers
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add executable target.
#
# This BASIS function overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable">
# add_executable()</a> command in order to store information of imported targets
# which is in particular used to generate the source code of the ExecutableTargetInfo
# modules which are part of the BASIS utilities.
#
# @note Use basis_add_executable() instead where possible!
#
# @param [in] TARGET_UID Name of the target.
# @param [in] ARGN       Further arguments of CMake's add_executable().
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
function (add_executable TARGET_UID)
  if (ARGC EQUAL 2 AND ARGV1 MATCHES "^IMPORTED$")
    _add_executable (${TARGET_UID} IMPORTED)
    basis_add_imported_target ("${TARGET_UID}" EXECUTABLE)
  else ()
    _add_executable (${TARGET_UID} ${ARGN})
    basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add library target.
#
# This BASIS function overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library">
# add_library()</a> command in order to store information of imported targets.
#
# @note Use basis_add_library() instead where possible!
#
# @param [in] TARGET_UID Name of the target.
# @param [in] ARGN       Further arguments of CMake's add_library().
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library
function (add_library TARGET_UID)
  if (ARGC EQUAL 3 AND ARGV2 MATCHES "^IMPORTED$")
    _add_library (${TARGET_UID} "${ARGV1}" IMPORTED)
    basis_add_imported_target ("${TARGET_UID}" "${ARGV1}")
  else ()
    _add_library (${TARGET_UID} ${ARGN})
    basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add executable built from C++ source code.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_executable() if the (detected) programming language
#       of the given source code files is @c CXX (i.e., C/C++).
#
# This function adds an executable target for the build of an executable from
# C++ source code files. Refer to the documentation of basis_add_executable()
# for a description of general options for adding an executable target.
#
# By default, the BASIS C++ utilities library is added as link dependency.
# If none of the BASIS C++ utilities are used by this target, the option
# NO_BASIS_UTILITIES can be given. To enable this option by default, set the
# variable @c BASIS_UTILITIES to @c FALSE, best in the <tt>Settings.cmake</tt>
# file located in the @c PROJECT_CONFIG_DIR (add such file if missing).
# If the use of the BASIS C++ utilities is disabled by default, the
# @c USE_BASIS_UTILITIES option can be used to enable them for this target
# only. Note that the utilities library is a static library and thus the linker
# would simply not include any of the BASIS utility functions in the final
# binary file if not used. The only advantage of setting @c BASIS_UTILITIES to
# @c FALSE or to always specify @c NO_BASIS_UTILITIES if no target uses the
# utilities is that the BASIS utilities library will not be build in this case.
#
# @param [in] TARGET_NAME Name of build target.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted, all other arguments are
#                         considered to be source code files and simply passed
#                         on to CMake's add_executable() command.
# @par
# <table border=0>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of component as part of which this executable will be installed
#         if the specified @c DESTINATION is not "none".
#         (default: @c BASIS_RUNTIME_COMPONENT)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory relative to @c INSTALL_PREFIX.
#         If "none" (case-insensitive) is given as argument, no default
#         installation rules are added for this executable target.
#         (default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR
#         if @p LIBEXEC is given)</td>
#   </tr>
#   <tr>
#     @tp @b LIBEXEC @endtp
#     <td>Specifies that the built executable is an auxiliary executable which
#         is only called by other executables. (default: @c FALSE)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this executable and hence
#         no link dependency on the BASIS utilities library shall be added.
#         (default: @c NOT @c BASIS_UTILITIES)</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and required by this executable
#         and hence a link dependency on the BASIS utilities library has to be added.
#         (default: @c BASIS_UTILITIES)</td>
#   </tr>
# </table>
#
# @returns Adds executable target using CMake's add_executable() command.
#
# @sa basis_add_executable()
function (basis_add_executable_target TARGET_NAME)
  # check target name
  basis_check_target_name (${TARGET_NAME})
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  if (BASIS_VERBOSE)
    message (STATUS "Adding executable ${TARGET_UID}...")
  endif ()
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "USE_BASIS_UTILITIES;NO_BASIS_UTILITIES;EXPORT;NOEXPORT;LIBEXEC"
      "COMPONENT;DESTINATION"
      ""
    ${ARGN}
  )
  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})
  basis_set_flag (ARGN EXPORT  ${BASIS_EXPORT})
  if (ARGN_USE_BASIS_UTILITIES AND ARGN_NO_BASIS_UTILITIES)
    message (FATAL_ERROR "Target ${TARGET_UID}: Options USE_BASIS_UTILITIES and NO_BASIS_UTILITIES are mutually exclusive!")
  endif ()
  if (ARGN_USE_BASIS_UTILITIES)
    set (USES_BASIS_UTILITIES TRUE)
  elseif (ARGN_NO_BASIS_UTILITIES)
    set (USES_BASIS_UTILITIES FALSE)
  else ()
    set (USES_BASIS_UTILITIES ${BASIS_UTILITIES})
  endif ()
  # TEST flag
  basis_sanitize_for_regex (RE "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${RE}")
    set (TEST TRUE)
  else ()
    set (TEST FALSE)
  endif ()
  # installation component
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()
  # installation directory
  if (ARGN_DESTINATION)
    if (ARGN_DESTINATION MATCHES "^[nN][oO][nN][eE]$")
      set (ARGN_DESTINATION)
    elseif (IS_ABSOLUTE "${ARGN_DESTINATION}")
      file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
    endif ()
  elseif (ARGN_LIBEXEC)
    set (ARGN_DESTINATION "${INSTALL_LIBEXEC_DIR}")
  else ()
    set (ARGN_DESTINATION "${INSTALL_RUNTIME_DIR}")
  endif ()
  # configure (.in) source files
  basis_configure_sources (SOURCES ${SOURCES})
  # add executable target
  add_executable (${TARGET_UID} ${SOURCES})
  basis_make_target_uid (HEADERS_TARGET headers)
  if (TARGET "${HEADERS_TARGET}")
    add_dependencies (${TARGET_UID} ${HEADERS_TARGET})
  endif ()
  _set_target_properties (${TARGET_UID} PROPERTIES BASIS_TYPE "EXECUTABLE" OUTPUT_NAME "${TARGET_NAME}")
  if (ARGN_LIBEXEC)
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 1 COMPILE_DEFINITIONS LIBEXEC)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
  endif ()
  _set_target_properties (${TARGET_UID} PROPERTIES TEST ${TEST})
  # output directory
  if (TEST)
    if (ARGN_LIBEXEC)
      _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TESTING_LIBEXEC_DIR}")
    else ()
      _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
    endif ()
  elseif (ARGN_LIBEXEC)
    _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${BINARY_LIBEXEC_DIR}")
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}")
  endif ()
  # link to BASIS utilities
  if (USES_BASIS_UTILITIES)
    if (NOT TARGET ${BASIS_CXX_UTILITIES_LIBRARY})
      message (FATAL_ERROR "Target ${TARGET_UID} seems to make use of the BASIS C++"
                           " utilities but BASIS was built without C++ utilities enabled."
                           " Either specify the option NO_BASIS_UTILITIES, set the global"
                           " variable BASIS_UTILITIES to FALSE"
                           " (in ${PROJECT_CONFIG_DIR}/Settings.cmake) or"
                           " rebuild BASIS with C++ utilities enabled.")
    endif ()
    # add project-specific library target if not present yet
    basis_add_utilities_library (BASIS_UTILITIES_TARGET)
    # non-project specific utilities build as part of BASIS
    basis_target_link_libraries (${TARGET_UID} ${BASIS_CXX_UTILITIES_LIBRARY})
    # project-specific utilities build as part of this project
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_TARGET})
  endif ()
  _set_target_properties (${TARGET_UID} PROPERTIES BASIS_UTILITIES ${USES_BASIS_UTILITIES})
  # export target
  set (EXPORT_OPT)
  if (EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY EXPORT_TARGETS "${TARGET_UID}")
      set (EXPORT_OPT "EXPORT" "${PROJECT_NAME}") # for install() below
    endif ()
  endif ()
  # installation
  if (ARGN_DESTINATION)
    if (TEST)
      # TODO install (selected?) tests
    else ()
      install (
        TARGETS ${TARGET_UID} ${EXPORT_OPT}
        DESTINATION "${ARGN_DESTINATION}"
        COMPONENT   "${ARGN_COMPONENT}"
      )
    endif ()
    # the following property is used by basis_get_target_location()
    _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_INSTALL_DIRECTORY "${ARGN_DESTINATION}")
  endif ()
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Adding executable ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add library built from C++ source code.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_library() if the (detected) programming language
#       of the given source code files is @c CXX (i.e., C/C++) and the
#       option @c MEX is not given.
#
# This function adds a library target which builds a library from C++ source
# code files. Refer to the documentation of basis_add_library() for a
# description of the general options for adding a library target.
#
# By default, the BASIS C++ utilities library is added as link dependency.
# If none of the BASIS C++ utilities are used by this target, the option
# NO_BASIS_UTILITIES can be given. To enable this option by default, set the
# variable @c BASIS_UTILITIES to @c FALSE, best in the <tt>Settings.cmake</tt>
# file located in the @c PROJECT_CONFIG_DIR (add such file if missing).
# If the use of the BASIS C++ utilities is disabled by default, the
# @c USE_BASIS_UTILITIES option can be used to enable them for this target
# only. Note that the utilities library is a static library and thus the linker
# would simply not include any of the BASIS utility functions in the final
# binary file if not used. The only advantage of setting @c BASIS_UTILITIES to
# @c FALSE or to always specify @c NO_BASIS_UTILITIES if no target uses the
# utilities is that the BASIS utilities library will not be build in this case.
#
# @param [in] TARGET_NAME Name of build target.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted. All other arguments are
#                         considered to be source code files and simply
#                         passed on to CMake's add_library() command.
# @par
# <table border=0>
#   <tr>
#     @tp <b>STATIC</b>|<b>SHARED</b>|<b>MODULE</b> @endtp
#     <td>Type of the library. (default: @c SHARED if @c BUILD_SHARED_LIBS
#         evaluates to true or @c STATIC otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of component as part of which this library will be installed
#         if either the @c RUNTIME_INSTALL_DIRECTORY or
#         @c LIBRARY_INSTALL_DIRECTORY property is not "none". Used only if
#         either @p RUNTIME_COMPONENT or @p LIBRARY_COMPONENT not specified.
#         (default: see @p RUNTIME_COMPONENT and @p LIBRARY_COMPONENT)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory for runtime and library component relative
#         to @c INSTALL_PREFIX. Used only if either @p RUNTIME_DESTINATION
#         or @p LIBRARY_DESTINATION not specified. If "none" (case-insensitive)
#         is given as argument, no default installation rules are added.
#         (default: see @p RUNTIME_DESTINATION and @p LIBRARY_DESTINATION)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_COMPONENT name @endtp
#     <td>Name of component as part of which import/static library will be intalled
#         if @c LIBRARY_INSTALL_DIRECTORY property is not "none".
#         (default: @c COMPONENT if specified or @c BASIS_LIBRARY_COMPONENT otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_DESTINATION dir @endtp
#     <td>Installation directory of the library component relative to
#         @c INSTALL_PREFIX. If "none" (case-insensitive) is given as argument,
#         no installation rule for the library component is added.
#         (default: @c INSTALL_ARCHIVE_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_COMPONENT name @endtp
#     <td>Name of component as part of which runtime library will be installed
#         if @c RUNTIME_INSTALL_DIRECTORY property is not "none".
#         (default: @c COMPONENT if specified or @c BASIS_RUNTIME_COMPONENT otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_DESTINATION dir @endtp
#     <td>Installation directory of the runtime component relative to
#         @c INSTALL_PREFIX. If "none" (case-insensitive) is given as argument,
#         no installation rule for the runtime library is added.
#         (default: @c INSTALL_LIBRARY_DIR on Unix or @c INSTALL_RUNTIME_DIR Windows)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this executable and hence
#         no link dependency on the BASIS utilities library shall be added.
#         (default: @c NOT BASIS_UTILITIES)</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and required by this executable
#         and hence a link dependency on the BASIS utilities library shall be added.
#         (default: @c BASIS_UTILITIES)</td>
#   </tr>
# </table>
#
# @returns Adds library target using CMake's add_library() command.
#
# @sa basis_add_library()
function (basis_add_library_target TARGET_NAME)
  # On UNIX-based systems setting the VERSION property only creates
  # annoying files with the version string as suffix.
  # Moreover, MEX-files may NEVER have a suffix after the MEX extension!
  # Otherwise, the MATLAB Compiler when using the symbolic link
  # without this suffix will create code that fails on runtime
  # with an .auth file missing error.
  #
  # Thus, do NOT set VERSION and SOVERSION properties on library targets!

  # check target name
  basis_check_target_name (${TARGET_NAME})
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;USE_BASIS_UTILITIES;NO_BASIS_UTILITIES;EXPORT;NOEXPORT"
      "COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT;DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION"
      ""
    ${ARGN}
  )
  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})
  basis_set_flag (ARGN EXPORT ${BASIS_EXPORT})
  if (ARGN_USE_BASIS_UTILITIES AND ARGN_NO_BASIS_UTILITIES)
    message (FATAL_ERROR "Target ${TARGET_UID}: Options USE_BASIS_UTILITIES and NO_BASIS_UTILITIES are mutually exclusive!")
  endif ()
  if (ARGN_USE_BASIS_UTILITIES)
    set (USES_BASIS_UTILITIES TRUE)
  elseif (ARGN_NO_BASIS_UTILITIES)
    set (USES_BASIS_UTILITIES FALSE)
  else ()
    set (USES_BASIS_UTILITIES ${BASIS_UTILITIES})
  endif ()
  # TEST flag
  basis_sanitize_for_regex (RE "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${RE}")
    set (TEST TRUE)
  else ()
    set (TEST FALSE)
  endif ()
  # library type
  if (NOT ARGN_SHARED AND NOT ARGN_STATIC AND NOT ARGN_MODULE)
    if (BUILD_SHARED_LIBS)
      set (ARGN_SHARED TRUE)
    else ()
      set (ARGN_STATIC TRUE)
    endif ()
  endif ()
  set (TYPE)
  if (ARGN_STATIC)
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}!")
    endif ()
    set (TYPE "STATIC")
  endif ()
  if (ARGN_SHARED)
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}!")
    endif ()
    set (TYPE "SHARED")
  endif ()
  if (ARGN_MODULE)
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}!")
    endif ()
    set (TYPE "MODULE")
  endif ()
  string (TOLOWER "${TYPE}" type)
  # status message
  if (BASIS_VERBOSE)
    message (STATUS "Adding ${type} library ${TARGET_UID}...")
  endif ()
  # installation component
  if (ARGN_COMPONENT)
    if (NOT ARGN_RUNTIME_COMPONENT)
      set (ARGN_RUNTIME_COMPONENT "${ARGN_COMPONENT}")
    endif ()
    if (NOT ARGN_LIBRARY_COMPONENT)
      set (ARGN_LIBRARY_COMPONENT "${ARGN_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "Unspecified")
  endif ()
  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "Unspecified")
  endif ()
  # installation directories
  if (ARGN_DESTINATION)
    if (NOT ARGN_STATIC AND NOT ARGN_RUNTIME_DESTINATION)
      set (ARGN_RUNTIME_DESTINATION "${ARGN_DESTINATION}")
    endif ()
    if (NOT ARGN_LIBRARY_DESTINATION)
      set (ARGN_LIBRARY_DESTINATION "${ARGN_DESTINATION}")
    endif ()
  endif ()
  if (NOT ARGN_RUNTIME_DESTINATION)
    set (ARGN_RUNTIME_DESTINATION "${INSTALL_RUNTIME_DIR}")
  endif ()
  if (NOT ARGN_LIBRARY_DESTINATION)
    set (ARGN_LIBRARY_DESTINATION "${INSTALL_LIBRARY_DIR}")
  endif ()
  if (ARGN_STATIC OR ARGN_RUNTIME_DESTINATION MATCHES "^[nN][oO][nN][eE]$")
    set (ARGN_RUNTIME_DESTINATION)
  endif ()
  if (ARGN_LIBRARY_DESTINATION MATCHES "^[nN][oO][nN][eE]$")
    set (ARGN_LIBRARY_DESTINATION)
  endif ()
  # configure (.in) source files
  basis_configure_sources (SOURCES ${SOURCES})
  # add library target
  add_library (${TARGET_UID} ${TYPE} ${SOURCES})
  basis_make_target_uid (HEADERS_TARGET headers)
  if (TARGET ${HEADERS_TARGET})
    add_dependencies (${TARGET_UID} ${HEADERS_TARGET})
  endif ()
  _set_target_properties (${TARGET_UID} PROPERTIES BASIS_TYPE "${TYPE}_LIBRARY" OUTPUT_NAME "${TARGET_NAME}")
  # output directory
  if (TEST)
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}"
        LIBRARY_OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}"
        ARCHIVE_OUTPUT_DIRECTORY "${TESTING_ARCHIVE_DIR}"
    )
  else ()
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}"
        LIBRARY_OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}"
        ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}"
    )
  endif ()
  # link to BASIS utilities
  if (USES_BASIS_UTILITIES)
    if (NOT TARGET ${BASIS_CXX_UTILITIES_LIBRARY})
      message (FATAL_ERROR "Target ${TARGET_UID} makes use of the BASIS C++ utilities"
                           " but BASIS was build without C++ utilities enabled."
                           " Either specify the option NO_BASIS_UTILITIES, set the global"
                           " variable BASIS_UTILITIES to FALSE"
                           " (in ${PROJECT_CONFIG_DIR}/Settings.cmake) or"
                           " rebuild BASIS with C++ utilities enabled.")
    endif ()
    # add project-specific library target if not present yet
    basis_add_utilities_library (BASIS_UTILITIES_TARGET)
    # non-project specific utilities build as part of BASIS
    basis_target_link_libraries (${TARGET_UID} ${BASIS_CXX_UTILITIES_LIBRARY})
    # project-specific utilities build as part of this project
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_TARGET})
  endif ()
  _set_target_properties (${TARGET_UID} PROPERTIES BASIS_UTILITIES ${USES_BASIS_UTILITIES})
  # installation
  if (TEST)
    # TODO At the moment, no tests are installed. Once there is a way to
    #      install selected tests, the shared libraries they depend on
    #      need to be installed as well.
    if (EXPORT)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  else ()
    if (EXPORT)
      set (EXPORT_OPT "EXPORT" "${PROJECT_NAME}")
      basis_set_project_property (APPEND PROPERTY EXPORT_TARGETS "${TARGET_UID}")
    else ()
      set (EXPORT_OPT)
    endif ()
    if (ARGN_RUNTIME_DESTINATION)
      install (
        TARGETS ${TARGET_UID} ${EXPORT_OPT}
        RUNTIME
          DESTINATION "${ARGN_RUNTIME_DESTINATION}"
          COMPONENT   "${ARGN_RUNTIME_COMPONENT}"
      )
      # the following property is used by basis_get_target_location()
      _set_target_properties (${TARGET_UID} PROPERTIES RUNTIME_INSTALL_DIRECTORY "${ARGN_RUNTIME_DESTINATION}")
    endif ()
    if (ARGN_LIBRARY_DESTINATION)
      install (
        TARGETS ${TARGET_UID} ${EXPORT_OPT}
        LIBRARY
          DESTINATION "${ARGN_LIBRARY_DESTINATION}"
          COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
        ARCHIVE
          DESTINATION "${ARGN_LIBRARY_DESTINATION}"
          COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
      )
      # the following property is used by basis_get_target_location()
      _set_target_properties (${TARGET_UID} PROPERTIES LIBRARY_INSTALL_DIRECTORY "${ARGN_LIBRARY_DESTINATION}")
    endif ()
  endif ()
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Adding ${type} library ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add script library target.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_library() if the (detected) programming language
#       of the given source code files is neither @c CXX (i.e., C/C++) nor
#       @c MATLAB.
#
# This function adds a build target for libraries which are a collection of
# one or more modules written in a scripting language. The relative paths
# of the modules relative to the library's @p SOURCE_DIRECTORY property are
# preserved. This is important for the most widely used scripting languages
# such as Python, Perl, or MATLAB, where the file path relative to the
# package root directory defines the package namespace.
#
# A custom CMake build target with the following properties is added by this
# function to the build system. These properties are used by
# basis_build_script_library() to generate a build script written in CMake
# code which is executed by a custom CMake command. Before the invokation of
# basis_build_script_library(), the target properties can be modified using
# basis_set_target_properties().
#
# @note Custom BASIS build targets are finalized by BASIS at the end of
#       basis_project_impl(), i.e., the end of the root CMake configuration file
#       of the (sub-)project.
#
# @par Properties on script library targets
# <table border=0>
#   <tr>
#     @tp @b BASIS_TYPE @endtp
#     <td>Read-only property with value "SCRIPT_LIBRARY" for script library targets.</td>
#   </tr>
#   <tr>
#     @tp @b BASIS_UTILITIES @endtp
#     <td>Whether the BASIS utilities are used by any module of this library.
#         For the supported scripting languages for which BASIS utilities are
#         implemented, BASIS will in most cases automatically detect whether
#         these utilities are used by a module or not. Otherwise, set this
#         property manually or use either the @p USE_BASIS_UTILITIES or the
#         @p NO_BASIS_UTILITIES option when adding the library target.
#         (default: auto-detected or @c UNKNOWN)</td>
#   </tr>
#   <tr>
#     @tp @b BINARY_DIRECTORY @endtp
#     <td>Build tree directory of this target. (default: @c CMAKE_CURRENT_BINARY_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE @endtp
#     <td>Whether to compile the library, respectively, it's modules if the
#         programming language allows such pre-compilation as in case of Python,
#         for example. If @c TRUE, only the compiled files are installed.
#         (default: @c BASIS_COMPILE_SCRIPTS)</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE_DEFINITIONS @endtp
#     <td>CMake code which is evaluated after the inclusion of the default script
#         configuration files. This code can be used to set the replacement text of the
#         CMake variables ("@VAR@" patterns) used in the source files.
#         See <a href="http://www.rad.upenn.edu/sbia/software/basis/standard/scripttargets.html#script-configuration">
#         Build System Standard</a> for details. (default: "")</td>
#   </tr>
#   <tr>
#     @tp @b EXPORT @endtp
#     <td>Whether to export this build target in which case an import library
#         target is added to the custom exports file with the path to the
#         built/installed modules set as @c IMPORT_LOCATION. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE @endtp
#     <td>Read-only property of programming language of modules in uppercase letters.
#         (default: see @p LANGUAGE argument)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_COMPONENT @endtp
#     <td>Name of component as part of which this library is installed if
#         @c LIBRARY_INSTALL_DIRECTORY is not set to "none".
#         (default: see @p COMPONENT argument)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_INSTALL_DIRECTORY @endtp
#     <td>Installation directory of library configured for use in installation tree
#         relative to @c INSTALL_PREFIX. Set to "none" (case-insensitive) to skip the
#         addition of an installation rule.
#         (default: <tt>INSTALL_&lt;LANGUAGE&gt;_LIBRARY_DIR</tt> if defined or
#         @c INSTALL_LIBRARY_DIR otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_OUTPUT_DIRECTORY @endtp
#     <td>Output directory of library configured for use within the build tree.
#         (default: <tt>BINARY_&lt;LANGUAGE&gt;_LIBRARY_DIR</tt> if defined or
#         @c BINARY_LIBRARY_DIR otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b LINK_DEPENDS @endtp
#     <td>Paths or target names of script modules and libraries used by this script.
#         For each listed build target, a dependency is added between this
#         library target and the named build targets. Use basis_target_link_libraries()
#         to add additional link dependencies. Further note that if this library is
#         a link dependency of an executable script added by basis_add_executable()
#         (i.e., basis_add_script() actually), the link dependencies of this library
#         are inherited by the executable script.
#         (default: BASIS utilities module if used or empty list otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b PREFIX @endtp
#     <td>Common module prefix. The given directory path is appended to both
#         @c LIBRAR_OUTPUT_DIRECTORY and @c LIBRARY_INSTALL_DIRECTORY and can be,
#         for example, be used to install modules of a Python package as part of
#         another Python package, where @c LIBRARY_OUTPUT_DIRECTORY or
#         @c LIBRARY_INSTALL_DIRECTORY, respectively, is the directory of the
#         main package which is added to the @c PYTHONPATH. Possibly missing
#         __init__.py files in case of Python are generated by the _initpy target
#         which is automatically added by BASIS in that case and further added to
#         the dependencies of this library target.
#         (default: @c PROJECT_NAMESPACE_PYTHON if @c LANGUAGE is @c PYTHON with
#         periods (.) replaced by slashes (/), @c PROJECT_NAMESPACE_PERL if
#         @c LANGUAGE is @c PERL with <tt>::</tt> replaced by slashes (/),
#         and "" otherwise)</td>
#   </tr>
#   <tr>
#     @tp @b SOURCE_DIRECTORY @endtp
#     <td>Source directory of this target. This directory is in particular
#         used to convert the paths of the given source files to relative paths.
#         The built modules within the build and installation tree will have the
#         same relative path (relative to the @c LIBRARY_OUTPUT_DIRECTORY or
#         @c LIBRARY_INSTALL_DIRECTORY, respectively).
#         (default: @c CMAKE_CURRENT_SOURCE_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b SOURCES @endtp
#     <td>Read-only property which lists the source files of this library.
#         Note that the first element in this list actually names a directory
#         in the build, the one where the build script for this target is located
#         instead of a source file and thus should be ignored.</td>
#   </tr>
# </table>
#
# @attention Properties documented as read-only must not be modified.
#
# @param [in] TARGET_NAME Name of build target.
# @param [in] ARGN        The remaining arguments are parsed and the following
#                         arguments extracted. All unparsed arguments are treated
#                         as the module files of the script library.
# @par
# <table border=0>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of installation component as part of which this library is being
#         installed if the @c LIBRARY_INSTALL_DIRECTORY property is not "none".
#         (default: @c BASIS_LIBRARY_COMPONENT)</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory for library relative to @c INSTALL_PREFIX.
#         If an absolute path is given as argument, it is made relative to the
#         configured installation prefix. (default: @c INSTALL_LIBRARY_DIR)</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Programming language in which modules are written (case-insensitive).
#         If not specified, the programming language is derived from the file name
#         extensions of the source files and the shebang directive on the first line
#         of each module if any. If the programming language could not be detected
#         automatically, the @c LANGUAGE property is set to @c UNKNOWN. Note that
#         for script library targets, the library may still be built correctly
#         even if the scripting language was not recognized. The automatic detection
#         whether the BASIS utilities are used and required will fail, however.
#         In this case, specify the programming language using this option.
#         (default: auto-detected or @c UNKNOWN)</td>
#   </tr>
#   <tr>
#     @tp @b [NO]EXPORT @endtp
#     <td>Whether to export this target. (default: @c TRUE)</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are not used by this library. If the
#         programming language of the modules is known and BASIS utilities are
#         available for this language, BASIS will in most cases automatically
#         detect whether these utilities are used by any module of this library.
#         Use this option to skip this check in the case that no module makes
#         use of the BASIS utilities.</td>
#   </tr>
#   <tr>
#     @tp @b USE_BASIS_UTILITIES @endtp
#     <td>Specify that the BASIS utilities are used and thus required by this library.
#         If the programming language of the modules is known and BASIS utilities are
#         available for this language, BASIS will in most cases automatically
#         detect whether these utilities are used by any module of this library.
#         Use this option to skip this check when it is already known that no module
#         makes use of the BASIS utilities. Note that an error is raised if this option
#         is given, but no BASIS utilities are available for the programming language
#         of this script or if the programming language is unknown, respectively, not
#         detected correctly. In this case, consider the use of the @p LANGUAGE argument.</td>
#   </tr>
# </table>
#
# @returns Adds a custom CMake target with the documented properties. The actual custom
#          command to build the library is added by basis_build_script_library().
#
# @sa basis_add_library()
function (basis_add_script_library TARGET_NAME)
  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  if (BASIS_VERBOSE)
    message (STATUS "Adding script library ${TARGET_UID}...")
  endif ()
  # dump CMake variables for configuration of script
  set (BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_UID}.dir")
  basis_dump_variables ("${BUILD_DIR}/cache.cmake")
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "NO_BASIS_UTILITIES;USE_BASIS_UTILITIES;EXPORT;NOEXPORT"
      "COMPONENT;DESTINATION;LANGUAGE"
      ""
    ${ARGN}
  )
  basis_set_flag (ARGN EXPORT ${BASIS_EXPORT})
  set (SOURCES "${ARGN_UNPARSED_ARGUMENTS}")
  # TEST flag
  basis_sanitize_for_regex (RE "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${RE}")
    set (TEST TRUE)
  else ()
    set (TEST FALSE)
  endif ()
  # check source files
  set (_SOURCES)
  foreach (S IN LISTS SOURCES)
    get_filename_component (S "${S}" ABSOLUTE)
    if (NOT EXISTS "${S}" AND NOT S MATCHES "\\.in$" AND EXISTS "${S}.in" AND NOT IS_DIRECTORY "${S}.in")
      set (S "${S}.in")
    elseif (IS_DIRECTORY "${S}")
      message (FATAL_ERROR "Target ${TARGET_UID}: Directory ${S} given where file name expected!")
    endif ()
    if (NOT EXISTS "${S}")
      string (REGEX REPLACE "\\.in$" "" S "${S}")
      message (FATAL_ERROR "Target ${TARGET_UID}: Source file ${S}[.in] does not exist!")
    endif ()
    list (APPEND _SOURCES "${S}")
  endforeach ()
  if (NOT _SOURCES)
    message (FATAL_ERROR "Target ${TARGET_UID}: No source files specified!")
  endif ()
  set (SOURCES "${_SOURCES}")
  unset (_SOURCES)
  # auto-detect programming language (may be as well UNKNOWN)
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)
  if (NOT ARGN_LANGUAGE)
    basis_get_source_language (ARGN_LANGUAGE ${SOURCES})
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message (FATAL_ERROR "Target ${TARGET_UID}: Failed to determine programming"
                           " language of modules! Make sure that all modules are"
                           " written in the same language and that the used programming"
                           " language is supported by BASIS, i.e., either Python (Jython),"
                           " Perl, Bash, or MATLAB. Otherwise, try to specify the language"
                           " explicitly using the LANGUAGE option.")
    endif ()
  endif ()
  # output directory
  if (TEST)
    if (DEFINED TESTING_${ARGN_LANGUAGE}_LIBRARY_DIR)
      set (OUTPUT_DIRECTORY "${TESTING_${ARGN_LANGUAGE}_LIBRARY_DIR}")
    else ()
      set (OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}")
    endif ()
  else ()
    if (DEFINED BINARY_${ARGN_LANGUAGE}_LIBRARY_DIR)
      set (OUTPUT_DIRECTORY "${BINARY_${ARGN_LANGUAGE}_LIBRARY_DIR}")
    else ()
      set (OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}")
    endif ()
  endif ()
  # installation component
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()
  # installation directory
  if (TEST)
    if (ARGN_DESTINATION)
      message (WARNING "Target ${TARGET_UID} is a library used for testing only."
                       " Installation to the specified directory will be skipped.")
      set (ARGN_DESTINATION)
    endif ()
  else ()
    if (ARGN_DESTINATION)
      if (IS_ABSOLUTE "${ARGN_DESTINATION}")
        file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
      endif ()
    else ()
      if (DEFINED INSTALL_${ARGN_LANGUAGE}_LIBRARY_DIR)
        set (ARGN_DESTINATION "${INSTALL_${ARGN_LANGUAGE}_LIBRARY_DIR}")
      else ()
        set (ARGN_DESTINATION "${INSTALL_LIBRARY_DIR}")
      endif ()
    endif ()
  endif ()
  # common module prefix
  if (ARGN_LANGUAGE MATCHES "PYTHON")
    string (REPLACE "."  "/" PREFIX "${PROJECT_NAMESPACE_PYTHON}")
  elseif (ARGN_LANGUAGE MATCHES "PERL")
    string (REPLACE "::" "/" PREFIX "${PROJECT_NAMESPACE_PERL}")
  else ()
    set (PREFIX)
  endif ()
  # auto-detect use of BASIS utilities
  if (ARGN_USE_BASIS_UTILITIES)
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "${ARGN_LANGUAGE}")
      message (FATAL_ERROR "Target ${TARGET_UID} requires the BASIS utilities for ${ARGN_LANGUAGE}"
                           " but BASIS was either build without the build of these utilities enabled"
                           " or no utilities for this programming language are implemented. Remove the"
                           " USE_BASIS_UTILITIES option if no BASIS utilities are used by the modules"
                           " of the library or specify the correct programming language if it was not"
                           " detected correctly.")
    endif ()
    set (USES_BASIS_UTILITIES TRUE)
  elseif (NOT ARGN_NO_BASIS_UTILITIES AND NOT ARGN_LANGUAGE MATCHES "UNKNOWN")
    set (USES_BASIS_UTILITIES FALSE)
    foreach (M IN LISTS SOURCES)
      basis_utilities_check (USES_BASIS_UTILITIES "${M}" ${ARGN_LANGUAGE})
      if (USES_BASIS_UTILITIES)
        break ()
      endif ()
    endforeach ()
  else ()
    set (USES_BASIS_UTILITIES FALSE)
  endif ()
  if (USES_BASIS_UTILITIES)
    basis_set_project_property (PROPERTY PROJECT_USES_${ARGN_LANGUAGE}_UTILITIES TRUE)
    if (BASIS_DEBUG)
      message ("** Target ${TARGET_UID} uses the BASIS utilities for ${ARGN_LANGUAGE}.")
    endif ()
  endif ()
  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})
  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      LANGUAGE                  "${ARGN_LANGUAGE}"
      BASIS_TYPE                "SCRIPT_LIBRARY"
      BASIS_UTILITIES           "${USES_BASIS_UTILITIES}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      LIBRARY_OUTPUT_DIRECTORY  "${OUTPUT_DIRECTORY}"
      LIBRARY_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
      LIBRARY_COMPONENT         "${BASIS_LIBRARY_COMPONENT}"
      PREFIX                    "${PREFIX}"
      COMPILE_DEFINITIONS       ""
      LINK_DEPENDS              ""
      EXPORT                    "${EXPORT}"
      COMPILE                   "${COMPILE}"
      TEST                      "${TEST}"
  )
  # add target to list of targets
  basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")
  if (BASIS_VERBOSE)
    message (STATUS "Adding script library ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ============================================================================
# custom build commands
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Finalize custom targets by adding the missing build commands.
#
# This function is called by basis_project_impl() in order to finalize the
# addition of the custom build targets such as, for example, build targets
# for the build of executable scripts, Python packages, MATLAB Compiler
# executables and shared libraries, and MEX-files.
#
# @returns Generates the CMake build scripts and adds custom build commands
#          and corresponding targets for the execution of these scripts.
#
# @sa basis_build_script()
# @sa basis_build_script_library()
# @sa basis_build_mcc_target()
# @sa basis_build_mex_file()
function (basis_finalize_targets)
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (TARGET_UID ${TARGETS})
    if (NOT TARGET _${TARGET_UID})
      get_target_property (BASIS_TYPE ${TARGET_UID} BASIS_TYPE)
      if (BASIS_TYPE MATCHES "SCRIPT_LIBRARY")
        basis_build_script_library (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "SCRIPT")
        basis_build_script (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "MEX")
        basis_build_mex_file (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "MCC")
        basis_build_mcc_target (${TARGET_UID})
      endif ()
    endif ()
  endforeach ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add custom command for build of single script.
#
# This function is called by basis_finalize_targets() which in turn is called
# at the end of basis_project_impl(), i.e., the end of the root CMake
# configuration file of the (sub-)project.
#
# @param [in] TARGET_UID Name/UID of custom target added by basis_add_script().
#
# @sa basis_add_script()
function (basis_build_script TARGET_UID)
  # does this target exist ?
  basis_get_target_uid (TARGET_UID "${TARGET_UID}")
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown build target: ${TARGET_UID}")
  endif ()
  if (BASIS_VERBOSE AND BASIS_DEBUG)
    message (STATUS "Adding build command for target ${TARGET_UID}...")
  endif ()
  # get target properties
  basis_get_target_link_libraries (LINK_DEPENDS ${TARGET_UID}) # paths of script modules/packages
                                                               # including BASIS utilities if used
  set (
    PROPERTIES
      LANGUAGE             # programming language of script
      BASIS_TYPE           # must match "^SCRIPT_(EXECUTABLE|LIBEXEC|MODULE)$"
      SOURCE_DIRECTORY     # CMake source directory
      BINARY_DIRECTORY     # CMake binary directory
      OUTPUT_DIRECTORY     # output directory for built script
      INSTALL_DIRECTORY    # installation directory for built script
      COMPONENT            # installation component
      OUTPUT_NAME          # name of built script including extension (if any)
      COMPILE_DEFINITIONS  # CMake code to set variables used to configure script
      TEST                 # whether this script is used for testing only
      EXPORT               # whether this target shall be exported
      COMPILE              # whether to compile script if applicable
      SOURCES              # path of script source file
  )
  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()
  set (EXECUTABLE FALSE)
  set (LIBEXEC    FALSE)
  set (MODULE     FALSE)
  if (BASIS_TYPE MATCHES "^SCRIPT_(EXECUTABLE|LIBEXEC|MODULE)$")
    set (${CMAKE_MATCH_1} TRUE)
    if (LIBEXEC)
      set (EXECUTABLE TRUE)
    endif ()
  else ()
    message (FATAL_ERROR "Target ${TARGET_UID}: Unexpected BASIS_TYPE: ${BASIS_TYPE}")
  endif ()
  if (NOT BINARY_DIRECTORY)
    message (FATAL_ERROR "Target ${TARGET_UID}: Missing BINARY_DIRECTORY property!")
  endif ()
  if (NOT BINARY_DIRECTORY MATCHES "^${PROJECT_BINARY_DIR}(/|$)")
    message (FATAL_ERROR "Target ${TARGET_UID}: BINARY_DIRECTORY must be inside of build tree!")
  endif ()
  if (INSTALL_DIRECTORY AND NOT COMPONENT)
    set (COMPONENT "Unspecified")
  endif ()
  list (LENGTH SOURCES L)
  if (NOT L EQUAL 2)
    message (FATAL_ERROR "Target ${TARGET_UID}: Expected two elements in SOURCES list!"
                         " Have you accidentally modified this read-only property or"
                         " is your (newer) CMake version not compatible with BASIS?")
  endif ()
  list (GET SOURCES 0 BUILD_DIR) # strange, but CMake stores path to internal build directory here
  list (GET SOURCES 1 SOURCE_FILE)
  set (BUILD_DIR "${BUILD_DIR}.dir")
  # output name
  if (NOT OUTPUT_NAME)
    basis_get_target_name (OUTPUT_NAME ${TARGET_UID})
  endif ()
  if (PREFIX)
    set (OUTPUT_NAME "${PREFIX}${OUTPUT_NAME}")
  endif ()
  if (SUFFIX)
    set (OUTPUT_NAME "${OUTPUT_NAME}${SUFFIX}")
  endif ()
  # options of basis_configure_script()
  set (OUTPUT_FILE "${OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  if (INSTALL_DIRECTORY)
    get_filename_component (SOURCE_NAME "${SOURCE_FILE}" NAME)
    if (SOURCE_NAME MATCHES "\\.in$")
      set (INSTALL_FILE "${BINARY_DIRECTORY}/${SOURCE_NAME}")
      string (REGEX REPLACE "\\.in$" "" INSTALL_FILE "${INSTALL_FILE}")
    else ()
      # otherwise, Doxygen would have problems as it does not know which
      # file to process. thus, write configured file to directory excluded
      # from Doxygen search path.
      set (INSTALL_FILE "${BUILD_DIR}/${SOURCE_NAME}")
    endif ()
  else ()
    set (INSTALL_FILE)
  endif ()
  set (CONFIG_FILE)
  if (EXISTS "${BASIS_SCRIPT_CONFIG_FILE}")
    list (APPEND CONFIG_FILE "${BASIS_SCRIPT_CONFIG_FILE}")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    list (APPEND CONFIG_FILE "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
  endif ()
  if (COMPILE_DEFINITIONS)
    file (WRITE "${BUILD_DIR}/ScriptConfig.cmake" "# DO NOT edit. Automatically generated by BASIS.\n${COMPILE_DEFINITIONS}\n")
    list (APPEND CONFIG_FILE "${BUILD_DIR}/ScriptConfig.cmake")
  endif ()
  set (OPTIONS "CACHE_FILE;${BUILD_DIR}/cache.cmake;CONFIG_FILE;${CONFIG_FILE}")
  if (COMPILE)
    list (APPEND OPTIONS COMPILE)
  endif ()
  if (EXECUTABLE)
    list (APPEND OPTIONS EXECUTABLE)
  endif ()
  # link dependencies - module search paths
  set (BUILD_LINK_DEPENDS)
  set (INSTALL_LINK_DEPENDS)
  foreach (LINK_DEPEND IN LISTS LINK_DEPENDS)
    basis_get_target_uid (UID "${LINK_DEPEND}")
    if (TARGET "${UID}")
      basis_get_target_location (LOCATION "${UID}" ABSOLUTE)
      list (APPEND BUILD_LINK_DEPENDS "${LOCATION}")
      basis_get_target_location (LOCATION "${UID}" POST_INSTALL)
      list (APPEND INSTALL_LINK_DEPENDS "${LOCATION}")
    else ()
      list (APPEND BUILD_LINK_DEPENDS   "${LINK_DEPEND}")
      list (APPEND INSTALL_LINK_DEPENDS "${LINK_DEPEND}")
    endif ()
  endforeach ()
  if (BUILD_LINK_DEPENDS)
    list (REMOVE_DUPLICATES BUILD_LINK_DEPENDS)
  endif ()
  if (INSTALL_LINK_DEPENDS)
    list (REMOVE_DUPLICATES INSTALL_LINK_DEPENDS)
  endif ()
  # list of all output files
  set (OUTPUT_FILES "${OUTPUT_FILE}")
  if (INSTALL_FILE)
    list (APPEND OUTPUT_FILES "${INSTALL_FILE}")
  endif ()
  if (MODULE AND COMPILE AND LANGUAGE MATCHES "[JP]YTHON")
    list (APPEND OUTPUT_FILES "${OUTPUT_FILE}c")
    if (INSTALL_FILE)
      list (APPEND OUTPUT_FILES "${INSTALL_FILE}c")
    endif ()
  endif ()
  # add build command for script
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${OUTPUT_FILE}")
  if (LANGUAGE MATCHES "UNKNOWN")
    set (COMMENT "Building script ${REL}...")
  elseif (MODULE)
    set (COMMENT "Building ${LANGUAGE} module ${REL}...")
  else ()
    set (COMMENT "Building ${LANGUAGE} executable ${REL}...")
  endif ()
  add_custom_command (
    OUTPUT          ${OUTPUT_FILES}
    COMMAND         "${CMAKE_COMMAND}"
                        "-DSOURCE_FILE=${SOURCE_FILE}"
                        "-DOUTPUT_FILE=${OUTPUT_FILE}"
                        "-DINSTALL_FILE=${INSTALL_FILE}"
                        "-DDESTINATION=${INSTALL_DIRECTORY}"
                        "-DBUILD_LINK_DEPENDS=${BUILD_LINK_DEPENDS}"
                        "-DINSTALL_LINK_DEPENDS=${INSTALL_LINK_DEPENDS}"
                        "-DOPTIONS=${OPTIONS}"
                        -P "${BASIS_MODULE_PATH}/configure_script.cmake"
    MAIN_DEPENDENCY ${SOURCE_FILE}
    DEPENDS         "${BUILD_DIR}/cache.cmake" ${CONFIG_FILE}
    COMMENT         "${COMMENT}"
    VERBATIM
  )
  # add custom target
  add_custom_target (_${TARGET_UID} DEPENDS ${OUTPUT_FILES})
  foreach (T IN LISTS LINK_DEPENDS)
    if (TARGET ${T})
      add_dependencies (_${TARGET_UID} ${T})
    endif ()
  endforeach ()
  add_dependencies (${TARGET_UID} _${TARGET_UID})
  # cleanup on "make clean" - always including compiled .pyc files regardless of COMPILE
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})
  foreach (OUTPUT_FILE IN LISTS OUTPUT_FILES)
    if (OUTPUT_FILE MATCHES "\\.py$")
      list (FIND OUTPUT_FILES "${OUTPUT_FILE}c" IDX)
      if (IDX EQUAL -1)
        set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${OUTPUT_FILE}c")
      endif ()
    endif ()
  endforeach ()
  # export target
  if (EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  endif ()
  # install script
  if (INSTALL_DIRECTORY)
    if (NOT INSTALL_FILE)
      set (INSTALL_FILE "${OUTPUT_FILE}")
    endif ()
    if (MODULE AND COMPILE AND LANGUAGE MATCHES "[JP]YTHON")
      set (INSTALL_FILE "${INSTALL_FILE}c")
    endif ()
    get_filename_component (OUTPUT_NAME "${OUTPUT_FILE}" NAME)
    if (MODULE)
      set (INSTALLTYPE FILES)
    else ()
      set (INSTALLTYPE PROGRAMS)
    endif ()
    install (
      ${INSTALLTYPE} "${INSTALL_FILE}"
      DESTINATION    "${INSTALL_DIRECTORY}"
      COMPONENT      "${COMPONENT}"
      RENAME         "${OUTPUT_NAME}"
    )
  endif ()
  # done
  if (BASIS_VERBOSE AND BASIS_DEBUG)
    message (STATUS "Adding build command for target ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add custom command for build of script library.
#
# This function is called by basis_finalize_targets() which in turn is called
# at the end of basis_project_impl(), i.e., the end of the root CMake
# configuration file of the (sub-)project.
#
# @param [in] TARGET_UID Name/UID of custom target added by basis_add_script_library().
#
# @sa basis_add_script_library()
function (basis_build_script_library TARGET_UID)
  # does this target exist ?
  basis_get_target_uid (TARGET_UID "${TARGET_UID}")
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target: ${TARGET_UID}")
  endif ()
  if (BASIS_VERBOSE AND BASIS_DEBUG)
    message (STATUS "Adding build command for target ${TARGET_UID}...")
  endif ()
  # get target properties
  basis_get_target_link_libraries (LINK_DEPENDS ${TARGET_UID}) # paths of script modules/packages
                                                               # including BASIS utilities if used
  set (
    PROPERTIES
      LANGUAGE                   # programming language of modules
      BASIS_TYPE                 # must be "SCRIPT_LIBRARY"
      BASIS_UTILITIES            # whether this target requires the BASIS utilities
      SOURCE_DIRECTORY           # CMake source directory
      BINARY_DIRECTORY           # CMake binary directory
      LIBRARY_OUTPUT_DIRECTORY   # output directory for built modules
      LIBRARY_INSTALL_DIRECTORY  # installation directory for built modules
      LIBRARY_COMPONENT          # installation component
      PREFIX                     # common path prefix for modules
      COMPILE_DEFINITIONS        # CMake code to set variables used to configure modules
      LINK_DEPENDS               # paths of script modules/packages used by the modules of this library
      EXPORT                     # whether to export this target
      COMPILE                    # whether to compile the modules/library if applicable
      SOURCES                    # source files of module scripts
  )
  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()
  string (REGEX REPLACE "/$" "" PREFIX "${PREFIX}")
  if (NOT BASIS_TYPE MATCHES "^SCRIPT_LIBRARY$")
    message (FATAL_ERROR "Target ${TARGET_UID}: Unexpected BASIS_TYPE: ${BASIS_TYPE}")
  endif ()
  if (NOT SOURCE_DIRECTORY)
    message (FATAL_ERROR "Missing SOURCE_DIRECTORY property!")
  endif ()
  if (NOT LIBRARY_OUTPUT_DIRECTORY)
    message (FATAL_ERROR "Missing LIBRARY_OUTPUT_DIRECTORY property!")
  endif ()
  if (NOT IS_ABSOLUTE "${LIBRARY_OUTPUT_DIRECTORY}")
    set (LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/${LIBRARY_OUTPUT_DIRECTORY}")
  endif ()
  if (NOT LIBRARY_OUTPUT_DIRECTORY MATCHES "^${PROJECT_BINARY_DIR}")
    message (FATAL_ERROR "Output directory LIBRARY_OUTPUT_DIRECTORY is outside the build tree!")
  endif ()
  if (NOT LIBRARY_COMPONENT)
    set (LIBRARY_COMPONENT "Unspecified")
  endif ()
  list (GET SOURCES 0 BUILD_DIR) # strange, but CMake stores path to internal build directory here
  list (REMOVE_AT SOURCES 0)
  set (BUILD_DIR "${BUILD_DIR}.dir")
  if (NOT SOURCES)
    message (FATAL_ERROR "Target ${TARGET_UID}: Empty SOURCES list!"
                         " Have you accidentally modified this read-only property or"
                         " is your (newer) CMake version not compatible with BASIS?")
  endif ()
  # options of basis_configure_script()
  set (CONFIG_FILE)
  if (EXISTS "${BASIS_SCRIPT_CONFIG_FILE}")
    list (APPEND CONFIG_FILE "${BASIS_SCRIPT_CONFIG_FILE}")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    list (APPEND CONFIG_FILE "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
  endif ()
  if (COMPILE_DEFINITIONS)
    file (WRITE "${BUILD_DIR}/ScriptConfig.cmake" "# DO NOT edit. Automatically generated by BASIS.\n${COMPILE_DEFINITIONS}\n")
    list (APPEND CONFIG_FILE "${BUILD_DIR}/ScriptConfig.cmake")
  endif ()
  set (OPTIONS "CACHE_FILE;${BUILD_DIR}/cache.cmake;CONFIG_FILE;${CONFIG_FILE}")
  if (COMPILE)
    list (APPEND OPTIONS COMPILE)
  endif ()
  # add build command for each module
  set (OUTPUT_FILES)                            # list of all output files
  set (FILES_TO_INSTALL)                        # list of output files for installation
  set (BINARY_INSTALL_DIRECTORY "${BUILD_DIR}") # common base directory for files to install 
  foreach (SOURCE_FILE IN LISTS SOURCES)
    file (RELATIVE_PATH S "${SOURCE_DIRECTORY}" "${SOURCE_FILE}")
    string (REGEX REPLACE "\\.in$" "" S "${S}")
    if (PREFIX)
      set (S "${PREFIX}/${S}")
    endif ()
    # build command arguments
    set (OUTPUT_FILE    "${LIBRARY_OUTPUT_DIRECTORY}/${S}")
    if (LIBRARY_INSTALL_DIRECTORY)
      set (INSTALL_FILE "${BINARY_INSTALL_DIRECTORY}/${S}")
      set (DESTINATION  "${LIBRARY_INSTALL_DIRECTORY}/${S}")
      get_filename_component (DESTINATION "${DESTINATION}" PATH)
    else ()
      set (INSTALL_FILE)
      set (DESTINATION)
    endif ()
    # output files of this command
    set (_OUTPUT_FILES "${OUTPUT_FILE}")
    if (COMPILE AND LANGUAGE MATCHES "[JP]YTHON")
      list (APPEND _OUTPUT_FILES "${OUTPUT_FILE}c")
    endif ()
    if (INSTALL_FILE)
      list (APPEND _OUTPUT_FILES "${INSTALL_FILE}")
      if (COMPILE AND LANGUAGE MATCHES "[JP]YTHON")
        list (APPEND _OUTPUT_FILES "${INSTALL_FILE}c")
        list (APPEND FILES_TO_INSTALL "${INSTALL_FILE}c")
      else ()
        list (APPEND FILES_TO_INSTALL "${INSTALL_FILE}")
      endif ()
    endif ()
    # add build command
    file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${OUTPUT_FILE}")
    set (COMMENT "Building ${LANGUAGE} module ${REL}...")
    add_custom_command (
      OUTPUT          ${_OUTPUT_FILES}
      COMMAND         "${CMAKE_COMMAND}"
                          "-DSOURCE_FILE=${SOURCE_FILE}"
                          "-DOUTPUT_FILE=${OUTPUT_FILE}"
                          "-DINSTALL_FILE=${INSTALL_FILE}"
                          "-DDESTINATION=${DESTINATION}"
                          "-DOPTIONS=${OPTIONS}"
                          -P "${BASIS_MODULE_PATH}/configure_script.cmake"
      MAIN_DEPENDENCY ${SOURCE_FILE}
      DEPENDS         "${BUILD_DIR}/cache.cmake" ${CONFIG_FILE}
      COMMENT         "${COMMENT}"
      VERBATIM
    )
    # add output files of command to list of all output files
    list (APPEND OUTPUT_FILES ${_OUTPUT_FILES})
  endforeach ()
  # add custom target to build modules
  add_custom_target (_${TARGET_UID} DEPENDS ${OUTPUT_FILES})
  foreach (T IN LISTS LINK_DEPENDS)
    if (TARGET ${T})
      add_dependencies (_${TARGET_UID} ${T})
    endif ()
  endforeach ()
  add_dependencies (${TARGET_UID} _${TARGET_UID})
  # cleanup on "make clean" - always including compiled .pyc files regardless of COMPILE
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})
  foreach (OUTPUT_FILE IN LISTS OUTPUT_FILES)
    if (OUTPUT_FILE MATCHES "\\.py$")
      list (FIND OUTPUT_FILES "${OUTPUT_FILE}c" IDX)
      if (IDX EQUAL -1)
        set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${OUTPUT_FILE}c")
      endif ()
    endif ()
  endforeach ()
  # export target
  if (EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  endif ()
  # add installation rule
  foreach (INSTALL_FILE IN LISTS FILES_TO_INSTALL)
    get_filename_component (D "${INSTALL_FILE}" PATH)
    file (RELATIVE_PATH D "${BINARY_INSTALL_DIRECTORY}" "${D}")
    install (
      FILES       "${INSTALL_FILE}"
      DESTINATION "${LIBRARY_INSTALL_DIRECTORY}/${D}"
      COMPONENT   "${LIBRARY_COMPONENT}"
    )
  endforeach ()
  # done
  if (BASIS_VERBOSE AND BASIS_DEBUG)
    message (STATUS "Adding build command for target ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
# @brief Add target to build/install __init__.py files.
function (basis_add_init_py_target)
  # constants
  set (BUILD_DIR "${PROJECT_BINARY_DIR}/CMakeFiles/_initpy.dir")
  basis_sanitize_for_regex (BINARY_PYTHON_LIBRARY_DIR_REGEX  "${BINARY_PYTHON_LIBRARY_DIR}")
  basis_sanitize_for_regex (TESTING_PYTHON_LIBRARY_DIR_REGEX "${TESTING_PYTHON_LIBRARY_DIR}")
  basis_sanitize_for_regex (INSTALL_PYTHON_LIBRARY_DIR_REGEX "${INSTALL_PYTHON_LIBRARY_DIR}")
  # collect build tree directories requiring a __init__.py file
  set (DEPENDENTS)      # targets which generate Python modules and depend on _initpy
  set (DIRS)            # directories for which to generate a __init__.py file
  set (EXCLUDE)         # exclude these directories
  set (INSTALL_EXCLUDE) # exclude these directories on installation
  set (COMPONENTS)      # installation components
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (TARGET_UID IN LISTS TARGETS)
    get_target_property (BASIS_TYPE ${TARGET_UID} BASIS_TYPE)
    get_target_property (LANGUAGE   ${TARGET_UID} LANGUAGE)
    if (BASIS_TYPE MATCHES "MODULE|LIBRARY" AND LANGUAGE MATCHES "PYTHON")
      # get absolute path of build Python modules
      basis_get_target_location (LOCATION         ${TARGET_UID} ABSOLUTE)
      basis_get_target_location (INSTALL_LOCATION ${TARGET_UID} POST_INSTALL_RELATIVE)
      if (BASIS_TYPE MATCHES "^SCRIPT_LIBRARY$")
        get_target_property (PREFIX           ${TARGET_UID} PREFIX)
        get_target_property (SOURCES          ${TARGET_UID} SOURCES)
        get_target_property (SOURCE_DIRECTORY ${TARGET_UID} SOURCE_DIRECTORY)
        if (PREFIX)
          set (LOCATION         "${LOCATION}/${PREFIX}")
          set (INSTALL_LOCATION "${INSTALL_LOCATION}/${PREFIX}")
        endif ()
        list (REMOVE_AT SOURCES 0) # strange, but this is a CMakeFiles/ subdirectory
        foreach (SOURCE IN LISTS SOURCES)
          file (RELATIVE_PATH SOURCE "${SOURCE_DIRECTORY}" "${SOURCE}")
          list (APPEND _LOCATION         "${LOCATION}/${SOURCE}")
          list (APPEND _INSTALL_LOCATION "${INSTALL_LOCATION}/${SOURCE}")
        endforeach ()
        set (LOCATION         "${_LOCATION}")
        set (INSTALL_LOCATION "${_INSTALL_LOCATION}")
      endif ()
      # get component (used by installation rule)
      get_target_property (COMPONENT ${TARGET_UID} "LIBRARY_COMPONENT")
      list (FIND COMPONENTS "${COMPONENT}" IDX)
      if (IDX EQUAL -1)
        list (APPEND COMPONENTS "${COMPONENT}")
        set (INSTALL_DIRS_${COMPONENT}) # list of directories for which to install
                                        # __init__.py for this component
      endif ()
      # directories for which to build a __init__.py file
      foreach (L IN LISTS LOCATION)
        basis_get_filename_component (DIR "${L}" PATH)
        if (L MATCHES "/__init__.py$")
          list (APPEND EXCLUDE "${DIR}")
        else ()
          list (APPEND DEPENDENTS ${TARGET_UID}) # depends on _initpy
          if (DIR MATCHES "^${BINARY_PYTHON_LIBRARY_DIR_REGEX}/.+")
            while (NOT "${DIR}" MATCHES "^${BINARY_PYTHON_LIBRARY_DIR_REGEX}$")
              list (APPEND DIRS "${DIR}")
              get_filename_component (DIR "${DIR}" PATH)
            endwhile ()
          elseif (DIR MATCHES "^${TESTING_PYTHON_LIBRARY_DIR_REGEX}/.+")
            while (NOT "${DIR}" MATCHES "^${TESTING_PYTHON_LIBRARY_DIR_REGEX}$")
              list (APPEND DIRS "${DIR}")
              get_filename_component (DIR "${DIR}" PATH)
            endwhile ()
          endif ()
        endif ()
      endforeach ()
      # directories for which to install a __init__.py file
      foreach (L IN LISTS INSTALL_LOCATION)
        basis_get_filename_component (DIR "${L}" PATH)
        if (L MATCHES "/__init__.py$")
          list (APPEND INSTALL_EXCLUDE "${DIR}")
        else ()
          list (APPEND DEPENDENTS ${TARGET_UID}) # depends on _initpy
          if (DIR MATCHES "^${INSTALL_PYTHON_LIBRARY_DIR_REGEX}/.+")
            while (NOT "${DIR}" MATCHES "^${INSTALL_PYTHON_LIBRARY_DIR_REGEX}$")
              list (APPEND INSTALL_DIRS_${COMPONENT} "${DIR}")
              get_filename_component (DIR "${DIR}" PATH)
            endwhile ()
          endif ()
        endif ()
      endforeach ()
    endif ()
  endforeach ()
  if (DEPENDENTS)
    list (REMOVE_DUPLICATES DEPENDENTS)
  endif ()
  # return if no Python module is being build
  if (NOT DIRS)
    return ()
  endif ()
  list (REMOVE_DUPLICATES DIRS)
  if (EXCLUDE)
    list (REMOVE_DUPLICATES EXCLUDE)
  endif ()
  if (INSTALL_EXCLUDE)
    list (REMOVE_DUPLICATES INSTALL_EXCLUDE)
  endif ()
  # generate build script
  set (C)
  set (OUTPUT_FILES)
  foreach (DIR IN LISTS DIRS)
    list (FIND EXCLUDE "${DIR}" IDX)
    if (IDX EQUAL -1)
      set (C "${C}configure_file (\"${BASIS_PYTHON_TEMPLATES_DIR}/__init__.py.in\" \"${DIR}/__init__.py\" @ONLY)\n")
      list (APPEND OUTPUT_FILES "${DIR}/__init__.py")
      if (BASIS_COMPILE_SCRIPTS)
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${DIR}/__init__.py')\")\n")
        list (APPEND OUTPUT_FILES "${DIR}/__init__.pyc")
      endif ()
    endif ()
  endforeach ()
  set (C "${C}configure_file (\"${BASIS_PYTHON_TEMPLATES_DIR}/__init__.py.in\" \"${BUILD_DIR}/__init__.py\" @ONLY)\n")
  list (APPEND OUTPUT_FILES "${BUILD_DIR}/__init__.py")
  if (BASIS_COMPILE_SCRIPTS)
    set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${BUILD_DIR}/__init__.py')\")\n")
    list (APPEND OUTPUT_FILES "${BUILD_DIR}/__init__.pyc")
  endif ()
  # write/update build script
  set (BUILD_SCRIPT "${BUILD_DIR}/build.cmake")
  if (EXISTS "${BUILD_SCRIPT}")
    file (WRITE "${BUILD_SCRIPT}.tmp" "${C}")
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
          "${BUILD_SCRIPT}.tmp" "${BUILD_SCRIPT}"
    )
    file (REMOVE "${BUILD_SCRIPT}.tmp")
  else ()
    file (WRITE "${BUILD_SCRIPT}" "${C}")
  endif ()
  # add custom build command
  add_custom_command (
    OUTPUT          ${OUTPUT_FILES}
    COMMAND         "${CMAKE_COMMAND}" -P "${BUILD_SCRIPT}"
    MAIN_DEPENDENCY "${BASIS_PYTHON_TEMPLATES_DIR}/__init__.py.in"
    COMMENT         "Building PYTHON modules */__init__.py..."
  )
  # add custom target which triggers execution of build script
  add_custom_target (_initpy ALL DEPENDS ${OUTPUT_FILES})
  if (BASIS_DEBUG)
    message ("** basis_add_init_py_target():")
  endif ()
  foreach (DEPENDENT IN LISTS DEPENDENTS)
    if (BASIS_DEBUG)
      message ("**    Adding dependency on _initpy target to ${DEPENDENT}")
    endif ()
    add_dependencies (${DEPENDENT} _initpy)
  endforeach ()
  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})
  # add install rules
  if (BASIS_COMPILE_SCRIPTS)
    set (INSTALL_INIT_FILE "${BUILD_DIR}/__init__.pyc")
  else ()
    set (INSTALL_INIT_FILE "${BUILD_DIR}/__init__.py")
  endif ()
  foreach (COMPONENT IN LISTS COMPONENTS)
    if (INSTALL_DIRS_${COMPONENT})
      list (REMOVE_DUPLICATES INSTALL_DIRS_${COMPONENT})
    endif ()
    foreach (DIR IN LISTS INSTALL_DIRS_${COMPONENT})
      list (FIND INSTALL_EXCLUDE "${DIR}" IDX)
      if (IDX EQUAL -1)
        install (
          FILES       "${INSTALL_INIT_FILE}"
          DESTINATION "${DIR}"
          COMPONENT   "${COMPONENT}"
        )
      endif ()
    endforeach ()
  endforeach ()
endfunction ()


## @}
# end of Doxygen group
