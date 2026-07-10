#!/opt/homebrew/bin/bash
#need to change the shebang path before uploading
staging="./.bvcs/staging"
HEAD="./.bvcs/HEAD"

decoy() {
    return 0
}

do_commit() {
    if (( $# != 2 )) || [[ "${1}" != "-m" ]]; then
        echo "Error: Commit message required. Use -m \"message\""
        return 1
    fi

    if [[ ! -s "$staging" ]]; then
        echo "Error: Nothing to commit."
        return 1
    fi

    #Generating commitID
    commitID=0

    if [[ ! -s "$HEAD" ]]; then
        commitID=0
    else
        read -r commitID < $HEAD
    fi

    ((commitID++))
    
    #create directory
    destination=".bvcs/objects/"$(printf "%04d" "$commitID")""
    (mkdir -p "${destination}")

    #copying entire files/ tree
    if [[ -s $HEAD ]]; then
        read -r headID < $HEAD
        src=".bvcs/objects/$headID"
        (cp -r "${src}/files" "${destination}/files")
    fi

    #Read $staging line by line
    count=0
    while IFS= read -r src; do
        dstPATH=""${destination}"/files/"${src}""

        (mkdir -p "$(dirname "$dstPATH")")
        (cp "$src" "$dstPATH")
        ((count++))
    done < $staging

    message="${2}"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "$message" > "${destination}/message"
    echo "$timestamp" > "${destination}/timestamp"

    printf "%04d|%s|%s\n" "$commitID" "$timestamp" "$message" >> ".bvcs/log"

    printf "%04d\n" "$commitID" > $HEAD
    : > $staging # truncating the file

    printf "[%04d] %s\n" "$commitID" "$message"
    echo "$count file(s) committed."

    return 0
}

show_status() {
    declare -A status_array
    declare -a staged modified untracked
    
    while IFS= read -r file; do
        status_array["${file#./}"]="untracked"
    done < <(find . -path "./.bvcs" -prune -o -type f -print)

    while IFS= read -r file; do
        status_array["$file"]="staged"
    done < "$staging"
    
    #if the head file is non-empty
    if [[ -s $HEAD ]]; then
        read -r headID < $HEAD
        snapshotPATH="./.bvcs/objects/$headID/files/"

        while IFS= read -r snapshotfile; do
            realfile="${snapshotfile#"$snapshotPATH"}"
            

            #the file has been deleted
            if [[ ! -f "$realfile" ]]; then
                continue
            fi

            #files that are being tracked but not staged and have been modified 
            if [[ ${status_array[$realfile]} != "staged" ]] && ! cmp -s "$realfile" "$snapshotfile"; then
                status_array[$realfile]="modified"
            fi
        done < <(find $snapshotPATH -type f)
    fi

    if (( ${#status_array[@]} == 0 )); then
        echo "Nothing to commit, working tree clean."
        return 0
    fi

    for key in ${!status_array[@]}; do

        case "${status_array["$key"]}" in
            "staged")   staged+=("$key") ;;
            "modified") modified+=("$key") ;;
            "untracked") untracked+=("$key") ;;
            *) ;;
        esac
    done

    if (( ${#staged[@]} > 0 )); then
        echo "Staged for commit: "
        for file in "${staged[@]}"; do
            echo "  ${file}"
        done

        echo
    fi

    if (( ${#modified[@]} > 0 )); then
        echo "Modified (not staged): "
        for file in "${modified[@]}"; do
            echo "  ${file}"
        done
        
        echo
    fi

    if (( ${#untracked[@]} > 0 )); then
        echo "Untracked files: "
        for file in "${untracked[@]}"; do
            echo "  ${file}"
        done
        
        echo
    fi

    return 0
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

    (
    mkdir .bvcs
    cd .bvcs
    mkdir objects
    touch staging
    touch log
    touch HEAD
    )

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
                show_status || return $?
            else
                printNotBVCS
            fi
            ;;
        commit)
            if check_repo; then
                do_commit "${@:2}" || return $?
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