STANDUP_DIR_PATH="~/notes/Bambee/raptors/standup"

function standup {
    local today=$(date +'%m/%d/%Y')
    local todayPath="$STANDUP_DIR_PATH/$(date +'%Y/%m')"
    local todayFile="$(date +'%d').md"
    local todayFullPath="$todayPath/$todayFile"
    
    if [ -f "$todayFullPath" ]; then
        echo "$todayFullPath exists."
    else 
        echo "DIDNT EXIST"
        mkdir -p $todayPath
        cat > $todayFullPath <<- EOM
\`Standup $today\`

**Yesterday**

- Task: ___
  - Ticket: https://bambee.atlassian.net/browse/RAP-001  
  - Status: ___
  - Reason: ___ 

**Today**:
- Task:
  - Ticket: ___ 
  - Status: ___
  - Reason: ___ 

**Blockers**
  - Ticket: ___
  - Reason: ___
EOM
    fi

    nvim $todayFullPath
}

function standupList {
    local todayPath="$STANDUP_PATH/$(date +'%Y/%m')"
    open $todayPath
}

