#Include %A_LineFile%\..\..\Plugin.ahk
/*
	Usage: Kudos <UserName>
	Desc: Gives an imaginary internet point to the user - limit of one per hour
*/

FilePath := "state\kudos.json"
FileCreateDir, state

if (Plugin.Params[1] = "Everybody" || Plugin.Params[1] = "Everyone")
{
	Chat(Channel, "Everybody now has 1 more kudos than before")
	ExitApp
}

if (Kudos := FileOpen(FilePath, "r").Read())
	Kudos := Json_ToObj(Kudos)
else
	Kudos := {Stats:{}}
Stats := Kudos.Stats

Nick := Plugin.Params[1] ? Plugin.Params[1] : PRIVMSG.Nick
if (Nick != PRIVMSG.Nick)
{
	Stats[Nick] := Round(Stats[Nick]) + 1
	FileOpen(FilePath, "w").Write(Json_FromObj(Kudos))
	Chat(Channel, Nick " now has " Stats[Nick] " kudos")
}
else
	Chat(Channel, Nick " has " Round(Stats[Nick]) " kudos")

ExitApp
