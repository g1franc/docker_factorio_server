#!/bin/bash
echo '      ___         ___           ___                       ___           ___                       ___     '
echo '     /  /\       /  /\         /  /\          ___        /  /\         /  /\        ___          /  /\    '
echo '    /  /:/_     /  /::\       /  /:/         /  /\      /  /::\       /  /::\      /  /\        /  /::\   '
echo '   /  /:/ /\   /  /:/\:\     /  /:/         /  /:/     /  /:/\:\     /  /:/\:\    /  /:/       /  /:/\:\  '
echo '  /  /:/ /:/  /  /:/~/::\   /  /:/  ___    /  /:/     /  /:/  \:\   /  /:/~/:/   /__/::\      /  /:/  \:\ '
echo ' /__/:/ /:/  /__/:/ /:/\:\ /__/:/  /  /\  /  /::\    /__/:/ \__\:\ /__/:/ /:/___ \__\/\:\__  /__/:/ \__\:\'
echo ' \  \:\/:/   \  \:\/:/__\/ \  \:\ /  /:/ /__/:/\:\   \  \:\ /  /:/ \  \:\/:::::/    \  \:\/\ \  \:\ /  /:/'
echo '  \  \::/     \  \::/       \  \:\  /:/  \__\/  \:\   \  \:\  /:/   \  \::/~~~~      \__\::/  \  \:\  /:/ '
echo '   \  \:\      \  \:\        \  \:\/:/        \  \:\   \  \:\/:/     \  \:\          /__/:/    \  \:\/:/  '
echo '    \  \:\      \  \:\        \  \::/          \__\/    \  \::/       \  \:\         \__\/      \  \::/   '
echo '     \__\/       \__\/         \__\/                     \__\/         \__\/                     \__\/    '
# Checking if server is ready 
if [ "$FACTORIO_WAITING" == "true" ] 
then 
  until [ -f /opt/factorio/saves/ready ] 
  do 
    echo "# Waiting for backup daemon to be ready" 
    sleep 1 
  done 
fi
# Setting initial command
factorio_command="/opt/factorio/bin/x64/factorio --server-settings /opt/factorio/data/server-settings.json"
# Handle default values if not provided
if [ -z "$FACTORIO_SERVER_NAME" ]
then
  FACTORIO_SERVER_NAME="Factorio Server $VERSION"
fi
if [ -z "$FACTORIO_SERVER_DESCRIPTION" ]
then
  FACTORIO_SERVER_DESCRIPTION="Factorio Server $VERSION running on docker"
fi
# Maximum number of players allowed, admins can join even a full server. 0 means unlimited.
if [ -z "$FACTORIO_SERVER_MAX_PLAYERS" ]
then
  FACTORIO_SERVER_MAX_PLAYERS=0
fi
# Set Visibility default value if not set by user param
if [ -z "$FACTORIO_SERVER_VISIBILITY_PUBLIC" == "true" ]
then
  if [ -z "$FACTORIO_USER_USERNAME" ]
  then
    echo "###"
    echo "# Server Visibility is set to public but no factorio.com Username is supplied!"
    echo "# Append: --env FACTORIO_USER_USERNAME=[USERNAME]"
    echo "# Defaulting back to Server Visibility Public: false"
    echo "###"
    FACTORIO_SERVER_VISIBILITY_PUBLIC="false"
  else
    if [ -z "$FACTORIO_USER_PASSWORD" ]
    then
    echo "###"
    echo "# Server Visibility is set to public but neither factorio.com Password is supplied!"
    echo "# Append: --env FACTORIO_USER_PASSWORD=[PASSWORD]"
    echo "# Defaulting back to Server  Visibility Public: false"
    echo "###"
    FACTORIO_SERVER_VISIBILITY_PUBLIC="false"
    fi
  fi
fi
# Server password
if [ -z "$FACTORIO_SERVER_GAME_PASSWORD" ]
then
  FACTORIO_SERVER_GAME_PASSWORD=""
fi
# Set Verify User Identity default value if not set by user param
if [ -z "$FACTORIO_SERVER_VERIFY_IDENTITY" ]
then
  FACTORIO_SERVER_VERIFY_IDENTITY="false"
fi
# max_upload_in_kilobytes_per_second: optional, default value is 0. 0 means unlimited.
if [ -z "$FACTORIO_SERVER_MAX_UPLOAD" ]
then
  FACTORIO_SERVER_MAX_UPLOAD=0
fi
# minimum_latency_in_ticks: optional one tick is 16ms in default speed, default value is 0. 0 means no minimum.
if [ -z "$FACTORIO_SERVER_MIN_LATENCY_TICK" ]
then
  FACTORIO_SERVER_MIN_LATENCY_TICK=0
fi
# ignore_player_limit_for_returning_players: Players that played on this map already can join even when the max player limit was reached.
if [ -z "$FACTORIO_IGNORE_LIMIT_RETURNING_PLAYERS" ]
then
  FACTORIO_IGNORE_LIMIT_RETURNING_PLAYERS="false"
fi
# allow_commands: Possible values are: true, false and admins-only.
if [ -z "$FACTORIO_ALLOW_COMMANDS" ]
then
  FACTORIO_ALLOW_COMMANDS="admins-only"
fi
# autosave_interval: Autosave interval in minutes.
if [ -z "$FACTORIO_AUTO_SAVE_INTERVAL" ]
then
  FACTORIO_AUTO_SAVE_INTERVAL=10
fi
# autosave_slots: server autosave slots, it is cycled through when the server autosaves.
if [ -z "$FACTORIO_AUTO_SAVE_SLOTS" ]
then
  FACTORIO_AUTO_SAVE_SLOTS=5
