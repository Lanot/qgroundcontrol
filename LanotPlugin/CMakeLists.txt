# @See: custom-example/CMakeLists.txt

message(STATUS "QGC: Adding LanotPlugin")

# ============================================================================
# LanotPlugin Android Package Template
# ============================================================================
#
#if(ANDROID)
#    set(LANOT_PLUGIN_ANDROID_DIR "${CMAKE_SOURCE_DIR}/LanotPlugin/android")
#    if(EXISTS "${LANOT_PLUGIN_ANDROID_DIR}")
#        file(GLOB LANOT_PLUGIN_ANDROID_FILES "${LANOT_PLUGIN_ANDROID_DIR}/*")
#        if(LANOT_PLUGIN_ANDROID_FILES)
#            message(STATUS "QGC: LanotPlugin Android package template found. Overlaying LanotPlugin files...")
#            set(DEFAULT_ANDROID_DIR "${CMAKE_SOURCE_DIR}/android")
#            set(FINAL_ANDROID_DIR "${CMAKE_BINARY_DIR}/LanotPlugin/android")
#
#            # Copy default Android template
#            file(COPY "${DEFAULT_ANDROID_DIR}/." DESTINATION "${FINAL_ANDROID_DIR}")
#
#            # Overlay LanotPlugin Android files
#            execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${LANOT_PLUGIN_ANDROID_DIR}" "${FINAL_ANDROID_DIR}")
#
#            # Track changes to Android directories
#            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
#                    "${DEFAULT_ANDROID_DIR}/"`
#                    "${LANOT_PLUGIN_ANDROID_DIR}/"
#            )
#
#            set(QGC_ANDROID_PACKAGE_SOURCE_DIR "${FINAL_ANDROID_DIR}" CACHE PATH "Path to a LanotPlugin Android package template" FORCE)
#            message(STATUS "QGC: Android package template path will be set to: ${QGC_ANDROID_PACKAGE_SOURCE_DIR}")
#        else()
#            message(STATUS "QGC: LanotPlugin Android package template empty. Using default.")
#        endif()
#    else()
#        message(STATUS "QGC: No LanotPlugin Android package template found. Using default.")
#    endif()
#endif()


# ============================================================================
# Custom Resources and Import Paths
# ============================================================================

# Add custom Qt resources
list(APPEND LANOT_PLUGIN_RESOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/custom.qrc
)
set(QGC_RESOURCES ${QGC_RESOURCES} ${LANOT_PLUGIN_RESOURCES} CACHE STRING "Paths to .qrc Resources" FORCE)

# Add custom QML import path
set(QML_IMPORT_PATH ${QML_IMPORT_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/res" CACHE STRING "Extra qml import paths" FORCE)

# ============================================================================
# Custom QML Module
# ============================================================================

qt_add_library(CustomModule STATIC)

# Set resource aliases for custom widgets
#set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomArtificialHorizon.qml PROPERTIES QT_RESOURCE_ALIAS CustomArtificialHorizon.qml)

#qgc_set_qt_resource_alias(
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomAttitudeWidget.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomIconButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomOnOffSwitch.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomQuickButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomSignalStrength.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomToolBarButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomVehicleButton.qml
#)

#qt_add_qml_module(CustomModule
#        URI Custom.Widgets
#        VERSION 1.0
#        RESOURCE_PREFIX /qml
#        QML_FILES
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomArtificialHorizon.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomAttitudeWidget.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomIconButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomOnOffSwitch.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomQuickButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomSignalStrength.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomToolBarButton.qml
#        ${CMAKE_CURRENT_SOURCE_DIR}/res/Custom/Widgets/CustomVehicleButton.qml
#        NO_PLUGIN
#)


# ============================================================================
# LanotPlugin Plugin Sources
# ============================================================================

set(LANOT_PLUGIN_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/src/LanotPlugin.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/LanotPlugin.h
    CACHE INTERNAL "" FORCE
)

# ============================================================================
# LanotPlugin Build Configuration
# ============================================================================

# LanotPlugin include directories
set(LANOT_PLUGIN_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/src
#    ${CMAKE_CURRENT_SOURCE_DIR}/src/AutoPilotPlugin
#    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin
    CACHE INTERNAL "" FORCE
)

# LanotPlugin compiler definitions
set(LANOT_PLUGIN_DEFINITIONS
    LANOT_PLUGIN_BUILD
    CUSTOMHEADER="LanotPlugin.h"
    CUSTOMCLASS=LanotPlugin
    CACHE INTERNAL "" FORCE
)

# LanotPlugin Qt components required
set(LANOT_PLUGIN_QT_COMPONENTS
    Core
    CACHE INTERNAL "" FORCE
)
