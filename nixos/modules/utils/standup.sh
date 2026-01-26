STANDUP_DIR_PATH="$HOME/notes/Bambee/raptors/standup"

function standup {
    local year=$(date +"%Y")
    local month=$(date +"%m")
    local today=$(date +"%d")

    local todaysDate="$year-$month-$today"

    local todayPath="$STANDUP_DIR_PATH/$year/$month"
    local todayFile="$todaysDate.md"
    local todayFullPath="$todayPath/$todayFile"
    
    if [ -f "$todayFullPath" ]; then
        echo "$todayFullPath exists."
    else 
        echo "DIDNT EXIST"
        mkdir -p $todayPath
        cat > $todayFullPath <<- EOM
\`Standup $todaysDate\`

Yesterday
- Task: ___
  - Ticket: https://bambee.atlassian.net/browse/RAP-001  
  - Status: ___
  - Reason: ___ 

Today:
- Task:
  - Ticket: ___ 
  - Status: ___
  - Reason: ___ 

Breakouts:
  - Ticket: ___
  - Reason: ___
EOM
    fi

    nvim $todayFullPath
}

function standupList {
    local todayPath="$STANDUP_DIR_PATH/$(date +'%Y/%m')"
    open $todayPath
}

