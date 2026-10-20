if application "Spotify" is running then
  tell application "Spotify"
    set track_name to name of current track
    set track_artist to artist of current track
    set spotifyState to (player state as text)
  end tell

  set message to "♫ '" & track_name & "' by " & track_artist

  -- Keep long titles from pushing the date and time off the status bar
  if (count of message) > 45 then
    set message to (text 1 thru 44 of message) & "…"
  end if

  if (spotifyState = "paused") then
    set message to message & " (" & spotifyState & ")"
  end if

  return message
else
  return ""
end if
