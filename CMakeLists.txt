cmake_minimum_required(VERSION 2.8.10)
project(COLORSPACE Fortran C CXX)

set(COLORSPACE_VERSION 6.0.0)

message("***COLORSPACE_BINARY_DIR=${COLORSPACE_BINARY_DIR}")
message("***COLORSPACE_SOURCE_DIR=${COLORSPACE_SOURCE_DIR}")
# Configure the warning and code coverage suppression file
configure_file(
  "${COLORSPACE_SOURCE_DIR}/CTestCustom.cmake.in"
  "${COLORSPACE_BINARY_DIR}/CTestConfig.cmake"
  COPYONLY
)

# Add the CMake directory for custon CMake modules
set(CMAKE_MODULE_PATH "${COLORSPACE_SOURCE_DIR}/CMAKE" ${CMAKE_MODULE_PATH})

if("${CMAKE_BUILD_TYPE}" MATCHES "Debug")
  add_definitions(-DDEBUG)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -g -O0 -fPIC -D_POSIX_C_SOURCE=200112L")
#  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}")
else("${CMAKE_BUILD_TYPE}" MATCHES "Debug")
  add_definitions(-DARMA_NO_DEBUG)
  add_definitions(-DNDEBUG)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -O3 -fPIC -D_POSIX_C_SOURCE=200112L")
#  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}")
endif("${CMAKE_BUILD_TYPE}" MATCHES "Debug")


#F95, F90, F77
#option(COLORSPACE_F90 "Build COLORSPACE by fortran F90" ON)
option(BUILD_COLORSPACE_GENERIC "Build Generic MACHINE COLORSPACE" ON)
option(BUILD_COLORSPACE_VEC "Build VECTOR MACHINE COLORSPACE" OFF)
option(BUILD_COLORSPACE_NEON "Build ARM NEON MACHINE COLORSPACE" OFF)
option(BUILD_COLORSPACE_CUDA "Build CUDA MACHINE COLORSPACE" OFF)

if(ANDROID_NDK)
	# export FC=/path/to/android-ndk-r9/toolchains/arm-linux-androideabi-4.8.0/prebuilt/linux-x86/bin/arm-linux-androideabi-gfortran
	message ("**** CMAKE_Fortran_COMPILER full path: " ${CMAKE_Fortran_COMPILER})
	#set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fPIC -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}" )
	set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fPIC" )
	get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)
	if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
		# gfortran
		message ("*** Fortran compiler: " ${Fortran_COMPILER_NAME})
#		set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fPIE -pie -fPIC -fno-f2c -O3")
#		set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -fPIE -pie -fPIC -g")

#		set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fPIC -fno-f2c -O3 -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}")
#		set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -fPIC -g -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}")
		set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fPIC -fno-f2c -O3 ")
		set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -fPIC -g ")
	else (Fortran_COMPILER_NAME MATCHES "gfortran.*")
		message ("CMAKE_Fortran_COMPILER full path: " ${CMAKE_Fortran_COMPILER})
		message ("Fortran compiler: " ${Fortran_COMPILER_NAME})
		message ("No optimized Fortran compiler flags are known, we just try -O2...")
#		set (CMAKE_Fortran_FLAGS_RELEASE "-O2 -fPIE -pie -fPIC")
#		set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -fPIE -pie -fPIC -g")
		set (CMAKE_Fortran_FLAGS_RELEASE "-O2 -fPIC")
		set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -fPIC -g")
	endif (Fortran_COMPILER_NAME MATCHES "gfortran.*")
