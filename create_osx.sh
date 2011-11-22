#!/bin/bash

PROJECTNAME=''
USERNAME=`whoami`
USERS=( $USERNAME '_www' )

showHelp() {
    echo "########################################"
    echo "# create Symfony2 standard project"
    echo "########################################"
    echo "Usage: ./create.sh -p <projectname>"
    echo "########################################"
}

createProject() {
    cloneSymfonyStandard
    renameProjectFolder
    cd $PROJECTNAME
    cleanupGitFiles
    changeFolderPermissions
    prepareGit
    rm -rf LICENSE
    prepareReadme
    php bin/vendors install
    git commit -m "Welcome to $PROJECTNAME"
}

cloneSymfonyStandard() {
    echo "Cloning symfony-standard from GitHub..."
    git clone http://github.com/symfony/symfony-standard.git
    echo "... done"
}

renameProjectFolder() {
    mv symfony-standard/ $PROJECTNAME
}

cleanupGitFiles() {
    rm -rf .git
}

changeFolderPermissions() {
    # get number of elements in the array
    cnt=${#USERS[@]}

    for (( i=0;i<${#USERS[@]};i++)); do
        echo "Fixing permissions for user ${USERS[${i}]}"
        chmod -R +a "${USERS[${i}]} allow list,add_file,search,delete,add_subdirectory,delete_child,file_inherit,directory_inherit,read,write,delete,append,execute" app/{cache,logs}
    done

}

prepareGit() {
    echo '/web/bundles/
    /app/bootstrap*
    /app/cache/*
    /app/logs/*
    /vendor/
    /app/config/parameters.ini' > .gitignore
    git init
    git add app/ bin/ deps deps.lock src/ web/ .gitignore
}

prepareReadme() {
    echo "Welcome to $PROJECTNAME." > README.md
    echo "You are running Symfony2." >> README.md
    git add README.md
}

showGitCommandSuggestions() {
    echo "########################################"
    echo "You should now add your project to GitHub."
    echo "Please adjust the examples provided below to match your desired GitHub settings."
    echo "    git remote add origin git@github.com:\$USERNAME/\$PROJECTNAME.git"
    echo "    git push -u origin master"
    echo "########################################"
}

while getopts ":p:h" opt; do
    case $opt in
        p)
            # detect project name
            PROJECTNAME=$OPTARG
            ;;
        h)
            # help instructions
            showHelp
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            ;;
    esac
done

# @TODO add checking of requirements (php, etc.)
createProject
showGitCommandSuggestions
