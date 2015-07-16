tell application "Spotify"
  set track_name to name of current track
  set track_artist to artist of current track
  set track_album to album of current track
  set state to player state
  set track_id to id of current track
end tell

tell application "Spotify" to set spotifyState to (player state as text)

set AppleScript's text item delimiters to ":"
set track_id to third text item of track_id
set AppleScript's text item delimiters to {""}

set message to "'" & track_name & "' by " & track_artist

if (spotifyState = "paused") then
  set message to message & " (" & spotifyState & ")"
end if

return message
