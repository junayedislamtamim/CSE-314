#!/usr/bin/bash
#need to change the shebang path before uploading
staging="./.bvcs/staging"
HEAD="./.bvcs/HEAD"
log="./.bvcs/log"
OLD_IFS="$IFS"

decoy() {
    return 0
}

restore() {
    if (( $# > 1  || $# == 0 )); then
        echo "Error: invalid argument."
        return 1
    fi

    #if head is empty
    if [[ ! -s "$HEAD" ]]; then
        echo "Error: no commits yet."
        return 1
    fi

    read -r commitID < "$HEAD"
    snapshotPATH=".bvcs/objects/${commitID}/files/"
    filename="${1}"

    if [[ ! -f "${snapshotPATH}${filename}" ]]; then
        echo "Error: '${filename}' does not exist in commit ${commitID}."
        return 1
    fi

    echo -n "Restore '${filename}' from commit ${commitID}? [y/N]: "
    read -r prompt 
    case "$prompt" in
        y|Y) 
            mkdir -p "$(dirname "$filename")"
            cp "${snapshotPATH}${filename}" "${filename}"
            echo "Restored: $filename"
                ;;
        n|N) 
            echo "Aborted."
            return 1 ;;
        *) 
            echo "Unknown command. Aborted."
            return 1 ;;
    esac 
}

show_diff() {
    #if head is empty
    if [[ ! -s "$HEAD" ]]; then
        echo "Error: no commits yet."
        return 1
    fi

    read -r commitID < "$HEAD"
    snapshotPATH=".bvcs/objects/${commitID}/files/"

    if (( $# == 1 )); then 
        filename="${1}"
        #if the file does not exist
        if [[ ! -f "${snapshotPATH}${filename}" ]]; then
            echo "Error: '${filename}' is not tracked."
            return 1
        fi

        if diff -q "${snapshotPATH}${filename}" "${filename}" > /dev/null; then
            echo "${filename}:  no changes."
        else
            diff -u --label "${snapshotPATH}${filename}" --label "${filename}" "${snapshotPATH}${filename}" "${filename}"
        fi
    elif (( $# == 0 )); then
        while IFS= read -r -d '' filepath; do
            filename="${filepath#${snapshotPATH}}"

            if diff -q "${snapshotPATH}${filename}" "${filename}" > /dev/null; then
                echo "${filename}:  no changes."
            else
                diff -u --label "${snapshotPATH}${filename}" --label "${filename}" "${snapshotPATH}${filename}" "${filename}"
            fi
        done < <(find "$snapshotPATH" -type f -print0 | sort -z)
    else
        echo "Error: invalid argument."
        return 1
    fi

    return 0
}

show_log() {
    #if log is empty
    if [[ ! -s "$log" ]]; then
        echo "No commits yet."
        return 0
    fi

    mapfile -t log_lines < "$log"

    for (( i = ${#log_lines[@]} - 1 ; i >= 0; --i)); do
        line="${log_lines[$i]}"
        
        IFS='|' read -r commitID timestamp message <<< "$line"

        printf "commit %04d\n" "$commitID"
        echo "Date:     $timestamp"
        echo "Message:  $message"
        echo 
    done 

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
        read -r commitID < "$HEAD"
    fi

    ((commitID++))
    
    #create directory
    destination=".bvcs/objects/$(printf "%04d" "$commitID")"
    (mkdir -p "${destination}")

    #copying entire files/ tree
    if [[ -s "$HEAD" ]]; then
        read -r headID < "$HEAD"
        src=".bvcs/objects/$headID"
        (cp -r "${src}/files" "${destination}/files")
    fi

    #Read $staging line by line
    count=0
    while IFS= read -r src; do
        dstPATH="${destination}/files/${src}"

        (mkdir -p "$(dirname "$dstPATH")")
        (cp "$src" "$dstPATH")
        ((count++))
    done < "$staging"

    message="${2}"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "$message" > "${destination}/message"
    echo "$timestamp" > "${destination}/timestamp"

    printf "%04d|%s|%s\n" "$commitID" "$timestamp" "$message" >> ".bvcs/log"

    printf "%04d\n" "$commitID" > "$HEAD"
    : > "$staging" # truncating the file

    printf "[%04d] %s\n" "$commitID" "$message"
    echo "$count file(s) committed."

    return 0
}

show_status() {
    declare -A status_array
    declare -a staged modified untracked
    
    while IFS= read -r -d '' file; do
        status_array["${file#./}"]="untracked"
    done < <(find . -path "./.bvcs" -prune -o -type f -print0)

    while IFS= read -r file; do
        status_array["$file"]="staged"
    done < "$staging"
    
    #if the head file is non-empty
    if [[ -s "$HEAD" ]]; then
        read -r headID < "$HEAD"
        snapshotPATH="./.bvcs/objects/"$headID"/files/"

        while IFS= read -r -d '' snapshotfile; do
            realfile="${snapshotfile#${snapshotPATH}}"

            #every file that is in head is tracked
            if [[ "${status_array["$realfile"]}" == "untracked" ]]; then
                status_array["$realfile"]="tracked"
            fi

            #the file has been deleted
            if [[ ! -f "$realfile" ]]; then
                continue
            fi

            #files that are being tracked but not staged and have been modified 
            if [[ "${status_array["$realfile"]}" != "staged" ]] && ! cmp -s "$realfile" "$snapshotfile"; then
                status_array["$realfile"]="modified"
            fi
        done < <(find "$snapshotPATH" -type f -print0)
    fi

    for key in "${!status_array[@]}"; do

        case "${status_array["$key"]}" in
            "staged")   staged+=("$key") ;;
            "modified") modified+=("$key") ;;
            "untracked") untracked+=("$key") ;;
            *) ;;
        esac
    done

    if (( ${#staged[@]} == 0 && ${#modified[@]} == 0 && ${#untracked[@]} == 0 )); then
        echo "Nothing to commit, working tree clean."
        return 0
    fi

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
    if (( $# <= 0 )); then
        echo "Error: No files specified."
        return 1
    fi

    for (( i = 1; i <= $#; ++i)); do
        filename="${!i}"
        if [[ ! -f "$filename" ]]; then
            echo "Error: "$filename" not found."
        elif grep -Fxq "$filename" "$staging" ; then
            echo "Already staged: $filename" 
        else
            echo "$filename" >> "$staging"
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
    echo "TwT"
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
    case "${1}" in
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
                show_log || return $?
            else
                printNotBVCS
            fi
            ;;
        diff)
            if check_repo; then
                show_diff "${@:2}" || return $?
            else
                printNotBVCS
            fi
            ;;
        restore)
            if check_repo; then
                #implement add
                restore "${@:2}" || return $?
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
                echo "Error: Unknown subcommand '"${2}"'"
            else
                printNotBVCS
            fi
            ;;
    esac

    return 0
}

main  "${@:1}"
IFS="$OLD_IFS"