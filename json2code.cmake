cmake_minimum_required(VERSION 3.3)
get_filename_component(_json_dir "${CMAKE_BINARY_DIR}/_json_rc/incude" ABSOLUTE)
set(JSON_INCLUDE_DIR "${_json_dir}" CACHE INTERNAL "Directory for json include files")
set(h_content [==[
#ifndef JSON_RC_H_INCLUDED
#define JSON_RC_H_INCLUDED

namespace json_rc {

extern const char * const g_jstr;

}

#endif
]==])

set(json_rc_h "${JSON_INCLUDE_DIR}/JsonRC.h" CACHE INTERNAL "")
set(_gen 1)
if(EXISTS "${json_rc_h}")
    file(READ "${json_rc_h}" _cur)
    if(_cur STREQUAL h_content)
        set(_gen 0)
    endif()
endif()
file(GENERATE OUTPUT "${json_rc_h}" CONTENT "${h_content}" CONDITION ${_gen})

add_library(json-rc-base INTERFACE)
target_include_directories(json-rc-base INTERFACE $<BUILD_INTERFACE:${JSON_INCLUDE_DIR}>)
add_library(jsonrc::base ALIAS json-rc-base)
set(rc_json "${CMAKE_SOURCE_DIR}/example.json" CACHE INTERNAL "")
if(NOT EXISTS "${rc_json}")
    message(FATAL_ERROR "json file not exit in ${rc_json}")
endif()
file(READ "${rc_json}" _rc)
string(CONFIGURE [=[
#include "JsonRC.h"
namespace json_rc {
const char * const g_jstr = R"foo(
@_rc@
)foo";
}
]=] rc_c @ONLY)
get_filename_component(libdir "${CMAKE_CURRENT_BINARY_DIR}/__json_rc" ABSOLUTE)
get_filename_component(lib_tmp_cpp "${libdir}/lib_.cpp" ABSOLUTE)
# string(REPLACE "\n        " "\n" rc_c "${rc_c}")
file(GENERATE OUTPUT "${lib_tmp_cpp}" CONTENT "${rc_c}")
get_filename_component(libcpp "${libdir}/lib.cpp" ABSOLUTE)
add_custom_command(OUTPUT "${libcpp}"
    DEPENDS "${lib_tmp_cpp}" "${json_rc_h}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${lib_tmp_cpp}" "${libcpp}"
    COMMENT "Generating resource loader"
    )
add_library(rc STATIC ${libcpp})
target_link_libraries(rc PUBLIC jsonrc::base)
target_compile_features(rc PRIVATE cxx_std_17)