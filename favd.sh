#
# favd.sh (favorite directories)
#
# auther: Yuji Hirose <yuji.hirose.bug at gmail.com>
# license: New BSD License
#

function favd_select() {
    # create .favd file if it doesn't exist.
    if ! [ -f ~/.favd ]; then
        echo -n "" > ~/.favd
    fi

    # read paths
    local paths=""
    while read path; do
        path=${path// /%20}
        paths="$paths $path"
    done < ~/.favd

    # select path
    select favd_path in $paths; do
        favd_path=${favd_path//%20/\\ }
        break
    done
}

function favd() {
    if [ -n "$1" ]; then
        # add the current path
        if [ $1 = "add" ]; then
            local curd=`pwd`
            local rtn=`grep -c -e "^$curd$" ~/.favd`
            if [ $rtn = "0" ]; then
                echo "add $curd..."
                echo $curd >> ~/.favd
            fi

        # delete by number
        elif [ $1 = "del" ]; then
            favd_select
            if [ -n "$favd_path" ]; then
                sed -e "/${favd_path//\//\\/}/d" ~/.favd > ~/.favd_tmp
                rm -f ~/.favd
                mv ~/.favd_tmp ~/.favd
            fi

        # edit .favd
        elif [ $1 = "edit" ]; then
            # (1) alternatives symbolic file system
            if [ -f `which editor` ]; then
                editor ~/.favd
            # (2) EDITOR environment variable
            elif [ -n "$EDITOR" ]; then
                $EDITOR ~/.favd
            # (3) vi
            else
                vi ~/.favd
            fi

        # jump by number
        elif [ $(($1)) != 0 ]; then
            sed -e "$1p" -e "d" ~/.favd > ~/.favd_tmp
            read path < ~/.favd_tmp
            rm -f ~/.favd_tmp
            cd $path

        # show usage
        else
            echo "usage: favd [<number> | add | del | edit]"
        fi
    else
        # jump with selection
        favd_select
        if [ -n "$favd_path" ]; then
            eval cd $favd_path
        fi
    fi
}
