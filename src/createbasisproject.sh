#! /usr/bin/env bash

##############################################################################
# \file  createbasisproject.sh
# \brief This shell script instantiates the project template and creates the
#        structure for a new project based on BASIS.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################
 
# ============================================================================
# constants
# ============================================================================

progName=${0##*/} # name of this script
progDir=`cd \`dirname $0\`; pwd`

versionMajor=@VERSION_MAJOR@ # major version number
versionMinor=@VERSION_MINOR@ # minor version number
versionPatch=@VERSION_PATCH@ # version patch number

# version string
version="$versionMajor.$versionMinor.$versionPatch"

# ============================================================================
# usage / help / version
# ============================================================================

# ****************************************************************************
# \brief Prints version information.
version ()
{
	echo "$progName $version"
}

# ****************************************************************************
# \brief Prints usage information.
usage ()
{
	$progName $versionMajor.$versionMinor
	echo
	echo "Description:"
    echo "  Instantiates the BASIS project template version $versionMajor.$versionMinor,"
    echo "  creating the core project structure for a new project."
    echo
    echo "  Besides the name of the new project and a brief description,"
    echo "  names of external packages required or optionally used by this"
    echo "  project can be specified. For each such package, an entry in the"
    echo "  Depends.cmake file is created. If the package is not supported"
    echo "  explicitly by this script, generic CMake statements to find the"
    echo "  package are added. Note that these may not work for this unsupported"
    echo "  package. In this case, the Depends.cmake file has to be edited manually."
    echo
	echo "Usage:"
	echo "  $progName [options] <project name>"
	echo
    echo "Required options:"
    echo "  <project name>          Name of the new project."
    echo "  -d [--description] arg  Brief project description."
    echo
    echo "Options:"
    echo "  -t [ --template ] arg   Root directory of project template."
    echo "  -r [ --root ] arg       Specify root directory of new project."
    echo "  -p [ --pkg ] arg        Name of external package required by this project."
    echo "  --optPkg arg            Name of external package optionally used by this project."
    echo "  -v [ --verbose ]        Increases verbosity of output messages. Can be given multiple times."
    echo "  -h [ --help ]           Displays help and exit."
    echo "  -u [ --usage ]          Displays usage information and exits."
    echo "  -V [ --version ]        Displays version information and exits."
	echo
	echo "Example:"
	echo "  $progName SimpleExample -d \"Novel image analysis method.\""
    echo "  $progName ITKExample -d \"An example project which uses ITK.\" -p ITK"
    echo "  $progName MatlabExample -d \"An example project which uses MATLAB.\" -p Matlab"
    echo "  $progName MatlabITKExample -d \"An example project which uses MATLAB and ITK.\" -p Matlab -p ITK"
    echo
    echo "Contact:"
    echo "  SBIA Group <sbia-software -at- uphs.upenn.edu>"
}

# ****************************************************************************
# \brief Prints help.
help ()
{
	usage
}

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Make path absolute.
#
# This function returns the absolute path via command substitution, i.e.,
# use it as follows:
#
# \code
# abspath=$(makeAbsolute $relpath)
# \endcode
#
# \param [in]  1      The (relative) path of a file or directory
#                     (does not need to exist yet).
# \param [out] stdout Prints the absolute path of the specified file or
#                     directory to STDOUT.
#
# \return 0 on success and 1 on failure.
makeAbsolute ()
{
    local path="$1"

    if [ -z "$path" ]; then
        echo "makeAbsolute (): Argument missing!" 1>&2
        return 1
    else
        [ "${path/#\//}" != "$path" ] || path="$(pwd)/$path"
    fi

    echo "$path"
    return 0
}

# ****************************************************************************
# \brief Create directory or file in project root from template.
#
# Only the name directory or file is copied to the project root directory.
# If verbosity is > 0, all created directories and files are printed.
#
# \param [in] 1 The path of the directory or file relative to the template
#               or project root, respectively.

create ()
{
    local path="$1"
    if [ $overwrite -ne 0 -o ! -e "$root/$path" ]; then
        if [ -d "$template/$path" ]; then
            if [ ! -d "$root/$path" ]; then
                mkdir -p "$root/$path"
                if [ $verbosity -gt 0 ]; then
                    echo "$root/$path"
                fi
            fi
        elif [ -f "$template/$path" ]; then
            local dir="`dirname \"$root/$path\"`"
            if [ ! -d $dir ]; then
                mkdir -p $dir
                if [ $verbosity -gt 0 ]; then
                    echo "$dir"
                fi
            fi
            cp "$template/$path" "$root/$path"
            if [ $verbosity -gt 0 ]; then
                echo "$root/$path"
            fi
        else
            echo "Template $template/$path is missing!" 1>&2
            exit 1
        fi
    fi
}

# ============================================================================
# options
# ============================================================================

# ----------------------------------------------------------------------------
# default options
# ----------------------------------------------------------------------------

# root directory of project template
template="$progDir/@TEMPLATE_DIR@"

root=""            # root directory of new project (defaults to `pwd`/$name)
name=""            # name of the project to create
description=""     # project description
verbosity=0        # verbosity level of output messages
packageNames=()    # names of packages the new project depends on
packageRequired=() # whether the package at the same index in packageNames
                   # is required or optional
packageNum=0       # length of arrays packageNames and packageRequired
overwrite=0        # whether to overwrite existing files

# ----------------------------------------------------------------------------
# parse options
# ----------------------------------------------------------------------------

while [ $# -gt 0 ]
do
	case "$1" in
		-u|--usage)
			usage
			exit 0
			;;

		-h|--help)
			help
			exit 0
			;;

		-V|--version)
			version
			exit 0
			;;

        -v|--verbose)
            ((verbosity++))
            ;;

        -t|--template)
            shift
            if [ $# -gt 0 ]; then
                template=$(makeAbsolute $1)
            else
                usage
                echo
                echo "Option -t requires an argument!" 1>&2
                exit 1
            fi
            ;;
 
        -r|--root)
            if [ "X$root" != "X" ]; then
                usage
                echo
                echo "Option -r may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                root=$(makeAbsolute $1)
            else
                usage
                echo
                echo "Option -r requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -d|--description)
            if [ "X$description" != "X" ]; then
                usage
                echo
                echo "Option -d may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                description="$1"
            else
                usage
                echo
                echo "Option -d requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --overwrite)
            overwrite=1
            ;;

        -p|--pkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=1
                ((packageNum++))
            else
                echo "Option -p requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --optPkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=0
                ((packageNum++))
            else
                echo "Option --optPkg requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -*)
            usage
            echo
            echo "Invalid option $1!" 1>&2
            exit 1
            ;;

        *)
            if [ "X$name" != "X" ]; then
                usage
                echo
                echo "Project name already specified!" 1>&2
                exit 1
            fi
            name="$1"
            ;;
	esac
    shift
