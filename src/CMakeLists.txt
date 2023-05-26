#cmake_minimum_required(VERSION 3.5)
set(LIBNAME dtkcore)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set (DSG_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}" CACHE STRING "PREFIX of DSG_DATA_DIRS")
add_definitions(-DPREFIX="${DSG_PREFIX_PATH}")
add_definitions(-DLIBDTKCORE_LIBRARY)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)
if(LINUX)
  find_package(PkgConfig REQUIRED)
  find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS DBus)
  if("${QT_VERSION_MAJOR}" STREQUAL "5")
      pkg_check_modules(QGSettings REQUIRED IMPORTED_TARGET gsettings-qt) #Dtk6 removed.
  endif()

  if("${QT_VERSION_MAJOR}" STREQUAL "6")
    find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core5Compat)
  endif()

  if(BUILD_WITH_SYSTEMD)
    pkg_check_modules(Systemd REQUIRED IMPORTED_TARGET libsystemd)
  endif()
endif()
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Xml)

# start base
include(base/base.cmake)
# end base


# start log
include(log/log.cmake)
#end log

#start utils
#include(util/util.cmake)
#end utils

#GLOB
#include(glob.cmake)
#endGLOG

if(LINUX)
  add_library(${LIBNAME} SHARED
    ${base_SRCS}
    ${dci_SRCS}
    ${filesystem_SRCS}
    ${log_SRCS}
    ${settings_SRC}
    ${utils_SRC}
    ${glob_SRC}
  )
  target_link_libraries(
    ${LIBNAME} PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::DBus
    Qt${QT_VERSION_MAJOR}::Xml
  )
  target_link_libraries(${LIBNAME} PRIVATE
#    ICU::uc
    Qt${QT_VERSION_MAJOR}::CorePrivate
#    uchardet
  )
  if("${QT_VERSION_MAJOR}" STREQUAL "6")
    target_link_libraries(${LIBNAME} PRIVATE
      Qt${QT_VERSION_MAJOR}::Core5Compat #TODO: [QTextCodec] : should remove this dependencies
    )
  endif()
 if(BUILD_WITH_SYSTEMD)
   target_link_libraries(${LIBNAME} PRIVATE
     PkgConfig::Systemd
   )
   add_definitions(-DBUILD_WITH_SYSTEMD)
 endif()

else()
  add_library(${LIBNAME} SHARED
    ${base_SRCS}
    ${log_SRCS}
    ${utils_SRC}
    ${glob_SRC}
  )
  target_link_libraries(
    ${LIBNAME} PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Xml
  )
  target_link_libraries(${LIBNAME} PRIVATE
#    ICU::uc
    Qt${QT_VERSION_MAJOR}::CorePrivate
#    uchardet
  )
  if("${QT_VERSION_MAJOR}" STREQUAL "6")
    target_link_libraries(${LIBNAME} PRIVATE
      Qt${QT_VERSION_MAJOR}::Core5Compat
    )
  endif()
endif()

set_target_properties(${LIBNAME} PROPERTIES
  VERSION ${CMAKE_PROJECT_VERSION}
  SOVERSION ${CMAKE_PROJECT_VERSION_MAJOR}
  EXPORT_NAME Core
)

target_include_directories(${LIBNAME} PRIVATE
  ${uchardet_INCLUDE_DIRS}
)
target_include_directories(${LIBNAME} PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/util>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/dci>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/log>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/base>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/base/private>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/global>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/DtkCore>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/settings>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/filesystem>
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)
target_include_directories(${LIBNAME} INTERFACE
  $<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}>
)

target_link_directories(${LIBNAME} INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:${LIBRARY_INSTALL_DIR}>
)

set(TOINSTALLBASE
  base/dobject.h
  base/dsingleton.h
  base/private/dobject_p.h
  base/derror.h
  base/dexpected.h
)
install(FILES ${TOINSTALLBASE} DESTINATION "${INCLUDE_INSTALL_DIR}")
install(DIRECTORY global/ DESTINATION "${INCLUDE_INSTALL_DIR}" FILES_MATCHING PATTERN "*.h")
file(GLOB TOINSTALLLOG
  log/*.h
)
install(FILES ${TOINSTALLLOG} DESTINATION "${INCLUDE_INSTALL_DIR}")

install(DIRECTORY util/ DESTINATION "${INCLUDE_INSTALL_DIR}" FILES_MATCHING PATTERN "*.h")
install(TARGETS ${LIBNAME} EXPORT DtkCoreTargets
 DESTINATION ${LIBRARY_INSTALL_DIR})

install(EXPORT DtkCoreTargets
  FILE DtkCoreTargets.cmake
  NAMESPACE Dtk::
  DESTINATION ${CONFIG_CMAKE_INSTALL_DIR}
)
