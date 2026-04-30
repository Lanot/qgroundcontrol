# @See: custom-example/CMakeLists.txt

message(STATUS "QGC: Adding LanotQGCCorePlugin")

# ============================================================================
# LanotQGCCorePlugin Android Package Template
# ============================================================================
#
#if(ANDROID)
#    set(QGC_LANOT_CORE_PLUGIN_ANDROID_DIR "${CMAKE_SOURCE_DIR}/LanotQGCCorePlugin/android")
#    if(EXISTS "${QGC_LANOT_CORE_PLUGIN_ANDROID_DIR}")
#        file(GLOB QGC_LANOT_CORE_PLUGIN_ANDROID_FILES "${QGC_LANOT_CORE_PLUGIN_ANDROID_DIR}/*")
#        if(QGC_LANOT_CORE_PLUGIN_ANDROID_FILES)
#            message(STATUS "QGC: LanotQGCCorePlugin Android package template found. Overlaying LanotQGCCorePlugin files...")
#            set(DEFAULT_ANDROID_DIR "${CMAKE_SOURCE_DIR}/android")
#            set(FINAL_ANDROID_DIR "${CMAKE_BINARY_DIR}/LanotQGCCorePlugin/android")
#
#            # Copy default Android template
#            file(COPY "${DEFAULT_ANDROID_DIR}/." DESTINATION "${FINAL_ANDROID_DIR}")
#
#            # Overlay LanotQGCCorePlugin Android files
#            execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${QGC_LANOT_CORE_PLUGIN_ANDROID_DIR}" "${FINAL_ANDROID_DIR}")
#
#            # Track changes to Android directories
#            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
#                    "${DEFAULT_ANDROID_DIR}/"`
#                    "${QGC_LANOT_CORE_PLUGIN_ANDROID_DIR}/"
#            )
#
#            set(QGC_ANDROID_PACKAGE_SOURCE_DIR "${FINAL_ANDROID_DIR}" CACHE PATH "Path to a LanotQGCCorePlugin Android package template" FORCE)
#            message(STATUS "QGC: Android package template path will be set to: ${QGC_ANDROID_PACKAGE_SOURCE_DIR}")
#        else()
#            message(STATUS "QGC: LanotQGCCorePlugin Android package template empty. Using default.")
#        endif()
#    else()
#        message(STATUS "QGC: No LanotQGCCorePlugin Android package template found. Using default.")
#    endif()
#endif()

# ============================================================================
# LanotQGCCorePlugin Plugin Sources
# ============================================================================

set(QGC_LANOT_CORE_PLUGIN_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/LanotQGCCorePlugin.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/LanotQGCCorePlugin.h
    CACHE INTERNAL "" FORCE
)

# ============================================================================
# LanotQGCCorePlugin Build Configuration
# ============================================================================

# LanotQGCCorePlugin include directories
set(QGC_LANOT_CORE_PLUGIN_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/src
#    ${CMAKE_CURRENT_SOURCE_DIR}/src/AutoPilotPlugin
#    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin
    CACHE INTERNAL "" FORCE
)

# LanotQGCCorePlugin compiler definitions
set(QGC_LANOT_CORE_PLUGIN_DEFINITIONS
    QGC_LANOT_CORE_PLUGIN_BUILD
    CUSTOMHEADER="LanotQGCCorePlugin.h"
    CUSTOMCLASS=LanotQGCCorePlugin
    CACHE INTERNAL "" FORCE
)

# LanotQGCCorePlugin Qt components required
#set(QGC_LANOT_CORE_PLUGIN_QT_COMPONENTS
#    Core
#    CACHE INTERNAL "" FORCE
#)
