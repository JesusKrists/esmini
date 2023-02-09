# Set the compiler warnings
#
# https://clang.llvm.org/docs/DiagnosticsReference.html https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md
function(
    set_project_warnings
    project_name
    ENABLE_WARNINGS_AS_ERRORS)

    set(MSVC_WARNINGS
        /utf-8
        /w14640
        /w14826
        /w14619
        /w14311
        /w14296
        /we4289
        /w14287
        /w14265
        /w14263
        /w14242
        /w14254
        /w14165
        /w44242
        /w44254
        /w44263
        /w34265
        /w34287
        /w44296
        /w44365
        /w44388
        /w44464
        /w14545
        /w14546
        /w14547
        /w14549
        /w14555
        /w34619
        /w34640
        /w24826
        /w14905
        /w14906
        /w14928
        /w45038
        /W4
        /permissive-
        /volatile:iso
        /Zc:preprocessor
        /Zc:__cplusplus
        /Zc:externConstexpr
        /Zc:throwingNew
        /EHsc)

    set(CLANG_WARNINGS
        -Wall
        -Wextra # reasonable and standard
        -Wshadow # warn the user if a variable declaration shadows one from a parent context
        -Wnon-virtual-dtor # warn the user if a class with virtual functions has a non-virtual destructor. This helps
        # catch hard to track down memory errors
        -Wold-style-cast # warn for c-style casts
        -Wcast-align # warn for potential performance problem casts
        -Wunused # warn on anything being unused
        -Woverloaded-virtual # warn if you overload (not override) a virtual function
        -Wpedantic # warn if non-standard C++ is used
        -Wconversion # warn on type conversions that may lose data
        -Wsign-conversion # warn on sign conversions
        -Wnull-dereference # warn if a null dereference is detected
        -Wdouble-promotion # warn if float is implicit promoted to double
        -Wformat=2 # warn on security issues around functions that format output (ie printf)
        -Wimplicit-fallthrough # warn on statements that fallthrough without an explicit annotation
        -Wextra-semi
        -Werror=float-equal
        -Wundef
        -Wcast-qual)

    set(GCC_WARNINGS
        ${CLANG_WARNINGS}
        -Wmisleading-indentation # warn if indentation implies blocks where blocks do not exist
        -Wduplicated-cond # warn if if / else chain has duplicated conditions
        -Wduplicated-branches # warn if if / else branches have duplicated code
        -Wlogical-op # warn about logical operations being used where bitwise were probably wanted
        -Wuseless-cast # warn if you perform a cast to the same type
    )

    if(ENABLE_WARNINGS_AS_ERRORS)
        if(NOT
           APPLE) # some warnings still remaining on Mac
            message(
                TRACE
                "Warnings are treated as errors")
            list(
                APPEND
                CLANG_WARNINGS
                -Werror)
            list(
                APPEND
                GCC_WARNINGS
                -Werror)
            list(
                APPEND
                MSVC_WARNINGS
                /WX)
        endif(
            NOT
            APPLE)
    endif()

    if(MSVC)
        set(PROJECT_WARNINGS_CXX
            ${MSVC_WARNINGS})
    elseif(
        CMAKE_CXX_COMPILER_ID
        MATCHES
        ".*Clang")
        set(PROJECT_WARNINGS_CXX
            ${CLANG_WARNINGS})
    elseif(
        CMAKE_CXX_COMPILER_ID
        STREQUAL
        "GNU")
        set(PROJECT_WARNINGS_CXX
            ${GCC_WARNINGS})
    else()
        message(AUTHOR_WARNING "No compiler warnings set for CXX compiler: '${CMAKE_CXX_COMPILER_ID}'")
        # TODO support Intel compiler
    endif()

    # Add C warnings
    set(PROJECT_WARNINGS_C
        "${PROJECT_WARNINGS_CXX}")
    list(
        REMOVE_ITEM
        PROJECT_WARNINGS_C
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Woverloaded-virtual
        -Wuseless-cast)

    set(PROJECT_WARNINGS_CUDA
        "${CUDA_WARNINGS}")

    target_compile_options(
        ${project_name}
        INTERFACE # C++ warnings
                  $<$<COMPILE_LANGUAGE:CXX>:${PROJECT_WARNINGS_CXX}>
                  # C warnings
                  $<$<COMPILE_LANGUAGE:C>:${PROJECT_WARNINGS_C}>)
endfunction()
