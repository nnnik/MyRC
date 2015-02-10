#Include %A_LineFile%\.. ; Load includes from the directory containing the file this line is in
#Include <Socket> ; Include the sockets library
#Include <IRCClass> ; Include the IRC library
#Include <Utils>

Feed := "http://ahkscript.org/boards/feed.php"
UserAgent := "Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0"
Channel := "#AhkScript"

BadForums =
( Join, Comments
Ich brauche Hilfe ; German
Skripte und Funktionen
Tooltime
Allgemeines
Pedir Ayuda ; Spanish
Scripts y Funciones
Tutoriales
Otras Utilidades y Recursos
)
Shorten("ahk4me", "NOTTHEAPIKEY")
MyBot := new IRCBot() ; Create a new instance of your bot
MyBot.Connect("chat.freenode.net", 6667, "ForumBot", "GeekBot", "ForumBot", "NOTMYPASSWORD") ; Connect to an IRC server
MyBot.SendJOIN(Channel) ; Join a channel
GetNewPosts()
SetTimer, Poll, % 1 * 60 * 1000
return

Poll:
Out := ""
for each, Post in GetNewPosts()
	Out := Chr(3) "03" Post.Author " - " Post.Title " - " Shorten(Post.Url) "`n" Out
if Out
	MyBot.SendPRIVMSG(Channel, Out)
return

class IRCBot extends IRC
{
	Log(Data)
	{
		Print(Data)
	}
}

Print(Text)
{
	static _ := DllCall("AllocConsole")
	StdOut := FileOpen("CONOUT$", "w")
	StdOut.Write(Text "`n")
}

GetRss(Feed, UserAgent="")
{
	try
	{
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		http.open("GET", Feed, False)
		if UserAgent
			http.setRequestHeader("User-Agent", UserAgent)
		http.send()
		return http.responseText
	}
	Catch
		return
}

GetNewPosts()
{
	static Previous := []
	global BadForums, UserAgent, Feed
	
	; Trim out some fluff that breaks wine compatiblity, as well as remove the irrelevant error messages at the end of the feed
	; I can use such an "unsafe" regex because user inputted < and > are escaped as &lt; and &gt;
	Rss := RegExReplace(GetRss(Feed, UserAgent), "s)<feed[^>]*>(.*)</feed>.*$", "<feed>$1</feed>")
	
	xml := ComObjCreate("MSXML2.DOMDocument")
	xml.loadXML(Rss)
	if !entries := xml.selectNodes("/feed/entry")
		return ; Malformed xml
	
	NewPosts := []
	While (entry := entries.item[A_Index-1])
	{
		Url := entry.selectSingleNode("link/@href").text
		if !Previous[Url]
		{
			Title := HtmlDecode(entry.selectSingleNode("title").text)
			if Title contains %BadForums%
				continue
			
			Author := entry.selectSingleNode("author/name").text
			
			Print([Author, Title, Url])
			NewPosts.Insert({Author: Author, Title: Title, Url: Url})
		}
	}
	
	for each, Post in NewPosts
		Previous[Post.Url] := True
	
	return NewPosts
}