else(ANDROID_NDK)
	message ("*** Fortran compiler: " ${Fortran_COMPILER_NAME})
	if (UNIX)
	#unix, linux
		if ( "${CMAKE_Fortran_COMPILER}" MATCHES "ifort" )
			set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fltconsistency -fp_port" )
		endif ()
		if ( "${CMAKE_Fortran_COMPILER}" MATCHES "xlf" )
			set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qnosave -qstrict=none" )
		endif ()
		# Delete libmtsk in linking sequence for Sun/Oracle Fortran Compiler.
		# This library is not present in the Sun package SolarisStudio12.3-linux-x86-bin
		STRING(REPLACE \;mtsk\; \; CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES "${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES}")

		#set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fPIC -DTRIGO_LUT=${COLORSPACE_TRIGO_LUT}" )
		set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fPIC" )
		if(BUILD_COLORSPACE_GENERIC)
			set( CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS} -O3 -fPIC -fomit-frame-pointer -fopenmp" )
			set( CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS} -O0 -fPIC -g -fopenmp" )
		endif()
		if(BUILD_COLORSPACE_VEC)
			set( CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS} -O3 -fPIC -xAVX" )
			set( CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS} -O0 -fPIC -g" )
		endif()
		if(BUILD_COLORSPACE_CUDA)
			set( CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS} -fPIC -fast -mp -Mcuda=cc3x,cuda5.5 -Minfo" )
			set( CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS} -O0 -fPIC -g " )
		endif()
	endif ()
	message ("*** Fortran compiler RELEASE FLAGS: " ${CMAKE_Fortran_FLAGS_RELEASE})
	message ("*** Fortran compiler DEBUG FLAGS: " ${CMAKE_Fortran_FLAGS_DEBUG})
endif(ANDROID_NDK)

# Get Python
IF(WIN32 AND NOT UNIX)
find_package(PythonInterp)
message(STATUS "Looking for Python found - ${PYTHONINTERP_FOUND}")
if (PYTHONINTERP_FOUND)
   message(STATUS "Using Python version ${PYTHON_VERSION_STRING}")
endif()
ENDIF(WIN32 AND NOT UNIX)

# --------------------------------------------------
#install all .a, .so to colorspace/lib
set(COLORSPACE_INSTALL_EXPORT_NAME colorspace-targets)

macro(colorspace_install_library lib)
  install(TARGETS ${lib}
    EXPORT ${COLORSPACE_INSTALL_EXPORT_NAME}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
  )
endmacro()

# --------------------------------------------------
# Testing

enable_testing()
#BUILD_TESTING is turned ON by enable_testing()
include(CTest)
enable_testing()
# --------------------------------------------------

# Organize output files.  On Windows this also keeps .dll files next
# to the .exe files that need them, making tests easy to run.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${COLORSPACE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${COLORSPACE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${COLORSPACE_BINARY_DIR}/lib)

# --------------------------------------------------
# Check for any necessary platform specific compiler flags
include( CheckCOLORSPACECompilerFlags )
CheckCOLORSPACECompilerFlags()

# --------------------------------------------------
# Precision to build
# By default all precisions are generated

# --------------------------------------------------
# Subdirectories that need to be processed

#COLORSPACE
message("***BUILD_COLORSPACE_VEC=${BUILD_COLORSPACE_VEC}")
if (ANDROID_NDK)
	if (BUILD_COLORSPACE_GENERIC)
		set( COLORSPACE_LIBRARIES colorspace )
	endif()
	if (BUILD_COLORSPACE_VEC)
		set( COLORSPACE_LIBRARIES colorspace_vec )
	endif()
	if (BUILD_COLORSPACE_CUDA)
		set( COLORSPACE_LIBRARIES colorspace_cuda )
	endif()
	#option(BUILD_SINGLE "Build COLORSPACE Single Precision" OFF)
	#option(BUILD_DOUBLE "Build COLORSPACE Double Precision" OFF)
	#option(BUILD_COMPLEX "Build COLORSPACE Complex Precision" ON)
	#option(BUILD_COMPLEX16 "Build COLORSPACE Double Complex Precision" OFF)
else()
	set( COLORSPACE_LIBRARIES colorspace )
	#option(BUILD_SINGLE "Build COLORSPACE Single Precision" OFF)
	#option(BUILD_DOUBLE "Build COLORSPACE Double Precision" OFF)
	#option(BUILD_COMPLEX "Build COLORSPACE Complex Precision" OFF)
	#option(BUILD_COMPLEX16 "Build COLORSPACE Double Complex Precision" ON)
endif()

#force to static lib
add_library(colorspace STATIC
		colorspace.c
		colorcalc.c)

#target_link_libraries(colorspace m)

colorspace_install_library(colorspace)

message(STATUS "BUILD TESTING : ${BUILD_TESTING}" )
#BUILD_TESTING is turned ON by enable_testing()
if(BUILD_TESTING)
#	add_subdirectory(tests)
endif(BUILD_TESTING)

# --------------------------------------------------
# CPACK Packaging

