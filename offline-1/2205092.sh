#!/opt/homebrew/bin/bash
#need to change the shebang path before uploading
staging=".bvcs/staging"
HEAD="./bvcs/HEAD"

decoy() {
    return 0
}

show_status() {
    declare -A status_array

    while IFS= read -r file; do
        status_array["$file"]="staged"
    done < "$staging"
    
    #if the head file is non-empty
    if [[ -s $HEAD ]]; then
        read -r headID < $HEAD
        snapshotPATH="./bvcs/objects/$headID/files/"

        while IFS= read -r snapshotfile; do
            realfile="${snapshotfile#"$snapshotPATH"}"

            #files that are being tracked but not staged and have been modified 
            if [[ ${status_array[$realfile]} != "staged" ]] && ! cmp -s $realfile $snapshotfile; then
                status_array[$realfile]="modified"
            fi
        done < <(find $snapshotPATH -type f)
    fi


}

add_files() {
    if [[ $# -le 0 ]]; then
        echo "Error: No files specified."
        return 1
    fi

    for (( i = 1; i <= $#; ++i)); do
        filename=${!i}
        if [[ ! -f $filename ]]; then
            echo "Error: $filename not found."
        elif grep -Fxq $filename $staging ; then
            echo "Already staged: $filename" 
        else
            echo "$filename" >> $staging
            echo "Staged: $filename"
        fi
    done
}

printNotBVCS() {
    echo "ERROR: Not a BVCS repository. Run 'init' first."
    return 1
}

usage() {
    #function to be completed
    return 1
}

check_repo() {
    if [[ -d ".bvcs" ]]; then
        return 0 #true
    else
        return 1 #false
    fi
}

init_repo() {
    if check_repo; then
        echo "ERROR: BVCS repository already exists"
        return 1
    fi

    mkdir .bvcs
    cd .bvcs
    mkdir objects
    touch staging
    touch log
    touch HEAD

    echo "Initialized empty BVCS repository."

    return 0
}

main() {
    case ${1} in
        init)
            init_repo
            ;;
        add)
            if check_repo; then
                add_files "${@:2}" || return $? #All arguement starting from the second
            else
                printNotBVCS
            fi
            ;;
        status)
            if check_repo; then
                #implement add
                show_status || return $?
            else
                printNotBVCS
            fi
            ;;
        commit)
            if check_repo; then
                #implement add
                decoy || return $?
            else
                printNotBVCS
            fi
            ;;
        log)
            if check_repo; then
                #implement add
                decoy || return $?
            else
                printNotBVCS
            fi
            ;;
        diff)
            if check_repo; then
                #implement add
                decoy || return $?
            else
                printNotBVCS
            fi
            ;;
        restore)
            if check_repo; then
                #implement add
                decoy || return $?
            else
                printNotBVCS
            fi
            ;;
        help)
            #implement help function
            usage
            ;;
        *)
            if check_repo; then
                echo "Error: Unknown subcommand '${2}'"
            else
                printNotBVCS
            fi
            ;;
    esac

    return 0
}

main  ${@:1}