done

# simplify template path
cwd=$(pwd)
cd $template
if [ $? -ne 0 ]; then
    echo "Invalid project template!"
    exit 1
fi
template=$(pwd)
cd $cwd

# check required options
if [ -z "$name" ]; then
    usage
    echo
    echo "No project name specified!" 1>&2
    exit 1
fi

# set project root from project name if not explicitly specified
if [ -z "$root" ]; then
    root="$(pwd)/$name"
fi

# test if project root already exists
if [ -d "$root" -a $overwrite -eq 0 ]; then
    usage
    echo
    echo "Project root directory already exists!" 1>&2
    echo "Please choose another project name or specify a non-existent directory using the -d option or use the --overwrite option." 1>&2
    exit 1
elif [ $verbosity -gt 0 ]; then
    echo "Project root: $root"
    echo "Project template: $template"
    echo
fi

# ============================================================================
# instantiate template
# ============================================================================

# ----------------------------------------------------------------------------
# create project structure

echo "Creating project structure..."
set +e

if [ $verbosity -gt 0 ]; then
    echo
fi

# minimal project structure
create "AUTHORS"
create "README"
create "INSTALL"
create "LICENSE"
create "CMakeLists.txt"
create "config/Settings.cmake"
create "config/Depends.cmake"
create "doc/CMakeLists.txt"
create "src/CMakeLists.txt"

# additional configuration files
create "config/ScriptConfig.cmake.in"
create "config/Config.cmake.in"
create "config/ConfigVersion.cmake.in"
create "config/ConfigBuild.cmake"
create "config/ConfigInstall.cmake"
create "config/GenerateConfig.cmake"
create "config/Use.cmake.in"

