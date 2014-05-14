#!/bin/bash
APP_HU_DIR=$PWD/../appconnector-suite-build

print_usage(){
    echo "Usage:"
    echo "    ./build-qtgst.sh option [release]"
    echo "    option:"
    echo "        arm         build binding for Linux armv7l, support software floating point"
    echo "        armv7l-hf   build binding for Linux armv7l, support hardware floating point"
    echo "        host        build binding for Linux X86"
    echo "        clean       clean"
    echo "    release:"
    echo "        build in release mode, otherwise in debug mode"
}


if [ ! -d $APP_HU_DIR ] ; then
  echo "There is no '../appconnector-hu/NativeUI' path in a current directory, we need the path for running this."  
  exit 0
fi  


set_x86_build_env() {
    pushd $APP_HU_DIR 
    ./configure
    . ./config
    . ./Linux/environment    
    popd

    if [ ! -d build ] ; then
        mkdir build
    fi

    cd build; 
}


set_arm_build_env() {
    pushd $APP_HU_DIR
    ./configure poky
    . ./config
    . ./poky/environment
    popd


    if [ ! -d build ] ; then
        mkdir build
    fi

    cd build;

    if [ ! -f .arm_cfg ] ; then
        cp $APPCON_SDK_PATH/.arm_cfg .   
    fi

    source .arm_cfg

    echo using CROSSCOMPILE_HOST: $CROSSCOMPILE_HOST
    echo using CROSSCOMPILE_PREFIX: $CROSSCOMPILE_PREFIX
    echo using TARGET_ROOT: $TARGET_ROOT
}


BUILD_MODE=debug

if [ $# -eq 2 ]; then
    if [ $2 == "release" ]; then
        BUILD_MODE=release
    fi
fi


case $1 in
    clean )
        rm -rf build out
        exit 0
        ;;
    Clean )
        rm -rf build out
        exit 0
        ;;
    arm )
        set_arm_build_env
        ARGS="-DUSE_HARDWARE_FP:BOOL=false"
        ;;
    armhf )
        set_arm_build_env
        ARGS="-DUSE_HARDWARE_FP:BOOL=true"
        ;;
    host )
        set_x86_build_env
        ;;
    * )
        print_usage
        exit 1
esac

cmake .. -DCMAKE_INSTALL_PREFIX=/usr $ARGS
make -j4 && make install DESTDIR=../out/$MY_TARGET_ARCH