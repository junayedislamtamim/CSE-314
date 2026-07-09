#need to change the shebang path before uploading
#!/bin/bash

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
        help)
            #implement help function
            ;;
        *)
            echo "Unknown command"
            ;;
    esac

}

main  ${0} ${1}