SET(CPACK_PACKAGE_NAME "COLORSPACE")
SET(CPACK_PACKAGE_VENDOR "The Courant Mathematics and Computing Laboratory (CMCL) is a research center \
						at the Courant Institute of New York University.")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "COLORSPACE- Linear Algebra Package")
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 3)
set(CPACK_PACKAGE_VERSION_PATCH 2)
#set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/readme.txt")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "COLORSPACE")
IF(WIN32 AND NOT UNIX)
  # There is a bug in NSI that does not handle full unix paths properly. Make
  # sure there is at least one set of four (4) backlasshes.
  SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\http://www.cims.nyu.edu/cmcl/colorspace/colorspace.html")
  SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.cims.nyu.edu/cmcl/colorspace/colorspace.html")
  SET(CPACK_NSIS_CONTACT "thomas@biotrump.com")
  SET(CPACK_NSIS_MODIFY_PATH ON)
  SET(CPACK_NSIS_DISPLAY_NAME "COLORSPACE-${COLORSPACE_VERSION}")
  set(CPACK_PACKAGE_RELOCATABLE "true")
ELSE(WIN32 AND NOT UNIX)
  SET(CPACK_GENERATOR "TGZ")
  SET(CPACK_SOURCE_GENERATOR TGZ)
  SET(CPACK_SOURCE_PACKAGE_FILE_NAME "colorspace-${COLORSPACE_VERSION}" )
  SET(CPACK_SOURCE_IGNORE_FILES ~$ .gitignore ${CPACK_SOURCE_IGNORE_FILES} )
ENDIF(WIN32 AND NOT UNIX)
INCLUDE(CPack)

# --------------------------------------------------
# By default static library
OPTION(BUILD_SHARED_LIBS "Build shared libraries" OFF )
OPTION(BUILD_STATIC_LIBS "Build static libraries" ON )
#OPTION(BUILD_SHARED_LIBS "Build shared libraries" ON )

if(NOT LATESTCOLORSPACE_FOUND)
  set(ALL_TARGETS ${ALL_TARGETS} colorspace)
endif(NOT LATESTCOLORSPACE_FOUND)

# Export colorspace targets, not including colorspacee, from the
# install tree, if any.
set(_colorspace_config_install_guard_target "")
if(ALL_TARGETS)
  install(EXPORT colorspace-targets
    DESTINATION lib/cmake/colorspace-${COLORSPACE_VERSION})

  # Choose one of the colorspace targets to use as a guard for
  # colorspace-config.cmake to load targets from the install tree.
  list(GET ALL_TARGETS 0 _colorspace_config_install_guard_target)
endif()


# Export colorspace and colorspacee targets from the build tree, if any.
set(_colorspace_config_build_guard_target "")
if(ALL_TARGETS)
  export(TARGETS ${ALL_TARGETS} FILE colorspace-targets.cmake)

  # Choose one of the colorspace or colorspacee targets to use as a guard
  # for colorspace-config.cmake to load targets from the build tree.
  list(GET ALL_TARGETS 0 _colorspace_config_build_guard_target)
endif()

configure_file(${COLORSPACE_SOURCE_DIR}/CMAKE/colorspace-config-version.cmake.in
  ${COLORSPACE_BINARY_DIR}/colorspace-config-version.cmake @ONLY)
configure_file(${COLORSPACE_SOURCE_DIR}/CMAKE/colorspace-config-build.cmake.in
  ${COLORSPACE_BINARY_DIR}/colorspace-config.cmake @ONLY)


#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/colorspace.pc.in ${CMAKE_CURRENT_BINARY_DIR}/colorspace.pc)
#  install(FILES
#  ${CMAKE_CURRENT_BINARY_DIR}/colorspace.pc
#  DESTINATION ${PKG_CONFIG_DIR}
#   )

configure_file(${COLORSPACE_SOURCE_DIR}/CMAKE/colorspace-config-install.cmake.in
  ${COLORSPACE_BINARY_DIR}/CMakeFiles/colorspace-config.cmake @ONLY)
install(FILES
  ${COLORSPACE_BINARY_DIR}/CMakeFiles/colorspace-config.cmake
  ${COLORSPACE_BINARY_DIR}/colorspace-config-version.cmake
  DESTINATION lib/cmake/colorspace-${COLORSPACE_VERSION}
  )
