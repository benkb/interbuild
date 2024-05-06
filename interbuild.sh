set -u

prn(){ printf "%s\n" "$*"; }
die(){ echo "$@" >&2; exit 1; }
fail(){ echo "Fail: $@" >&2;  }

build__main(){
    local cmd=
    local input=
    while [ $# -gt 0 ] ; do
        case "$1" in
            -|--help) 'todo help' ;;
            -*) die "usage: ..." ;;
            print|run) cmd="$1" ;;
            *) 
                input="$1" 
                shift
                break
                ;;
        esac
        shift
    done

    [ -z "$cmd" ] && die "Err: no build cmd"
    #
    case "$cmd" in
        print)
            build__load_build_conf  
            build__set_globals
            build__print
            exit
            ;;
        run) 
            [ -z "$input" ] && die "Err: no build input"
            build__run "$input" 
            ;;
    esac


}


build__load_build_conf(){
    if [ -f "$PWD/build.conf" ] ; then
        sourcing "$PWD/build.conf" || die "Err: could load build.conf in '$PWD/build.conf'"
    else
        die "Err: 'build.conf' missing"
     fi
 }

build__run(){
    local input="${1:-}"

    [ -f "$input" ] || die "Err: no file input"

    local build_cached=

    if [ -f "$PWD/build.cache" ] ; then
        if sourcing "$PWD/build.cache"; then
            build_cached=1
        else
            die "Err: could not load cache"
        fi
    else
        build__load_build_conf  
    fi


    if [ -z "$build_cached" ] ; then
        build__set_globals
    fi


    if sourcing "$PWD/build.sh" "$input" ; then
        echo 'build.sh ran successfully ...'
        exit 1
    else
        die 'Err: could not run build.sh successfully'
    fi
}



sourcing(){
    local file="${1:-}"
    [ -n "${file}" ] || die "Err file '${file}' is empty"
    shift

    if [ -f "${file}" ] ; then
        . "${file}" "$@" || die "Err: could not source '$file'"
    else
        die "Err: file not exists '${file}'"
    fi
}


calculate_homedir(){
    local name="${1:-}"
    if [ -z "$name" ]; then 
        fail "no name"
        return 1
    fi
    local basedir="${2:-}"
    local altdir="${3:-}"
    local version="${4:-}"
    local minor="${5:-}"

    local rootdir=
    if [ -z "$basedir" ] ; then
        if [ -z "$altdir" ] ; then
            fail 'cannot set root dir'
            return 1
        else
            rootdir="$altdir"
        fi
    else
        rootdir="$basedir"
    fi

    if ! [ -d "$rootdir" ] ; then
        fail "rootdir '$rootdir' doesn't exists"
        return 1
    fi

    local homedir=
    for d in "${rootdir}/${name}@${version}/$minor" "${rootdir}/${name}/${version}/$minor" "${rootdir}/${name}@${version}" "${rootdir}/${name}/${version}" "${rootdir}/${name}" "${rootdir}"; do
        if [ -d "$d" ] ; then
            homedir="$d"
            break
        fi
    done

    if [ -d "$homedir" ] ; then
        prn "$homedir"
    else
        fail "could not find bin for '$homedir'"
        return 1
    fi
}


calculate_bin(){
    local name="${1:-}"
    if [ -z "$name" ]; then
        fail "no name"
        return 1
    fi

    local homedir="${2:-}"
    if [ -z "$homedir" ]; then
        fail "no homedir"
        return 1
    fi

    local bin=
    if [ -f "$homedir/bin/$name" ] ; then
        bin="$homedir/bin/$name"
    elif [ -f "$homedir/$name" ] ; then
        bin="$homedir/$name"
    fi

    if [ -f "$bin" ] ; then
        prn "$bin"
    else
        fail "could not find bin for '$bin'"
        return 1
    fi
}

calculate_lib(){
    local libname="${1:-}"
    if [ -z "$libname" ]; then
        fail "no name"
        return 1
    fi

    local homedir="${2:-}"
    if [ -z "$homedir" ]; then
        fail "no homedir"
        return 1
    fi

    local lib=
    if [ -d "$homedir/$libname" ] ; then
        prn "$homedir/$libname"
    else
        fail "could not find lib for '$bin'"
        return 1
    fi

}

build__print(){
    echo "COMPILER_NAME='$COMPILER_NAME'"
    echo "BUILD__COMPILER_BIN='$BUILD__COMPILER_BIN'"
    echo "BUILD__COMPILER_LIB='$BUILD__COMPILER_LIB'"
    echo "BUILD__INTERP_BIN='$BUILD__INTERP_BIN'"
    echo "BUILD__INTERP_LIB='$BUILD__INTERP_LIB'"
}


build__set_globals(){

    [ -z ${COMPILER_NAME+x} ] && die 'Err: var COMPILER_NAME not set'

    local build__compiler_home=
    if [ -n "${COMPILER_VERS_BASEDIR:-}" ] ; then
        build__compiler_home="$(calculate_homedir "$COMPILER_NAME" "${COMPILER_VERS_BASEDIR:-}" "" "${COMPILER_VERS:-}" "${COMPILER_VERS_MINOR:-}")"
    elif [ -n "${COMPILER_HOME:-}" ] ; then
        build__compiler_home="$(calculate_homedir "$COMPILER_NAME" "${COMPILER_HOME:-}" "${COMPILER_HOME_DEFAULT:-}" "${COMPILER_VERS:-}" "${COMPILER_VERS_MINOR:-}")"
    else
        die "Err: neither COMPILER_VERS_BASEDIR nor COMPILER_HOME are defined"

    fi

    [ -d "$build__compiler_home" ] || die "Err: could not set compiler_homedir under '$build__compiler_home'"


    BUILD__COMPILER_BIN="$(calculate_bin "${COMPILER_NAME:-}" "$build__compiler_home")" || die "Err: could not calculate compiler bin"

    BUILD__COMPILER_LIB=
    if [ -n "${COMPILER_LIB:-}" ] ; then
        BUILD__COMPILER_LIB="$(calculate_lib "${COMPILER_LIB:-}" "$build__compiler_home")" || die "Err: could not calculate compiler lib"
    fi


    if [ -n "${INTERP_NAME:-}" ] ; then
        local build__interp_home=
        if [ -n "${INTERP_VERS_BASEDIR:-}" ] ; then
            build__interp_home="$(calculate_homedir "$INTERP_NAME" "${INTERP_VERS_BASEDIR:-}" "" "${INTERP_VERS:-}" "${INTERP_VERS_MINOR:-}")"
        elif [ -n "${INTERP_HOME:-}" ] ; then
            build__interp_home="$(calculate_homedir "$INTERP_NAME" "${INTERP_HOME:-}" "${INTERP_HOME_DEFAULT:-}" "${INTERP_VERS:-}" "${INTERP_VERS_MINOR:-}")"
        fi

        [ -d "$build__interp_home" ] || die "Err: could not set compiler_homedir under '$build__interp_home'"

        BUILD__INTERP_BIN="$(calculate_bin "${INTERP_NAME:-}" "$build__interp_home")" || die "Err: could not calculate"


        BUILD__INTERP_LIB=
        if [ -n "${INTERP_LIB:-}" ] ; then
            BUILD__INTERP_LIB="$(calculate_lib "${INTERP_LIB:-}" "$build__interp_home")" || die "Err: could not calculate interp lib"
        fi
    fi
}



### MAIN
build__main $@

