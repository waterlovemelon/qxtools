set(BINNAME dlog-example)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS DBus)

add_executable(${BINNAME}
  main.cpp
)

target_include_directories(${BINNAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/src/log/
)

target_link_libraries(
  ${BINNAME} PUBLIC
  dtkcore
)

