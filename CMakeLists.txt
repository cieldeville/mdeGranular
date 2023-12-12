# ============================================================================ #
# CMake Build Script
#
# Project: mdeGranular
# Version: 1.2
#
# This script can be used to generate build files for both Pure-Data as well
# as MaxMSP. It supports building with Pure-Data on Linux, Windows and MacOSX
# as well as with MaxMSP on Windows and MacOSX.
#
# Below you can find which compiler was used to test each build:
# - PD/Linux:    GCC
# - PD/Windows:  MinGW (GCC from MSYS2)
# - PD/MacOSX:   LLVM (using Xcode)
# - Max/Windows: Visual Studio
# - Max/MacOSX:  LLVM (using Xcode)
# ============================================================================ #

# ============================= #
# CMake Prerequisites
# ============================= #
cmake_minimum_required(VERSION 3.27)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake/modules)

# ============================= #
# Project Metadata
# ============================= #
project(mdeGranular VERSION 1.2
					DESCRIPTION "A real-time, multi-channel, multi-voice, multi-transposition granular synthesis external for Max/MSP and PD"
					HOMEPAGE_URL "https://michael-edwards.org/software/mdegranular/mdegranular.shtml"
					LANGUAGES C)

# ============================= #
# Project Options
# ============================= #

# Present with option to choose target SDK (PureData or Max/MSP)
set(MDE_SUPPORTED_SDKS PD MAXMSP)
set(MDE_TARGET_SDK PD CACHE STRING "Target SDK to build against (PD for PureData or MAXMSP for Max/MSP)")
set_property(CACHE MDE_TARGET_SDK PROPERTY STRINGS ${MDE_SUPPORTED_SDKS}) # Makes choices available as dropdown in CMake GUI

if (NOT MDE_TARGET_SDK IN_LIST MDE_SUPPORTED_SDKS)
	message(FATAL_ERROR "Invalid target SDK specifier encountered; please use PD for Pure-Data or MAXMSP for Max/MSP")
endif()

message("Building against Target SDK: ${MDE_TARGET_SDK}")


# Present with option to specify path to target SDK
set(MDE_TARGET_SDK_PATH CACHE PATH "Path to the target SDK's main directory ; if left unspecified we will try our best to figure out where to find libraries and headers (e.g. system install directories)")

# ============================= #
# SDK Preparations
# ============================= #

set(MDE_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src)

if (MDE_TARGET_SDK STREQUAL "PD")
	set (PureData_BASEDIR ${MDE_TARGET_SDK_PATH})
	find_package(PureData REQUIRED)
	
	set(MDE_ADDITIONAL_SOURCES ${MDE_SOURCE_DIR}/mdeGranular~pd.c)
elseif (MDE_TARGET_SDK STREQUAL "MAXMSP")
	message(FATAL_ERROR "Support for Max/MSP not yet available")
	
	# Configure Max SDK
	add_subdirectory(../sdk ./sdk)
	set(C74SUPPORT_DIR ${PROJECT_SOURCE_DIR}/../sdk/source/max-sdk-base/c74support)
	set(C74SCRIPT_DIR ${C74SUPPORT_DIR}/../script)
	set(MAX_SDK_MAX_INCLUDES ${C74SUPPORT_DIR}/max-includes)
	set(MAX_SDK_MSP_INCLUDES ${C74SUPPORT_DIR}/msp-includes)

	if (APPLE)
		if (CMAKE_OSX_ARCHITECTURES STREQUAL "")
			set (CMAKE_OSX_ARCHITECTURES x86_64)
		endif()
		set (CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum OS X deployment version" FORCE)

		file (STRINGS "${C74SCRIPT_DIR}/max-linker-flags.txt" C74_SYM_MAX_LINKER_FLAGS)
		set (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${C74_SYM_MAX_LINKER_FLAGS}")
	endif()

	set(MDE_ADDITIONAL_SOURCES ${MDE_SOURCE_DIR}/mdeGranular~maxmsp.c)
endif()


# ============================= #
# Library Definition
# ============================= #

add_library(mdeGranular MODULE)
set_target_properties(mdeGranular PROPERTIES OUTPUT_NAME mdeGranular~)

# Define symbol for target SDK in source code
target_compile_definitions(mdeGranular PUBLIC ${MDE_TARGET_SDK})

# Add sources, including SDK specific ones
target_sources(mdeGranular PRIVATE ${MDE_SOURCE_DIR}/mdeGranular~.c ${MDE_ADDITIONAL_SOURCES})


# ============================= #
# SDK Linkage
# ============================= #

if (MDE_TARGET_SDK STREQUAL "PD")
	set_target_properties(mdeGranular PROPERTIES PREFIX "")
	
	if (WIN32)
		target_link_options(mdeGranular PUBLIC "-static-libgcc")
	elseif (UNIX AND NOT APPLE)
		set_target_properties(mdeGranular PROPERTIES SUFFIX "pd_linux")
	elseif (APPLE)
		set_target_properties(mdeGranular PROPERTIES SUFFIX "pd_darwin")
	endif ()
	
	target_link_libraries(mdeGranular PRIVATE PureData::PureData)
elseif (MDE_TARGET_SDK STREQUAL "MAXMSP")
	target_include_directories(mdeGranular PUBLIC ${MAX_SDK_MAX_INCLUDES} ${MAX_SDK_MSP_INCLUDES})

	if (WIN32)
		target_link_directories(mdeGranular PRIVATE ${C74SUPPORT_DIR}/max-includes/x64 ${C74SUPPORT_DIR}/msp-includes/x64)
		target_link_libraries(mdeGranular PRIVATE MaxAPI MaxAudio)
	elseif (APPLE)
		find_library(
			MSP_LIBRARY "MaxAudioAPI"
			REQUIRED
			PATHS "${MAX_SDK_MSP_INCLUDES}"
			NO_DEFAULT_PATH
			NO_CMAKE_FIND_ROOT_PATH
		)
		target_link_libraries(mdeGranular PUBLIC ${MSP_LIBRARY})
		
		set_target_properties(mdeGranular PROPERTIES BUNDLE True)
		set_target_properties(mdeGranular PROPERTIES BUNDLE_EXTENSION "mxo")
		
		set_target_properties(mdeGranular PROPERTIES XCODE_ATTRIBUTE_WRAPPER_EXTENSION "mxo")
		set_target_properties(mdeGranular PROPERTIES MACOSX_BUNDLE_BUNDLE_VERSION "${VERSION}")
		set_target_properties(mdeGranular PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${C74SCRIPT_DIR}/Info.plist.in)
		set_target_properties(mdeGranular PROPERTIES XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${AUTHOR_DOMAIN}.${BUNDLE_IDENTIFIER}")
		
		# add_custom_command(
			# TARGET mdeGranular
			# POST_BUILD
			# COMMAND cp "${C74SCRIPT_DIR}/PkgInfo" "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/mdeGranular\~.mxo/Contents/PkgInfo"
			# COMMENT "Copy PkgInfo"
		# )
	endif ()
endif ()