fi
# afk_autokick_interval: How many minutes until someone is kicked when doing nothing, 0 for never.
if [ -z "$FACTORIO_AUTOKICK_INTERVAL" ]
then
  FACTORIO_AUTOKICK_INTERVAL=0
fi
# auto_pause: Whether should the server be paused when no players are present. Default is true.
if [ -z "$FACTORIO_AUTOPAUSE" ]
then
  FACTORIO_AUTOPAUSE="true"
fi
# only_admins_can_pause_the_game: Can only admin pause the game. Default is true.
if [ -z "$FACTORIO_ONLY_ADMIN_CAN_PAUSE" ]
then
  FACTORIO_ONLY_ADMIN_CAN_PAUSE="true"
fi
# autosave_only_on_server: Whether autosaves should be saved only on server or also on all connected clients. Default is true.
if [ -z "$FACTORIO_ONLY_SERVER_CAN_AUTOSAVE" ]
then
  FACTORIO_ONLY_SERVER_CAN_AUTOSAVE="true"
fi
# Handle username and password
if [ -z "$FACTORIO_USER_USERNAME" ]
then
  FACTORIO_USER_USERNAME=""
fi
if [ -z "$FACTORIO_USER_PASSWORD" ]
then
  FACTORIO_USER_PASSWORD=""
fi
# Force RCON on port 27015 as it can be rebind while exposing port
factorio_command="$factorio_command --rcon-port 27015"
# Setting RCON password option
if [ -z "$FACTORIO_RCON_PASSWORD" ]
then
  FACTORIO_RCON_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c16)
  echo "###"
  echo "# RCON password is '$FACTORIO_RCON_PASSWORD'"
  echo "###"
fi
factorio_command="$factorio_command --rcon-password $FACTORIO_RCON_PASSWORD"
# copy example file to use it as server configuration
cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
sed -i "s/\"name\": \"[[:print:]]*\",/\"name\": \"$FACTORIO_SERVER_NAME\",/g" /opt/factorio/data/server-settings.json
sed -i "s/\"description\": \"[[:print:]]*\",/\"description\": \"$FACTORIO_SERVER_DESCRIPTION\",/g" /opt/factorio/data/server-settings.json
sed -i "s/\"max_players\": [[:digit:]]*,/\"max_players\": $FACTORIO_SERVER_MAX_PLAYERS,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"public\": true,/\"public\": $FACTORIO_SERVER_VISIBILITY_PUBLIC,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"username\": \"\",/\"username\": $FACTORIO_USER_USERNAME,/g" /opt/factorio/data/server-settings.json 
sed -i "s/\"password"\": \"\",/\"password"\": $FACTORIO_USER_PASSWORD,/g" /opt/factorio/data/server-settings.json 
sed -i "s/\"game_password\": \"[[:print:]]*\",/\"game_password\": $FACTORIO_SERVER_GAME_PASSWORD,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"require_user_verification\": true,/\"require_user_verification\": $FACTORIO_SERVER_VERIFY_IDENTITY,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"max_upload_in_kilobytes_per_second\": [[:digit:]]*,/\"max_upload_in_kilobytes_per_second\": $FACTORIO_SERVER_MAX_UPLOAD,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"minimum_latency_in_ticks\": [[:digit:]]*,/\"minimum_latency_in_ticks\": $FACTORIO_SERVER_MIN_LATENCY_TICK,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"ignore_player_limit_for_returning_players\": false,/\"ignore_player_limit_for_returning_players\": $FACTORIO_IGNORE_LIMIT_RETURNING_PLAYERS,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"allow_commands\": \"[[:print:]]*\",/\"allow_commands\": \"$FACTORIO_ALLOW_COMMANDS\",/g" /opt/factorio/data/server-settings.json
sed -i "s/\"autosave_interval\": [[:digit:]]*,/\"autosave_interval\": $FACTORIO_AUTO_SAVE_INTERVAL,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"autosave_slots\": [[:digit:]]*,/\"autosave_slots\": $FACTORIO_AUTO_SAVE_SLOTS,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"afk_autokick_interval\": [[:digit:]]*,/\"afk_autokick_interval\": $FACTORIO_AUTOKICK_INTERVAL,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"auto_pause\": true,/\"auto_pause\": $FACTORIO_AUTOPAUSE,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"only_admins_can_pause_the_game\": true,/\"only_admins_can_pause_the_game\": $FACTORIO_ONLY_ADMIN_CAN_PAUSE,/g" /opt/factorio/data/server-settings.json
sed -i "s/\"autosave_only_on_server\": true,/\"autosave_only_on_server\": $FACTORIO_ONLY_SERVER_CAN_AUTOSAVE,/g" /opt/factorio/data/server-settings.json
# Show server-settings.json config
echo "###"
echo "# Server config:"
cat /opt/factorio/data/server-settings.json
echo "###"
cd /opt/factorio/saves
# Handling save settings
save_dir="/opt/factorio/saves"
if [ -z "$FACTORIO_SAVE" ]
then
  if [ "$(ls -A $save_dir)" ]
  then
    echo "###"
    echo "# Taking latest save"
    echo "###"
  else
    echo "###"
    echo "# Creating a new map [save.zip]"
    echo "###"
    /opt/factorio/bin/x64/factorio --create save.zip
  fi
  factorio_command="$factorio_command --start-server-load-latest"
else
  factorio_command="$factorio_command --start-server $FACTORIO_SAVE"
fi
echo "###"
echo "# Launching Game"
echo "###"
# Closing stdin
exec 0<&-
exec $factorio_command