# package configuration files
create "config/Package.cmake"
create "config/Components.cmake"

# auxiliary data
create "data/CMakeLists.txt"

# testing tree
create "CTestConfig.cmake"
create "config/CTestCustom.cmake.in"
create "test/CMakeLists.txt"
create "test/data"
create "test/expected"
create "test/system/CMakeLists.txt"
create "test/unit/CMakeLists.txt"

# example
create "example/CMakeLists.txt"

if [ $verbosity -gt 0 ]; then
    echo
fi

set -e
echo "Creating project structure... - done"
echo

exit 0 # \todo

# ----------------------------------------------------------------------------
# alter project settings

echo "Altering project settings..."

settingsFilePath="$(find "$root" -name "$settingsFile")"

if [ -z "$settingsFilePath" ]; then
    echo "Settings file $settingsFile not found!" 1>&2
    exit 1
fi

if [ $verbosity -gt 0 ]; then
    echo "Settings file: $settingsFilePath"
fi

sed -i "s/PROJECT_NAME \".*\"/PROJECT_NAME \"$name\"/g" "$settingsFilePath"

if [ $? -ne 0 ]; then
    echo "Failed to set project name!" 1>&2
fi

sed -i "s/PROJECT_DESCRIPTION \".*\"/PROJECT_DESCRIPTION \"$description\"/g" "$settingsFilePath"

if [ $? -ne 0 ]; then
    echo "Failed to set project description!" 1>&2
fi

echo "Altering project settings... - done"

# ============================================================================
# dependencies
# ============================================================================

findPackage ()
{
    local file=$1
    local package=$2
    local required=$3
    local useFile=$4
    local prefix=$package

    if [ $# -gt 3 ]; then
        prefix=$(echo $prefix | tr [:lower:] [:upper:])
    fi

    echo >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo "# $package" >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo >> $file
    if [ $required -ne 0 ]; then
    echo "find_package (${package} REQUIRED)" >> $file
    else
    echo "find_package (${package})" >> $file
    fi
    echo >> $file
    echo "if (${prefix}_FOUND)" >> $file
    if [ $useFile -ne 0 ]; then
    echo "  include (\${${prefix}_USE_FILE})" >> $file
    else
    echo "  if (${prefix}_INCLUDE_DIRS)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIRS})" >> $file
    echo "  elseif (${prefix}_INCLUDE_DIR)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIR})" >> $file
    echo "  endif ()" >> $file
    echo >> $file
    echo "  if (${prefix}_LIBRARY_DIRS)" >> $file
    echo "    link_directories (\${${prefix}_LIBRARY_DIRS})" >> $file
    echo "  elseif (${prefix}_LIBRARY_DIR)" >> $file
    echo "    link_directories (\${${prefix}_LIBRARY_DIR})" >> $file
    echo "  endif ()" >> $file
    fi
    echo "endif ()" >> $file
}

if [ $packageNum -gt 0 ]; then
    echo "Setting up project dependencies..."

    dependsFilePath="$(find "$root" -name "$dependsFile")"

    if [ -z "$dependsFilePath" ]; then
        echo "Dependencies file $dependsFile not found!" 1>&2
        exit 1
    fi

    if [ $verbosity -gt 0 ]; then
        echo "Dependencies file: $dependsFilePath"
    fi

    idx=0

    while [ $idx -lt $packageNum ]
    do
        pkg="${packageNames[$idx]}"
        required="${packageRequired[$idx]}"

        case "$pkg" in
            # use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            # -> package provides <PKG>_USE_FILE
            ITK)
                findPackage $dependsFilePath $pkg $required 0 1
                ;;
            # use package name for find_package ()
            # and <PKG>_VARIABLE variable names
            Matlab)
                findPackage $dependsFilePath $pkg $required 1 0
                ;;
            # default, use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            *)
                findPackage $dependsFilePath $pkg $required 0 0
                ;;
        esac

        ((idx++))
    done

    echo "Setting up project dependencies... - done"
fi

# ============================================================================
# done
# ============================================================================

echo
echo "Project \"$name\" created in $root"
exit 0
