set -u

#BUILD__COMPILER_HOME /Users/ben/build/lunarml/lunarml.git
#BUILD__COMPILER_BIN /Users/ben/build/lunarml/lunarml.git/bin/lunarml
#BUILD__COMPILER_LIB /Users/ben/build/lunarml/lunarml.git/lib/lunarml
#BUILD__INTERP_HOME /usr/local/Cellar//lua@5.3/5.3.6
#BUILD__INTERP_BIN /usr/local/Cellar//lua@5.3/5.3.6/bin/lua
#BUILD__INTERP_LIB

if [ $# -eq 0 ] ; then
    die "usage: <file>"
else
    file="${1:-}"
     [ -f "$file" ] || die "Err: invalid file"
     shift


    target=
    if [ -n "${1:-}" ] ; then
        case "$1" in
            lua|luajit|lua-continuations|nodejs|nodejs-cps) target="$1";;
            *) 
                echo "Err: invalid target '$1'" >&2 
                exit 1
                ;;
        esac
        shift
    else
        target=lua
    fi

    file_dir="$(dirname $file)"
    file_base="$(basename $file)"
    file_name="${file_base%.*}"
    file_ext="${file_base##*.}"

    file_out="$file_dir/$file_name.lua"

#    if ! [ "$file_dir" = "$file_base" ] ; then

    case "$file_ext" in
        sml) 
            rm -f "$file_out"
            "${BUILD__COMPILER_BIN}" -B"${BUILD__COMPILER_LIB}" --"$target" $@ compile "$file" && ${BUILD__INTERP_BIN} $file_out

            ;;
        *)
            echo 'no sml file ' $file >&2
            exit 1
            ;;
    esac
fi
