#!/bin/bash
###############################################################################
# Creates a Symfony2 project starting from the latest symfony-standard version.
# 
# @since 2011-nov
###############################################################################

PROJECTNAME=''
USERNAME=`whoami`
USERS=( $USERNAME '_www' )

showHeader() {
    echo "##################################################"
    echo "[#] create Symfony2 standard project"
    echo "[#]"
}

showHelp() {
    showHeader
    echo "[INFO] Usage: ./`basename $0` -p <projectname>"
    echo "[#]"
}

showFooter() {
    echo "##################################################"
}

checkProjectnameCorrect() {
    ERRORMSG=""
    if [ -z "$PROJECTNAME" ]; then
        ERRORMSG="No project name."
    # else
        # TODO add alphanumeric+length validation
    fi

    if [ -n "$ERRORMSG" ]; then
        exitWithError "$ERRORMSG"
    fi
}

exitWithError() {
    if [ -n "$1" ]; then
        showHelp; echo "[ERR] $1"; showFooter; exit 1;
    fi
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
    echo "[#]"
    echo "[#] You should now add your project to GitHub."
    echo "[#] Please adjust the examples provided below"
    echo "[#]       to match your desired GitHub settings."
    echo "> git remote add origin git@github.com:\$USER/\$PROJECT.git"
    echo "> git push -u origin master"
    echo "[#]"
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
            showHelp
            echo "[ERROR] Invalid option: -$OPTARG" >&2
            showFooter
            exit 1
            ;;
        :)
            showHelp
            echo "[ERROR] Option -$OPTARG requires an argument." >&2
            showFooter
            exit 0
            ;;
    esac
done

echo "[DEBUG] $PROJECTNAME"

# if [ -n $PROJECTNAME ]; then
#     showHelp
#     echo "[ERROR] No project name provided!"
#     showFooter
#     exit 0
# else

# @TODO add checking of requirements (php, etc.)
date

checkProjectnameCorrect # script exits here in case something goes wrong

showHeader
createProject
showGitCommandSuggestions
showFooter

date
# fi
