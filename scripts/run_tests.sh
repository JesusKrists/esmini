#!/bin/bash

arg1=$1
arg2=$2

buildConfiguration="Release"
skipOpenGLTests=false

if ! [[ -z "$arg1" ]]; then
    if [[ "$arg1" = "Debug" ]]; then
        buildConfiguration="Debug"
    fi 
fi

if ! [[ -z "$arg2" ]]; then
    if [[ "$arg2" = true ]]; then
        skipOpenGLTests=true
    fi 
fi

echo "$buildConfiguration - Skip OpenGL tests: $skipOpenGLTests"


# Run from esmini root ddirectory: ./scripts/run_unittests.sh

exit_with_msg() {
    echo $1
    exit -1
}

export workingDir=$(pwd)

export LSAN_OPTIONS="print_suppressions=false:suppressions="${workingDir}"/scripts/LSAN.supp"
export ASAN_OPTIONS="detect_invalid_pointer_pairs=1:strict_string_checks=1:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1:detect_leaks=1:fast_unwind_on_malloc=0:suppressions="${workingDir}"/scripts/ASAN.supp"

export UNIT_TEST_FOLDER=${workingDir}/build/EnvironmentSimulator/Unittest
export SMOKE_TEST_FOLDER=${workingDir}/test

if [[ "$OSTYPE" == "msys" ]]; then
    export PATH=${PATH}";../Libraries/esminiLib/$buildConfiguration;../Libraries/esminiRMLib/$buildConfiguration"
    export EXE_FOLDER="./$buildConfiguration"
    export PYTHON="python"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export LD_LIBRARY_PATH=${workingDir}"/externals/OSI/linux/lib-dyn"
    export path="../../../bin"
    export EXE_FOLDER="."
    export PYTHON="python3"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export LD_LIBRARY_PATH=${workingDir}"/externals/OSI/mac/lib-dyn"
    export path="../../../bin"
    export EXE_FOLDER="."
    export PYTHON="python3"
else
    echo "Unsupported OS: " $OSTYPE
fi

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then

    cd $UNIT_TEST_FOLDER

    echo $'\n'Run unit tests:

    if ! ${EXE_FOLDER}/OperatingSystem_test; then
        exit_with_msg "OperatingSystem_test failed"
    fi

    if ! ${EXE_FOLDER}/CommonMini_test; then
        exit_with_msg "CommonMini_test failed"
    fi

    if ! ${EXE_FOLDER}/RoadManager_test; then
        exit_with_msg "RoadManager_test failed"
    fi

    if ! ${EXE_FOLDER}/ScenarioPlayer_test; then
        exit_with_msg "ScenarioPlayer_test failed"
    fi

    if [[ "$skipOpenGLTests" == false ]]; then
        if ! ${EXE_FOLDER}/ScenarioEngineDll_test; then
            exit_with_msg "ScenarioEngineDll_test failed"
        fi
    fi

    ls -al *.tga *.ppm

    if ! ${EXE_FOLDER}/RoadManagerDll_test; then
        exit_with_msg "RoadManagerDll_test failed"
    fi

    if ! ${EXE_FOLDER}/FollowRoute_test; then
        exit_with_msg "FollowRoute_test failed"
    fi

    if ! ${EXE_FOLDER}/FollowRouteController_test; then
        exit_with_msg "FollowRouteController_test failed"
    fi
fi

cd $SMOKE_TEST_FOLDER

if [[ "$skipOpenGLTests" == false ]]; then

    echo $'\n'Run smoke tests:

    if ! ${PYTHON} smoke_test.py; then
        exit_with_msg "smoke test failed"
    fi

fi

echo $'\n'Run ALKS test suite:

if ! ${PYTHON} alks_suite.py; then
    exit_with_msg "alks_suite test failed"
fi
