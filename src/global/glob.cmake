set(OUTER_SOURCE
  ${CMAKE_CURRENT_LIST_DIR}/global/dtkcore_global.cpp
  ${CMAKE_CURRENT_LIST_DIR}/global/dtkcore_global.include(CheckCCompilerFlag)
)

if(LINUX)
  if(DEFINED D_DSG_APP_DATA_FALLBACK)
      add_definitions(-DD_DSG_APP_DATA_FALLBACK="${D_DSG_APP_DATA_FALLBACK}")
  endif()
  list(APPEND OUTER_SOURCE
    ${CMAKE_CURRENT_LIST_DIR}/dconfigfile.cpp
  )
  list(APPEND OUTER_HEADER
    ${CMAKE_CURRENT_LIST_DIR}/dconfigfile.h
  )
#   generic dbus interfaces
  if(NOT DEFINED DTK_DISABLE_DBUS_CONFIG)
    include(${CMAKE_CURRENT_LIST_DIR}/dbus/dbus.cmake)
    list(APPEND glob_SRC ${dbus_SRCS})
  else()
    add_definitions(-DD_DISABLE_DBUS_CONFIG)
  endif()
else()
    add_definitions(-DD_DISABLE_DCONFIG)
endif()

list(APPEND glob_SRC
  ${OUTER_HEADER}
  ${OUTER_SOURCE}
)
