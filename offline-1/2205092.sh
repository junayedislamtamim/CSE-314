#need to change the shebang path before uploading
#!/bin/bash

decoy() {
    return 0
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
    if [[ ${1} = "bvcs" ]]; then
        echo "ERROR: unknown command ${0}"
        return 1
    fi

    case ${2} in
        init)
            init_repo
            ;;
        add)
            if check_repo; then
                #implement add
                decoy
            else
                printNotBVCS
            fi
            ;;
        status)
            if check_repo; then
                #implement add
                decoy
            else
                printNotBVCS
            fi
            ;;
        commit)
            if check_repo; then
                #implement add
                decoy
            else
                printNotBVCS
            fi
            ;;
        log)
            if check_repo; then
                #implement add
                decoy
            else
                printNotBVCS
            fi
            ;;
        diff)
            if check_repo; then
                #implement add
                decoy
            else
                printNotBVCS
            fi
            ;;
        restore)
            if check_repo; then
                #implement add
                decoy
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
                echo "Unknown subcommand '${2}'"
            else
                printNotBVCS
            fi
            ;;
    esac

    return 0
}

main  ${0} ${1}