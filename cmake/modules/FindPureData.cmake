include(FindPackageHandleStandardArgs)

set (PureData_ADDITIONAL_HINTS "")
if (DEFINED ENV{PDDIR})
	set (PureData_ADDITIONAL_HINTS "$ENV{PDDIR}/src")
endif () 

if (PureData_BASEDIR)
	list(APPEND PureData_ADDITIONAL_HINTS ${PureData_BASEDIR})
	list(APPEND PureData_ADDITIONAL_HINTS ${PureData_BASEDIR}/src)
endif ()

find_library(
	PureData_LIBRARY
	NAMES pd
	HINTS
		ENV PDDIR
		${PureData_ADDITIONAL_HINTS}
)
find_path(
	PureData_INCLUDE_DIR
	NAMES m_pd.h
	HINTS
		ENV PDDIR
		${PureData_ADDITIONAL_HINTS}
)

find_package_handle_standard_args(
	PureData
	REQUIRED_VARS PureData_LIBRARY PureData_INCLUDE_DIR
)

if (PureData_FOUND)
	mark_as_advanced(PureData_LIBRARY)
	mark_as_advanced(PureData_INCLUDE_DIR)
endif ()

if (PUREDATA_FOUND AND NOT TARGET PureData::PureData)
	add_library(PureData::PureData SHARED IMPORTED)
	if (WIN32)
		set_property(TARGET PureData::PureData PROPERTY IMPORTED_IMPLIB ${PureData_LIBRARY})
	else ()
		set_property(TARGET PureData::PureData PROPERTY IMPORTED_LOCATION ${PureData_LIBRARY})
	endif ()
	target_include_directories(PureData::PureData INTERFACE ${PureData_INCLUDE_DIR})
endif ()